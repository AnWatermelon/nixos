{
  flake.modules.nixos.netbird =
    {
      config,
      inputs,
      lib,
      pkgs,
      ...
    }:
    let
      managementUrl = "https://netbird.hilton-tech.net";
      pauseFile = "/run/netbird-wt0-watchdog.paused";

      # Acts on observed state on a fixed tick, not network events, which race
      # the thing being repaired.
      watchdog = pkgs.writeShellApplication {
        name = "netbird-wt0-watchdog";
        runtimeInputs = with pkgs; [
          coreutils
          curl
          iproute2
          iputils
          jq
          systemd
        ];
        text = ''
          nb=/run/current-system/sw/bin/netbird-wt0
          mgmt_url=''${NB_MANAGEMENT_URL:?}
          tick=2
          grace=5
          settle=20
          backoff_base=30
          backoff_cap=600
          escalate_after=3

          log() { echo "$*"; }

          underlay_up() {
            curl -s -o /dev/null --max-time 5 "$mgmt_url" && return 0

            # with no peers up, netbird's own routes can black-hole the management
            # server, so also probe the internet over the physical link directly
            local dev
            for dev in $(ip -j route show default | jq -r '.[] | select(.dev | test("wt0|mullvad") | not) | .dev'); do
              curl -s -o /dev/null --interface "$dev" --max-time 5 http://1.1.1.1 && return 0
            done
            return 1
          }

          healthy() {
            local st
            st=$(timeout 10 "$nb" status --json 2>/dev/null) || return 1
            jq -e '.management.connected == true and .signal.connected == true' \
              <<<"$st" >/dev/null || return 1
            [ -z "$PROBE_HOSTS" ] && return 0
            local h
            for h in $PROBE_HOSTS; do
              ping -c 2 -W 2 -q "$h" >/dev/null 2>&1 && return 0
            done
            return 1
          }

          recover() {
            if [ "$attempts" -ge "$escalate_after" ]; then
              log "recovery: restarting netbird-wt0.service (attempt $((attempts + 1)))"
              systemctl restart netbird-wt0.service || true
            else
              log "recovery: netbird down/up (attempt $((attempts + 1)))"
              timeout 30 "$nb" down || true
              timeout 60 "$nb" up || true
            fi
          }

          unhealthy_since=0
          next_attempt=0
          attempts=0
          state=ok

          set_state() {
            [ "$state" = "$1" ] || { log "state: $state -> $1"; state=$1; }
          }

          while sleep "$tick"; do
            now=$(date +%s)

            if [ -e "${pauseFile}" ]; then
              set_state paused; unhealthy_since=0; continue
            fi

            if healthy; then
              set_state ok; unhealthy_since=0; attempts=0; next_attempt=0
              continue
            fi

            if ! underlay_up; then
              # no network to repair; restart the grace clock so netbird can reconnect itself
              set_state offline; unhealthy_since=0; continue
            fi

            [ "$unhealthy_since" -eq 0 ] && unhealthy_since=$now
            set_state unhealthy
            [ $((now - unhealthy_since)) -lt "$grace" ] && continue
            [ "$now" -lt "$next_attempt" ] && continue

            recover
            delay=$((backoff_base * (1 << attempts)))
            [ "$delay" -gt "$backoff_cap" ] && delay=$backoff_cap
            attempts=$((attempts + 1))
            next_attempt=$(( $(date +%s) + delay ))
            sleep "$settle"
          done
        '';
      };
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        defaultSopsFile = ./secrets/netbird-setup-key.yaml;
        secrets."netbird-setup-key" = {
          restartUnits = [ "netbird-wt0-login.service" ];
        };
      };

      services.netbird.clients.wt0 = {
        port = 443;

        login = {
          enable = true;
          setupKeyFile = config.sops.secrets."netbird-setup-key".path;
          systemdDependencies = [ "sops-install-secrets.service" ];
        };

        ui.enable = true;

        openFirewall = true;
        openInternalFirewall = true;

        environment = {
          NB_MANAGEMENT_URL = managementUrl;
          NB_ADMIN_URL = managementUrl;
        };
      };

      systemd.services.netbird-wt0-watchdog = {
        description = "Health-based recovery for the netbird wt0 client";
        wantedBy = [ "multi-user.target" ];
        after = [ "netbird-wt0.service" ];

        environment = {
          NB_MANAGEMENT_URL = managementUrl;
          # space-separated netbird IPs of always-on peers; empty = control plane only
          PROBE_HOSTS = "";
        };

        serviceConfig = {
          ExecStart = lib.getExe watchdog;
          Restart = "always";
          RestartSec = 5;
        };
      };
    };
}
