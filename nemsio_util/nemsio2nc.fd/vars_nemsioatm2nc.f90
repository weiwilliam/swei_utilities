module vars_nemsioatm2nc
  use nemsio_module
  implicit none
  private
  public :: infile, outfile, nemsfile
  public :: ncid, xdimid, ydimid, zdimid, zidimid, tdimid, varids
  public :: lat, lon
  public :: idate, nfday, nfhour, nfminute, dimx, dimy, dimz, nrecs
  public :: nbits, deflate
  
  character(len=255) :: infile, outfile
  type(nemsio_gfile) :: nemsfile
  integer :: ncid, xdimid, ydimid, zdimid, zidimid, tdimid
  integer, dimension(50) :: varids
  real(nemsio_realkind),dimension(:),allocatable :: lat, lon
  integer(nemsio_intkind), dimension(7) :: idate
  integer(nemsio_intkind) :: nfday, nfhour, nfminute, dimx, dimy, dimz, nrecs
  integer :: nbits, deflate

end module vars_nemsioatm2nc
