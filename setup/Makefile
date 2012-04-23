all: $(patsubst %.erb,%,$(wildcard *.erb))

%:: %.erb common/*.erb
	cat common/lib.erb $< | erb -T - > $@ || rm -f $@
