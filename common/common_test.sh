#!/bin/bash

__SCRIPT_BASE=`echo $(cd $(dirname $0); pwd)`

. ${__SCRIPT_BASE}/../test-common.sh
. ${__SCRIPT_BASE}/common.sh

test__show_ok() { #{{{
  __MSG_COL=

  echo -n "ok test1"
  __show_ok

  echo -n "ok test2"
  __show_ok 40

  echo -n "ok test3"
  __show_ok message

  echo -n "ok test4"
  __show_ok 40 message

  __MSG_COL=40
  echo -n "ok test5"
  __show_ok

  echo -n "ok test6"
  __show_ok message
}
#}}}

test__show_failed() { #{{{
  __MSG_COL=

  echo -n "fail test1"
  __show_failed

  echo -n "fail test2"
  __show_failed 40

  echo -n "fail test3"
  __show_failed message

  echo -n "fail test4"
  __show_failed 40 message

  __MSG_COL=40
  echo -n "fail test5"
  __show_failed

  echo -n "fail test6"
  __show_failed message
}
#}}}

test__progress() { #{{{
  __setup_showing_progress

  for I in {1..5}; do
    if [[ $I == 2 ]]; then
      __show_progress_warn "warning test"
    fi
    if [[ $I == 4 ]]; then
      __show_progress_error "error test"
    fi

    __show_progress "__show_progress : $I"
    sleep 0.3
  done

  __teardown_showing_progress
}
#}}}

. ${__SCRIPT_BASE}/../shunit2/shunit2

# vim: ts=2 sw=2 sts=2 et nu foldmethod=marker
