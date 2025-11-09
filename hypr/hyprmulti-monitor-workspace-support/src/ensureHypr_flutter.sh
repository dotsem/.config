#!/bin/bash
pkill hypr_flutter
pgrep -x "bundle/hypr_flutter" > /dev/null ||  $1 &