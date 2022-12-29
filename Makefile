
MIX_ENV ?= dev
MIX_TARGET ?= host
UNAME := $(shell uname -s | tr '[:upper:]' '[:lower:]')

SRCDIR = src
PRIVDIR = priv
OUTDIR = $(PRIVDIR)/$(MIX_TARGET)

#-pedantic -Wall allow unused during debugging
#-Werror remove to run on macos with lots of warnings
PORT_TARGET = $(OUTDIR)/ash_serial
PORT_SOURCES = $(SRCDIR)/*.c
PORT_HEADERS = $(SRCDIR)/*.h
PORT_CFLAGS = -g0 -O3 -pedantic -Wall -Wextra -D_XOPEN_SOURCE=700
PORT_LDFLAGS = -fPIC -Wl,-rpath,'$$ORIGIN' -L$(OUTDIR) -lpthread

.PHONY: all pre clean reset post 

all: pre $(PORT_TARGET) post

pre:
	env | sort > Makefile.$(UNAME).$(MIX_TARGET).env
	[ -d $(OUTDIR) ] || mkdir -p $(OUTDIR)
	echo $(MIX_TARGET) > $(PRIVDIR)/target

post:
	rm -fR $(OUTDIR)/*.dSYM

clean:
	rm -fr $(PRIVDIR)/target
	rm -fr $(OUTDIR)

reset: clean
	rm -fr _build deps
	rm Makefile.*.env

$(PORT_TARGET): $(PORT_SOURCES) $(PORT_HEADERS) Makefile
	$(CC) $(PORT_CFLAGS) $(PORT_SOURCES) $(PORT_LDFLAGS) -o $@
