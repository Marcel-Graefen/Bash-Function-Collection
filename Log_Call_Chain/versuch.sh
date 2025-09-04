#!/bin/bash


source log_call_chain.sh

log_call_chain -m "Hallo" -d "/home/marcel/HURENSOHN" "/home/marcel/TEST" "/haus" -D "The directory /tmp/test_log_callchain cannot be written to by the current user. Check permissions or run as root."
