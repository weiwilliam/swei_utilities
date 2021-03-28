! nemsioatm2nc
! uses nemsio and netcdf libraries to take input NEMS file and output
! netCDF file following GFSv16 file conventions
! cory.r.martin@noaa.gov
! 2019 Nov 19
program nemsioatm2nc
  use init_nemsioatm2nc
  use convert_nemsioatm2nc
  implicit none

  call init
  call nemsatm2nc

end program nemsioatm2nc
