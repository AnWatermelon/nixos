{
  flake.modules.nixos.u2f =
    { lib, pkgs, ... }:
    let
      origin = "pam://maxfh";
      creds = [
        "H8LZgyEuQZE7WAMDLDv7kng8fw5vHA95fkw0pG8F221DgEvnNymlJznJqGv+xyAuatTkenSRmXNVZqCGIrLXlA==,UKHonHz31YbA3vZSuXEdREnvT9FEuLrwKg+vrMhY+E4fHOphiuAbHE+3FPehA9ixBW7X3m0iYFYbDrrHzrsu+g==,es256,+presence" # yubikey 1
        "LLorBdLj2ICMZ8KWAClS89locYeXTWRGqk6MJ5lbJEtv/xwP3fdV0v12xUabj3MM0YB5uVAHOu4rtmCS9mwVGQ==,AZ46UD2E2uA1XVz36VMA9/YkUg3rfQfHurj7G0UhwiRWOrpamlmTab4VKsTw+GDdu6Ha5Kv+weS6dl32rpRu0g==,es256,+presence" # yubikey 2
      ];
    in
    {
      security.pam.u2f = {
        enable = true;
        control = "required"; # password AND key. "sufficient" = key replaces password
        settings = {
          inherit origin;
          appid = origin;
          cue = true; # prints "touch your key" instead of silently hanging
          authfile = pkgs.writeText "u2f_keys" "maxfh:${lib.concatStringsSep ":" creds}\n";
        };
      };
    };
}
