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

# vim: ts=2 sw=2 sts=2 et nu foldmethod=marker
