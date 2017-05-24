#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

/usr/bin/xrandr -d :0 --newmode "1600x1200_60.00"  161.00  1600 1712 1880 2160  1200 1203 1207 1245 -hsync +vsync
/usr/bin/xrandr -d :0 --addmode VIRTUAL1 1600x1200_60.00
/usr/bin/xrandr -d :0 --output VIRTUAL1 --mode "1600x1200_60.00"