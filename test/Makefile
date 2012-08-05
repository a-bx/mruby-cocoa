# makefile discription.
# basic build file for cocoa library

# project-specific macros
# extension of the executable-file is modifiable(.exe .out ...)
BASEDIR = $(shell pwd)
TARGET := $(BASEDIR)/cocoa_test
MRBCSRC := $(patsubst %.rb,%.c,$(wildcard $(BASEDIR)/mrb/*.rb))
LIBR := $(BASEDIR)/../lib/libmruby-cocoa.a

EXCEPT1 := $(MRBCSRC)

OBJ1 := $(patsubst %.c,%.o,$(filter-out $(EXCEPT1),$(wildcard $(BASEDIR)/*.c)))
OBJ2 := $(patsubst %.m,%.o,$(filter-out $(EXCEPT1),$(wildcard $(BASEDIR)/*.m)))
OBJMRB := $(patsubst %.c,%.o,$(MRBCSRC))
OBJS := $(OBJ1) $(OBJ2) $(OBJ3)

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
  LDFLAGS = 
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

ALL_CFLAGS = -Wall -Werror-implicit-function-declaration -std=c99 $(CFLAGS) $(MRUBY_CFLAGS) $(LIBFFI_CFLAGS)



##############################
# internal variables

export CP := cp
export RM_F := rm -f
export CAT := cat


##############################
# generic build targets, rules

.PHONY : all
all : $(TARGET)

.PHONY : run
run : $(TARGET)
	$(TARGET)

# executable constructed using linker from object files
$(TARGET) : $(OBJS) $(OBJMRB) $(LIBR)
	$(LL) -o $@ $(CFLAGS) $(LDFLAGS) $^ $(MRUBY_LIBS) $(LIBFFI_LIBS) $(CFUNC_LIBS) $(LIBS)

-include $(OBJS:.o=.d) $(OBJMRB:.o=.d)

# mrby complie
$(OBJMRB) : %.o : %.rb
	$(MRBC) -Cinit_$(*F) $<
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $(basename $<).c -o $@

# objects compiled from source
$(OBJ1) : %.o : %.c
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $< -o $@

$(OBJ2) : %.o : %.m
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $< -o $@

# clean up
.PHONY : clean #cleandep
clean :
	@echo "make: removing targets, objects and depend files of `pwd`"
	-$(RM_F) $(TARGET) $(OBJS) $(OBJMRB) $(MRB)
	-$(RM_F) $(OBJS:.o=.d) $(OBJY:.o=.d)
	-$(RM_F) $(patsubst %.c,%.o,$(EXCEPT1)) $(patsubst %.c,%.d,$(EXCEPT1))