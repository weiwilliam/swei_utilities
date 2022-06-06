program testnemsio

   USE nemsio_module, ONLY: nemsio_init,nemsio_open,nemsio_close, &
                  nemsio_gfile,nemsio_getfilehead,nemsio_readrecv, &
                  nemsio_writerecv
 
   implicit none
   character(len=256) :: filename
   
   integer :: k, iret, ij, i
   integer :: nfhour, nfminute, nfsecondn, nfsecondd, nrec
   integer :: lonb, latb, levs
   character(3) :: clon,clat,clev
   integer,dimension(7) :: idate
   real(8),dimension(:),allocatable :: temp1d
   real(8),dimension(:,:,:),allocatable :: varval
   real(8) :: power,diff
   character(16),allocatable:: recname(:),reclevtyp(:)
   integer,allocatable:: reclev(:)

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

   write(6,*) recname
   write(6,*) reclevtyp
   write(6,*) reclev

   call nemsio_close(gfile,iret=iret)

   


end
