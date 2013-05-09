PWD=$(shell pwd)
BUILDBOT=$(PWD)/bin/buildbot
export PYTHONDONTWRITEBYTECODE=1

start:
	cd master && $(BUILDBOT) start $$PWD
stop:
	cd master && $(BUILDBOT) stop $$PWD
restart:
	cd master && $(BUILDBOT) restart $$PWD
reconfig:
	cd master && $(BUILDBOT) reconfig $$PWD
checkconfig:
	cd master && $(BUILDBOT) checkconfig
version:
	$(BUILDBOT) --version
