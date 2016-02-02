@echo off
rem  This Source Code Form is subject to the terms of the Mozilla Public
rem License, v. 2.0. If a copy of the MPL was not distributed with this
rem file, You can obtain one at http://mozilla.org/MPL/2.0/.
rem Make sure runner runs at boot

SET MOZBUILDDIR=C:\mozilla-build
SET MOZILLABUILD=%MOZBUILDDIR%
echo "MozillaBuild directory: %MOZBUILDDIR%"

REM set BUILDBOT_PATH
Set BUILDBOT_PATH=C:\mozilla-build\buildbotve

echo "About to run check_ami.py"

"%MOZILLABUILD%\msys\bin\bash" --login -c "'%BUILDBOT_PATH%\Scripts\python' "/C/opt/runner/check_ami.py"

echo "%date% %time% - check_ami.py finished"
