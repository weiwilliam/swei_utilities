program testnemsio

   USE nemsio_module, ONLY: nemsio_init,nemsio_open,nemsio_close, &
                  nemsio_gfile,nemsio_getfilehead,nemsio_readrecv, &
                  nemsio_writerecv
 
   implicit none
   character(len=256) :: filename
   character(len=32) :: varname
   character(len=32) :: slevarrecidx,varrectype
   character(len=32) :: dlev
   
   integer :: k, iret, ij, i
   integer :: nfhour, nfminute, nfsecondn, nfsecondd, nrec
   integer :: lonb, latb, levs
   character(3) :: clon,clat,clev
   integer,dimension(7) :: idate
   real(8),dimension(:),allocatable :: temp1d
   real(4),dimension(:),allocatable :: lat,lon
   real(8),dimension(:,:,:),allocatable :: varval
   real(8) :: power,diff
   character(16),allocatable:: recname(:),reclevtyp(:)
   
   integer,allocatable:: reclev(:)
   integer :: varrecidx, var_inquire_state, vlev, ilev
   

   type(nemsio_gfile) :: gfile
   
   call getarg(1,filename)
   call getarg(2,varname)
   call getarg(3,slevarrecidx)
       select case (slevarrecidx)
       case('1')
           varrectype="sfc"
       case('2')
           varrectype="mid layer"
       case('3')
           varrectype="soil layer"
       case('4')
           varrectype="2 m above gnd"
       case('5')
           varrectype="10 m above gnd"
       end select
 
   call getarg(4,dlev)
      read(dlev,'(I)') ilev

   call nemsio_init(iret=iret)
   call nemsio_open(gfile,filename,'READ',iret=iret)
   if (iret.ne.0) write(6,*) 'open ',filename,' error'
   call nemsio_getfilehead(gfile, iret=iret, nfhour=nfhour, nrec=nrec, &
          nfminute=nfminute, nfsecondn=nfsecondn, nfsecondd=nfsecondd, &
          idate=idate, dimx=lonb, dimy=latb, dimz=levs )
   
   allocate(temp1d(lonb*latb))
   allocate(lat(lonb*latb),lon(lonb*latb))
!   write(6,*) nrec
   allocate(recname(nrec),reclevtyp(nrec),reclev(nrec)) 
   call nemsio_getfilehead(gfile,iret=iret,recname=recname, &
          reclevtyp=reclevtyp,reclev=reclev,lat=lat,lon=lon)

!   write(6,*) recname
!   write(6,*) reclevtyp
!   write(6,*) reclev

   var_inquire_state=1
   do i=1,nrec
      if (varname.ne.recname(i)) then
         var_inquire_state=1
         cycle
      else
         if ( varrectype .eq. reclevtyp(i) ) then
            var_inquire_state=0
            varrecidx=i
            exit
         end if
      end if
   end do
   if (var_inquire_state.eq.1) then
      write(6,*) 'Error: No ',varname,' in ',filename
      call nemsio_close(gfile,iret=iret)
      stop(1)
   end if
   
!   write(6,*) varname, recname(varrecidx)
   
   write(6,*) lonb
   write(6,*) latb

   call nemsio_readrecv(gfile,trim(recname(varrecidx)),varrectype,ilev,temp1d,iret=iret)
   write(100,*) temp1d
   write(101,*) lat
   write(102,*) lon

   close(100)
   close(101)
   close(102)
   call nemsio_close(gfile,iret=iret)

end
