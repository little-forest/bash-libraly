#!/bin/bash

__make_backup_name() { #{{{
  local FILE="$1"
  [[ ! -f "$FILE" ]] && return
  local DIR=$(dirname $(readlink -f "$FILE"))
  local BASENAME=$(basename $(readlink -f "$FILE"))

  if [[ -z `echo "$FILE" | tr -dc .` ]]; then
    echo "${DIR}/${BASENAME}_`date '+%Y%m%d-%H%M%S'`"
  else
    echo "${DIR}/${BASENAME%.*}_`date '+%Y%m%d-%H%M%S'`.${BASENAME##*.}"
  fi
}
#}}}

__get_tmp_base() { #{{{
  local TMP_BASE
  if [[ `uname` != Darwin ]]; then
    [[ -d /dev/shm ]] && TMP_BASE=/dev/shm/ || TMP_BASE=/tmp/
  fi
  TMP_BASE="${TMP_BASE}tmp.`basename $0`.$$"
  [[ ! -d "$TMP_BASE" ]] && mkdir "$TMP_BASE"
  echo "$TMP_BASE"
}
#}}}

__make_tmp() { #{{{
  local TMP_BASE=`__get_tmp_base`
  local OPT=()
  [[ "$1" == '-d' ]] && OPT+=($1)
  [[ `uname` == Darwin ]] && OPT+=('-t') || OPT+=('-p')
  OPT+=("$TMP_BASE")
  mktemp ${OPT[@]}
}
#}}}

__script_end_clean_tmp() { #{{{
  local TMP_BASE=`__get_tmp_base`
  [[ -d "$TMP_BASE" ]] && rm -rf "${TMP_BASE}"
}
#}}}

__prepare_dir() { #{{{
  local DIR="$1"
  if [[ ! -d "$DIR" ]]; then
    mkdir -p "$DIR"
    [[ ! -d "$DIR" ]] && return 1
    return 0
  fi
  return 0
}
#}}}

# Create a temporary file/directory for the environment.
# No automatic deletion will be performed. But it is easy to use.
__make_temp_simple() { #{{{
  [[ "$1" == '-d' ]] && local MAKE_DIR="$1"
  if [[ `uname` == Darwin || ! -d /dev/shm ]]; then
    mktemp ${MAKE_DIR}
  else
    mktemp -p /dev/shm ${MAKE_DIR}
  fi
}
#}}}

# vim: ts=2 sw=2 sts=2 et nu foldmethod=marker
