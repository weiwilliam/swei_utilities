SHELL=/bin/sh

CORELIB=/data/users/swei/Q3FY17/lib.2015mod
COREINC=$(CORELIB)/incmod
INCnemsio = $(COREINC)/nemsio_v2.2.2
INCcrtm= $(COREINC)/crtm_v2.2.4

FC=ifort
CF=$(FC)

FFLAGS_F90    = -fp-model strict -xSSE2 -align rec32byte -assume byterecl -free -traceback #-convert big_endian
#FFLAGS_F90    = -free -traceback
FFLAGS_COM_N  = -I./ -I$(INCnemsio) -I$(INCcrtm) -O3
FFLAGS_N  = $(FFLAGS_F90) $(FFLAGS_COM_N)

CC            = gcc
CFLAGS_N      = -I. -DFortranByte=char -DFortranInt=int -DFortranLlong='long long'  -O2  -Dfunder

LD            = $(CF)
LIBS_N        = -L$(CORELIB) -lcrtm_v2.2.4 -lnemsio_v2.2.2 -lw3nco_v2.0.6_d -lsp_2.0.2g_d -lbacio_v2.0.2_4 -mkl
LDFLAGS_N     = $(FFLAGS_F90) $(FFLAGS_COM_N)
EXEpath       = ~/bin

# -----------------------
#  # Default compiling rules
# -----------------------
.SUFFIXES : .f90 .o

.f90.o  :
	@echo
	@echo '---> Compiling $<'
	$(CF) $(FFLAGS_N) -c $<

# ------------------------
#  # Call compiler and linker
# ------------------------
all : nemsio_2dat nemsio_getvar nemsio_diff nemsio_varinfo nemsio_header nemsio_inc2dat nemsio_vardump

nemsio_2dat: nemsio_2dat.o
	@echo
	@echo '=======compiling nemsio_2dat========'
	$(FC) -o $(EXEpath)/nemsio_2dat.x $(FFLAGS_N) nemsio_2dat.o $(LIBS_N)

nemsio_inc2dat: nemsio_inc2dat.o
	@echo
	@echo '=======compiling nemsio_inc2dat========'
	$(FC) -o $(EXEpath)/nemsio_inc2dat.x $(FFLAGS_N) nemsio_inc2dat.o $(LIBS_N)

nemsio_getvar: nemsio_getvar.o
	@echo
	@echo '=======compiling nemsio_getvar========'
	$(FC) -o $(EXEpath)/nemsio_getvar.x $(FFLAGS_N) nemsio_getvar.o $(LIBS_N)

nemsio_diff: nemsio_diff.o
	@echo
	@echo '=======compiling nemsio_diff========'
	$(FC) -o $(EXEpath)/nemsio_diff.x $(FFLAGS_N) nemsio_diff.o $(LIBS_N)

nemsio_varinfo: nemsio_varinfo.o
	@echo
	@echo '=======compiling nemsio_varinfo========'
	$(FC) -o $(EXEpath)/nemsio_varinfo.x $(FFLAGS_N) nemsio_varinfo.o $(LIBS_N)

nemsio_header: nemsio_header.o
	@echo
	@echo '=======compiling nemsio_getvar========'
	$(FC) -o $(EXEpath)/nemsio_header.x $(FFLAGS_N) nemsio_header.o $(LIBS_N)

nemsio_vardump: nemsio_vardump.o
	@echo
	@echo '=======compiling nemsio_vardump========'
	$(FC) -o $(EXEpath)/nemsio_vardump.x $(FFLAGS_N) nemsio_vardump.o $(LIBS_N)

nemsio_2Dint: nemsio_2Dint.o
	@echo
	@echo '=======compiling nemsio_2Dint========'
	$(FC) -o $(EXEpath)/nemsio_2Dint.x $(FFLAGS_N) nemsio_2Dint.o $(LIBS_N)

nemsio_crtmprofile: nemsio_crtmprofile.o
	@echo
	@echo '=======compiling nemsio_crtmprofile========'
	$(FC) -o $(EXEpath)/nemsio_crtmprofile.x $(FFLAGS_N) nemsio_crtmprofile.o $(LIBS_N)

clean:
	@echo
	@echo '==== CLEAN ==================================================='
	- rm -f *.x *.o *.mod *.MOD *.lst *.exe
