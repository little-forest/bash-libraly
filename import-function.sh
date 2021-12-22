#!/bin/bash

#-------------------------------------------------------------------------------
#- common global variables -----------------------------------------------------
__SCRIPT_BASE=`echo $(cd $(dirname $0); pwd)`
__SCRIPT_NAME=`basename $0`

#-------------------------------------------------------------------------------
#- common functions ------------------------------------------------------------
#{{{
__setup_color() { #{{{
  [[ $# -gt 0 ]] && local MODE="$1" || local MODE=

  local I
  local COLOR_MAP=(\
    BLACK 0 MAROON 1 GREEN 2 OLIVE 3 NAVY 4 PURPLE 5 TEAL 6 SILVER 7 GREY 8 \
    RED 9 LIME 10 YELLOW 11 BLUE 12 FUCHSIA 13 AQUA 14 WHITE 15 \
    MAGENTA 5 CYAN 6 PINK 218 ORANGE 214 DARK_ORANGE3 166 \
  )

  if [[ "$MODE" == none ]]; then
    # declare only empty variables to avoid errors when 'set -u' is specified.
    for I in OFF BOLD REV UL; do
      eval "C_${I}="
    done
    for ((I=0; I<${#COLOR_MAP[@]}; I+=2)); do
      eval "C_${COLOR_MAP[$I]}=; C_B=${COLOR_MAP[$I]}=; C_U_${COLOR_MAP[$I]}=; C_R_${COLOR_MAP[$I]}=;"
    done
    return 0
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

  # show examples (you can delete this)
  if [[ "$MODE" == show ]]; then
    for ((I=0; I<${#COLOR_MAP[@]}; I+=2)); do
      printf "%3d : " ${COLOR_MAP[(($I + 1))]}  
      eval "echo -en \"\${C_${COLOR_MAP[$I]}}C_${COLOR_MAP[$I]}\${C_OFF}\""
      tput hpa 24
      eval "echo -en \"\${C_B_${COLOR_MAP[$I]}}C_B_${COLOR_MAP[$I]}\${C_OFF}\""
      tput hpa 48
      eval "echo -en \"\${C_R_${COLOR_MAP[$I]}} C_R_${COLOR_MAP[$I]} \${C_OFF}\""
      tput hpa 72
      eval "echo -e \"\${C_U_${COLOR_MAP[$I]}}C_U_${COLOR_MAP[$I]}\${C_OFF}\""
    done
  fi
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

__show_ok() { #{{{
  [[ -n "${__SILENT}" ]] && return
  [[ "$1" && "$1" -gt 0 ]] && echo -en "\\033[${1}G"
  echo -en "[${C_GREEN} OK ${C_OFF}"
  [[ -n "$2" ]] && echo "] $2" || echo "]"
}
#}}}

__show_info() { #{{{
  [[ -n "${__SILENT}" ]] && return
  [[ "$1" == "-n" ]] && echo -en "${C_CYAN}${2}${C_OFF}" || echo -e "${C_CYAN}${1}${C_OFF}"
}
#}}}

__show_error() { #{{{
  echo -e "[${C_RED} ERROR ${C_OFF}] $*" >&2
}
#}}}

__error_end() { #{{{
  __show_error "$*"; exit 1
}
#}}}

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

#}}}

#-------------------------------------------------------------------------------
#- functions -------------------------------------------------------------------

_usage() { #{{{
  [[ "$1" ]] && __show_error "$1"
  cat <<!!!
usege : $__SCRIPT_NAME [-l] [-o TARGET] [-h]
          -l : list supported functions
          -o : import target file
          -h : display usage
!!!
  exit 1
}
#}}}

_search_func() { #{{{
  local FILE_NAME="$1"
  local FUNC_NAME="$2"
  local LINENUM_CMD='s/^([0-9]+):.*/\1/'

  local TOP=`egrep -n "^${FUNC_NAME}\(\)" ${FILE_NAME} | sed -re "${LINENUM_CMD}"`
  [[ -z "$TOP" ]] && return 1

  local BOTTOM=`sed -e "1,${TOP}d" ${FILE_NAME} | egrep -n "^}$" | head -n1 | sed -re "${LINENUM_CMD}"`
  [[ -z "$BOTTOM" ]] && return 1
  BOTTOM=$(( ${BOTTOM} + ${TOP} ))

  echo "${TOP} ${BOTTOM}"
}
#}}}

_import() { #{{{
  local FROM="$1"
  local FROM_TOP="$2"
  local FROM_BOTTOM="$3"
  local TO="$4"
  local TO_TOP="$5"
  local TO_BOTTOM="$6"
  local CMD

  # copy before function
  CMD="1,$(( ${TO_TOP} - 1 ))p"
  sed -ne "${CMD}" ${TO} || __error_end "sed error1 : ${CMD}"

  # import function
  CMD="${FROM_TOP},${FROM_BOTTOM}p"
  sed -ne "${CMD}" ${FROM} || __error_end "sed error2 : ${CMD}"

  # copy after function
  CMD="$(( ${TO_BOTTOM} + 1 )),\$p"
  sed -ne "${CMD}" ${TO} || __error_end "sed error3 : ${CMD}"
}
#}}}

_import_function() { #{{{
  local FROM="$1"
  local TO="$2"
  local FUNC_NAME="$3"
  local OUT_FILE="$4"
  local F_TOP F_BOTTOM T_TOP T_BOTTOM

  read F_TOP F_BOTTOM < <(_search_func ${FROM} ${FUNC_NAME})
  read T_TOP T_BOTTOM < <(_search_func ${TO} ${FUNC_NAME})
  if [[ -z "${F_TOP}" ]] || [[ -z "${F_BOTTOM}" ]]; then
    __show_error " Function not found in ${FROM} : ${FUNC_NAME}"
    return 1
  fi
  if [[ -z "${T_TOP}" ]] || [[ -z "${T_BOTTOM}" ]]; then
    __show_error " Function not found in ${TO} : ${FUNC_NAME}"
    return 1
  fi

  _import "${FROM}" "${F_TOP}" "${F_BOTTOM}" "${TO}" "${T_TOP}" "${T_BOTTOM}" > ${OUT_FILE}
  return $?
}
#}}}

_list_function() { #{{{
  local FILE="$1"
  sed -nre 's|^[ \t]*(__[a-zA-Z0-9_-]+)\(\)[ \t]*\{.*|\1|p' "$FILE"
}
#}}}

_make_backup_name() { #{{{
  local FILE="$1"
  [[ ! -f "$FILE" ]] && return
  local DIR=$(dirname $(readlink -f "$FILE"))
  local BASENAME=$(basename $(readlink -f "$FILE"))

  echo "${DIR}/${BASENAME%.*}_`date '+%Y%m%d-%H%M%S'`.${BASENAME##*.}"
}
#}}}

_find_library() { #{{{
  local NAME="$1"
  find ${__SCRIPT_BASE} -type f -name '${NAME}.sh'
  return $?
}
#}}}

_pickup_functions() { #{{{
  # pickup function names which are import target candidates from specified file
  local SRC="$1"
  sed -nre 's|^[ \t]*(__[a-zA-Z0-9_-]+)\(\).*|\1|p' "$SRC"
}
#}}}

_list_library_files() { #{{{
  # find & list library script files from specified directory
  local BASE_DIR="$1"
  find ${BASE_DIR} -mindepth 2 -type f -regextype posix-egrep -regex '.+/[a-z].+\.sh' | egrep -v '_(test|example)\.sh$'
}
#}}}

_list_functions() { #{{{
  local BASE_DIR="$1"
  local LIBNAME RELNAME
  while read LIBNAME; do
    RELNAME=`sed -Ee "s|^${__SCRIPT_BASE}/||" <<<"${LIBNAME}"`
    _pickup_functions "$LIBNAME" | sed -Ee "s|^|${C_CYAN}${RELNAME}::${C_OFF}|"
  done < <(_list_library_files "${__SCRIPT_BASE}" | sort)
}
#}}}

_exec() { #{{{
  local TO="$1"
  local SUCCESS=0

  local TARGET=`__make_tmp`
  cp -rp "${TO}" "${TARGET}" 

  local SRC=`__make_tmp`
  _list_library_files "${__SCRIPT_BASE}" | xargs cat > ${SRC}

  local FUNC_NAME
  while read FUNC_NAME; do
    echo -ne "${C_CYAN}Searching function...${C_OFF} : ${FUNC_NAME}"
    read F_TOP F_BOTTOM < <(_search_func ${SRC} ${FUNC_NAME})

    if [[ "${F_TOP}" ]] && [[ "${F_BOTTOM}" ]]; then
      echo -e " [${C_GREEN}FOUND${C_OFF}]"
      local TMP=`__make_tmp`
      if _import_function ${SRC} "${TARGET}" "${FUNC_NAME}" "${TMP}"; then
        mv "${TMP}" "${TARGET}" && SUCCESS=$(( ${SUCCESS} + 1 ))
      else
        __show_error "Failed to import ${FUNC_NAME} from ${SRC} to ${TO}"
        break
      fi
    else
      echo -e " [${C_YELLOW}NOT FOUND${C_OFF}]"
    fi
  done < <(_pickup_functions "$TO")


  if [[ "${SUCCESS}" -gt 0 ]]; then
    if diff -q "${TO}" "${TARGET}" > /dev/null; then
      echo "${C_GREEN}Nothing changed.${C_OFF}"
    else
      local BACKUP=`_make_backup_name "${TO}"`
      mv "${TO}" "${BACKUP}" && mv "${TARGET}" "${TO}"
      echo "${C_GREEN}${SUCCESS} function(s) imported, previous file is backuped to ${BACKUP}.${C_OFF}"
    fi
  fi
  [[ -f "${TARGET}" ]] && rm "${TARGET}"
  [[ -f "${SRC}" ]] && rm "${SRC}"
}
#}}}

#-------------------------------------------------------------------------------
#- Main process ----------------------------------------------------------------
#-------------------------------------------------------------------------------
#- setup -----------------------------------------------------------------------
__setup_color

#- Get options -----------------------------------------------------------------
#{{{
while getopts lo:h OPT; do
  case "$OPT" in
    o) TO="$OPTARG"
      ;;
    l) _list_functions
      exit 0
      ;;
    h|\?) _usage
      ;;
  esac
done
shift `expr $OPTIND - 1`


[[ -z "$TO" ]] && __error_end "Destination is not given."
[[ ! -f "$TO" ]] && __error_end "File not found. : ${TO}"

IMPORT_FUNCS=("$@")
#}}}

#- Main process ----------------------------------------------------------------

_exec "$TO"

# vim: ts=2 sw=2 sts=2 et nu foldmethod=marker
