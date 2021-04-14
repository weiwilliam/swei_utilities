FC=ifort
NETCDF_LIB=-L$(NETCDF)/lib -lnetcdff -L$(NETCDF)/lib -Wl,-rpath -Wl,$(NETCDF)/lib -lnetcdf -lnetcdf
NETCDF_INC=-I$(NETCDF)/include
FCFLAGS=-O3 -traceback
LDFLAGS=$(NETCDF_LIB) $(NEMSIO_LIB) $(BACIO_LIB4) $(W3NCO_LIB4) 
INCFLAGS=$(NETCDF_INC) -I$(NEMSIO_INC)

objects = init_nemsioatm2nc.o vars_nemsioatm2nc.o convert_nemsioatm2nc.o mainatm.o
sfcobjects = init_nemsiosfc2nc.o vars_nemsiosfc2nc.o convert_nemsiosfc2nc.o mainsfc.o

all: nemsioatm2nc nemsiosfc2nc

nemsioatm2nc: $(objects)
	$(FC) $(FCFLAGS) -o nemsioatm2nc $(objects) $(LDFLAGS) $(INCFLAGS)

mainatm.o:  init_nemsioatm2nc.o mainatm.f90
	$(FC) $(FCFLAGS) $(LDFLAGS) $(INCFLAGS) -c mainatm.f90
init_nemsioatm2nc.o:  vars_nemsioatm2nc.o init_nemsioatm2nc.f90
	$(FC) $(FCFLAGS) $(LDFLAGS) $(INCFLAGS) -c init_nemsioatm2nc.f90
convert_nemsioatm2nc.o:  vars_nemsioatm2nc.o init_nemsioatm2nc.o convert_nemsioatm2nc.f90
	$(FC) $(FCFLAGS) $(LDFLAGS) $(INCFLAGS) -c convert_nemsioatm2nc.f90
vars_nemsioatm2nc.o:  vars_nemsioatm2nc.f90
	$(FC) $(FCFLAGS) $(LDFLAGS) $(INCFLAGS) -c vars_nemsioatm2nc.f90

nemsiosfc2nc: $(sfcobjects)
	$(FC) $(FCFLAGS) -o nemsiosfc2nc $(sfcobjects) $(LDFLAGS) $(INCFLAGS)
mainsfc.o:  init_nemsiosfc2nc.o mainsfc.f90
	$(FC) $(FCFLAGS) $(LDFLAGS) $(INCFLAGS) -c mainsfc.f90
init_nemsiosfc2nc.o:  vars_nemsiosfc2nc.o init_nemsiosfc2nc.f90
	$(FC) $(FCFLAGS) $(LDFLAGS) $(INCFLAGS) -c init_nemsiosfc2nc.f90
convert_nemsiosfc2nc.o:  vars_nemsiosfc2nc.o init_nemsiosfc2nc.o convert_nemsiosfc2nc.f90
	$(FC) $(FCFLAGS) $(LDFLAGS) $(INCFLAGS) -c convert_nemsiosfc2nc.f90
vars_nemsiosfc2nc.o:  vars_nemsiosfc2nc.f90
	$(FC) $(FCFLAGS) $(LDFLAGS) $(INCFLAGS) -c vars_nemsiosfc2nc.f90

clean:
	rm nemsioatm2nc nemsiosfc2nc *.mod *.o 
