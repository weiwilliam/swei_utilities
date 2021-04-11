module convert_nemsiosfc2nc
  use netcdf
  use nemsio_module
  use vars_nemsiosfc2nc, only: n_soillayers
  implicit none

  integer, parameter :: n_sfc3 = 3
  integer, parameter :: n_sfc2 = 32 
  integer, parameter :: n_nst2 = 19 
  character(len=10) :: sfc_nc3(n_sfc3)
  character(len=10) :: sfc_nc2(n_sfc2)
  character(len=10) :: sfc_nems3(n_sfc3)
  character(len=10) :: sfc_nems2(n_sfc2)
  character(len=40) :: sfc_long3(n_sfc3)
  character(len=40) :: sfc_long2(n_sfc2)
  character(len=10) :: sfc_unit3(n_sfc3)
  character(len=10) :: sfc_unit2(n_sfc2)
  character(len=10) :: nst_nc2(n_nst2)
  character(len=10) :: nst_nems2(n_nst2)
  character(len=40) :: nst_long2(n_nst2)
  character(len=10) :: nst_unit2(n_nst2)
  data sfc_nc3 / 'slc       ', 'smc       ', 'stc       ' /
  data sfc_nc2 / 'alnsf     ', 'alnwf     ', 'alvsf     ', 'alvwf     ',&
                 'cnwat     ', 'crain     ', 'f10m      ', 'facsf     ',&
                 'facwf     ', 'ffhh      ', 'ffmm      ', 'fricv     ',&
                 'icec      ', 'icetk     ', 'land_sfc  ', 'orog      ',&
                 'salbd     ', 'sfcr      ', 'shdmax    ', 'shdmin    ',&
                 'sltyp     ', 'snod      ', 'sotyp     ', 'spfh      ',&
                 'tg3       ', 'tisfc     ', 'tmp2m     ', 'tmpsfc    ',&
                 'tprcp     ', 'veg       ', 'vtype     ', 'weasd     ' /
  data nst_nc2 / 'c0        ', 'cd        ', 'dconv     ', 'dtcool    ',&
                 'ifd       ', 'land_nst  ', 'qrain     ', 'tref      ',&
                 'w0        ', 'wd        ', 'xs        ', 'xt        ',&
                 'xtts      ', 'xu        ', 'xv        ', 'xz        ',&
                 'xzts      ', 'zc        ', 'zm        ' /

  data sfc_nems3 / 'slc       ', 'smc       ', 'stc       ' /
  data sfc_nems2 / 'alnsf     ', 'alnwf     ', 'alvsf     ', 'alvwf     ',&
                   'cnwat     ', 'crain     ', 'f10m      ', 'facsf     ',&
                   'facwf     ', 'ffhh      ', 'ffmm      ', 'fricv     ',&
                   'icec      ', 'icetk     ', 'land      ', 'orog      ',&
                   'salbd     ', 'sfcr      ', 'shdmax    ', 'shdmin    ',&
                   'sltyp     ', 'snod      ', 'sotyp     ', 'spfh      ',&
                   'tg3       ', 'tisfc     ', 'tmp       ', 'tmp       ',&
                   'tprcp     ', 'veg       ', 'vtype     ', 'weasd     ' /

  data nst_nems2 / 'c0        ', 'cd        ', 'dconv     ', 'dtcool    ',&
                   'ifd       ', 'land      ', 'qrain     ', 'tref      ',&
                   'w0        ', 'wd        ', 'xs        ', 'xt        ',&
                   'xtts      ', 'xu        ', 'xv        ', 'xz        ',&
                   'xzts      ', 'zc        ', 'zm        ' /
  
  data sfc_long3 / 'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ' /
  data sfc_long2 / 'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ' /
  data nst_long2 / 'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ',&
                   'n/a                                    ' /
  data sfc_unit3 / 'n/a       ', 'n/a       ', 'n/a       ' /
  data sfc_unit2 / 'n/a       ', 'n/a       ', 'n/a       ', 'n/a       ',&
                   'n/a       ', 'n/a       ', 'n/a       ', 'n/a       ',&
                   'n/a       ', 'n/a       ', 'n/a       ', 'n/a       ',&
                   'n/a       ', 'n/a       ', 'n/a       ', 'n/a       ',&
                   'n/a       ', 'n/a       ', 'n/a       ', 'n/a       ',&
                   'n/a       ', 'n/a       ', 'n/a       ', 'n/a       ',&
                   'n/a       ', 'n/a       ', 'n/a       ', 'n/a       ',&
                   'n/a       ', 'n/a       ', 'n/a       ', 'n/a       ' /
  data nst_unit2 / 'n/a       ', 'n/a       ', 'n/a       ', 'n/a       ',&
                   'n/a       ', 'n/a       ', 'n/a       ', 'n/a       ',&
                   'n/a       ', 'n/a       ', 'n/a       ', 'n/a       ',&
                   'n/a       ', 'n/a       ', 'n/a       ', 'n/a       ',&
                   'n/a       ', 'n/a       ', 'n/a       ' /
                 

contains
  subroutine nemssfc2nc
    ! nemssfc2nc - loop through vars/levels/etc.
    !           read from nemsio and write to netCDF
    !           do compression if necessary?
    use vars_nemsiosfc2nc, only: nemsfile, nst_nemsf, ncid, dimx, dimy, varids, nrecs, nst_nrecs,&
                              xdimid,ydimid,zdimid,tdimid,&
                              nbits, deflate, outfile
    use init_nemsiosfc2nc, only: check_nc, nstexist
    implicit none
    character(10), allocatable, dimension(:) :: recname, reclevtyp
    integer, allocatable, dimension(:) :: reclev
    character(10), allocatable, dimension(:) :: nst_recname, nst_reclevtyp
    integer, allocatable, dimension(:) :: nst_reclev
    integer(nemsio_intkind) :: iret
    real(nemsio_realkind), allocatable, dimension(:) :: tmp1d
    real, allocatable, dimension(:,:) :: tmp2d, tmp2d2
    real(4) :: err1, err2
    integer :: ivar, irec, nclev, varid, tmp_irec
    logical :: writevar

    ! get record info from NEMSIO file
    allocate(recname(nrecs), reclevtyp(nrecs), reclev(nrecs))
    allocate(tmp1d(dimx*dimy),tmp2d(dimx,dimy),tmp2d2(dimx,dimy))
    call nemsio_getfilehead(nemsfile,iret=iret,recname=recname,reclevtyp=reclevtyp,reclev=reclev)

    ! define all of these netCDF output vars
    call check_nc(nf90_redef(ncid))
    do ivar=1,n_sfc3 
      writevar = .false.
      do irec=1,nrecs
        if (recname(irec) == sfc_nems3(ivar)) then
           writevar = .true.
           exit
        end if
      end do 
      if (writevar) then
         if (deflate > 0) then ! compress
           call check_nc(nf90_def_var(ncid,sfc_nc3(ivar),nf90_float,&
                        (/xdimid,ydimid,zdimid,tdimid/),varids(6+ivar),&
                        shuffle=.true.,deflate_level=deflate))
           call check_nc(nf90_put_att(ncid,varids(6+ivar),'max_abs_compression_error',0))
         else
           call check_nc(nf90_def_var(ncid,sfc_nc3(ivar),nf90_float,(/xdimid,ydimid,zdimid,tdimid/),varids(6+ivar)))
         end if
         call check_nc(nf90_put_att(ncid,varids(6+ivar),'long_name',sfc_long3(ivar)))
         call check_nc(nf90_put_att(ncid,varids(6+ivar),'units',sfc_unit3(ivar)))
         call check_nc(nf90_put_att(ncid,varids(6+ivar),'missing_value',-1.0e10))
         call check_nc(nf90_put_att(ncid,varids(6+ivar),'_FillValue',-1.0e10))
         call check_nc(nf90_put_att(ncid,varids(6+ivar),'cell_methods','time: point'))
         call check_nc(nf90_put_att(ncid,varids(6+ivar),'output_file','sfc'))
      end if
    end do
    tmp_irec=0
    do ivar=1,n_sfc2 
      writevar = .false.
      do irec=1,nrecs
        if (recname(irec) == sfc_nems2(ivar) .and. irec > tmp_irec) then
           writevar = .true.
           tmp_irec = irec
           exit
        end if
      end do
      if (writevar) then
         if (deflate > 0) then ! compress
           call check_nc(nf90_def_var(ncid,sfc_nc2(ivar),nf90_float,&
                         (/xdimid,ydimid,tdimid/),varids(6+n_sfc3+ivar),&
                         shuffle=.true.,deflate_level=deflate))
           call check_nc(nf90_put_att(ncid,varids(6+n_sfc3+ivar),'max_abs_compression_error',0))
         else
           call check_nc(nf90_def_var(ncid,sfc_nc2(ivar),nf90_float,(/xdimid,ydimid,tdimid/),varids(6+n_sfc3+ivar)))
         end if
         call check_nc(nf90_put_att(ncid,varids(6+n_sfc3+ivar),'long_name',sfc_long2(ivar)))
         call check_nc(nf90_put_att(ncid,varids(6+n_sfc3+ivar),'units',sfc_unit2(ivar)))
         call check_nc(nf90_put_att(ncid,varids(6+n_sfc3+ivar),'missing_value',-1.0e10))
         call check_nc(nf90_put_att(ncid,varids(6+n_sfc3+ivar),'_FillValue',-1.0e10))
         call check_nc(nf90_put_att(ncid,varids(6+n_sfc3+ivar),'cell_methods','time: point'))
         call check_nc(nf90_put_att(ncid,varids(6+n_sfc3+ivar),'output_file','sfc'))
       end if
    end do
    if ( nstexist ) then
       allocate(nst_recname(nst_nrecs), nst_reclevtyp(nst_nrecs), nst_reclev(nst_nrecs))
       call nemsio_getfilehead(nst_nemsf,iret=iret,recname=nst_recname,reclevtyp=nst_reclevtyp,reclev=nst_reclev)
       do ivar=1,n_nst2 
         writevar = .false.
         do irec=1,nst_nrecs
           if (nst_recname(irec) == nst_nems2(ivar)) then
              writevar = .true.
              exit
           end if
         end do
         if (writevar) then
            if (deflate > 0) then ! compress
              call check_nc(nf90_def_var(ncid,nst_nc2(ivar),nf90_float,&
                            (/xdimid,ydimid,tdimid/),varids(6+n_sfc3+n_sfc2+ivar),&
                            shuffle=.true.,deflate_level=deflate))
              call check_nc(nf90_put_att(ncid,varids(6+n_sfc3+n_sfc2+ivar),'max_abs_compression_error',0))
            else
              call check_nc(nf90_def_var(ncid,nst_nc2(ivar),nf90_float,(/xdimid,ydimid,tdimid/),varids(6+n_sfc3+n_sfc2+ivar)))
            end if
            call check_nc(nf90_put_att(ncid,varids(6+n_sfc3+n_sfc2+ivar),'long_name',nst_long2(ivar)))
            call check_nc(nf90_put_att(ncid,varids(6+n_sfc3+n_sfc2+ivar),'units',nst_unit2(ivar)))
            call check_nc(nf90_put_att(ncid,varids(6+n_sfc3+n_sfc2+ivar),'missing_value',-1.0e10))
            call check_nc(nf90_put_att(ncid,varids(6+n_sfc3+n_sfc2+ivar),'_FillValue',-1.0e10))
            call check_nc(nf90_put_att(ncid,varids(6+n_sfc3+n_sfc2+ivar),'cell_methods','time: point'))
            call check_nc(nf90_put_att(ncid,varids(6+n_sfc3+n_sfc2+ivar),'output_file','sfc'))
          end if
       end do
    end if

    call check_nc(nf90_enddef(ncid))
    ! loop through records, reshape, and write to netCDF
    do irec=1,nrecs
      write(*,*) 'Converting: ',recname(irec), reclevtyp(irec), reclev(irec)
      call nemsio_readrecvw34(nemsfile,trim(recname(irec)),trim(reclevtyp(irec)),&
                             lev=reclev(irec),data=tmp1d(:),iret= iret)
      tmp2d = reshape(tmp1d,(/dimx,dimy/))
      if (trim(reclevtyp(irec)) /= 'soil layer') then
        if ( trim(recname(irec)) == 'land' ) then
           call check_nc(nf90_inq_varid(ncid, 'land_sfc', varid))
        else if ( trim(recname(irec)) == 'tmp' .and. trim(reclevtyp(irec)) == '2 m above' ) then
           call check_nc(nf90_inq_varid(ncid, 'tmp2m', varid))
        else if ( trim(recname(irec)) == 'tmp' .and. trim(reclevtyp(irec)) == 'sfc' ) then
           call check_nc(nf90_inq_varid(ncid, 'tmpsfc', varid))
        else
           call check_nc(nf90_inq_varid(ncid, trim(recname(irec)), varid))
        end if
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
        nclev = n_soillayers+1-reclev(irec) 
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
    if (nstexist) then
       do irec=1,nst_nrecs
         write(*,*) 'Converting: ',nst_recname(irec), nst_reclevtyp(irec), nst_reclev(irec)
         call nemsio_readrecvw34(nst_nemsf,trim(nst_recname(irec)),trim(nst_reclevtyp(irec)),&
                                lev=nst_reclev(irec),data=tmp1d(:),iret= iret)
         tmp2d = reshape(tmp1d,(/dimx,dimy/))
         if (trim(nst_reclevtyp(irec)) == 'sfc') then
            if ( trim(nst_recname(irec)) == 'land' ) then
               call check_nc(nf90_inq_varid(ncid, 'land_nst', varid))
            else
               call check_nc(nf90_inq_varid(ncid, trim(nst_recname(irec)), varid))
            end if
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
         end if
       end do
    end if
    ! close the files
    call nemsio_close(nemsfile)
    call nemsio_close(nst_nemsf)
    call check_nc(nf90_close(ncid))

    ! write success message
    write(*,*) 'Success! - netCDF file written to: ', trim(outfile)
  end subroutine nemssfc2nc

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

end module convert_nemsiosfc2nc
