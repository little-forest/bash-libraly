#!/bin/bash

__SCRIPT_BASE=`echo $(cd $(dirname $0); pwd)`

source ${__SCRIPT_BASE}/color.sh

___setup_color_show_examples() { #{{{
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

set -u

__COLOR_MAP=()
__setup_color

___setup_color_show_examples

# vim: ts=2 sw=2 sts=2 et nu foldmethod=marker
