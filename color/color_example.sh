#!/bin/bash

# from https://unix.stackexchange.com/questions/269077/tput-setaf-color-table-how-to-determine-color-codes

fromhex(){
    local hex=${1#"#"}
    local r=$(printf '0x%0.2s' "$hex")
    local g=$(printf '0x%0.2s' ${hex#??})
    local b=$(printf '0x%0.2s' ${hex#????})
    printf '%03d' "$(( (r<75?0:(r-35)/40)*6*6 +
                       (g<75?0:(g-35)/40)*6   +
                       (b<75?0:(b-35)/40)     + 16 ))"
}

color(){
    local c
    for c; do
        printf '\e[48;5;%dm %03d ' $c $c
    done
    printf '\e[0m \n'
}

IFS=$' \t\n'
color {0..15}
for ((i=0;i<6;i++)); do
    color $(seq $((i*36+16)) $((i*36+51)))
done
color {232..255}

echo

for ((i=16;i<=21;i++)); do
    ARR=()
    ARR+=(`seq $i 6 $(( $i + 30 ))`)
    ARR+=(`seq $(( $i + 66 )) -6 $(( $i + 36 ))`)
    ARR+=(`seq $(( $i + 72 )) 6 $(( $i + 102 ))`)
    ARR+=(`seq $(( $i + 138 )) -6 $(( $i + 108 ))`)
    ARR+=(`seq $(( $i + 144 )) 6 $(( $i + 174 ))`)
    ARR+=(`seq $(( $i + 210 )) -6 $(( $i + 180 ))`)
    color ${ARR[@]}
done

HEX="$1"
if [[ -n $HEX ]]; then
  C_OFF=`tput sgr0`
  CODE=`fromhex $HEX`
  echo "$HEX is $CODE"
  C_WHITE_BACK=`tput setab 7`
  C_FG_B=`tput setaf 0`
  C_FG_W=`tput setaf 7`
  C_BG_W=`tput setab 7`
  C_FG=`tput setaf $CODE`
  C_BG=`tput setab $CODE`
  echo "Foreground : tput setaf ${CODE}"
  echo -e "${C_FG} SAMPLE ${C_BG_W} SAMPLE ${C_OFF}"
  echo "Backgroupd : tput setab ${CODE}"
  echo -e "${C_BG}${C_FG_W} SAMPLE ${C_FG_B} SAMPLE ${C_OFF}"
fi

# vim: ts=2 sw=2 sts=2 et nu foldmethod=marker
