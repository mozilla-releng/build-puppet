REM This Source Code Form is subject to the terms of the Mozilla Public
REM License, v. 2.0. If a copy of the MPL was not distributed with this
REM file, You can obtain one at http://mozilla.org/MPL/2.0/.

REM This file lives in the 'buildslave' puppet module, but is not installed via
REM puppet - this is just a convenient place to store it.

REM wait a bit for things to settle
sleep 30

REM reset working directory, for fun
cd c:\

REM set screen resolution
nircmd.exe setdisplay 1280 1024 32

REM make sure Apache is running
"C:\Program Files (x86)\Apache Software Foundation\Apache2.2\bin\httpd.exe" -w -n "Apache2.2" -k stop
echo cleared > "C:\Program Files (x86)\Apache Software Foundation\Apache2.2\logs\access.log"
echo cleared > "C:\Program Files (x86)\Apache Software Foundation\Apache2.2\logs\error.log"
"C:\Program Files (x86)\Apache Software Foundation\Apache2.2\bin\httpd.exe" -w -n "Apache2.2" -k start

REM Cleanup profile, temp, and log files.
del /F /Q C:\Users\cltbld\AppData\Roaming\Mozilla\Firefox\console.log
rmdir /S /Q C:\Users\cltbld\AppData\Local\Temp
mkdir C:\Users\cltbld\AppData\Local\Temp
rm c:\talos-slave\twistd.log.*

C:\mozilla-build\python25\python c:\runslave.py
