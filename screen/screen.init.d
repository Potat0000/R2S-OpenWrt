#!/bin/sh /etc/rc.common
# Copyright (c) 2011-2015 OpenWrt.org

START=99

start() {
    nohup /usr/bin/screen 2>&1 &
}

stop() {
    killall -q -2 screen
}
