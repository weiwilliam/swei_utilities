program testnemsio

   USE nemsio_module, ONLY: nemsio_init,nemsio_open,nemsio_close, &
                  nemsio_gfile,nemsio_getfilehead,nemsio_readrecv, &
                  nemsio_writerecv
 
   implicit none
   character(len=256) :: file1, file2
   
   integer :: k, iret, ij, i
   integer :: nfhour, nfminute, nfsecondn, nfsecondd, nrec
   integer :: lonb, latb, levs, vlev
   character(3) :: clon,clat,clev
   integer,dimension(7) :: idate
   real(8),dimension(:),allocatable :: temp1d
   real(8),dimension(:,:,:),allocatable :: varval1,varval2
   character(16),allocatable:: recname1(:),reclevtyp1(:)
   integer,allocatable:: reclev1(:)
   character(16),allocatable:: recname2(:),reclevtyp2(:)
   integer,allocatable:: reclev2(:)
   real(8) :: diffmax,diffmin,diffrms
   real(8) :: maxvar1,minvar1,avgvar1
   real(8) :: maxvar2,minvar2,avgvar2

   character(10) :: varname

   type(nemsio_gfile) :: gfile1, gfile2
   
   call getarg(1,file1)
   call getarg(2,file2)

   call nemsio_init(iret=iret)
   call nemsio_open(gfile1,file1,'READ',iret=iret)
   if (iret.ne.0) write(6,*) 'open ',file1,' error'
   call nemsio_getfilehead(gfile1, iret=iret, nfhour=nfhour, nrec=nrec, &
          nfminute=nfminute, nfsecondn=nfsecondn, nfsecondd=nfsecondd, &
          idate=idate, dimx=lonb, dimy=latb, dimz=levs )
   call nemsio_open(gfile2,file2,'READ',iret=iret)

!   write(6,*) nrec
   allocate(recname1(nrec),reclevtyp1(nrec),reclev1(nrec)) 
   call nemsio_getfilehead(gfile1,iret=iret,recname=recname1, &
          reclevtyp=reclevtyp1,reclev=reclev1)
   allocate(recname2(nrec),reclevtyp2(nrec),reclev2(nrec)) 
   call nemsio_getfilehead(gfile2,iret=iret,recname=recname2, &
          reclevtyp=reclevtyp2,reclev=reclev2)

   write(clon,'(I3)') lonb
   write(clat,'(I3)') latb

   allocate(temp1d(lonb*latb))

   do i=1,nrec
      if (reclev1(i) .eq. 1 ) then
!         write(6,*) "process ",i," nrec "
         if (reclevtyp1(i) .eq. "sfc" ) then
            vlev=1
         else if (reclevtyp1(i) .eq. "mid layer" ) then
            vlev=64
         else if (reclevtyp1(i) .eq. "soil layer" ) then
            vlev=4
         else if (reclevtyp1(i) .eq. "2 m above gnd" ) then
            vlev=1
         else if (reclevtyp1(i) .eq. "10 m above gnd" ) then
            vlev=1
         end if
         write(clev,'(I3.3)') vlev
         allocate(varval1(lonb,latb,vlev),varval2(lonb,latb,vlev))
         
         do k=1,vlev
            call nemsio_readrecv(gfile1,trim(recname1(i)),reclevtyp1(i),k,temp1d,iret=iret)
            varval1(:,:,k)=reshape(temp1d,(/lonb,latb/))
            call nemsio_readrecv(gfile2,trim(recname1(i)),reclevtyp1(i),k,temp1d,iret=iret)
            varval2(:,:,k)=reshape(temp1d,(/lonb,latb/))
         end do

            maxvar1=maxval(varval1)
            minvar1=minval(varval1)
            avgvar1=sum(varval1)/(lonb*latb*vlev)
            maxvar2=maxval(varval2)
            minvar2=minval(varval2)
            avgvar2=sum(varval2)/(lonb*latb*vlev)
            diffmax=maxval(varval2-varval1)
            diffmin=minval(varval2-varval1)
            diffrms=sqrt(sum((varval2-varval1)**2)/(lonb*latb*vlev))

         write(6,*) "Var ",recname1(i)
         write(6,*) "File1 Maximum=",maxvar1,"File1 Minimum=",minvar1,"File1 Avg.=",avgvar1
         write(6,*) "File2 Maximum=",maxvar2,"File2 Minimum=",minvar2,"File2 Avg.=",avgvar2
         write(6,*) "Maximum diff.=",diffmax,"Minimum diff.=",diffmin,"RMSD=",diffrms
         
         deallocate(varval1,varval2)
      end if
   end do

   call nemsio_close(gfile1,iret=iret)
   call nemsio_close(gfile2,iret=iret)

end
