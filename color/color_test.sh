#!/bin/bash

__SCRIPT_BASE=`echo $(cd $(dirname $0); pwd)`

. ${__SCRIPT_BASE}/../test-common.sh
. ${__SCRIPT_BASE}/color.sh

test__setup_color() { #{{{
  set -u

  __COLOR_MAP=()
  __setup_color

  for ((I=0; I<${#__COLOR_MAP[@]}; I+=2)); do
    printf "%3d : " ${__COLOR_MAP[(($I + 1))]}  
    eval "echo -en \"\${C_${__COLOR_MAP[$I]}}C_${__COLOR_MAP[$I]}\${C_OFF}\""
    tput hpa 24
    eval "echo -en \"\${C_B_${__COLOR_MAP[$I]}}C_B_${__COLOR_MAP[$I]}\${C_OFF}\""
    tput hpa 48
    eval "echo -en \"\${C_R_${__COLOR_MAP[$I]}} C_R_${__COLOR_MAP[$I]} \${C_OFF}\""
    tput hpa 72
    eval "echo -e \"\${C_U_${__COLOR_MAP[$I]}}C_U_${__COLOR_MAP[$I]}\${C_OFF}\""
  done
}
#}}}

. ${__SCRIPT_BASE}/../shunit2/shunit2

# vim: ts=2 sw=2 sts=2 et nu foldmethod=marker
