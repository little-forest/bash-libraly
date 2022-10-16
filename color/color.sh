#!/bin/bash

__setup_color() { #{{{
  local I
  local COLOR_MAP=(\
    BLACK 0 MAROON 1 GREEN 2 OLIVE 3 NAVY 4 PURPLE 5 TEAL 6 SILVER 7 GREY 8 \
    RED 9 LIME 10 YELLOW 11 BLUE 12 FUCHSIA 13 AQUA 14 WHITE 15 \
    MAGENTA 5 CYAN 6 MALIBU 74 PINK 218 ORANGE 214 DARK_ORANGE3 166 \
  )

  # export color map when `__COLOR_MAP` is defined
  [[ ${__COLOR_MAP+dummy} ]] && __COLOR_MAP=("${COLOR_MAP[@]}")

  if [[ $- == *u* ]] && [[ `type -t __setup_color_prepare_empty` == 'function' ]]; then
    __setup_color_prepare_empty ${COLOR_MAP[@]}
  fi

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

__setup_color_prepare_empty() { #{{{
  local I
  local COLOR_MAP=($@)

  # declare only empty variables to avoid errors when 'set -u' is specified.
  for I in OFF BOLD REV UL; do
    eval "C_${I}="
  done
  for ((I=0; I<${#COLOR_MAP[@]}; I+=2)); do
    eval "C_${COLOR_MAP[$I]}=; C_B=${COLOR_MAP[$I]}=; C_U_${COLOR_MAP[$I]}=; C_R_${COLOR_MAP[$I]}=;"
  done
}
#}}}

# vim: ts=2 sw=2 sts=2 et nu foldmethod=marker
