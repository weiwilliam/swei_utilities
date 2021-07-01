! compile with
! f2py read_gsidiag.f90 -m read_gsidiag -h read_gsidiag.pyf
! f2py -c read_gsidiag.pyf read_gsidiag.f90 --f90flags='-ffree-form'

subroutine read_cnvhead(infile,nrecs,varlist, &
                        psnreal,tnreal,qnreal,gpsnreal, &
                        sstnreal,uvnreal,tcpnreal, &
                        psnum,tnum,qnum,gpsnum,sstnum,uvnum,tcpnum)
implicit none
integer :: i,v,ios,idate
integer, intent(  out) :: nrecs
character(len=256),intent(in   ) :: infile
integer :: nchar,nreal,ii,mype
integer, dimension(7) :: nrealout
character*3 :: var
character*3,dimension(7),intent(  out) :: varlist
integer,dimension(7) :: obsnum
integer, intent(  out) :: psnreal,tnreal,qnreal,gpsnreal,sstnreal,uvnreal,tcpnreal
integer, intent(  out) :: psnum,tnum,qnum,gpsnum,sstnum,uvnum,tcpnum

   varlist(1)=' ps'//char(0)
   varlist(2)='  t'//char(0)
   varlist(3)='  q'//char(0)
   varlist(4)='gps'//char(0)
   varlist(5)='sst'//char(0)
   varlist(6)=' uv'//char(0)
   varlist(7)='tcp'//char(0)

   open(17,file=trim(infile), status='OLD',iostat=ios,access='SEQUENTIAL',  &
           form='UNFORMATTED',convert='big_endian')
   if(ios > 0 ) then
      write(*,*) ' no diag file availabe :', trim(infile)
   endif
   obsnum(:)=0
   nrealout(:)=0
   read(17, iostat=ios) idate
   nrecs=0
   ios=0
   do while (ios==0)
      read(17,iostat=ios)
      read(17,iostat=ios)
      if (ios .ne. 0) exit
      nrecs=nrecs+1
   end do
   rewind(17)
   read(17, iostat=ios) idate
   do i=1,nrecs
      read(17,iostat=ios) var,nchar,nreal,ii,mype
      read(17) 
      do v=1,7
         if (var==varlist(v)) then
            nrealout(v)=nreal
            obsnum(v)=obsnum(v)+ii 
         end if
      end do
   end do
   psnreal=nrealout(1); tnreal=nrealout(2); qnreal=nrealout(3); gpsnreal=nrealout(4)
   sstnreal=nrealout(5); uvnreal=nrealout(6); tcpnreal=nrealout(7)
   psnum=obsnum(1); tnum=obsnum(2); qnum=obsnum(3); gpsnum=obsnum(4)
   sstnum=obsnum(5); uvnum=obsnum(6); tcpnum=obsnum(7)

   close(17)
   return
end subroutine read_cnvhead

subroutine load_cnvdata(infile,nrecs,varlist, &
                        psnreal,tnreal,qnreal,gpsnreal, &
                        sstnreal,uvnreal,tcpnreal, &
                        psnum,tnum,qnum,gpsnum,sstnum,uvnum,tcpnum, &
                        ps_stid,ps_data,t_stid,t_data,q_stid,q_data, &
                        gps_stid,gps_data,sst_stid,sst_data, &
                        uv_stid,uv_data,tcp_stid,tcp_data)
implicit none
character(len=256),intent(in   ) :: infile
character*3,dimension(7),intent(in   ) :: varlist
integer, intent(in   ) :: nrecs
integer, intent(in   ) :: psnreal,tnreal,qnreal,gpsnreal,sstnreal,uvnreal,tcpnreal
integer, intent(in   ) :: psnum,tnum,qnum,gpsnum,sstnum,uvnum,tcpnum

character*3 :: var
integer :: nchar,nreal,ii,mype
character*8,allocatable,dimension(:):: cdiagbuf
real(4),allocatable,dimension(:,:)::rdiagbuf

!data varlist/' ps','  t','  q','gps','sst',' uv','tcp'/
character*8,dimension(psnum),intent(  out) :: ps_stid
character*8,dimension(tnum),intent(  out) :: t_stid
character*8,dimension(qnum),intent(  out) :: q_stid
character*8,dimension(gpsnum),intent(  out) :: gps_stid
character*8,dimension(sstnum),intent(  out) :: sst_stid
character*8,dimension(uvnum),intent(  out) :: uv_stid
character*8,dimension(tcpnum),intent(  out) :: tcp_stid
real(4),dimension(psnreal,psnum),intent(  out) :: ps_data
real(4),dimension(tnreal,tnum),intent(  out) :: t_data
real(4),dimension(qnreal,qnum),intent(  out) :: q_data
real(4),dimension(gpsnreal,gpsnum),intent(  out) :: gps_data
real(4),dimension(sstnreal,sstnum),intent(  out) :: sst_data
real(4),dimension(uvnreal,uvnum),intent(  out) :: uv_data
real(4),dimension(tcpnreal,tcpnum),intent(  out) :: tcp_data

integer :: i,ios,idate
integer :: psidx,tidx,qidx,gpsidx,sstidx,uvidx,tcpidx

   open(17,file=trim(infile), status='OLD',iostat=ios,access='SEQUENTIAL',  &
           form='UNFORMATTED',convert='big_endian')
   if(ios > 0 ) then
      write(*,*) ' no diag file availabe :', trim(infile)
   endif

   read(17, iostat=ios) idate
   write(6,*) 'Processing conv diag on ', idate

   psidx=1; tidx=1; qidx=1; gpsidx=1; sstidx=1; uvidx=1; tcpidx=1
   do i=1,nrecs
      read(17,iostat=ios) var,nchar,nreal,ii,mype
      if ( ios /= 0 ) then
         exit
      end if
      allocate(cdiagbuf(ii),rdiagbuf(nreal,ii))
      read(17,iostat=ios) cdiagbuf, rdiagbuf
      select case (var)
      case (' ps')
           ps_stid(psidx:psidx+ii-1)=cdiagbuf
           ps_data(:,psidx:psidx+ii-1)=rdiagbuf
           psidx=psidx+ii
      case ('  t')
           t_stid(tidx:tidx+ii-1)=cdiagbuf
           t_data(:,tidx:tidx+ii-1)=rdiagbuf
           tidx=tidx+ii
      case ('  q')
           q_stid(qidx:qidx+ii-1)=cdiagbuf
           q_data(:,qidx:qidx+ii-1)=rdiagbuf
           qidx=qidx+ii
      case ('gps')
           gps_stid(gpsidx:gpsidx+ii-1)=cdiagbuf
           gps_data(:,gpsidx:gpsidx+ii-1)=rdiagbuf
           gpsidx=gpsidx+ii
      case ('sst')
           sst_stid(sstidx:sstidx+ii-1)=cdiagbuf
           sst_data(:,sstidx:sstidx+ii-1)=rdiagbuf
           sstidx=sstidx+ii
      case (' uv')
           uv_stid(uvidx:uvidx+ii-1)=cdiagbuf
           uv_data(:,uvidx:uvidx+ii-1)=rdiagbuf
           uvidx=uvidx+ii
      case ('tcp')
           tcp_stid(tcpidx:tcpidx+ii-1)=cdiagbuf
           tcp_data(:,tcpidx:tcpidx+ii-1)=rdiagbuf
           tcpidx=tcpidx+ii
      end select 
      
      deallocate(cdiagbuf,rdiagbuf)
   end do


   close(17)
   return
end subroutine load_cnvdata

subroutine read_radhead(infile,nchanl1,npred1,nobs1,nreal1)
implicit none
character(len=256),intent(in   ) :: infile
integer,intent(  out) :: nchanl1,npred1,nobs1,nreal1
character(10) :: obstype !, obstype2
character(20) :: isis !, isis2
character(10) :: dplat !, dplat2
integer :: jiter !, jiter2
integer :: idate !, idate2
integer :: ipchan !, ipchan2
integer :: iextra,jextra
integer :: i,ios

   open(17,file=trim(infile),status='OLD',iostat=ios,access='SEQUENTIAL',  &
           form='UNFORMATTED',convert='big_endian')
   if(ios > 0 ) then
      write(*,*) ' no diag file availabe :', trim(infile)
   endif

   read(17) isis,dplat,obstype,jiter,nchanl1,npred1,idate,nreal1,ipchan,iextra,jextra
   do i=1,nchanl1
      read(17) 
   end do

   nobs1=0
   ios=0
   do while (ios .eq. 0 )
      read(17,iostat=ios) 
      if (ios .ne. 0) exit
      nobs1=nobs1+1
   end do
   close(17)

end subroutine read_radhead

subroutine load_raddata(infile,nchanl2,npred2,nobs2,nreal2, &
                        freq,pol,wave,varch,tlap,iuse_rad,nuchan,ich, &
                        locinfo, &
                        tb_obs,tbc,tbcnob,errinv,qcflag,emiss,tlapchn,ts, &
                        pred)
implicit none
character(len=64) :: myname='load_raddata:'
character(len=256),intent(in   ) :: infile
integer,intent(in   ) :: nchanl2,npred2,nobs2,nreal2
character(10) :: obstype !, obstype2
character(20) :: isis !, isis2
character(10) :: dplat !, dplat2
integer :: jiter !, jiter2
integer :: idate !, idate2
integer :: ireal !, ireal2
integer :: ipchan !, ipchan2
integer :: iextra,jextra
integer :: i,j,k,ios
integer :: dummy1,dummy2 !, nchanl,npred
real(4),dimension(:,:),allocatable :: diagbufchan
real(4),dimension(:),allocatable :: diagbuf

real(4),dimension(nchanl2),intent(  out) :: freq,pol,wave,varch,tlap
integer,dimension(nchanl2),intent(  out) :: iuse_rad,nuchan,ich
real(4),dimension(nreal2,nobs2),intent(  out) :: locinfo 
real(4),dimension(nchanl2,nobs2),intent(  out) :: tb_obs,tbc,tbcnob,errinv,qcflag,emiss,tlapchn,ts
real(4),dimension(nchanl2,npred2+2,nobs2),intent(  out) :: pred

   write(6,*) trim(myname),nchanl2,npred2,nobs2
   ios=0
   open(17,file=trim(infile),status='OLD',iostat=ios,access='SEQUENTIAL',  &
           form='UNFORMATTED',convert='big_endian')
   if(ios > 0 ) then
      write(*,*) ' no diag file availabe :', trim(infile)
   endif
   read(17) isis,dplat,obstype,jiter,dummy1,dummy2,idate,ireal,ipchan,iextra,jextra
   do i=1,nchanl2
      read(17) freq(i),pol(i),wave(i),varch(i),tlap(i),iuse_rad(i),nuchan(i),ich(i)
   end do

   write(6,*) trim(myname),nchanl2,npred2,nobs2
   allocate(diagbufchan(ipchan+npred2+2,nchanl2))
   allocate(diagbuf(ireal)) 

   diagbuf=0.
   diagbufchan=0.
   
   ios=0
   do i=1,nobs2
      read(17,iostat=ios) diagbuf,diagbufchan
      if (ios .ne. 0) then
         write(6,*) 'Error:: read in diagbuf, diagbufchan'
         exit
      end if 
      do j=1,nreal2
         locinfo(j,i)=diagbuf(j)
      end do
      do j=1,nchanl2
         tb_obs(j,i)=diagbufchan(1,j)
         tbc(j,i)=diagbufchan(2,j)
         tbcnob(j,i)=diagbufchan(3,j)
         errinv(j,i)=diagbufchan(4,j)
         qcflag(j,i)=diagbufchan(5,j)
         emiss(j,i)=diagbufchan(6,j)
         tlapchn(j,i)=diagbufchan(7,j)
         ts(j,i)=diagbufchan(8,j)
      end do
      do k=1,npred2+2
         do j=1,nchanl2
            pred(j,k,i)=diagbufchan(ipchan+k,j)
         end do
      end do
   end do

   close(17)
end subroutine load_raddata
