# makefile discription.
# basic build file for cocoa library

# project-specific macros
# extension of the executable-file is modifiable(.exe .out ...)
BASEDIR = .
REQUIRES := $(wildcard $(BASEDIR)/t/_*.rb)
TESTSRCS := $(filter-out $(REQUIRES),$(wildcard $(BASEDIR)/t/*.rb))
TESTOBJS := $(patsubst %.rb,%.o,$(TESTSRCS))
TESTS := $(patsubst %.rb,%.exe,$(TESTSRCS))
REQUIREOBJS := $(patsubst %.rb,%.o,$(REQUIRES))

LIBR := $(BASEDIR)/../lib/libmruby-cocoa.a
EXCEPT1 := $(MRBCSRC)
MRBC := $(BASEDIR)/../vendors/bin/mrbc

# libraries, includes
LIBS = -framework Foundation -ldl -lm
INCLUDES = -I$(BASEDIR)/../include

# libffi
LIBFFI_CFLAGS = $(shell pkg-config libffi --cflags)
LIBFFI_LIBS = $(shell pkg-config libffi --libs)

ifeq ($(shell uname -s),Darwin)
  LDFLAGS = -Wl,-allow_stack_execute
else
  LDFLAGS = -Wl,--export-dynamic
endif

ifeq ($(strip $(COMPILE_MODE)),)
  # default compile option
  COMPILE_MODE = debug
endif

ifeq ($(COMPILE_MODE),debug)
  CFLAGS = -g -O3 -rdynamic
else ifeq ($(COMPILE_MODE),release)
  CFLAGS = -O3 -rdynamic
else ifeq ($(COMPILE_MODE),small)
  CFLAGS = -Os -rdynamic
endif

ALL_CFLAGS = -Wall -Werror-implicit-function-declaration -std=c99 $(CFLAGS) $(CFUNC_CFLAGS) $(MRUBY_CFLAGS) $(LIBFFI_CFLAGS)



##############################
# internal variables

export CP := cp
export RM_F := rm -f
export CAT := cat


##############################
# generic build targets, rules

.PHONY : all
all : $(TESTS)

.PHONY : run
run : $(TESTS)
	@echo
	@echo "*** Start tests ***"
	@echo
	@for command in $(TESTS) ; do \
	    if $$command ; then \
		    echo ; \
	    else \
			echo "*** Failed tests ***" ; \
	    	exit 1 ; \
	    fi ; \
	done
	@echo "*** Passed tests ***"

# executable constructed using linker from object files
$(TESTS) : %.exe : %.o $(REQUIREOBJS)
	echo $(REQUIREOBJS)
	$(LL) $< -o $@ $(REQUIREOBJS) $(CFLAGS) $(LDFLAGS) $(LIBR) $(CFUNC_LIBS) $(LIBFFI_LIBS) $(MRUBY_LIBS) $(LIBS) 

-include $(OBJS:.o=.d) $(OBJMRB:.o=.d)

# mrby complie
$(TESTOBJS) : %.o : %.rb
	cat $< | ruby -e "print STDIN.read.gsub(/#\s*BEGIN\s+C.*/m,'')" | $(MRBC) -o- -Btest_irep - > $(basename $<).m
	echo "const char* appname = \"$(basename $<)\";" >> $(basename $<).m
	cat main.m >> $(basename $<).m
	cat $< | ruby -e 's=STDIN.read;print s.gsub(/.*#\s*BEGIN\s+C(.*)/m,"\\1") if s.match(/#\s*BEGIN\s+C/)' >> $(basename $<).m
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $(basename $<).m -o $@

$(REQUIREOBJS) : %.o : %.rb
	$(MRBC) -Bmruby_data_`basename $(basename $<)` $<
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $(basename $<).m -o $@

# clean up
.PHONY : clean #cleandep
clean :
	@echo "make: removing targets, objects and depend files of `pwd`"
	-$(RM_F) $(TESTS) $(TESTOBJS) $(TESTS)
	-$(RM_F) $(TESTOBJS:.o=.d) $(TESTOBJS:.o=.m)