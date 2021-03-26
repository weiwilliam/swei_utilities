FC=mpiifort
NETCDF_LIB=-L$(NETCDF)/lib -lnetcdff -lnetcdf
NETCDF_INC=-I$(NETCDF)/include
FV3GFSNCIO_INC=./fv3gfs_ncio
FV3GFSNCIO_LIB=./fv3gfs_ncio/module_fv3gfs_ncio.o
FCFLAGS=-O3 -traceback #-check
LDFLAGS=$(FV3GFSNCIO_LIB) $(NETCDF_LIB) 
INCFLAGS=$(NETCDF_INC) -I$(FV3GFSNCIO_INC)

#objects = test.o init_nemsioatm2nc.o vars_nemsioatm2nc.o convert_nemsioatm2nc.o mainatm.o
objects = vars_m2tofv3chem.o

m2tofv3chem.x: m2tofv3chem.f90 vars_m2tofv3chem.o
	$(FC) $(FCFLAGS) -o m2tofv3chem.x m2tofv3chem.f90 $(objects) $(LDFLAGS) $(INCFLAGS)

vars_m2tofv3chem.o:  vars_m2tofv3chem.f90
	$(FC) $(FCFLAGS) $(LDFLAGS) $(INCFLAGS) -c vars_m2tofv3chem.f90

clean:
	rm m2tofv3chem.x *.mod *.o 
