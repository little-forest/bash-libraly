#!/bin/bash

__SCRIPT_BASE=`echo $(cd $(dirname $0); pwd)`

source ${__SCRIPT_BASE}/../color/color.sh
source ${__SCRIPT_BASE}/common.sh

__setup_color

#-----------------------------------------------------------
# __show_ok
#-----------------------------------------------------------
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

echo

#-----------------------------------------------------------
# __show_fail
#-----------------------------------------------------------

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

echo

# vim: ts=2 sw=2 sts=2 et nu foldmethod=marker
