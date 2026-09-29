'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  local palette="$HOME/.local/state/zsh/matugen/palette.zsh"
  [[ -f $palette ]] && source $palette

  : ${VI_MODE_IND_NORMAL_BG:='#f0b0ff'}
  : ${VI_MODE_IND_INSERT_BG:='#f0b0ff'}
  : ${VI_MODE_IND_VISUAL_BG:='#d5c0d6'}
  : ${VI_MODE_IND_FG:='#1f1f1f'}
  : ${PROMPT_DIR_BG:='#2a2a2a'}
  : ${PROMPT_DIR_FG:='#e2e2e2'}
  : ${PROMPT_DIR_MUTED_FG:='#919191'}
  : ${PROMPT_VCS_BG:='#1f1f1f'}
  : ${PROMPT_VCS_FG:='#c6c6c6'}

  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # ===========================[ Prompt Elements ]===========================

  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    vi_mode
    dir
    vcs
    newline
    prompt_char
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status
    background_jobs
    direnv
    nix_shell
    context
    newline
  )

  # ===========================[ Basic Settings ]============================

  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_ICON_PADDING=moderate
  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=""
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=""
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off

  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  # ===========================[ vi_mode ]===================================

  typeset -g POWERLEVEL9K_VI_INSERT_MODE_STRING='INSERT'
  typeset -g POWERLEVEL9K_VI_COMMAND_MODE_STRING='NORMAL'
  typeset -g POWERLEVEL9K_VI_VISUAL_MODE_STRING='VISUAL'
  typeset -g POWERLEVEL9K_VI_OVERWRITE_MODE_STRING='OWR'
  typeset -g POWERLEVEL9K_VI_MODE_INSERT_BACKGROUND=$VI_MODE_IND_INSERT_BG
  typeset -g POWERLEVEL9K_VI_MODE_COMMAND_BACKGROUND=$VI_MODE_IND_NORMAL_BG
  typeset -g POWERLEVEL9K_VI_MODE_NORMAL_BACKGROUND=$VI_MODE_IND_NORMAL_BG
  typeset -g POWERLEVEL9K_VI_MODE_VISUAL_BACKGROUND=$VI_MODE_IND_VISUAL_BG
  typeset -g POWERLEVEL9K_VI_MODE_OVERWRITE_BACKGROUND=$VI_MODE_IND_VISUAL_BG
  typeset -g POWERLEVEL9K_VI_MODE_INSERT_FOREGROUND=$VI_MODE_IND_FG
  typeset -g POWERLEVEL9K_VI_MODE_COMMAND_FOREGROUND=$VI_MODE_IND_FG
  typeset -g POWERLEVEL9K_VI_MODE_NORMAL_FOREGROUND=$VI_MODE_IND_FG
  typeset -g POWERLEVEL9K_VI_MODE_VISUAL_FOREGROUND=$VI_MODE_IND_FG
  typeset -g POWERLEVEL9K_VI_MODE_OVERWRITE_FOREGROUND=$VI_MODE_IND_FG

  # ===========================[ prompt_char ]================================

  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=2
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=1
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_LEFT_WHITESPACE=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_RIGHT_WHITESPACE=' '

  # ===========================[ dir ]========================================

  typeset -g POWERLEVEL9K_DIR_BACKGROUND=$PROMPT_DIR_BG
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=$PROMPT_DIR_FG
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=$PROMPT_DIR_MUTED_FG
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$PROMPT_DIR_FG
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  local anchor_files=(
    .git
    .node-version
    .python-version
    .go-version
    .ruby-version
    .tool-versions
    package.json
    Cargo.toml
    flake.nix
    default.nix
  )
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3

  # ===========================[ vcs ]========================================

  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  typeset -g POWERLEVEL9K_VCS_BACKGROUND=$PROMPT_VCS_BG
  typeset -g POWERLEVEL9K_VCS_FOREGROUND=$PROMPT_VCS_FG
  function my_git_formatter() {
    emulate -L zsh
    if [[ -n $P9K_CONTENT ]]; then
      typeset -g my_git_format=$P9K_CONTENT
      return
    fi
    local       meta='%7F'
    local      clean='%2F'
    local   modified='%3F'
    local  untracked='%4F'
    local conflicted='%1F'

    local res
    local where
    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      res+="${clean}${POWERLEVEL9K_VCS_BRANCH_ICON}"
      where=${(V)VCS_STATUS_LOCAL_BRANCH}
    elif [[ -n $VCS_STATUS_TAG ]]; then
      res+="${meta}#"
      where=${(V)VCS_STATUS_TAG}
    else
      res+="${meta}@"
      where=${VCS_STATUS_COMMIT[1,8]}
    fi

    (( $#where > 32 )) && where[13,-13]="..."
    res+="${clean}${where//\%/%%}"

    if [[ -n $VCS_STATUS_REMOTE_BRANCH && $VCS_STATUS_LOCAL_BRANCH != $VCS_STATUS_REMOTE_BRANCH ]]; then
      res+="${meta}:${clean}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"
    fi

    (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${clean}${VCS_STATUS_COMMITS_BEHIND}"
    (( VCS_STATUS_COMMITS_AHEAD  )) && res+=" ${clean}${VCS_STATUS_COMMITS_AHEAD}"
    (( VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" ${clean}${VCS_STATUS_PUSH_COMMITS_BEHIND}"
    (( VCS_STATUS_PUSH_COMMITS_AHEAD  )) && res+=" ${clean}${VCS_STATUS_PUSH_COMMITS_AHEAD}"
    (( VCS_STATUS_NUM_STAGED    )) && res+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
    (( VCS_STATUS_NUM_UNSTAGED  )) && res+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
    (( VCS_STATUS_NUM_UNTRACKED )) && res+=" ${untracked}?${VCS_STATUS_NUM_UNTRACKED}"
    (( VCS_STATUS_HAS_STASHES   )) && res+=" ${clean}*${VCS_STATUS_NUM_STASHES}"

    typeset -g my_git_format=$res
  }
  functions -M my_git_formatter 2>/dev/null
  typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
  typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter(0)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_VCS_PREFIX=

  # ===========================[ status ]=====================================

  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=2
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=2
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=1
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=1
  typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=1
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION=

  # ===========================[ command_execution_time ]=====================

  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PREFIX='took '

  # ===========================[ background_jobs ]============================

  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=1
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION=

  # ===========================[ direnv ]=====================================

  typeset -g POWERLEVEL9K_DIRENV_FOREGROUND=3
  typeset -g POWERLEVEL9K_DIRENV_VISUAL_IDENTIFIER_EXPANSION=

  # ===========================[ nix_shell ]==================================

  typeset -g POWERLEVEL9K_NIX_SHELL_ICON=
  typeset -g POWERLEVEL9K_NIX_SHELL_FOREGROUND=4
  typeset -g POWERLEVEL9K_NIX_SHELL_IMPURE_MSG=''
  typeset -g POWERLEVEL9K_NIX_SHELL_PURE_MSG='nix'

  # ===========================[ context ]====================================

  typeset -g POWERLEVEL9K_CONTEXT_SSH_FOREGROUND=3
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_FOREGROUND=3
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=3
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=1
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_CONTENT_EXPANSION=
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_CONTEXT_PREFIX='at '

  # ===========================[ Instant prompt ]=============================

  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  (( ! $+functions[p10k] )) || p10k reload
}

typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
