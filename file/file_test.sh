#!/bin/bash

__SCRIPT_BASE=`echo $(cd $(dirname $0); pwd)`

. ${__SCRIPT_BASE}/../common/common.sh
. ${__SCRIPT_BASE}/file.sh

setUp() {
  SHUNIT_LOCALTMP=`mktemp -d -p /dev/shm`
}

tearDown() {
  [[ -d "${SHUNIT_LOCALTMP}" ]] && rm -rf "${SHUNIT_LOCALTMP}" && SHUNIT_LOCALTMP=
  return 0
}

test__make_backup_name_case1() { #{{{
  local TARGET="${SHUNIT_LOCALTMP}/test.txt"
  touch ${TARGET}

  local ACTUAL=`__make_backup_name "$TARGET"`
  assertTrue "[[ ${ACTUAL} =~ ^.+/test_`date '+%Y%m%d'`-[0-9]{6}\.txt$ ]]" 
}
#}}}

test__make_backup_name_case2() { #{{{
  local TARGET="${SHUNIT_LOCALTMP}/test"
  touch ${TARGET}

  local ACTUAL=`__make_backup_name "$TARGET"`
  assertTrue "[[ ${ACTUAL} =~ ^.+/test_`date '+%Y%m%d'`-[0-9]{6}$ ]]" 
}
#}}}

___make_ramdom_file() { #{{{
  head -c 32 /dev/urandom > ${SHUNIT_LOCALTMP}/$1
}
#}}}

test__rotate_files_case1() { #{{{
  ___make_ramdom_file test-20220101-123456.tar.gz
  ___make_ramdom_file test-20220102-123456.tar.gz
  ___make_ramdom_file test-20220103-123456.tar.gz
  ___make_ramdom_file test-20220104-123456.tar.gz
  ___make_ramdom_file test-20220105-123456.tar.gz

  __rotate_files 3 "${SHUNIT_LOCALTMP}/test-*.tar.gz"

  assertEquals 3 `ls -1 ${SHUNIT_LOCALTMP} | wc -l` 
  assertTrue "[[ -f ${SHUNIT_LOCALTMP}/test-20220103-123456.tar.gz ]]"
  assertTrue "[[ -f ${SHUNIT_LOCALTMP}/test-20220104-123456.tar.gz ]]"
  assertTrue "[[ -f ${SHUNIT_LOCALTMP}/test-20220105-123456.tar.gz ]]"
}
#}}}

test__rotate_files_case2() { #{{{
  ___make_ramdom_file test-20220101-123456.tar.gz
  ___make_ramdom_file test-20220102-123456.tar.gz

  __rotate_files 2 "${SHUNIT_LOCALTMP}/test-*.tar.gz"

  assertEquals 2 `ls -1 ${SHUNIT_LOCALTMP} | wc -l` 
}
#}}}

test__rotate_files_case3() { #{{{
  ___make_ramdom_file test-20220101-123456.tar.gz
  touch ${SHUNIT_LOCALTMP}/test-20220102-123456.tar.gz
  ___make_ramdom_file test-20220103-123456.tar.gz
  touch ${SHUNIT_LOCALTMP}/test-20220104-123456.tar.gz
  ___make_ramdom_file test-20220105-123456.tar.gz

  __rotate_files 2 "${SHUNIT_LOCALTMP}/test-*.tar.gz"

  assertEquals 2 `ls -1 ${SHUNIT_LOCALTMP} | wc -l` 
  assertTrue "[[ -f ${SHUNIT_LOCALTMP}/test-20220103-123456.tar.gz ]]"
  assertTrue "[[ -f ${SHUNIT_LOCALTMP}/test-20220105-123456.tar.gz ]]"
}
#}}}

. ${__SCRIPT_BASE}/../shunit2/shunit2

# vim: ts=2 sw=2 sts=2 et nu foldmethod=marker
