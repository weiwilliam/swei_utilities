FC=ifort
NETCDF_LIB=-L$(NETCDF)/lib -lnetcdff -L$(NETCDF)/lib -Wl,-rpath -Wl,$(NETCDF)/lib -lnetcdf -lnetcdf
NETCDF_INC=-I$(NETCDF)/include
FCFLAGS=-O3
LDFLAGS=$(NETCDF_LIB) $(NEMSIO_LIB) $(BACIO_LIB4) $(W3NCO_LIB4) 
INCFLAGS=$(NETCDF_INC) -I$(NEMSIO_INC)

objects = init_nemsioatm2nc.o vars_nemsioatm2nc.o convert_nemsioatm2nc.o mainatm.o

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

clean:
	rm nemsioatm2nc *.mod *.o 
