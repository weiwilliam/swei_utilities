program testnemsio

   USE nemsio_module, ONLY: nemsio_init,nemsio_open,nemsio_close, &
                  nemsio_gfile,nemsio_getfilehead,nemsio_readrecv, &
                  nemsio_writerecv
   USE constant, ONLY: 
 
   implicit none
   real(8), parameter :: rd=2.8705e+2, cp=1.0046e+3
   character(len=256) :: file1,tlat,tlon,aer
     real(8) :: intlat,intlon
   logical :: laerosol
   
   integer :: k, iret, ij, i, j
   integer :: nfhour, nfminute, nfsecondn, nfsecondd, nrec
   integer :: jcap, lonb, latb, levs, vlev
   real(4),dimension(:,:,:),allocatable :: vcoord5
   real(8),allocatable :: ak5(:), bk5(:)
   real(8),dimension(:),allocatable :: prsi,prsl,outvar
   real(8) :: ps,kap1,kapr
   character(4) :: clon,clat,cjcap
   character(3) :: clev
   integer,dimension(7) :: idate
   real(8),dimension(:,:),allocatable :: temp2d
   real(8),dimension(:),allocatable :: temp1d, tmplat, tmplon
   character(16),allocatable:: recname(:),reclevtyp(:)
   integer,allocatable:: reclev(:)
   real(8),dimension(:,:),allocatable :: xd, yd
   real(8) :: dummy,dx1,dx2,dy1,dy2,idx,idy, &
              tmpx1,tmpx2,tmpx3,tmpx4,tmpy1,tmpy2,varval
   integer :: outrec

   character(10) :: varname
   character(256) :: fixpath

   type(nemsio_gfile) :: gfile

!! Define some constant
    kap1=rd/cp+1.
    kapr=1./(rd/cp)

!! 
   call getarg(1,file1)
   call getarg(2,tlat)
        read(tlat,*) intlat
   call getarg(3,tlon)
        read(tlon,*) intlon
        if ( intlon .lt. 0 ) then
           intlon=intlon+360.0
        end if
   call getarg(4,aer)
        if ( trim(aer) .eq. "T" ) then
           laerosol=.true.
        end if

   call nemsio_init(iret=iret)
   call nemsio_open(gfile,file1,'READ',iret=iret)
   if (iret.ne.0) write(6,*) 'open ',file1,' error'
   call nemsio_getfilehead(gfile, iret=iret, nfhour=nfhour, nrec=nrec, &
          nfminute=nfminute, nfsecondn=nfsecondn, nfsecondd=nfsecondd, &
          idate=idate, dimx=lonb, dimy=latb, dimz=levs ,jcap=jcap)

!   write(6,*) nrec
   allocate(recname(nrec),reclevtyp(nrec),reclev(nrec),vcoord5(levs+1,3,2)) 
   call nemsio_getfilehead(gfile,iret=iret,recname=recname, &
          reclevtyp=reclevtyp,reclev=reclev,vcoord=vcoord5)

   allocate(ak5(levs+1),bk5(levs+1))
   ak5=vcoord5(:,1,1)
   bk5=vcoord5(:,2,1)

   write(clon,'(I0)') lonb
   write(clat,'(I0)') latb
   write(cjcap,'(I0)') jcap

   allocate(tmplon(lonb*latb))
   allocate(tmplat(lonb*latb))
!! Find the 4 grid points surrouding target point.
   fixpath="/data/users/swei/resultcheck/common/GFSfix/"
   open(15,file=trim(fixpath)//'global_latitudes.t'//trim(cjcap)//'.'//trim(clon)//'.'//trim(clat)//'.txt' &
        ,form='formatted')
   open(16,file=trim(fixpath)//'global_longitudes.t'//trim(cjcap)//'.'//trim(clon)//'.'//trim(clat)//'.txt' &
        ,form='formatted')
   do i=1,lonb*latb
      read(15,*) tmplat(i)
      read(16,*) dummy
         if (dummy.lt.0) then
             tmplon(i)=dummy+360.0
         else
             tmplon(i)=dummy
         end if
   end do  
   allocate(xd(lonb,latb),yd(lonb,latb))
   xd=reshape(tmplon,(/lonb,latb/))
   yd=reshape(tmplat,(/lonb,latb/))

   write(6,*) "Interpolation point is (lat,lon) ",intlat,intlon
   do j=1,latb
      do i=1,lonb
         if (intlon.lt.xd(i+1,j).and.intlon.gt.xd(i,j) &
        .and.intlat.gt.yd(i,j+1).and.intlat.lt.yd(i,j)) then
            write(6,*) "X-direction int point is between ",xd(i,j)," and ",xd(i+1,j)
            write(6,*) "Y-direction int point is between ",yd(i,j)," and ",yd(i,j+1)
              dx1=intlon-xd(i,j)
              dx2=xd(i+1,j)-intlon
              dy1=yd(i,j)-intlat
              dy2=intlat-yd(i,j+1)
              idx=i
              idy=j
            exit
         end if
      end do
   end do

   allocate(temp1d(lonb*latb))
   allocate(temp2d(lonb,latb))

   outrec=0
   if ( laerosol ) then
      open(27,file="aerprofile",form="formatted")
   else
      open(27,file="metprofile",form="formatted")
   end if
   readnrec:  do i=1,nrec
      !write(6,*) "read rec for ",recname(i)
      call nemsio_readrecv(gfile,trim(recname(i)),reclevtyp(i),reclev(i),temp1d,iret=iret)
      if ( iret .ne. 0 ) then
         write(6,*) "iret=",iret
         call exit(iret)
      end if
      temp2d=reshape(temp1d,(/lonb,latb/))
      tmpx1=temp2d(idx,idy)
      tmpx2=temp2d(idx+1,idy)
      tmpx3=temp2d(idx,idy+1)
      tmpx4=temp2d(idx+1,idy+1)
      tmpy1=tmpx1*dx2/(dx1+dx2)+tmpx2*dx1/(dx1+dx2)
      tmpy2=tmpx3*dx2/(dx1+dx2)+tmpx4*dx1/(dx1+dx2)
      varval=tmpy1*dy2/(dy1+dy2)+tmpy2*dy1/(dy1+dy2)
      !write(6,*) tmpx1,tmpx2,tmpx3,tmpx4
      select case (trim(recname(i)))
      case('pres')
          if ( laerosol ) then
             cycle readnrec
          end if 
          outrec=outrec+1
          allocate(prsi(levs+1),prsl(levs)) 
!          open(28,file="Pressure.dat",form="formatted")
          ps=varval
          write(6,*) "The pressure of taget = ",ps
          do k=1,levs+1
             prsi(k)=ak5(k)+(bk5(k)*ps)
          end do
          do k=1,levs
             prsl(k)=((prsi(k)**kap1-prsi(k+1)**kap1)/&
                       (kap1*(prsi(k)-prsi(k+1))))**kapr
          end do
          !write(27,rec=outrec) prsi  ! Level Pressure
          write(27,*) prsi  ! Level Pressure
            write(6,*) "Writing out Level Pressure"
          !write(27,rec=outrec+1) prsl ! Pressure
          write(27,*) prsl ! Pressure
            write(6,*) "Writing out mid-Layer Pressure"
      case('tmp','o3mr','clwmr')
          if ( laerosol ) then
             cycle readnrec
          end if
          if ( reclev(i) .eq. 1 ) then
             allocate(outvar(levs))
          end if
          outvar(reclev(i))=varval
          if ( reclev(i) .eq. levs ) then
             outrec=outrec+1
             !write(27,rec=outrec) outvar
             write(27,*) outvar
             write(6,*) "Writing out ",recname(i)
             deallocate(outvar)
          end if
      case('so4','ocphobic','ocphilic','bcphobic','bcphilic', &
           'du001','du002','du003','du004','du005', &
           'ss001','ss002','ss003','ss004','ss005')
          if ( reclev(i) .eq. 1 ) then
             allocate(outvar(levs))
          end if
          outvar(reclev(i))=varval
          if ( reclev(i) .eq. levs ) then
             outrec=outrec+1
             !write(27,rec=outrec) outvar
             write(27,*) outvar
             write(6,*) "Writing out ",recname(i)
             deallocate(outvar)
          end if

      end select
   end do readnrec

   close(27)
   call nemsio_close(gfile,iret=iret)

end
