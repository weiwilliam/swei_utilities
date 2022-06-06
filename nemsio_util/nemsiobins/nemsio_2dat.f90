program testnemsio

   USE nemsio_module, ONLY: nemsio_init,nemsio_open,nemsio_close, &
                  nemsio_gfile,nemsio_getfilehead,nemsio_readrecv, &
                  nemsio_writerecv
 
   implicit none
   character(len=256) :: filename
   
   integer :: k, iret, ij, i
   integer :: nfhour, nfminute, nfsecondn, nfsecondd, nrec
   integer :: lonb, latb, levs, vlev
   character(3) :: clon,clat,clev
   integer,dimension(7) :: idate
   real(8),dimension(:),allocatable :: temp1d
   real(8),dimension(:,:,:),allocatable :: varval
   real(8) :: power,diff
   character(16),allocatable:: recname(:),reclevtyp(:)
   integer,allocatable:: reclev(:)

   character(10) :: varname,pname
!   character(10),dimension(18):: varname=(/'du001',"du002","du003","du004","du005", &
!                    "ss001","ss002","ss003","ss004","ss005", &
!                    "dms","msa","so2","so4", &
!                    "ocphilic","ocphobic","bcphilic","bcpholic"/)
 

   type(nemsio_gfile) :: gfile
   
   call getarg(1,filename)

   call nemsio_init(iret=iret)
   call nemsio_open(gfile,filename,'READ',iret=iret)
   if (iret.ne.0) write(6,*) 'open ',filename,' error'
   call nemsio_getfilehead(gfile, iret=iret, nfhour=nfhour, nrec=nrec, &
          nfminute=nfminute, nfsecondn=nfsecondn, nfsecondd=nfsecondd, &
          idate=idate, dimx=lonb, dimy=latb, dimz=levs )

   write(6,*) nrec
   allocate(recname(nrec),reclevtyp(nrec),reclev(nrec)) 
   call nemsio_getfilehead(gfile,iret=iret,recname=recname, &
          reclevtyp=reclevtyp,reclev=reclev)

   write(clon,'(I3)') lonb
   write(clat,'(I3)') latb

   allocate(temp1d(lonb*latb))

   do i=1,nrec
      if (reclev(i) .eq. 1 ) then
         write(6,*) "process ",i," nrec "
         if (reclevtyp(i) .eq. "sfc" ) then
            vlev=1
         else if (reclevtyp(i) .eq. "mid layer" ) then
            vlev=64
         else if (reclevtyp(i) .eq. "soil layer" ) then
            vlev=4
         else if (reclevtyp(i) .eq. "2 m above gnd" ) then
            vlev=1
         else if (reclevtyp(i) .eq. "10 m above gnd" ) then
            vlev=1
         else if (reclevtyp(i) .eq. "atmos col" ) then
            vlev=1
         end if
         write(clev,'(I3.3)') vlev
         allocate(varval(lonb,latb,vlev))
         
         open(100,file=trim(recname(i))//"x"//trim(clon)//"y"//trim(clat)//"l"//trim(clev)//".dat",form="unformatted")
         do k=1,vlev
            write(6,*) "Process "//trim(recname(i))//" level ",k
            call nemsio_readrecv(gfile,trim(recname(i)),reclevtyp(i),k,temp1d,iret=iret)
            varval(:,:,k)=reshape(temp1d,(/lonb,latb/))
         end do
         write(100) varval
         close(100)
         deallocate(varval)
      end if
   end do

   call nemsio_close(gfile,iret=iret)

   


end
