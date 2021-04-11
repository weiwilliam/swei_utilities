! nemsioatm2nc
! uses nemsio and netcdf libraries to take input NEMS file and output
! netCDF file following GFSv16 file conventions
! cory.r.martin@noaa.gov
! 2019 Nov 19
program nemsiosfc2nc
  use init_nemsiosfc2nc
  use convert_nemsiosfc2nc
  implicit none

  call init_sfc
  call nemssfc2nc

end program nemsiosfc2nc
