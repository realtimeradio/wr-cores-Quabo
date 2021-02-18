@usage: gmake all
ODIR  	= bin/
IDIR   	= ./
HDIR 	= ../
SRCDIR	= ../src/
INCLUDE =  -I$(IDIR) -I$(SRCDIR) -I$(HDIR)
MY_OS   = LINUX

all: etherbone liblvEtherbone myeb_snoop myeb_write cleanobj
clean: cleanLib

etherbone:
	gcc  -D$(MY_OS) -fPIC -g -c -Wall $(INCLUDE) $(SRCDIR)etherbone.c
	gcc  -D$(MY_OS) -fPIC -g -c -Wall $(INCLUDE) $(SRCDIR)queue.c
	gcc  -D$(MY_OS) -fPIC -g -c -Wall $(INCLUDE) $(SRCDIR)ring.c
	gcc  -D$(MY_OS) -fPIC -g -c -Wall $(INCLUDE) $(SRCDIR)udp.c
	gcc  -D$(MY_OS) -fPIC -g -c -Wall $(INCLUDE) $(SRCDIR)fec.cpp
liblvEtherbone:
	@echo Making target lvEtherbone
	gcc  -D$(MY_OS) -fPIC -g -c -Wall $(INCLUDE) $(IDIR)lvEtherbone.c
	gcc -shared  -o $(ODIR)lvEtherbone.so lvEtherbone.o etherbone.o udp.o fec.o ring.o queue.o

myeb_snoop:
	@echo Making target myeb_snoop
	gcc  -D$(MY_OS) -fPIC -g -c -Wall $(INCLUDE) $(IDIR)myeb-snoop.c
	gcc -lstdc++ -o $(ODIR)myeb_snoop myeb-snoop.o etherbone.o udp.o fec.o ring.o queue.o

myeb_write:
	@echo Making target myeb_write
	gcc  -D$(MY_OS) -fPIC -g -c -Wall $(INCLUDE) $(IDIR)myeb-write.c
	gcc -lstdc++ -o $(ODIR)myeb_write myeb-write.o etherbone.o udp.o fec.o ring.o queue.o

cleanobj:
	rm *.o

cleanLib:
	@echo removing shared object libraries
	rm $(ODIR)lvEtherbone.so 
	rm $(ODIR)myeb_snoop 
	rm $(ODIR)myeb_write 
	rm *.o

