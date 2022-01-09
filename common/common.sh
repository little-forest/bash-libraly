#!/bin/bash

#-------------------------------------------------------------------------------
#- common functions ------------------------------------------------------------
__show_ok() { #{{{
  [[ -n "${__SILENT}" ]] && return
  local COL
  [[ ! "$1" =~ [0-9]+ ]] && COL="${__RES_COL}" || COL="$1" && shift 1
  local MSG="$1"

  [[ -n "${COL}" ]] && echo -en "\\033[${COL}G"
  echo -en " [ ${C_GREEN}OK${C_OFF}"
  [[ -n "${MSG}" ]] && echo " ] ${MSG}" || echo " ]"
}
#}}}

__show_info() { #{{{
  [[ -n "${__SILENT}" ]] && return
  [[ "$1" == "-n" ]] && echo -en "${C_CYAN}${2}${C_OFF}" || echo -e "${C_CYAN}${1}${C_OFF}"
}
#}}}

__show_error() { #{{{
  echo -e "[${C_RED}ERROR${C_OFF}] $*" >&2
}
#}}}

__show_failed() { #{{{
  [[ -n "${__SILENT}" ]] && return
  local COL
  [[ ! "$1" =~ [0-9]+ ]] && COL="${__RES_COL}" || COL="$1" && shift 1
  local MSG="$1"

  [[ -n "${COL}" ]] && echo -en "\\033[${COL}G"
  echo -en " [ ${C_RED}FAILED${C_OFF}"
  [[ -n "${MSG}" ]] && echo " ] ${MSG}" || echo " ]"
}
#}}}

__error_end() { #{{{
  __show_error "$*"; exit 1
}
#}}}

__move_col() { #{{{
  tput hpa "$1"
}
#}}}

__script_end() { #{{{
  local FUNC
  while read FUNC; do
    $FUNC
  done < <(declare -F | sed -e 's/^declare -f //' | egrep '^__?script_end_.+' | sort)
}
trap '__script_end' EXIT
#}}}

__confirm() { #{{{
  local MSG="$1"
  local CHAR
  local RESULT
  echo -n "$1 (y/n) "
  while :;do
    read -s -n 1 CHAR
    case $CHAR in
      y|Y) RESULT=0; break ;;
      n|N) RESULT=1; break ;;
      *) ;;
    esac
  done
  echo $CHAR
  return $RESULT
}
#}}}

# vim: ts=2 sw=2 sts=2 et nu foldmethod=marker
