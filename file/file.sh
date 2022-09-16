#!/bin/bash

__make_backup_name() { #{{{
  local FILE="$1"
  [[ ! -f "$FILE" ]] && return
  local DIR=$(dirname $(readlink -f "$FILE"))
  local BASENAME=$(basename $(readlink -f "$FILE"))

  if [[ -z `echo "$BASENAME" | tr -dc .` ]]; then
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
  if [[ `uname` != Darwin ]] && [[ ! -d "$TMP_BASE" ]]; then
    mkdir "$TMP_BASE"
  fi
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
  if [[ `uname` != Darwin ]]; then
    [[ -d "$TMP_BASE" ]] && rm -rf "${TMP_BASE}"
  else
    local T=`mktemp`
    local TMP_ROOT=`dirname "$T"`
    rm -rf $T ${TMP_ROOT}/${TMP_BASE}* 2> /dev/null
  fi
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

# Deletes files matching the pattern, except for the specified number of files.
#   Global parameter : __DRY_RUN
__rotate_files() { #{{{
  local RETENTION="$1"
  local PATTERN="$2"
  local RESULT=0
  local F CNT

  ___do_rotate() {
    local F="$1"
    local MSG
    if [[ ${__DRY_RUN} != 'yes' ]]; then
      echo -n "  Deleting... $F"
      MSG=`rm "$F" 2>&1`
      if [[ $? -eq 0 ]]; then
        __show_ok
        return 0
      else
        echo -e "\n  [${C_RED}FAILED${C_OFF}] ${MSG}"
        return 1
      fi
    else
      echo "  will be deleted : $F"
    fi
  }

  if [[ ! "${RETENTION}" =~ [0-9]+ ]]; then
    __show_error "Invalid retention : ${RETENTION}"
    return 1
  fi

  if [[ ! "$PATTERN" =~ ^(.+)/([^/]+)$ ]]; then
    __show_error "Invalid pattern : ${PATTERN}"
    return 1
  fi
  local BASEDIR="${BASH_REMATCH[1]}"
  local FILE_PATTERN="${BASH_REMATCH[2]}"

  local FIND_ARGS=("${BASEDIR}" -mindepth 1 -maxdepth 1 -type f -name "${FILE_PATTERN}")

  # delete empty files
  __show_info "Deleting empty files..."
  CNT=0
  while read F; do
    ___do_rotate "$F" && CNT=$(( $CNT + 1 )) || RESULT=1
  done < <(find ${FIND_ARGS[@]} -size 0c)
  [[ "$CNT" -eq 0 ]] && echo "  nothing to delete."

  # delete old files
  __show_info "Deleting old files..."
  CNT=0
  while read F; do
    ___do_rotate "$F" && CNT=$(( $CNT + 1 )) || RESULT=1
  done < <(find ${FIND_ARGS[@]} -size +1c | sort -n | head --lines=-${RETENTION})
  [[ "$CNT" -eq 0 ]] && echo "  nothing to delete."

  return $RESULT
}
#}}}

# vim: ts=2 sw=2 sts=2 et nu foldmethod=marker
