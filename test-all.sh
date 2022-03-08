#!/bin/bash

__SCRIPT_BASE=`echo $(cd $(dirname $0); pwd)`

SHUNIT_VER=2.1.8
SHUNIT_DIR=${__SCRIPT_BASE}/shunit2

_prepare() {
  [[ -d "${SHUNIT_DIR}" ]] && return 0
  pushd "${__SCRIPT_BASE}" > /dev/null
  curl -sLo - https://github.com/kward/shunit2/archive/refs/tags/v${SHUNIT_VER}.tar.gz | tar zx

  if [[ ! -d shunit2-${SHUNIT_VER} ]]; then
    echo "Failed to get shunit2" >&2
    return 1
  fi

  mv shunit2-${SHUNIT_VER} shunit2
  
  popd > /dev/null
}

_test_all() {
  while read FILE; do
    $FILE
  done < <(find ${__SCRIPT_BASE} -path '*/shunit2' -prune -o -name '*_test.sh' -print)
}

_prepare
_test_all

# vim: ts=2 sw=2 sts=2 et nu foldmethod=marker
