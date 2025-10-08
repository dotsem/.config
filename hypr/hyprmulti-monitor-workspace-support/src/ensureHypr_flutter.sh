#!/bin/bash
pgrep -x "bundle/hypr_flutter" > /dev/null ||  $1 &