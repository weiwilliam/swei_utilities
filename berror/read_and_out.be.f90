program readandoutbe

implicit none

real(4),allocatable,dimension(:,:):: stdev3d4,hscale3d4,vscale3d4
real(4),allocatable,dimension(:):: stdevpro,hscalpro,vscalpro
   real(4),allocatable,dimension(:,:,:):: tcon4
   real(4),allocatable,dimension(:,:):: nrhvar4, &
        vpcon4,pscon4,varsst4,corlsst4
   real(4),allocatable,dimension(:):: psvar4,pshln4
integer :: nsig,nlat,nlon
character(len=5) :: var
integer :: i,isig,j,k
character(len=20) :: metfile,aerofile,outfile

metfile="./met.be"
aerofile="./aero.be"
outfile="./met_aero.be"

open(50,file=metfile,form="unformatted")
rewind(50)
open(51,file=aerofile,form="unformatted")
rewind(51)

open(52,file=trim(outfile)//".little",form="unformatted",convert="LITTLE_ENDIAN")
rewind(52)
open(62,file=trim(outfile)//".big",form="unformatted",convert="BIG_ENDIAN")
rewind(62)

open(53,file="be.ascii",form="formatted")
rewind(53)

read(50) nsig,nlat,nlon
read(51) nsig,nlat,nlon
allocate(stdev3d4(nlat,nsig),hscale3d4(nlat,nsig),vscale3d4(nlat,nsig))
allocate(stdevpro(nsig),hscalpro(nsig),vscalpro(nsig))
allocate(nrhvar4(nlat,nsig))
allocate(pscon4(nlat,nsig),vpcon4(nlat,nsig))
allocate(varsst4(nlat,nlon),corlsst4(nlat,nlon))
allocate(tcon4(nlat,nsig,nsig))
allocate(psvar4(nlat),pshln4(nlat))

write(52) nsig,nlat,nlon
write(62) nsig,nlat,nlon
write(53,*) nsig,nlat,nlon

read(50) tcon4,vpcon4,pscon4
write(52) tcon4,vpcon4,pscon4
write(62) tcon4,vpcon4,pscon4
write(53,*) tcon4,vpcon4,pscon4

open(55,file='metbe.ascii',form='formatted')
  rewind(55)

do i=1,6
   read(50) var,nsig
     write(6,*) var
   write(52) var,nsig
   write(62) var,nsig
   write(53,*) var,nsig
   write(55,*) var,nsig
   if (i==4) then
      read(50) stdev3d4(:,:),nrhvar4
      read(50) hscale3d4(:,:)
      read(50) vscale3d4(:,:)
      write(52) stdev3d4(:,:),nrhvar4
      write(52) hscale3d4(:,:)
      write(52) vscale3d4(:,:)
      write(62) stdev3d4(:,:),nrhvar4
      write(62) hscale3d4(:,:)
      write(62) vscale3d4(:,:)
      write(53,*) stdev3d4(:,:),nrhvar4
      write(53,*) hscale3d4(:,:)
      write(53,*) vscale3d4(:,:)
      write(55,*) stdev3d4(:,:),nrhvar4
      write(55,*) hscale3d4(:,:)
      write(55,*) vscale3d4(:,:)
   else
      read(50) stdev3d4(:,:)
      read(50) hscale3d4(:,:)
      read(50) vscale3d4(:,:)
      write(52) stdev3d4(:,:)
      write(52) hscale3d4(:,:)
      write(52) vscale3d4(:,:)
      write(62) stdev3d4(:,:)
      write(62) hscale3d4(:,:)
      write(62) vscale3d4(:,:)
      write(53,*) stdev3d4(:,:)
      write(53,*) hscale3d4(:,:)
      write(53,*) vscale3d4(:,:)
      write(55,*) stdev3d4(:,:)
      write(55,*) hscale3d4(:,:)
      write(55,*) vscale3d4(:,:)
   end if
end do

   read(50) var,isig
     write(6,*) var
   read(50) psvar4
   read(50) pshln4
   write(52) var,isig
   write(52) psvar4
   write(52) pshln4
   write(62) var,isig
   write(62) psvar4
   write(62) pshln4
   write(53,*) var,isig
   write(53,*) psvar4
   write(53,*) pshln4

   read(50) var,isig
     write(6,*) var
   read(50) varsst4
   read(50) corlsst4
   write(52) var,isig
   write(52) varsst4
   write(52) corlsst4
   write(62) var,isig
   write(62) varsst4
   write(62) corlsst4
   write(53,*) var,isig
   write(53,*) varsst4
   write(53,*) corlsst4

! open the file for domain avg. BE
open(54,file='aero_dom_avg.ascii',form='formatted')
  rewind(54)
open(56,file='aero_be.ascii',form='formatted')
  rewind(56)

do i=1,14
   read(51) var,nsig
     write(6,*) var
   read(51) stdev3d4(:,:)
   read(51) hscale3d4(:,:)
   read(51) vscale3d4(:,:)
   write(52) var,nsig
   write(52) stdev3d4(:,:)
   write(52) hscale3d4(:,:)
   write(52) vscale3d4(:,:)
   write(62) var,nsig
   write(62) stdev3d4(:,:)
   write(62) hscale3d4(:,:)
   write(62) vscale3d4(:,:)
   write(53,*) var,nsig
   write(53,*) stdev3d4(:,:)
   write(53,*) hscale3d4(:,:)
   write(53,*) vscale3d4(:,:)
   write(56,*) var,nsig
   write(56,*) stdev3d4(:,:)
   write(56,*) hscale3d4(:,:)
   write(56,*) vscale3d4(:,:)
   stdevpro=0.
   hscalpro=0.
   vscalpro=0.
     do k=1,nsig
        do j=1,nlat
           stdevpro(k)=stdevpro(k)+stdev3d4(j,k)/nlat
           hscalpro(k)=hscalpro(k)+hscale3d4(j,k)/nlat
           vscalpro(k)=vscalpro(k)+vscale3d4(j,k)/nlat
        enddo
     enddo
   write(54,*) var,nsig
   write(54,*) stdevpro
   write(54,*) hscalpro
   write(54,*) vscalpro
end do

close(50)
close(51)
close(52)
close(62)
close(53)
close(54)
close(55)
close(56)

end
