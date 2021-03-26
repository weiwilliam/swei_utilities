program main
   use module_fv3gfs_ncio !, only: Dataset, Variable, Dimension, &
                          !       open_dataset, create_dataset, &
                          !       close_dataset, &
                          !       get_ndim, get_dim, get_idate_from_time_units, &
                          !       write_vardata, read_vardata
   use vars_m2tofv3chem, only: infile, outfile, ak, bk, m2ptop, fv3levb 
   implicit none
   integer,dimension(6):: idate
   integer,dimension(4):: odate
   type(Dataset) :: innc, tmpnc, outnc
   type(Dimension) :: ncdim

   integer :: i,j,k,kk,v,ii
   integer :: lonb, latb, levb
   integer :: lonzeroidx
   real, allocatable, dimension(:,:) :: psfc
   real, allocatable, dimension(:) :: rwork1d, rlons
   real, allocatable, dimension(:,:) :: rwork2d
   real, allocatable, dimension(:,:,:) :: rwork3d,rwork3d_in, rwork3d_out
   real, allocatable, dimension(:,:,:) :: m2prsi, m2prsl
   real, allocatable, dimension(:,:,:) :: fv3l64_prsi, fv3l64_prsl
   integer, allocatable, dimension(:,:,:) :: cup_idx, clo_idx
   real, allocatable, dimension(:,:,:) :: cup, clo
   integer :: ndim, nvar
   character(len=256) :: varname 
   logical :: coordvar

   call get_command_argument(1,infile)
   if (len_trim(infile) == 0) then
      write(*,*) 'Wrong usage!: test infile outfile'
      stop
   end if

   call get_command_argument(2,outfile)
   if (len_trim(outfile) == 0) then
      write(*,*) 'Wrong usage!: test infile outfile'
      stop
   end if

   innc = open_dataset(infile)
   
   ncdim  = get_dim(innc,'lon'); lonb = ncdim%len
   ncdim  = get_dim(innc,'lat'); latb = ncdim%len
   ncdim  = get_dim(innc,'lev'); levb = ncdim%len
   write(6,*) 'dimension (lon,lat,lev)=', lonb, latb, levb

   allocate(rlons(lonb))
   call read_vardata(innc,'lon',rlons)
   lonzeroidx=99999
   do i=1,lonb
     if (rlons(i) .lt. 0. .and. abs(rlons(i)) .gt. 1e-9) then
       rlons(i)=rlons(i)+360.
     else if (abs(rlons(i)) .lt. 1e-9) then
       lonzeroidx=min(i,lonzeroidx)
       rlons(lonzeroidx)=0.
     end if
   end do
   !write(6,*) 'zero longitude at ',lonzeroidx
   !write(6,*) rlons
      
   allocate(rwork2d(lonb,latb))
   allocate(rwork3d(lonb,latb,1))

   rwork3d=0.

   idate= get_idate_from_time_units(innc)
   write(6,*) idate
   
   !write(6,*) innc%variables%ndims
   !write(6,*) innc%variables%varid

   allocate(psfc(lonb,latb),m2prsi(lonb,latb,levb+1),m2prsl(lonb,latb,levb))

   psfc=m2ptop
   m2prsi(:,:,1)=m2ptop
   do k=1,levb
      call read_vardata(innc,'DELP',rwork3d,nslice=k, slicedim=3)
      psfc=psfc+rwork3d(:,:,1)
      m2prsi(:,:,k+1)=psfc
      m2prsl(:,:,k)=exp((log(m2prsi(:,:,k))+log(m2prsi(:,:,k+1)))/2.)
   end do
   
   !write(6,*) psfc(1:10,1)
   !write(6,*) m2prsi(100,100,:)
   !write(6,*) m2prsl(100,100,:)

   allocate(fv3l64_prsl(lonb,latb,fv3levb),fv3l64_prsi(lonb,latb,fv3levb+1))
   do k=1,fv3levb+1
      fv3l64_prsi(:,:,k)=ak(k)+bk(k)*psfc(:,:)
   end do
   do k=1,fv3levb
      fv3l64_prsl(:,:,k)=exp((log(fv3l64_prsi(:,:,k))+log(fv3l64_prsi(:,:,k+1)))/2.)
   end do

   !write(6,*) fv3l64_prsi(100,100,:)
   !write(6,*) fv3l64_prsl(100,100,:)

! calculate the interpolation level coefficients
   allocate(cup_idx(lonb,latb,fv3levb),clo_idx(lonb,latb,fv3levb))
   allocate(    cup(lonb,latb,fv3levb),    clo(lonb,latb,fv3levb))
   do k=1,fv3levb
   do kk=1,levb-1
     do j=1,latb
       do i=1,lonb
          if ( fv3l64_prsl(i,j,k) .le. m2prsl(i,j,kk+1) &
               .and. fv3l64_prsl(i,j,k) .ge. m2prsl(i,j,kk) ) then
             cup_idx(i,j,k)=kk
             clo_idx(i,j,k)=kk+1
             cup(i,j,k)=(log(m2prsl(i,j,clo_idx(i,j,k)))-log(fv3l64_prsl(i,j,k))) / &
                        (log(m2prsl(i,j,clo_idx(i,j,k)))-log(m2prsl(i,j,cup_idx(i,j,k))))
             clo(i,j,k)=        (log(fv3l64_prsl(i,j,k))-log(m2prsl(i,j,cup_idx(i,j,k)))) / &
                        (log(m2prsl(i,j,clo_idx(i,j,k)))-log(m2prsl(i,j,cup_idx(i,j,k))))
          else if ( fv3l64_prsl(i,j,k) .lt. m2prsl(i,j,1) ) then
             cup_idx(i,j,k)=1; clo_idx(i,j,k)=2
             cup(i,j,k)=1.; clo(i,j,k)=0.
          else if ( fv3l64_prsl(i,j,k) .gt. m2prsl(i,j,levb) ) then
             cup_idx(i,j,k)=levb-1; clo_idx(i,j,k)=levb
             cup(i,j,k)=0.; clo(i,j,k)=1.
          end if
       end do
     end do
   end do
   end do

! loop over all variables to reset the level dimensions
  tmpnc = innc
  ndim  = get_ndim(tmpnc,'lev')
    tmpnc%dimensions(ndim)%len=fv3levb
  nvar  = get_nvar(tmpnc,'lev')
    tmpnc%variables(nvar)%chunksizes=fv3levb
    do v=1,tmpnc%nvars
       varname=tmpnc%variables(v)%name
       coordvar = .false.
       if (trim(varname) == 'lats' .or. trim(varname) == 'lons' .or. &
           trim(varname) == 'lat'  .or. trim(varname) == 'lon') then
           coordvar = .true.
       else
          do ndim=1,tmpnc%ndims
             if (trim(varname) == trim(tmpnc%dimensions(ndim)%name)) then
                coordvar = .true.
             endif
          enddo
       endif
       if (trim(tmpnc%variables(v)%name) == 'lev') then
          tmpnc%variables(v)%dimlens(1)=fv3levb
       end if
       if (.not. coordvar) then
          do ndim=1,tmpnc%variables(v)%ndims
             if (trim(tmpnc%variables(v)%dimnames(ndim))=='lev') then
                tmpnc%variables(v)%dimlens(ndim)=fv3levb
             end if
          end do
       end if
    end do

!  do v=1,tmpnc%nvars 
!     write(6,*) trim(tmpnc%variables(v)%name), &
!                tmpnc%variables(v)%chunksizes, &
!                tmpnc%variables(v)%dimlens(:)
!  end do
!  do i=1,tmpnc%ndims
!     write(6,*) trim(tmpnc%dimensions(i)%name), tmpnc%dimensions(i)%isunlimited, tmpnc%dimensions(i)%len
!  end do

! create output dataset
  outnc = create_dataset(outfile,tmpnc)
  write(6,*) 'create outnc'

  allocate(rwork3d_in(lonb,latb,levb))
  allocate(rwork3d_out(lonb,latb,fv3levb))

  do v = 1, outnc%nvars
    varname=outnc%variables(v)%name
    coordvar = .false.
    if (trim(varname) == 'lats' .or. trim(varname) == 'lons' .or. &
        trim(varname) == 'lat'  .or. trim(varname) == 'lon') then
       coordvar = .true.
    else
       do ndim=1,outnc%ndims
          if (trim(varname) == trim(outnc%dimensions(ndim)%name)) then
             coordvar = .true.
          endif
       enddo
    endif
    rwork3d_in=0. ; rwork3d_out=0.
    write(6,*) trim(varname)
    if (outnc%variables(v)%ndims == 4 .and. trim(varname) /= 'DELP') then
    !if (trim(varname)=='abcd') then
       call read_vardata(innc,trim(varname),rwork3d_in,nslice=1,slicedim=4)
       write(6,*) 'Get input data'
       do k=1,fv3levb
         do j=1,latb
           do i=1,lonb
              if (i.lt.lonzeroidx) then
                 ii=i+lonb-(lonzeroidx-1)
              else if (i.ge.lonzeroidx) then
                 ii=i-lonzeroidx+1
              end if
              rwork3d_out(ii,j,k)=rwork3d_in(i,j,cup_idx(i,j,k))*cup(i,j,k)+ &
                                  rwork3d_in(i,j,clo_idx(i,j,k))*clo(i,j,k)
           end do
         end do
       end do
       write(6,*) 'Intepolate input to output vertical coordinate and flip longitude to starting from zero'
       call write_vardata(outnc,trim(varname),rwork3d_out,nslice=1,slicedim=4)
    else if (trim(varname) == 'lev') then
       allocate(rwork1d(fv3levb))
       do k=1,fv3levb
         rwork1d(k)=k
       end do
       call write_vardata(outnc,trim(varname),rwork1d)
       deallocate(rwork1d)
    else if (trim(varname) == 'lon') then
       allocate(rwork1d(lonb))
       rwork1d=0.
       do i=1,lonb
         if (i.lt.lonzeroidx) then
           rwork1d(i+lonb-lonzeroidx+1)=rlons(i)
         else if (i.ge.lonzeroidx) then
           rwork1d(i-lonzeroidx+1)=rlons(i)
         end if
       end do
       call write_vardata(outnc,trim(varname),rwork1d)
       deallocate(rwork1d)
    else if (.not. coordvar) then
       call write_vardata(outnc,trim(varname),rwork3d_out,nslice=1,slicedim=4)
       !write(6,*) outnc%variables(v)%hasunlim
       !write(6,*) outnc%variables(v)%dimlens
    end if
  end do
  
! close datasets
   deallocate(rlons)
   call close_dataset(innc)
   call close_dataset(outnc)
      
end
