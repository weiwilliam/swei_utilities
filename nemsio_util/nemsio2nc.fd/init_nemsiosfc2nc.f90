module init_nemsiosfc2nc
  use netcdf
  use nemsio_module
  implicit none
  public :: nstexist
  logical :: nstexist
contains
  subroutine init_sfc
    ! init - read in input and output files
    !        get grid information from input NEMSIO file
    !        print diagnostic info
    !        create output file
    use vars_nemsiosfc2nc, only: infile, outfile, nemsfile, nstfile, nst_nemsf, ncid, lat, lon, &
                              idate, nfday, nfhour, nfminute, dimx, dimy, &
                              nst_idate, nst_nfday, nst_nfhour, nst_nfminute, nst_dimx, nst_dimy, &
                              xdimid, ydimid, zdimid, tdimid, varids,&
                              nrecs, nst_nrecs, nbits, deflate, n_soillayers, soil_layer
    implicit none

    integer(nemsio_intkind)         :: iret, ntrac
    integer                         :: k
    integer, dimension(6)           :: idate6
    character(len=nf90_max_name)    :: time_units
    real(nemsio_realkind),dimension(:,:,:),allocatable :: vcoord
    real, allocatable, dimension(:) :: ak, bk, pfull, phalf
    real(nemsio_realkind), allocatable, dimension(:,:) :: lats, lons
    character(len=10) :: nbits_str, deflate_str
    logical :: exists

    ! get infile and outfile from command line arguments
    call get_command_argument(1,infile)
    if (len_trim(infile) == 0) then
      write(*,*) 'Wrong usage!: nemsiosfc2nc sfcfile outfile <nstfile> <nbits> <deflate>'
      stop
    end if
    call get_command_argument(2,outfile)
    if (len_trim(outfile) == 0) then
      write(*,*) 'Wrong usage!: nemsiosfc2nc sfcfile outfile <nstfile> <nbits> <deflate>'
      stop
    end if
    call get_command_argument(3,nstfile)
    if (len_trim(nstfile) == 0) then
       nstexist=.false.
    else
       inquire(file=trim(nstfile), exist=exists)
       if (exists) then 
          nstexist=.true.
       else
          write(*,*) 'Input nstfile is not available, please check it'
          stop
       end if
    end if
    call get_command_argument(4,nbits_str)
    if (len_trim(nbits_str) == 0) then
      nbits = 0
    else
      read(nbits_str,*) nbits
    end if
    call get_command_argument(5,deflate_str)
    if (len_trim(deflate_str) == 0) then
      deflate = 1
    else
      read(deflate_str,*) deflate
    end if

    ! open NEMSIO file and get header info
    call nemsio_init(iret)
    write(*,*) 'Opening input NEMSIO file =',trim(infile) 
    call nemsio_open(nemsfile, infile, "read", iret=iret)
    if (iret /= 0) then
      write(*,*) 'Fatal error opening input NEMSIO file ',trim(infile),'iret=',iret
      stop
    end if
    ! need to get dimensions, number of variables, other metadata, etc.
    call nemsio_getfilehead(nemsfile,iret=iret,idate=idate,nfday=nfday,nfhour=nfhour, &
                            nfminute=nfminute,dimx=dimx,dimy=dimy,nrec=nrecs)
    if (iret /= 0) then
      write(*,*) 'Fatal error reading input NEMSIO file header ',trim(infile),'iret=',iret
      stop
    end if

    write(*,*) 'nx=',dimx,', ny=',dimy
    write(*,*) 'init=',idate(1:7),', fhour=',nfhour

    if (nstexist) then
       write(*,*) 'Opening input NST NEMSIO file =',trim(nstfile) 
       call nemsio_open(nst_nemsf, nstfile, "read", iret=iret)
       if (iret /= 0) then
         write(*,*) 'Fatal error opening input NST NEMSIO file ',trim(nstfile),'iret=',iret
         stop
       end if
       ! need to get dimensions, number of variables, other metadata, etc.
       call nemsio_getfilehead(nst_nemsf,iret=iret,idate=nst_idate,nfday=nst_nfday,nfhour=nst_nfhour, &
                               nfminute=nst_nfminute,dimx=nst_dimx,dimy=nst_dimy,nrec=nst_nrecs)
       if (iret /= 0) then
         write(*,*) 'Fatal error reading input NST NEMSIO file header ',trim(nstfile),'iret=',iret
         stop
       end if

       write(*,*) 'nst_nx=',nst_dimx,', nst_ny=',nst_dimy
       write(*,*) 'init=',nst_idate(1:7),', fhour=',nst_nfhour
       
       if ( nst_dimx /= dimx .or. nst_dimy /= dimy ) then
          write(*,*) 'Error: the dimension of nst and sfc file is different.'
          stop
       end if        
    end if

    if (nbits > 0) then
      write(*,*) 'Writing compressed netCDF file, nbits=',nbits,', deflate=',deflate
    else
      write(*,*) 'Writing uncompressed netCDF file'
    end if
    ! get lat/lon
    allocate(lat(dimx*dimy),lon(dimx*dimy))
    call nemsio_getfilehead(nemsfile,iret=iret,lat=lat,lon=lon)
    if (iret /= 0) then
      write(*,*) 'Fatal error reading input NEMSIO file lat/lon ',trim(infile),'iret=',iret
      stop
    end if
    allocate(lats(dimx,dimy),lons(dimx,dimy))
    ! reshape lat/lon
    lats = reshape(lat,(/dimx,dimy/))
    lons = reshape(lon,(/dimx,dimy/))


    ! get vcoord and ntrac
    !allocate(vcoord(dimz+1,3,2))
    !call nemsio_getfilehead(nemsfile,iret=iret,vcoord=vcoord, ntrac=ntrac)
    !allocate(ak(dimz+1),bk(dimz+1),pfull(dimz),phalf(dimz+1))
    !do k=1,dimz+1
    !  ak(dimz+2-k) = vcoord(k,1,1)
    !  bk(dimz+2-k) = vcoord(k,2,1)
    !end do
    !call get_eta_level(dimz, 100000., pfull, phalf, ak, bk, 0.01)
    !if (iret /= 0) then
    !  write(*,*) 'Fatal error reading input NEMSIO file vcoord ',trim(infile),'iret=',iret
    !  stop
    !end if
    

    ! initialize output netCDF file
    ! below is needed for large file support (operational GFS for example)
    !call check_nc(nf90_create(path=outfile,cmode=or(nf90_clobber,nf90_64bit_offset),ncid=ncid))
    call check_nc(nf90_create(trim(outfile), &
                 cmode=ior(ior(nf90_clobber,nf90_netcdf4),nf90_classic_model),ncid=ncid))

    ! dimensions
    call check_nc(nf90_def_dim(ncid,'grid_xt',dimx,xdimid))
    call check_nc(nf90_def_dim(ncid,'grid_yt',dimy,ydimid))
    call check_nc(nf90_def_dim(ncid,'soil_layers',n_soillayers,zdimid))
    call check_nc(nf90_def_dim(ncid,'time',nf90_unlimited,tdimid))

    !!! non-data variables
    ! grid_xt
    call check_nc(nf90_def_var(ncid,'grid_xt',nf90_double,xdimid,varids(1)))
    call check_nc(nf90_put_att(ncid,varids(1),'cartesian_axis','X'))
    call check_nc(nf90_put_att(ncid,varids(1),'long_name','T-cell longitude'))
    call check_nc(nf90_put_att(ncid,varids(1),'units','degrees_E'))
    ! lon
    call check_nc(nf90_def_var(ncid,'lon',nf90_double,(/xdimid,ydimid/),varids(2)))
    call check_nc(nf90_put_att(ncid,varids(2),'long_name','T-cell longitude'))
    call check_nc(nf90_put_att(ncid,varids(2),'units','degrees_E'))
    ! grid_yt
    call check_nc(nf90_def_var(ncid,'grid_yt',nf90_double,ydimid,varids(3)))
    call check_nc(nf90_put_att(ncid,varids(3),'cartesian_axis','Y'))
    call check_nc(nf90_put_att(ncid,varids(3),'long_name','T-cell latitude'))
    call check_nc(nf90_put_att(ncid,varids(3),'units','degrees_N'))
    ! lat
    call check_nc(nf90_def_var(ncid,'lat',nf90_double,(/xdimid,ydimid/),varids(4)))
    call check_nc(nf90_put_att(ncid,varids(4),'long_name','T-cell latitude'))
    call check_nc(nf90_put_att(ncid,varids(4),'units','degrees_N'))
   ! ! pfull
    call check_nc(nf90_def_var(ncid,'soil_layers',nf90_real,zdimid,varids(5)))
    call check_nc(nf90_put_att(ncid,varids(5),'cartesian_axis','Z'))
    call check_nc(nf90_put_att(ncid,varids(5),'long_name','soil layers'))
    call check_nc(nf90_put_att(ncid,varids(5),'units','n/a'))
    call check_nc(nf90_put_att(ncid,varids(5),'positive','down'))
    ! time information
    idate6(1:5)=idate(1:5)
    if (idate(7) == 0) then
       idate6(6)=0
    else 
       idate6(6)=int(idate(6)/idate(7))
    end if
    time_units = get_time_units_from_idate(idate6)
    call check_nc(nf90_def_var(ncid,'time',nf90_double,tdimid,varids(6))) 
    call check_nc(nf90_put_att(ncid,varids(6),'units',trim(time_units)))
    call check_nc(nf90_put_att(ncid,varids(6),'cartesian_axis','T'))
    call check_nc(nf90_put_att(ncid,varids(6),'calendar_type','JULIAN'))
    call check_nc(nf90_put_att(ncid,varids(6),'calendar','JULIAN'))
    ! global attributes
    call check_nc(nf90_put_att(ncid,nf90_global,'hydrostatic','non-hydrostatic'))
    !call check_nc(nf90_put_att(ncid,nf90_global,'ncnsto',ntrac))
    !call check_nc(nf90_put_att(ncid,nf90_global,'ak',ak))
    !call check_nc(nf90_put_att(ncid,nf90_global,'bk',bk))
    call check_nc(nf90_put_att(ncid,nf90_global,'source','FV3GFS'))
    call check_nc(nf90_put_att(ncid,nf90_global,'grid','gaussian'))
    call check_nc(nf90_put_att(ncid,nf90_global,'note','This file was converted from a NEMSIO file using nemsiosfc2nc'))
    ! end defintions for now
    call check_nc(nf90_enddef(ncid))
    ! write lat/lon/time/etc to file
    call check_nc(nf90_put_var(ncid,varids(1),lons(:,1)))
    call check_nc(nf90_put_var(ncid,varids(2),lons))
    call check_nc(nf90_put_var(ncid,varids(3),lats(1,:)))
    call check_nc(nf90_put_var(ncid,varids(4),lats))
    call check_nc(nf90_put_var(ncid,varids(5),soil_layer))
    call check_nc(nf90_put_var(ncid,varids(6),nfhour))
    !call check_nc(nf90_close(ncid))

  end subroutine init_sfc

  function get_time_units_from_idate(idate, time_measure) result(time_units)
      ! create time units attribute of form 'hours since YYYY-MM-DD HH:MM:SS'
      ! from integer array with year,month,day,hour,minute,second
      ! optional argument 'time_measure' can be used to change 'hours' to
      ! 'days', 'minutes', 'seconds' etc.
      ! NOTE this subroutine borrowed from J. Whitaker's module_fv3gfs_ncio
      character(len=*), intent(in), optional :: time_measure
      integer, intent(in) ::  idate(6)
      character(len=12) :: timechar
      character(len=nf90_max_name) :: time_units
      if (present(time_measure)) then
         timechar = trim(time_measure)
      else
         timechar = 'hours'
      endif
      write(time_units,101) idate
101   format(' since ',i4.4,'-',i2.2,'-',i2.2,' ',&
      i2.2,':',i2.2,':',i2.2)
      time_units = trim(adjustl(timechar))//time_units
  end function get_time_units_from_idate

  subroutine check_nc(status)
    integer, intent(in) :: status

    if(status /= nf90_noerr) then
      print *, 'netCDF error!:'
      print *, trim(nf90_strerror(status))
      stop "Stopped"
    end if
  end subroutine check_nc

 subroutine get_eta_level(npz, p_s, pf, ph, ak, bk, pscale)
  ! borrowed from FV3GFS
  integer, intent(in) :: npz
  real, intent(in)  :: p_s            !< unit: pascal
  real, intent(in)  :: ak(npz+1)
  real, intent(in)  :: bk(npz+1)
  real, intent(in), optional :: pscale
  real, intent(out) :: pf(npz)
  real, intent(out) :: ph(npz+1)
  integer k
  real, parameter :: kappa=287.05/1004.6

  ph(1) = ak(1)
  do k=2,npz+1
     ph(k) = ak(k) + bk(k)*p_s
  enddo

  if ( present(pscale) ) then
      do k=1,npz+1
         ph(k) = pscale*ph(k)
      enddo
  endif

  if( ak(1) > 1.E-8 ) then
     pf(1) = (ph(2) - ph(1)) / log(ph(2)/ph(1))
  else
     pf(1) = (ph(2) - ph(1)) * kappa/(kappa+1.)
  endif

  do k=2,npz
     pf(k) = (ph(k+1) - ph(k)) / log(ph(k+1)/ph(k))
  enddo

 end subroutine get_eta_level


end module init_nemsiosfc2nc
