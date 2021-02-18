# The installation prefix default to /usr/local, but can be set on the cmdline
PREFIX      ?= /usr/local
STAGING     ?=
EXTRA_FLAGS ?=

#BUILD = lm32
#BUILD = win32
BUILD = unix

ifeq ($(BUILD), lm32)
TARGET	= lm32-elf-
FLAGS   = -I/home/mkreider/hdlprojects/wrpc-sw/ptp-noposix/libptpnetif -I/home/mkreider/hdlprojects/wrpc-sw/lib
endif
ifeq ($(BUILD), win32)
LIBS	= -lwsock32 -lws2_32
LIBRARY = etherbone.dll
EXTRA   = libetherbone.dll.a
endif
ifeq ($(BUILD), unix)
FLAGS   = -fPIC
LIBS    = -Wl,-rpath,$(PREFIX)/lib
LIBRARY = libetherbone.so
EXTRA   = libetherbone.so.*
endif

ifeq ($(BUILD), lm32)
TOOLS     =
TESTS     =
CPLUSPLUS =
TRANSPORT = transport/lm32.c
else
TOOLS     = tools/eb-read tools/eb-write tools/eb-put tools/eb-get tools/eb-snoop tools/eb-ls tools/eb-find tools/eb-tunnel tools/eb-discover
TESTS     = test/sizes test/loopback test/etherbonetest
CPLUSPLUS = glue/cplusplus.cpp
TRANSPORT = transport/posix-ip.c		\
	    transport/posix-udp.c		\
	    transport/posix-tcp.c		\
	    transport/tunnel.c			\
	    transport/dev.c			\
	    transport/transports.c		\
	    transport/run.c
endif

ARCHIVE = libetherbone.a

FLAGS	:= $(FLAGS) -Wall -O2
#FLAGS	:= $(FLAGS) -DEB_USE_DYNAMIC    # deterministic untill table overflow (default)
#FLAGS	:= $(FLAGS) -DEB_USE_STATIC=200 # fully deterministic
#FLAGS	:= $(FLAGS) -DEB_USE_MALLOC     # non-deterministic
#FLAGS	:= $(FLAGS) -DDISABLE_SLAVE
#FLAGS	:= $(FLAGS) -DDISABLE_MASTER

CFLAGS	= $(EXTRA_FLAGS) $(FLAGS) -Wmissing-declarations -Wmissing-prototypes
CXXFLAGS= $(EXTRA_FLAGS) $(FLAGS)
CC	= $(TARGET)gcc
CXX	= $(TARGET)g++

OBJECTS	= $(patsubst %.cpp,%.o,$(patsubst %.c,%.o,$(SOURCES)))
SOURCES	= memory/static.c		\
	  memory/dynamic.c		\
	  memory/array.c		\
	  memory/malloc.c		\
	  format/slave.c		\
	  format/master.c		\
	  glue/widths.c			\
	  glue/operation.c		\
	  glue/cycle.c			\
	  glue/device.c			\
	  glue/format.c			\
	  glue/socket.c			\
	  glue/handler.c		\
	  glue/readwrite.c		\
	  glue/strncasecmp.c		\
	  glue/sdb.c			\
	  $(CPLUSPLUS)			\
	  $(TRANSPORT)

all:	glue/version.h $(TOOLS) $(TESTS) $(ARCHIVE) $(LIBRARY)

install: all
	mkdir -p $(STAGING)$(PREFIX)/bin $(STAGING)$(PREFIX)/include $(STAGING)$(PREFIX)/lib/pkgconfig
	cp -d $(LIBRARY) $(EXTRA) $(ARCHIVE) $(STAGING)$(PREFIX)/lib
	cp etherbone.h $(STAGING)$(PREFIX)/include
	sed "s#@PREFIX@#$(PREFIX)#" < etherbone.pc.in > $(STAGING)$(PREFIX)/lib/pkgconfig/etherbone.pc
	cp $(TOOLS) $(STAGING)$(PREFIX)/bin

glue/version.h::
	git log -n1 --pretty="format:%H" . > git.version_full
	git log -n1 --pretty="format:%ci" . > git.date_full
	cut -b1-8 < git.version_full > git.version_short
	date +%Y%m%d -f git.date_full > git.date_short
	sed 's/@EB_VERSION_FULL@/'"`cat git.version_full`"'/;s/@EB_VERSION_SHORT@/'"`cat git.version_short`"'/;s/@EB_DATE_FULL@/'"`cat git.date_full`"'/;s/@EB_DATE_SHORT@/'"`cat git.date_short`"'/' < $@.in > $@.tmp
	if ! test -f $@ || ! diff $@ $@.tmp > /dev/null; then mv $@.tmp $@; fi
	rm -f $@.tmp git.version_full git.date_full git.version_short git.date_short

$(ARCHIVE):	$(OBJECTS)
	rm -f $@
	$(TARGET)ar rcs $@ $^
	$(TARGET)ranlib $@

etherbone.dll:	$(OBJECTS)
	$(TARGET)g++ $(CXXFLAGS) -shared -Wl,--out-implib=libetherbone.dll.a -Wl,--output-def,etherbone.def -o $@ $^ $(LIBS)

libetherbone.so:	libetherbone.so.1
	rm -f $@; ln -s $< $@
libetherbone.so.1:	libetherbone.so.1.0
	rm -f $@; ln -s $< $@
libetherbone.so.1.0:	$(OBJECTS)
	$(TARGET)g++ $(CXXFLAGS) -shared -Wl,-soname,libetherbone.so.1 -o $@ $^ $(LIBS)

tools/%:	tools/%.c $(LIBRARY)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

tools/eb-tunnel:	tools/eb-tunnel.c $(ARCHIVE)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

tools/eb-discover:	tools/eb-discover.c $(ARCHIVE)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

test/%:	test/%.c $(LIBRARY)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

test/%:	test/%.cpp $(LIBRARY)
	$(CXX) $(CXXFLAGS) -o $@ $^ $(LIBS)

clean:
	rm -f $(LIBRARY) $(EXTRA) $(ARCHIVE) $(OBJECTS) $(TOOLS)

%.o:	%.c
	$(CC) $(CFLAGS) -o $@ -c $^

%.o:	%.cpp
	$(CXX) $(CXXFLAGS) -o $@ -c $^
