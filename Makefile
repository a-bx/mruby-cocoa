# makefile discription.
# basic build file for mruby

# compiler, linker (gcc), archiver, parser generator
CC = clang
LL = clang
LIBFFI_VERSION = 3.0.11

ifeq ($(strip $(COMPILE_MODE)),)
  # default compile option
  COMPILE_MODE = debug
endif

ifeq ($(COMPILE_MODE),debug)
  CFLAGS = -g -O3
else ifeq ($(COMPILE_MODE),release)
  CFLAGS = -O3
else ifeq ($(COMPILE_MODE),small)
  CFLAGS = -Os
endif
CFLAGS += -pthread

BASEDIR = $(shell pwd)
INCLUDES = -I$(BASEDIR)/include -I$(BASEDIR)/vendors/include

MRUBY_CFLAGS = -I$(BASEDIR)/vendors/include
MRUBY_LIBS = -L$(BASEDIR)/vendors/lib -lmruby

LIBFFI_CFLAGS = -I$(BASEDIR)/vendors/lib/libffi-$(LIBFFI_VERSION)/include/
LIBFFI_LIBS = $(BASEDIR)/vendors/lib/libffi.a

CFUNC_CFLAGS = -I$(BASEDIR)/vendors/include
CFUNC_LIBS = -L$(BASEDIR)/vendors/lib -lmruby-cfunc

ALL_CFLAGS = $(CFLAGS) $(INCLUDES) $(MRUBY_CFLAGS)
MAKE_FLAGS = --no-print-directory CC='$(CC)' LL='$(LL)' CFLAGS='$(ALL_CFLAGS)' \
	LIBFFI_CFLAGS='$(LIBFFI_CFLAGS)' LIBFFI_LIBS='$(LIBFFI_LIBS)' \
	CFUNC_CFLAGS='$(CFUNC_CFLAGS)' CFUNC_LIBS='$(CFUNC_LIBS)' \
	MRUBY_CFLAGS='$(MRUBY_CFLAGS)' MRUBY_LIBS='$(MRUBY_LIBS)'


##############################
# internal variables

export CP := cp
export RM_F := rm -f
export CAT := cat


##############################
# generic build targets, rules

# mruby test
.PHONY : test
test : all
	@$(MAKE) -C test $(MAKE_FLAGS) run

.PHONY : all
all : vendors/lib/libffi.a vendors/lib/libmruby.a vendors/lib/libmruby-cfunc.a
	@$(MAKE) -C src $(MAKE_FLAGS)

# clean up
.PHONY : clean
clean :
	@$(MAKE) clean -C src $(MAKE_FLAGS)
	@$(MAKE) clean -C test $(MAKE_FLAGS)


##################
# libmruby-cfunc.a
tmp/mruby-cfunc:
	mkdir -p tmp
	cd tmp && git clone https://github.com/mobiruby/mruby-cfunc.git


vendors/lib/libmruby-cfunc.a: tmp/mruby-cfunc vendors/lib/libffi.a vendors/lib/libmruby.a
	cd tmp/mruby-cfunc/src && make MRBC="$(BASEDIR)/vendors/bin/mrbc" \
		CFLAGS="$(CFLAGS)" \
		TARGET="$(BASEDIR)/vendors/lib/libmruby-cfunc.a" \
		MRUBY_CFLAGS="$(MRUBY_CFLAGS)" \
		MRUBY_LIBS="$(MRUBY_LIBS)" \
		LIBFFI_CFLAGS="$(LIBFFI_CFLAGS)" \
		LIBFFI_LIBS="$(LIBFFI_LIBS)"
	cp -r tmp/mruby-cfunc/include/* vendors/include/


##################
# libffi.a
tmp/libffi:
	mkdir -p tmp
	cd tmp && git clone https://github.com/atgreen/libffi.git

vendors/lib/libffi.a: tmp/libffi
	cd tmp/libffi && ./configure --prefix=`pwd`/../../vendors && make clean install CFLAGS="$(CFLAGS)"


##################
# libmruby.a
tmp/mruby:
	mkdir -p tmp/mruby
	cd tmp; git clone https://github.com/mruby/mruby.git
	sed -i -e 's/\/\/\#define MRB_INT64/\#define MRB_INT64/' tmp/mruby/include/mrbconf.h

vendors/lib/libmruby.a: tmp/mruby
	cd tmp/mruby && make clean && make all CFLAGS="$(CFLAGS)"
	cp -r tmp/mruby/include vendors/
	cp -r tmp/mruby/lib vendors/
	cp -r tmp/mruby/bin vendors/