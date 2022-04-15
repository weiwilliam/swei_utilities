program testnemsio

   USE nemsio_module, ONLY: nemsio_init,nemsio_open,nemsio_close, &
                  nemsio_gfile,nemsio_getfilehead,nemsio_readrecv, &
                  nemsio_writerecv
   USE, INTRINSIC :: IEEE_ARITHMETIC
 
   implicit none
   character(len=256) :: file1, file2
   
   integer :: k, iret, ij, i, j, x, y, z
   integer :: inicount,nancount
   integer :: nfhour, nfminute, nfsecondn, nfsecondd, nrec
   integer :: lonb, latb, levs, vlev
   integer :: arcount
   character(3) :: clon,clat,clev
   integer,dimension(7) :: idate
   real(8),dimension(:),allocatable :: temp1d
   real(8),dimension(:,:,:),allocatable :: varval
   character(16),allocatable:: recname1(:),reclevtyp1(:)
   integer,allocatable:: reclev1(:)
   character(16),allocatable:: recname2(:),reclevtyp2(:)
   integer,allocatable:: reclev2(:)
   real(8) :: maxvar,minvar,avgvar
   real(8) :: lmaxvar,lminvar,lavgvar

   character(10) :: varname

   type(nemsio_gfile) :: gfile1, gfile2

   call getarg(1,file1)

   call nemsio_init(iret=iret)
   call nemsio_open(gfile1,file1,'READ',iret=iret)
   if (iret.ne.0) write(6,*) 'open ',file1,' error'
   call nemsio_getfilehead(gfile1, iret=iret, nfhour=nfhour, nrec=nrec, &
          nfminute=nfminute, nfsecondn=nfsecondn, nfsecondd=nfsecondd, &
          idate=idate, dimx=lonb, dimy=latb, dimz=levs )

!   write(6,*) nrec
   allocate(recname1(nrec),reclevtyp1(nrec),reclev1(nrec)) 
   call nemsio_getfilehead(gfile1,iret=iret,recname=recname1, &
          reclevtyp=reclevtyp1,reclev=reclev1)

   write(clon,'(I3)') lonb
   write(clat,'(I3)') latb

   allocate(temp1d(lonb*latb))

   do i=1,nrec
      if (reclev1(i) .eq. 1 ) then
!         write(6,*) "process ",i," nrec "
         if (reclevtyp1(i) .eq. "sfc" ) then
            vlev=1
         else if (reclevtyp1(i) .eq. "mid layer" ) then
            vlev=levs
         else if (reclevtyp1(i) .eq. "soil layer" ) then
            vlev=4
         else if (reclevtyp1(i) .eq. "2 m above gnd" ) then
            vlev=1
         else if (reclevtyp1(i) .eq. "10 m above gnd" ) then
            vlev=1
         else if (reclevtyp1(i) .eq. "atmos col" ) then
            vlev=1
         end if
         write(clev,'(I3.3)') vlev
         allocate(varval(lonb,latb,vlev))
         
         
         do k=1,vlev
            call nemsio_readrecv(gfile1,trim(recname1(i)),reclevtyp1(i),k,temp1d,iret=iret)
            varval(:,:,k)=reshape(temp1d,(/lonb,latb/))
            if ( vlev .ne. 1 ) then
            lmaxvar=maxval(varval(:,:,k))
            lminvar=minval(varval(:,:,k))
            nancount=0
            do y=1,latb
              do x=1,lonb
                 if ( ieee_is_nan(varval(x,y,k)) ) then
                   nancount=nancount+1
                 end if
              end do
            end do
            lavgvar=sum(varval(:,:,k))/(lonb*latb*vlev)
            write(6,*) "Var ",trim(recname1(i))," at lev ", k
            write(6,*) "   Level ",k," Maximum=",lmaxvar
            write(6,*) "   Level ",k," Minimum=",lminvar
            write(6,*) "   Level ",k," Average=",lavgvar
            write(6,*) "   Level ",k," NaN num=",nancount 
            end if
         end do
 
         maxvar=maxval(varval)
         minvar=minval(varval)
         nancount=0
         do z=1,vlev
           do y=1,latb
             do x=1,lonb
                if ( ieee_is_nan(varval(x,y,z)) ) then
                  nancount=nancount+1
                end if
             end do
           end do
         end do
         avgvar=sum(varval)/(lonb*latb*vlev)

         write(6,*) "Var ",trim(recname1(i))," ",trim(reclevtyp1(i))
         write(6,*) "   Maximum=",maxvar
         write(6,*) "   Minimum=",minvar
         write(6,*) "   Average=",avgvar
         write(6,*) "   NaN num=",nancount
         
         deallocate(varval)
      end if
   end do

   call nemsio_close(gfile1,iret=iret)

end
