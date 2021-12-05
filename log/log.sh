#!/bin/bash

__log() { #{{{
  # log messages to specified file descriptor or syslog
  # 
  # usage:: __log [-f<FILE_DESCRIPTOR>] [-P<PREFIX>] [-n] MESSAGE...
  #   FILE_DESCRIPTOR: file descriptor, default is 1(stdout)
  #   PREFIX:          log prefix (ex: -p"[ERROR] ")
  #   -n:              if specified, don't break lines
  #   MESSAGE:         strings to log. if not given, read from stdin
  #
  # global flag::
  #   __TTY:     if 'yes'. write to specified file descriptor
  #   __SYSLOG:  if 'yes', also output to syslog
  #   __LOG_TAG: 

  # get output file descriptor
  local FD=1 #stdout
  if [[ "$1" =~ ^-f[0-9]+$ ]]; then
    local FD=${1:2}
    shift 1
  fi

  # get prefix
  local PREFIX=
  if [[ "$1" =~ ^-P.*$ ]]; then
    local PREFIX="${1:2}"
    shift 1
  fi

  # get no line break option
  if [[ "$1" == '-n' ]]; then
    local N_OPT='-n'
    shift 1
  fi

  local REMOVE_ESC="s:\x1B[\(\)][AB012]::g;s:\x1B\[([0-9]{1,2}(;[0-9]{1,2})*)?m::g"
  local PRIORITY='user.info'
  local LOGGER_OPT=()
  [[ -n "${__LOG_TAG}" ]] && LOGGER_OPT+=(-t "${__LOG_TAG}")
  LOGGER_OPT+=(-p "${PRIORITY}")

  if [[ $# -gt 0 ]]; then
    # arguments are given
    if [[ "${__SYSLOG}" == 'yes' ]]; then
      logger ${LOGGER_OPT[@]} `echo -n "${PREFIX}$@" | sed -re "${REMOVE_ESC}"`
    fi
    if [[ "${__TTY}" == 'yes' ]]; then
      echo ${N_OPT} "$@" >&${FD}
    fi
  else
    # no argument, read from stdin
    if [[ "${__SYSLOG}" == 'yes' ]] && [[ "${__TTY}" == 'yes' ]]; then
      tee >(sed -re "s/^/${PREFIX}/" -e "${REMOVE_ESC}" | logger ${LOGGER_OPT[@]}) >&${FD}
    elif [[ "${__SYSLOG}" == 'yes' ]]; then
      sed -re "s/^/${PREFIX}/" -e "${REMOVE_ESC}" | logger ${LOGGER_OPT[@]}
    elif [[ "${__TTY}" == 'yes' ]]; then
      cat >&${FD}
    fi
  fi
}
#}}}

# vim: ts=2 sw=2 sts=2 et nu foldmethod=marker
