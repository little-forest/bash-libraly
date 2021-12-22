#!/bin/bash

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

# vim: ts=2 sw=2 sts=2 et nu foldmethod=marker
