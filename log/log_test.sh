#!/bin/bash

__SCRIPT_BASE=`echo $(cd $(dirname $0); pwd)`

source ${__SCRIPT_BASE}/log.sh

DUMMMY_SYSLOG=`mktemp`

# logger command mock
logger() { #{{{
  local OPT
  while getopts t:p: OPT; do
    case "$OPT" in
      t) ;;
      p) ;;
    esac
  done
  shift `expr $OPTIND - 1`

  if [[ -f ${DUMMMY_SYSLOG} ]]; then
    if [[ $# -gt 0 ]]; then
      echo -e "${C_BLUE}<<syslog:echo >> $@${C_OFF}" >> ${DUMMMY_SYSLOG}
    else
      sed -re "s/^(.*)$/${C_BLUE}<<syslog:stdin>> \1${C_OFF}/" >> ${DUMMMY_SYSLOG}
    fi
  else
    if [[ $# -gt 0 ]]; then
      echo -e "${C_BLUE}<<syslog:echo >> $@${C_OFF}"
    else
      sed -re "s/^(.*)$/${C_BLUE}<<syslog:stdin>> \1${C_OFF}/"
    fi
  fi
}
###}}}

__setup_color() { #{{{
  local I
  local COLOR_MAP=(\
    BLACK 0 MAROON 1 GREEN 2 OLIVE 3 NAVY 4 PURPLE 5 TEAL 6 SILVER 7 GREY 8 \
    RED 9 LIME 10 YELLOW 11 BLUE 12 FUCHSIA 13 AQUA 14 WHITE 15 \
    MAGENTA 5 CYAN 6 PINK 218 ORANGE 214 DARK_ORANGE3 166 \
  )

  C_OFF=`tput sgr0`   # Reset attribute
  C_BOLD=`tput bold`  # Bold mode
  C_REV=`tput rev`    # Reverse mode
  C_UL=`tput smul`    # Underline mode

  for ((I=0; I<${#COLOR_MAP[@]}; I+=2)); do
    # echo "$I : ${COLOR_MAP[$I]} ${COLOR_MAP[(($I + 1))]}"
    eval "C_${COLOR_MAP[$I]}=\`tput setaf ${COLOR_MAP[(($I + 1))]}\`"
    eval "C_B_${COLOR_MAP[$I]}=\`tput bold\`\`tput setaf ${COLOR_MAP[(($I + 1))]}\`"
    eval "C_U_${COLOR_MAP[$I]}=\`tput smul\`\`tput setaf ${COLOR_MAP[(($I + 1))]}\`"
    eval "C_R_${COLOR_MAP[$I]}=\`tput bold\`\`tput rev\`\`tput setaf ${COLOR_MAP[(($I + 1))]}\`"
  done
}
#}}}

__show_ok() { #{{{
  [[ "${__TTY}" != 'yes' ]] && return
  # don't write to syslog
  echo -e " [ ${C_GREEN}OK${C_OFF} ]"
}
#}}}

__show_error() { #{{{
  local TITLE="$1"
  shift 1
  __log -f2 `echo -e "[${C_RED}ERROR${C_OFF}] ${C_RED}${TITLE}${C_OFF} $@"`
}
#}}}

__show_info() { #{{{
  local TITLE="$1"
  shift 1
  __log `echo -e "${C_CYAN}${TITLE}${C_OFF} $@"`
}
#}}}

_test_command() { #{{{
  echo "test command: stdout1 (don't use _log())" >&1
  echo "test command: stdout2 (don't use _log())" >&1

  echo "test command: stderr1 (don't use _log())" >&2
  echo "test command: stderr2 (don't use _log())" >&2
}
#}}}

_test() { #{{{
  __log test123 hello
  __log -n test123 hello - no line break -
  __show_ok
  cat <<EOM | __log
from stdin1
from stdin2
${C_YELLOW}from stddin(color)${C_OFF}
EOM
  __show_info "ShowInfo testing..." 111 222 333
  __show_error "ShowError testing..." 111 222 333
  _test_command

  echo -e "${C_MAGENTA}========== Syslog ==========${C_OFF}"
  cat ${DUMMMY_SYSLOG}
  cat /dev/null > ${DUMMMY_SYSLOG}
} 
#}}}

_show_title() { #{{{
  echo
  echo -e "${C_DARK_ORANGE3}------------------------------${C_OFF}"
  echo -e "${C_DARK_ORANGE3}--- $@${C_OFF}"
  echo -e "${C_DARK_ORANGE3}------------------------------${C_OFF}"
}
#}}}

__setup_error_log() { #{{{
  exec 9>&2

  sleep inf &
  SLEEP_PID=$!

  exec 2> >(__TTY=yes __SYSLOG=yes __log -f9 -P"[error] "; kill ${SLEEP_PID})
}
#}}}

__script_end() { #{{{
  [[ -f "${DUMMMY_SYSLOG}" ]] && rm ${DUMMMY_SYSLOG}
  exec 2>&9
  exec 9>&-
  # wait for infinity sleep
  wait > /dev/null 2>&1
}
trap '__script_end' EXIT
#}}}

__setup_color

_show_title "tty:on syslog:no"
__TTY=yes
__SYSLOG=
_test

_show_title "tty:on syslog:yes"
__TTY=yes
__SYSLOG=yes
_test

_show_title "tty:off syslog:yes"
__TTY=
__SYSLOG=yes
_test

_show_title "catch all standard error by _log function"
[[ -f "${DUMMMY_SYSLOG}" ]] && rm ${DUMMMY_SYSLOG}
__setup_error_log
_test_command

# vim: ts=2 sw=2 sts=2 et nu foldmethod=marker
