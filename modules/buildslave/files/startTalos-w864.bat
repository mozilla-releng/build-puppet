REM This Source Code Form is subject to the terms of the Mozilla Public
REM License, v. 2.0. If a copy of the MPL was not distributed with this
REM file, You can obtain one at http://mozilla.org/MPL/2.0/.

REM This file lives in the 'buildslave' puppet module, but is not installed via
REM puppet - this is just a convenient place to store it.

REM wait a bit for things to settle
sleep 30
cd c:\

REM Cleanup profile, temp, and log files.
del /F /Q C:\Users\cltbld\AppData\Roaming\Mozilla\Firefox\console.log
rmdir /S /Q C:\Users\cltbld\AppData\Local\Temp
mkdir C:\Users\cltbld\AppData\Local\Temp
rm c:\slave\twistd.log.*

C:\mozilla-build\python27\python c:\slave\runslave.py
