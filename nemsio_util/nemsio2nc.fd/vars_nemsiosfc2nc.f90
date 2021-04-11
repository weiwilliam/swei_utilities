module vars_nemsiosfc2nc
  use nemsio_module
  implicit none
  private
  public :: infile, outfile, nemsfile, nstfile, nst_nemsf
  public :: ncid, xdimid, ydimid, zdimid, tdimid, varids
  public :: lat, lon
  public :: idate, nfday, nfhour, nfminute, dimx, dimy, nrecs
  public :: nst_idate, nst_nfday, nst_nfhour, nst_nfminute, nst_dimx, nst_dimy, nst_nrecs
  public :: nbits, deflate
  public :: n_soillayers, soil_layer
  
  character(len=255) :: infile, outfile, nstfile
  type(nemsio_gfile) :: nemsfile, nst_nemsf
  integer :: ncid, xdimid, ydimid, zdimid, tdimid
  integer, dimension(100) :: varids
  real(nemsio_realkind),dimension(:),allocatable :: lat, lon
  integer(nemsio_intkind), dimension(7) :: idate, nst_idate
  integer(nemsio_intkind) :: nfday, nfhour, nfminute, dimx, dimy, nrecs
  integer(nemsio_intkind) :: nst_nfday, nst_nfhour, nst_nfminute, nst_dimx, nst_dimy, nst_nrecs
  integer :: nbits, deflate
  integer, parameter :: n_soillayers = 4
  integer, dimension(n_soillayers) :: soil_layer
  data soil_layer /1, 2, 3, 4/

end module vars_nemsiosfc2nc
