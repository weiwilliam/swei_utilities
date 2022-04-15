program testnemsio

   USE nemsio_module, ONLY: nemsio_init,nemsio_open,nemsio_close, &
                  nemsio_gfile,nemsio_getfilehead,nemsio_readrecv, &
                  nemsio_writerecv, nemsio_realkind
 
   implicit none
   character(len=256) :: file1, file2
   
   integer :: k, iret, ij, i, j
   integer :: nfhour, nfminute, nfsecondn, nfsecondd, nrec
   integer :: jcap, lonb, latb, levs, vlev
   character(3) :: clon,clat,clev
   integer,dimension(7) :: idate
   real(8),dimension(:),allocatable :: temp1d
   real(8),dimension(:,:,:),allocatable :: varval
   character(16),allocatable:: recname1(:),reclevtyp1(:)
   integer,allocatable:: reclev1(:)
   character(16),allocatable:: recname2(:),reclevtyp2(:)
   integer,allocatable:: reclev2(:)
   real(8) :: maxvar,minvar,avgvar
   real(nemsio_realkind),dimension(:,:,:),allocatable :: vcoord
   real,dimension(:),allocatable :: ak(:), bk(:)
   real,dimension(:),allocatable :: rlats(:),r4lat(:),r4lon(:), rlons(:)

   character(10) :: varname

   type(nemsio_gfile) :: gfile1, gfile2
   
   call getarg(1,file1)

   call nemsio_init(iret=iret)
   call nemsio_open(gfile1,file1,'READ',iret=iret)
   if (iret.ne.0) write(6,*) 'open ',file1,' error'
   call nemsio_getfilehead(gfile1, iret=iret, nfhour=nfhour, nrec=nrec, &
          nfminute=nfminute, nfsecondn=nfsecondn, nfsecondd=nfsecondd, &
          idate=idate, dimx=lonb, dimy=latb, dimz=levs, jcap=jcap)

   allocate(recname1(nrec),reclevtyp1(nrec),reclev1(nrec)) 
   allocate(vcoord(levs+1,3,2))
   allocate(ak(levs+1),bk(levs+1),rlons(lonb),rlats(latb),r4lon(lonb*latb),r4lat(lonb*latb))
   call nemsio_getfilehead(gfile1,iret=iret,vcoord=vcoord,recname=recname1, &
          reclevtyp=reclevtyp1,reclev=reclev1,lon=r4lon,lat=r4lat)

    do k=1,levs+1
      ak(levs+2-k) = vcoord(k,1,1)
      bk(levs+2-k) = vcoord(k,2,1)
    end do

    do j=1,latb
      rlats(latb+2-j)=r4lat(lonb/2+(j-1)*lonb)
    enddo
    do j=1,lonb
      rlons(j)=r4lon(j)
    end do

   write(6,*) "Filename= ",trim(file1)
   write(6,*) "jcap,lonb,latb,levs= ",jcap,",",lonb,",",latb,",",levs
   write(6,*) "idate=",idate
   write(6,*) "nfhour=",nfhour
   write(6,*) "nfminute=",nfminute
   write(6,*) "nrec=",nrec
   write(6,*) "lat=",rlats
   write(6,*) "lon=",rlons
   !write(6,*) "ak= ",ak
   !write(6,*) "bk= ",bk

   call nemsio_close(gfile1,iret=iret)

end
