PWD=$(shell pwd)
BUILDBOT=$(PWD)/bin/buildbot
export PYTHONDONTWRITEBYTECODE=1

start:
	@if [ $$(id -u) -eq 0 ]; then \
		echo "The script has been started as root account. Please start buildbot as cltbld user" ;\
		exit 1; \
	fi
	cd master && $(BUILDBOT) start $$PWD
stop:
	@if [ $$(id -u) -eq 0 ]; then \
		echo "The script has been started as root account. Please start buildbot as cltbld user" ;\
		exit 1; \
	fi
	cd master && $(BUILDBOT) stop $$PWD
restart:
	@if [ $$(id -u) -eq 0 ]; then \
		echo "The script has been started as root account. Please start buildbot as cltbld user" ;\
		exit 1; \
	fi
	cd master && $(BUILDBOT) restart $$PWD
reconfig:
	@if [ $$(id -u) -eq 0 ]; then \
		echo "The script has been started as root account. Please start buildbot as cltbld user" ;\
		exit 1; \
	fi
	cd master && $(BUILDBOT) reconfig $$PWD
checkconfig:
	@if [ $$(id -u) -eq 0 ]; then \
		echo "The script has been started as root account. Please start buildbot as cltbld user" ;\
		exit 1; \
	fi
	cd master && $(BUILDBOT) checkconfig
version:
	$(BUILDBOT) --version
