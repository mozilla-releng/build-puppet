REM This file lives in the 'buildslave' puppet module, but is not installed via
REM puppet - this is just a convenient place to store it.

REM This file is deployed to
REM "C:\Users\cltbld\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"

REM wait a bit for things to settle
C:\mozilla-build\msys\bin\sleep.exe 20

cd C:\mozilla-build
REM start-buildbot.bat calls C:\runslave.py
start /min start-buildbot.bat

REM and don't close this window so quickly that a SIGBREAK will be sent to start-buildbot.bat
C:\mozilla-build\msys\bin\sleep.exe 20
