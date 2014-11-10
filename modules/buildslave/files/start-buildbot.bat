@echo on

SET MOZBUILDDIR=%~dp0
SET MOZILLABUILD=%MOZBUILDDIR%

REM set Buildbot version 
cmd /c "C:/mozilla-build/bbpath.bat"

set log="c:\tmp\buildbot-startup.log"

echo "Mozilla tools directory: %MOZBUILDDIR%"

REM Use the "new" moztools-static
set MOZ_TOOLS=%MOZBUILDDIR%\moztools-x64

REM append moztools to PATH
SET PATH=%PATH%;%MOZ_TOOLS%\bin

cd "%USERPROFILE%"
:start

echo "%date% %time% - About to run runslave.py"

REM running this via 'bash' is critical - bash adds a bunch of items to PATH
REM which the build steps expect to find.

"%MOZILLABUILD%\msys\bin\bash" --login -c "python /c/mozilla-build/runslave.py"

echo "%date% %time% - runslave.py finished"

