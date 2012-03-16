REM This file lives in the 'buildslave' puppet module, but is not installed via
REM puppet - this is just a convenient place to store it.

REM reset working directory, for fun
cd c:\

REM set screen resolution
dc.exe -width=1280 -height=1024

REM make sure Apache is running
"C:\Program Files\Apache Software Foundation\Apache2.2\bin\httpd.exe" -w -n "Apache2" -k stop
echo cleared > "C:\Program Files\Apache Software Foundation\Apache2.2\logs\access.log"
echo cleared > "C:\Program Files\Apache Software Foundation\Apache2.2\logs\error.log"
"C:\Program Files\Apache Software Foundation\Apache2.2\bin\httpd.exe" -w -n "Apache2" -k start

REM clean out old twistd.log's
rm c:\talos-slave\twistd.log.*

REM sleep for 60s
sleep 60

C:\mozilla-build\python25\python c:\runslave.py
