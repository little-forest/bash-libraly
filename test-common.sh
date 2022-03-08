
oneTimeSetUp() {
  if [[ -z "${C_OFF}" ]]; then
    [[ -z "${__SCRIPT_BASE}" ]] && echo "[ABORT] __SCRIPT_BASE is not defined." >&2 && exit 1

    if ! . ${__SCRIPT_BASE}/../color/color.sh; then
      echo "[ABORT] Failed to source color.sh"
      exit 1
    fi

    if ! . ${__SCRIPT_BASE}/../common/common.sh; then
      echo "[ABORT] Failed to source common.sh"
      exit 1
    fi

    __setup_color
  fi
}

setUp() {
  echo -e "\n`tput setaf 6`--------------------`tput sgr0`"
  SHUNIT_LOCALTMP=`mktemp -d -p /dev/shm`
}

tearDown() {
  [[ -d "${SHUNIT_LOCALTMP}" ]] && rm -rf "${SHUNIT_LOCALTMP}" && SHUNIT_LOCALTMP=
  return 0
}

