FC=mpiifort
NETCDF_LIB=-L$(NETCDF)/lib -lnetcdff -lnetcdf
NETCDF_INC=-I$(NETCDF)/include
FCFLAGS=-O3 -traceback -check
LDFLAGS=$(NETCDF_LIB) 
INCFLAGS=$(NETCDF_INC) 

module_fv3gfs_ncio.o:
	$(FC) $(FCFLAGS) $(LDFLAGS) $(INCFLAGS) -c module_fv3gfs_ncio.f90

clean:
	rm *.mod *.o 
