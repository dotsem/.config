#!/bin/bash
pkill hypr_flutter
pgrep -x "bundle/hypr_flutter" > /dev/null || __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia $1 &