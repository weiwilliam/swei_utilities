module convert_nemsioatm2nc
  use netcdf
  use nemsio_module
  implicit none

  integer, parameter :: n_atm3 = 34
  integer, parameter :: n_atm2 = 2 
  character(len=10) :: atm_nc3(n_atm3)
  character(len=10) :: atm_nc2(n_atm2)
  character(len=10) :: atm_nems3(n_atm3)
  character(len=10) :: atm_nems2(n_atm2)
  character(len=40) :: atm_long3(n_atm3)
  character(len=40) :: atm_long2(n_atm2)
  character(len=10) :: atm_unit3(n_atm3)
  character(len=10) :: atm_unit2(n_atm2)
  data atm_nc3 / 'cld_amt   ', 'clwmr     ', 'delz      ', 'dpres     ',&
                 'dzdt      ', 'grle      ', 'icmr      ', 'o3mr      ',&
                 'rwmr      ', 'snmr      ', 'spfh      ', 'tmp       ',&
                 'ugrd      ', 'vgrd      ',&
                 'seas1     ', 'seas2     ', 'seas3     ', 'seas4     ',&
                 'seas5     ', 'dust1     ', 'dust2     ', 'dust3     ',&
                 'dust4     ', 'dust5     ', 'oc1       ', 'oc2       ',&
                 'bc1       ', 'bc2       ', 'msa       ', 'DMS       ',&
                 'sulf      ', 'so2       ', 'pp10      ', 'pp25      '/ 
  data atm_nc2 / 'hgtsfc    ', 'pressfc   ' / 
  data atm_nems3 / 'cld_amt   ', 'clwmr     ', 'delz      ', 'dpres     ',&
                   'dzdt      ', 'grle      ', 'icmr      ', 'o3mr      ',&
                   'rwmr      ', 'snmr      ', 'spfh      ', 'tmp       ',&
                   'ugrd      ', 'vgrd      ',& 
                   'seas1     ', 'seas2     ', 'seas3     ', 'seas4     ',&
                   'seas5     ', 'dust1     ', 'dust2     ', 'dust3     ',&
                   'dust4     ', 'dust5     ', 'oc1       ', 'oc2       ',&
                   'bc1       ', 'bc2       ', 'msa       ', 'DMS       ',&
                   'sulf      ', 'so2       ', 'pp10      ', 'pp25      '/ 
  data atm_nems2 / 'hgt       ', 'pres      ' / 
  
  
  data atm_long3 / 'cloud amount                           ',&
                   'cloud water mixing ratio               ',&
                   'height thickness                       ',&
                   'pressure thickness                     ',&
                   'vertical wind                          ',&
                   'graupel mixing ratio                   ',&
                   'cloud ice mixing ratio                 ',&
                   'ozone mixing ratio                     ',&
                   'rain mixing ratio                      ',&
                   'snow mixing ratio                      ',&
                   'specific humidity                      ',&
                   'temperature                            ',&
                   'zonal wind                             ',&
                   'meridional wind                        ',&
                   'sea salt bin 1                         ',&
                   'sea salt bin 2                         ',&
                   'sea salt bin 3                         ',&
                   'sea salt bin 4                         ',&
                   'sea salt bin 5                         ',&
                   'dust bin 1                             ',&
                   'dust bin 2                             ',&
                   'dust bin 3                             ',&
                   'dust bin 4                             ',&
                   'dust bin 5                             ',&
                   'organic carbon 1                       ',&
                   'organic carbon 2                       ',&
                   'black carbon 1                         ',&
                   'black carbon 2                         ',&
                   'methanesulphonic acid                  ',&
                   'dimethylsulphide                       ',&
                   'sulphate aerosol                       ',&
                   'sulphur dioxide                        ',&
                   'particular matter 10                   ',&
                   'particular matter 2.5                  '/

  data atm_long2 / 'surface geopotential height            ',&
                   'surface pressure                       ' /

  data atm_unit3 / '1         ', 'kg/kg     ', 'm         ', 'pa        ',&
                   'm/sec     ', 'kg/kg     ', 'kg/kg     ', 'kg/kg     ',&
                   'kg/kg     ', 'kg/kg     ', 'kg/kg     ', 'K         ',&
                   'm/sec     ', 'm/sec     ', &
                   'kg/kg     ', 'kg/kg     ', 'kg/kg     ', 'kg/kg     ',&
                   'kg/kg     ', 'kg/kg     ', 'kg/kg     ', 'kg/kg     ',&
                   'kg/kg     ', 'kg/kg     ', 'kg/kg     ', 'kg/kg     ',&
                   'kg/kg     ', 'kg/kg     ', 'kg/kg     ', 'kg/kg     ',&
                   'kg/kg     ', 'kg/kg     ', 'ug/m^3    ', 'ug/m^3    '/ 
  data atm_unit2 / 'gpm       ', 'pa        ' / 
                 

contains
  subroutine nemsatm2nc
    ! nemsatm2nc - loop through vars/levels/etc.
    !           read from nemsio and write to netCDF
    !           do compression if necessary?
    use vars_nemsioatm2nc, only: nemsfile, ncid, dimx, dimy, dimz, varids, nrecs,&
                              xdimid,ydimid,zdimid,zidimid,tdimid,&
                              nbits, deflate, outfile
    use init_nemsioatm2nc, only: check_nc
    implicit none
    character(10), allocatable, dimension(:) :: recname, reclevtyp
    integer, allocatable, dimension(:) :: reclev
    integer(nemsio_intkind) :: iret
    real(nemsio_realkind), allocatable, dimension(:) :: tmp1d
    real, allocatable, dimension(:,:) :: tmp2d, tmp2d2
    real(4) :: err1, err2
    integer :: ivar, irec, nclev, varid
    logical :: writevar

    ! get record info from NEMSIO file
    allocate(recname(nrecs), reclevtyp(nrecs), reclev(nrecs))
    allocate(tmp1d(dimx*dimy),tmp2d(dimx,dimy),tmp2d2(dimx,dimy))
    call nemsio_getfilehead(nemsfile,iret=iret,recname=recname,reclevtyp=reclevtyp,reclev=reclev)

    ! define all of these netCDF output vars
    call check_nc(nf90_redef(ncid))
    do ivar=1,n_atm3 
      writevar = .false.
      do irec=1,nrecs
        if (recname(irec) == atm_nems3(ivar)) then
           writevar = .true.
           exit
        end if
      end do 
      if (writevar) then
         if (deflate > 0) then ! compress
           call check_nc(nf90_def_var(ncid,atm_nc3(ivar),nf90_float,&
                        (/xdimid,ydimid,zdimid,tdimid/),varids(7+ivar),&
                        shuffle=.true.,deflate_level=deflate))
           call check_nc(nf90_put_att(ncid,varids(7+ivar),'max_abs_compression_error',0))
         else
           call check_nc(nf90_def_var(ncid,atm_nc3(ivar),nf90_float,(/xdimid,ydimid,zdimid,tdimid/),varids(7+ivar)))
         end if
         call check_nc(nf90_put_att(ncid,varids(7+ivar),'long_name',atm_long3(ivar)))
         call check_nc(nf90_put_att(ncid,varids(7+ivar),'units',atm_unit3(ivar)))
         call check_nc(nf90_put_att(ncid,varids(7+ivar),'missing_value',-1.0e10))
         call check_nc(nf90_put_att(ncid,varids(7+ivar),'_FillValue',-1.0e10))
         call check_nc(nf90_put_att(ncid,varids(7+ivar),'cell_methods','time: point'))
         call check_nc(nf90_put_att(ncid,varids(7+ivar),'output_file','atm'))
      end if
    end do
    do ivar=1,n_atm2 
      writevar = .false.
      do irec=1,nrecs
        if (recname(irec) == atm_nems2(ivar)) then
           writevar = .true.
           exit
        end if
      end do
      if (writevar) then
         if (deflate > 0) then ! compress
           call check_nc(nf90_def_var(ncid,atm_nc2(ivar),nf90_float,&
                         (/xdimid,ydimid,tdimid/),varids(7+n_atm3+ivar),&
                         shuffle=.true.,deflate_level=deflate))
           call check_nc(nf90_put_att(ncid,varids(7+n_atm3+ivar),'max_abs_compression_error',0))
         else
           call check_nc(nf90_def_var(ncid,atm_nc2(ivar),nf90_float,(/xdimid,ydimid,tdimid/),varids(7+n_atm3+ivar)))
         end if
         call check_nc(nf90_put_att(ncid,varids(7+n_atm3+ivar),'long_name',atm_long2(ivar)))
         call check_nc(nf90_put_att(ncid,varids(7+n_atm3+ivar),'units',atm_unit2(ivar)))
         call check_nc(nf90_put_att(ncid,varids(7+n_atm3+ivar),'missing_value',-1.0e10))
         call check_nc(nf90_put_att(ncid,varids(7+n_atm3+ivar),'_FillValue',-1.0e10))
         call check_nc(nf90_put_att(ncid,varids(7+n_atm3+ivar),'cell_methods','time: point'))
         call check_nc(nf90_put_att(ncid,varids(7+n_atm3+ivar),'output_file','atm'))
       end if
    end do

    call check_nc(nf90_enddef(ncid))
    ! loop through records, reshape, and write to netCDF
    do irec=1,nrecs
      write(*,*) 'Converting: ',recname(irec), reclevtyp(irec), reclev(irec)
      call nemsio_readrecvw34(nemsfile,trim(recname(irec)),trim(reclevtyp(irec)),&
                             lev=reclev(irec),data=tmp1d(:),iret= iret)
      tmp2d = reshape(tmp1d,(/dimx,dimy/))
      if (trim(reclevtyp(irec)) == 'sfc') then
        call check_nc(nf90_inq_varid(ncid, trim(recname(irec))//"sfc", varid))
        if (nbits > 0) then ! compress
          tmp2d2 = tmp2d
          call quantize2d(tmp2d2, tmp2d, nbits, err2)
          call check_nc(nf90_get_att(ncid, varid, 'max_abs_compression_error', err1))
          if (err2 > err1) then
            call check_nc(nf90_redef(ncid))
            call check_nc(nf90_put_att(ncid, varid, 'max_abs_compression_error',err2))
            call check_nc(nf90_enddef(ncid))
          end if
          call check_nc(nf90_put_var(ncid, varid, tmp2d))
        else
          call check_nc(nf90_put_var(ncid, varid, tmp2d))
        end if
      else
        call check_nc(nf90_inq_varid(ncid, trim(recname(irec)), varid))
        nclev = dimz+1-reclev(irec) 
        if (nbits > 0) then ! compress
          tmp2d2 = tmp2d
          call quantize2d(tmp2d2, tmp2d, nbits, err2)
          call check_nc(nf90_get_att(ncid, varid, 'max_abs_compression_error', err1))
          if (err2 > err1) then
            call check_nc(nf90_redef(ncid))
            call check_nc(nf90_put_att(ncid, varid, 'max_abs_compression_error',err2))
            call check_nc(nf90_enddef(ncid))
          end if
          call check_nc(nf90_put_var(ncid, varid, tmp2d, &
                        start=(/1,1,nclev,1/), count=(/dimx,dimy,1,1/)))
        else
          call check_nc(nf90_put_var(ncid, varid, tmp2d, &
                        start=(/1,1,nclev,1/), count=(/dimx,dimy,1,1/)))
        end if
      end if
    end do

    ! close the files
    call nemsio_close(nemsfile)
    call check_nc(nf90_close(ncid))

    ! write success message
    write(*,*) 'Success! - netCDF file written to: ', trim(outfile)
  end subroutine nemsatm2nc

  subroutine quantize2d(dataIn, dataOut, nbits,compress_err)
    ! borrowed from J. Whitaker's module_fv3gfs_ncio
    real(4), intent(in) :: dataIn(:,:)
    real(4), intent(out) :: dataOut(:,:)
    integer, intent(in) :: nbits
    real(4), intent(out) :: compress_err
    real(4) dataMin, dataMax, scale_fact, offset
    ! if nbits not between 1 and 31, don't do anything
    if (nbits <= 0 .or. nbits > 31) then
       dataOut = dataIn
       compress_err = 0.0
       return
    endif
    dataMax = maxval(dataIn); dataMin = minval(dataIn)
    ! convert data to 32 bit integers in range 0 to 2**nbits-1, then cast
    ! cast back to 32 bit floats (data is then quantized in steps
    ! proportional to 2**nbits so last 32-nbits in floating
    ! point representation should be zero for efficient zlib compression).
    scale_fact = (dataMax - dataMin) / (2**nbits-1); offset = dataMin
    dataOut = scale_fact*(nint((dataIn - offset) / scale_fact)) + offset
    compress_err = maxval(abs(dataIn-dataOut))
  end subroutine quantize2d

end module convert_nemsioatm2nc
