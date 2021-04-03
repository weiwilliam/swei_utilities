module crtmpromod
implicit none

private
public :: setupinterpolation
public :: GOCART_Aerosol_size

contains

   subroutine setupinterpolation(nlat,nlon,njcap,tlat,tlon,wa,wb,wc,wd,ix,ixp,iy,iyp)
   implicit none
   integer,intent(in) :: nlat, nlon, njcap
   real(8),intent(in) :: tlat, tlon
   real(8),intent(out) :: wa,wb,wc,wd
   integer,intent(out) :: ix,ixp,iy,iyp

   character(4) :: clon,clat,cjcap
   real(8) :: dummy
   !real(8),allocatable, dimension(:) :: tmplon, tmplat
   real(8),allocatable, dimension(:,:) :: xd,yd
   integer :: i,j,k
   real(8) :: lx,ly,dx1,dx2,dy1,dy2
   character(256) :: fixpath

   write(clon,'(I0)') nlon
   write(clat,'(I0)') nlat
   write(cjcap,'(I0)') njcap

   allocate(xd(nlon,nlat),yd(nlon,nlat))

!! Find the 4 grid points surrouding target point.
   fixpath="/data/users/swei/resultcheck/common/GFSfix/"
   open(15,file=trim(fixpath)//'global_latitudes.t'//trim(cjcap)//'.'//trim(clon)//'.'//trim(clat)//'.txt' &
        ,form='formatted')
   open(16,file=trim(fixpath)//'global_longitudes.t'//trim(cjcap)//'.'//trim(clon)//'.'//trim(clat)//'.txt' &
        ,form='formatted')

   do j=1,nlat
      do i=1,nlon
         read(15,*) yd(i,nlat-j+1) ! reverse the order, N to S ==> S to N
         read(16,*) dummy
         if (dummy.lt.0) then
             xd(i,j)=dummy+360.0
         else
             xd(i,j)=dummy
         end if
      end do
   end do  
   close(15)
   close(16)
!!
!! Find the surrounding points and setup weighting for interpolation
!!
   write(6,*) "Interpolation point is (lat,lon) ",tlat,tlon
   yloop: do j=1,nlat-1
     xloop:  do i=1,nlon-1
         if ( tlon.lt.xd(i+1,j).and.tlon.gt.xd(i,j) &
         .and.tlat.lt.yd(i,j+1).and.tlat.gt.yd(i,j) ) then
            write(6,*) "X-direction int point is between ",xd(i,j)," and ",xd(i+1,j)
            write(6,*) "Y-direction int point is between ",yd(i,j)," and ",yd(i,j+1)
            lx=abs(xd(i,j)-xd(i+1,j))
            ly=abs(yd(i,j)-yd(i,j+1))
            !write(6,*) lx, ly
              dx1=(tlon-xd(i,j))/lx
              dx2=1.-dx1
              dy1=(tlat-yd(i,j))/ly
              dy2=1.-dy1
              !write(6,*) dx1,dx2,dy1,dy2
              ix=i ; iy=j ; ixp=i+1 ; iyp=j+1
              wa=dx2*dy2 ; wb=dx1*dy2 ; wc=dx2*dy1 ; wd=dx1*dy1 
            exit yloop
         end if
      end do xloop
   end do yloop
   write(6,*) "Get the interpolation index by the loop"
   write(6,*) ix, iy, ixp, iyp, wa, wb, wc, wd
!   write(6,*) "Reach end of setupinterpolation"
   end subroutine setupinterpolation

   function GOCART_Aerosol_size( nbin, itype,  & ! Input
                                       lrh ) & ! Input in 0-1
                           result( R_eff  )   ! in micrometer
   use crtm_aerosolcoeff, only: AeroC, CRTM_AerosolCoeff_Load
   use crtm_module, only:SULFATE_AEROSOL,BLACK_CARBON_AEROSOL,ORGANIC_CARBON_AEROSOL,&
       DUST_AEROSOL,SEASALT_SSAM_AEROSOL,SEASALT_SSCM1_AEROSOL,SEASALT_SSCM2_AEROSOL,SEASALT_SSCM3_AEROSOL
   implicit none
!
!   modified from a function provided by Quanhua Liu
!
   integer,intent(in) :: nbin, itype
   real(8),intent(in) :: lrh

   integer :: j1,j2,k
   integer :: errstat
   real(8) :: h1
   real(8) :: R_eff

   errstat=CRTM_AerosolCoeff_Load("./AerosolCoeff.bin")

   if ( itype==DUST_AEROSOL ) then
      if (nbin==1) then
           R_eff = 0.55
      else if (nbin==2) then
           R_eff = 1.4
      else if (nbin==3) then
           R_eff = 2.4
      else if (nbin==4) then
           R_eff = 4.5
      else if (nbin==5) then
           R_eff = 8.0
      end if
      return
   else if ( itype==BLACK_CARBON_AEROSOL .and. nbin==1 ) then
      R_eff = AeroC%Reff(1,itype )
      return
   else if ( itype==ORGANIC_CARBON_AEROSOL .and. nbin==1 ) then
      R_eff = AeroC%Reff(1,itype )
      return
   endif

  j2 = 0

  if ( lrh < AeroC%RH(1) ) then
     j1 = 1
  else if ( lrh > AeroC%RH(AeroC%n_RH) ) then
     j1 = AeroC%n_RH
  else
     do k = 1, AeroC%n_RH-1
        if ( lrh <= AeroC%RH(k+1) .and. lrh > AeroC%RH(k) ) then
           j1 = k
           j2 = k+1
           h1 = (lrh-AeroC%RH(k))/(AeroC%RH(k+1)-AeroC%RH(k))
           exit
        endif
     enddo
  endif
  if ( j2 == 0 ) then
     R_eff = AeroC%Reff(j1,itype )
  else
     R_eff = (1.0-h1)*AeroC%Reff(j1,itype ) + h1*AeroC%Reff(j2,itype )
  endif

  return
  end function GOCART_Aerosol_size

end module crtmpromod


program crtmprofile
!!  
!! 02-23-2018 SWei : Design for cris_npp first, part of algorithm maybe need
!                    modification for other sensor due to lcf4crtm maybe true in
!                    some condition.
!!
   USE nemsio_module, ONLY: nemsio_init,nemsio_open,nemsio_close, &
                  nemsio_gfile,nemsio_getfilehead,nemsio_readrecv, &
                  nemsio_writerecv
   use crtm_module, only:SULFATE_AEROSOL,BLACK_CARBON_AEROSOL,ORGANIC_CARBON_AEROSOL,&
       DUST_AEROSOL,SEASALT_SSAM_AEROSOL,SEASALT_SSCM1_AEROSOL,SEASALT_SSCM2_AEROSOL,SEASALT_SSCM3_AEROSOL
   use crtmpromod
 
   implicit none
!! Atmosphere parameter
   real(8), parameter :: rv     = 4.6150e+2
   real(8), parameter :: rd     = 2.8705e+2
   real(8), parameter :: cp     = 1.0046e+3 !  specific heat of air @pressure   (J/kg/K)
   real(8), parameter :: ttp    = 2.7316e+2 !  temperature at h2o triple point  (K)
   real(8), parameter :: cvap   = 1.8460e+3 !  specific heat of h2o vapor       (J/kg/K)
   real(8), parameter :: csol   = 2.1060e+3 !  specific heat of solid h2o (ice) (J/kg/K)
   real(8), parameter :: cliq   = 4.1855e+3 
   real(8), parameter :: hvap   = 2.5000e+6 !  latent heat of h2o condensation  (J/kg)
   real(8), parameter :: hfus   = 3.3358e+5 !  latent heat of h2o fusion        (J/kg)
   real(8), parameter :: hsub   = hvap+hfus !  
   real(8), parameter :: tmix   = ttp-20.
   real(8), parameter :: psat   = 6.1078e+2  !  pressure at h2o triple point    (Pa)
   real(8), parameter :: kap1   = (rd/cp)+1.
   real(8), parameter :: kapr   = 1./(rd/cp)
   real(8), parameter :: fv     = (rv/rd)-1.
   real(8), parameter :: dldt   = cvap-cliq
   real(8), parameter :: dldti  = cvap-csol
   real(8), parameter :: xa     = -(dldt/rv)
   real(8), parameter :: xai    = -(dldti/rv)
   real(8), parameter :: xb     = xa+hvap/(rv*ttp)
   real(8), parameter :: xbi    = xai+hsub/(rv*ttp)
   real(8), parameter :: eps    = rd/rv
   real(8), parameter :: omeps  = 1.-eps
   real(8), parameter :: onep3  = 1.e3
   real(8), parameter :: qsmall = 1.e-6
   real(8), parameter :: grav   = 9.80665e+0
!!
   character(len=256) :: gdasfile,ngacfile
   real(8) :: intlat,intlon
   
   integer :: iret, i, j, k, revk
   integer :: nfhour, nfminute, nfsecondn, nfsecondd, nrec
   integer,dimension(7) :: idate
   integer :: jcap, lonb, latb, nsig, vlev
   real(4),dimension(:,:,:),allocatable :: vcoord5
   real(8),allocatable :: ak5(:), bk5(:)
   real(8) :: w00,w01,w10,w11
   integer :: idx,idxp,idy,idyp
   real(8),dimension(:,:),allocatable :: temp2d
   real(8),dimension(:),allocatable :: temp1d, temp1d1
   real(8) :: varval
!! GDAS field
   real(8) :: ps
   real(8),dimension(:),allocatable :: prsi,prsl
   real(8),dimension(:),allocatable :: tmp, spfh, wvmr, o3mr
   real(8) :: c3, tv
   real(8),dimension(:),allocatable :: tsen
   integer :: lmint
   logical :: ice=.false. !! Modification needed for airs_aqua 
   real(8) :: mint
   real(8) :: tr, tdry
   real(8) :: estmax,w
   real(8) :: pw,esmax,es,es2
   real(8),dimension(:),allocatable :: qsat, rh
!! NGAC field
   real(8),dimension(:),allocatable :: kgkg_kgm2
   real(8),dimension(:,:),allocatable :: so4,oc1,oc2,bc1,bc2,&
                                       dust1,dust2,dust3,dust4,dust5,&
                                       seas1,seas2,seas3,seas4

   type(nemsio_gfile) :: gfile1,gfile2
!! Local Variables
   character(len=3) :: clnum,clnum1
   character(len=128) :: r3doutfmt,r3doutfmt1
   character(len=256) :: filenameout

   namelist/main/gdasfile,ngacfile,intlat,intlon,filenameout
!!
  open(11,file='genprof.nml')
   read(11,main)
  close(11)
!! 
   call nemsio_init(iret=iret)
   if ( intlon .lt. 0 ) then
      intlon=intlon+360.0
   end if
!! 
! For GDAS variable, pressure, layer pressure, temperature, Ozone and H2O mixing
! ratio.
! 

   call nemsio_open(gfile1,gdasfile,'READ',iret=iret)
       if (iret.ne.0) write(6,*) 'open ',gdasfile,' error'

   call nemsio_getfilehead(gfile1, iret=iret, nfhour=nfhour, nrec=nrec, &
          nfminute=nfminute, nfsecondn=nfsecondn, nfsecondd=nfsecondd, &
          idate=idate, dimx=lonb, dimy=latb, dimz=nsig ,jcap=jcap)

   allocate(vcoord5(nsig+1,3,2)) 
   call nemsio_getfilehead(gfile1, iret=iret, vcoord=vcoord5)
       allocate(ak5(nsig+1),bk5(nsig+1))
       ak5=vcoord5(:,1,1)
       bk5=vcoord5(:,2,1)

   call setupinterpolation(latb,lonb,jcap,intlat,intlon,w00,w10,w01,w11,idx,idxp,idy,idyp)

   write(6,*) "Finish the interpolation setting"

   allocate(temp1d(lonb*latb))
   allocate(temp2d(lonb,latb))

!! Pressure field
    call nemsio_readrecv(gfile1,'pres','sfc',1,temp1d,iret=iret)
    if ( iret .ne. 0 ) then
       write(6,*) "iret=",iret
       call exit(iret)
    end if
    temp2d=reshape(temp1d,(/lonb,latb/))
    varval=temp2d(idx,idy)*w00+temp2d(idx,idyp)*w01+&
           temp2d(idxp,idy)*w10+temp2d(idxp,idyp)*w11
    allocate(prsi(nsig+1),prsl(nsig)) 
!          open(28,file="Pressure.dat",form="formatted")
    ps=varval
    write(6,*) "The surface pressure of taget = ",ps
    do k=1,nsig+1
       revk=(nsig+1)-k+1
        prsi(revk)=ak5(k)+(bk5(k)*ps)
    end do
    do k=1,nsig
       revk=nsig-k+1
        prsl(revk)=((prsi(revk)**kap1-prsi(revk+1)**kap1)/&
                (kap1*(prsi(revk)-prsi(revk+1))))**kapr
    end do
    write(6,*) "Process Level Pressure and Mid-Layer Pressure"
!! Temperature field
    allocate(tmp(nsig))
    do k=1,nsig
       call nemsio_readrecv(gfile1,'tmp','mid layer',k,temp1d,iret=iret)
            temp2d=reshape(temp1d,(/lonb,latb/))
            varval=temp2d(idx,idy)*w00+temp2d(idx,idyp)*w01+&
                   temp2d(idxp,idy)*w10+temp2d(idxp,idyp)*w11
       revk=nsig-k+1
       tmp(revk)=varval
    end do
    write(6,*) "Process Temperature"
!! Water vapor mixing ratio (H2O Mixing ratio)
!! Modification needed for other sensor, can check gsi/crtm_interface.f90
    allocate(spfh(nsig),wvmr(nsig))
    do k=1,nsig
       call nemsio_readrecv(gfile1,'spfh','mid layer',k,temp1d,iret=iret)
            temp2d=reshape(temp1d,(/lonb,latb/))
            varval=temp2d(idx,idy)*w00+temp2d(idx,idyp)*w01+&
                   temp2d(idxp,idy)*w10+temp2d(idxp,idyp)*w11
       revk=nsig-k+1
       spfh(revk)=max(qsmall,varval)
       c3=1./(1.-spfh(revk))
       wvmr(revk)=1000.0*spfh(revk)*c3
    end do
    write(6,*) "Process Specific humidity and water vapor mixing ratio"
!! Ozone
    allocate(o3mr(nsig))
    do k=1,nsig
       call nemsio_readrecv(gfile1,'o3mr','mid layer',k,temp1d,iret=iret)
            temp2d=reshape(temp1d,(/lonb,latb/))
            varval=temp2d(idx,idy)*w00+temp2d(idx,idyp)*w01+&
                   temp2d(idxp,idy)*w10+temp2d(idxp,idyp)*w11
       revk=nsig-k+1
       o3mr(revk)=varval
    end do
    write(6,*) "Process Ozone mixing ratio"
!! Cloud? 
!! Finish the variable in gdas
   deallocate(temp1d,temp2d)
!! 
!! To determine effective radius, needs relative humidity.
!! genqsat require tsen(sensible temperature)
!!  
   allocate(tsen(nsig))
   do k=1,nsig
      tv=tmp(k)*(1.+fv*spfh(k))
      tsen(k)=tv/(1.+fv*max(0.,spfh(k)))
   end do
!!
!! Generate qsat, code comes from GSI, genqsat.f90
!!
   mint=340.
   lmint=1
   do k=1,nsig
      if((prsl(k) < 30000.0 .and.  &
          prsl(k) > 2000.0) .and.  &
          tsen(k) < mint)then
          lmint=k 
          mint=tsen(k)
      end if
   end do
   write(6,*) lmint,mint
   tdry = mint
   tr = ttp/tdry
   if (tdry >= ttp .or. .not. ice) then
      estmax = psat * (tr**xa) * exp(xb*(1.0-tr))
   elseif (tdry < tmix) then
      estmax = psat * (tr**xai) * exp(xbi*(1.0-tr))
   else
      w  = (tdry - tmix) / (ttp - tmix)
      estmax =  w * psat * (tr**xa) * exp(xb*(1.0-tr)) &
              + (1.0-w) * psat * (tr**xai) * exp(xbi*(1.0-tr))
   endif
   allocate(qsat(nsig),rh(nsig))
   do k=1,nsig
      tdry = tsen(k)
      tr = ttp/tdry
      if (tdry >= ttp .or. .not. ice) then
         es = psat * (tr**xa) * exp(xb*(1.0-tr))
      elseif (tdry < tmix) then
         es = psat * (tr**xai) * exp(xbi*(1.0-tr))
      else
         !esw = psat * (tr**xa) * exp(xb*(1.0-tr))
         !esi = psat * (tr**xai) * exp(xbi*(1.0-tr))
         w  = (tdry - tmix) / (ttp - tmix)
         es =  w * psat * (tr**xa) * exp(xb*(1.0-tr)) &
                  + (1.0-w) * psat * (tr**xai) * exp(xbi*(1.0-tr))
      end if
      pw = prsl(k)
      esmax = es
      if(lmint > k )then
         esmax=0.1*pw
         esmax=min(esmax,estmax)
      end if
      es2=min(es,esmax)
      qsat(k) = eps * es2 / (pw - omeps * es2)
      rh(k)=spfh(k)/qsat(k)
      !write(6,*) spfh(k),qsat(k),rh(k)
   end do
!!
!! NGAC Aerosol read in
!!
!! Convert coefficient for mixing ratio to mass concentration
   allocate(kgkg_kgm2(nsig))
   do k=1,nsig
      kgkg_kgm2(k)=(prsi(k+1)-prsi(k))/grav
   end do

   call nemsio_open(gfile2,ngacfile,'READ',iret=iret)
       if (iret.ne.0) write(6,*) 'open ',ngacfile,' error'

   call nemsio_getfilehead(gfile2, iret=iret, dimx=lonb, dimy=latb, dimz=nsig ,jcap=jcap)  
   
   call setupinterpolation(latb,lonb,jcap,intlat,intlon,w00,w10,w01,w11,idx,idxp,idy,idyp)

!! (:,1): mass concentration, (:,2): effective radius
   allocate(so4(nsig,2),oc1(nsig,2),oc2(nsig,2),bc1(nsig,2),bc2(nsig,2))
   allocate(dust1(nsig,2),dust2(nsig,2),dust3(nsig,2),dust4(nsig,2),dust5(nsig,2))
   allocate(seas1(nsig,2),seas2(nsig,2),seas3(nsig,2),seas4(nsig,2))

   allocate(temp1d(lonb*latb))
   allocate(temp2d(lonb,latb))

!! SO4 field
   do k=1,nsig
      call nemsio_readrecv(gfile2,'so4','mid layer',k,temp1d,iret=iret)
      temp2d=reshape(temp1d,(/lonb,latb/))
      varval=temp2d(idx,idy)*w00+temp2d(idx,idyp)*w01+&
             temp2d(idxp,idy)*w10+temp2d(idxp,idyp)*w11
      revk=nsig-k+1
      so4(revk,1)=varval*kgkg_kgm2(revk)
      so4(revk,2)=GOCART_Aerosol_size(1,SULFATE_AEROSOL,rh(revk))
   end do   
   write(6,*) "Process Sulfate mass concentration and effective radius"
!! OC1 field
   do k=1,nsig
      call nemsio_readrecv(gfile2,'ocphobic','mid layer',k,temp1d,iret=iret)
      temp2d=reshape(temp1d,(/lonb,latb/))
      varval=temp2d(idx,idy)*w00+temp2d(idx,idyp)*w01+&
             temp2d(idxp,idy)*w10+temp2d(idxp,idyp)*w11
      revk=nsig-k+1
      oc1(revk,1)=varval*kgkg_kgm2(revk)
      oc1(revk,2)=GOCART_Aerosol_size(1,ORGANIC_CARBON_AEROSOL,rh(revk))
   end do   
   write(6,*) "Process OCPhobic mass concentration and effective radius"
!! OC2 field
   do k=1,nsig
      call nemsio_readrecv(gfile2,'ocphilic','mid layer',k,temp1d,iret=iret)
      temp2d=reshape(temp1d,(/lonb,latb/))
      varval=temp2d(idx,idy)*w00+temp2d(idx,idyp)*w01+&
             temp2d(idxp,idy)*w10+temp2d(idxp,idyp)*w11
      revk=nsig-k+1
      oc2(revk,1)=varval*kgkg_kgm2(revk)
      oc2(revk,2)=GOCART_Aerosol_size(2,ORGANIC_CARBON_AEROSOL,rh(revk))
   end do   
   write(6,*) "Process OCPhilic mass concentration and effective radius"
!! BC1 field
   do k=1,nsig
      call nemsio_readrecv(gfile2,'bcphobic','mid layer',k,temp1d,iret=iret)
      temp2d=reshape(temp1d,(/lonb,latb/))
      varval=temp2d(idx,idy)*w00+temp2d(idx,idyp)*w01+&
             temp2d(idxp,idy)*w10+temp2d(idxp,idyp)*w11
      revk=nsig-k+1
      bc1(revk,1)=varval*kgkg_kgm2(revk)
      bc1(revk,2)=GOCART_Aerosol_size(1,BLACK_CARBON_AEROSOL,rh(revk))
   end do   
!! BC2 field
   do k=1,nsig
      call nemsio_readrecv(gfile2,'bcphilic','mid layer',k,temp1d,iret=iret)
      temp2d=reshape(temp1d,(/lonb,latb/))
      varval=temp2d(idx,idy)*w00+temp2d(idx,idyp)*w01+&
             temp2d(idxp,idy)*w10+temp2d(idxp,idyp)*w11
      revk=nsig-k+1
      bc2(revk,1)=varval*kgkg_kgm2(revk)
      bc2(revk,2)=GOCART_Aerosol_size(2,BLACK_CARBON_AEROSOL,rh(revk))
   end do   
!! Dust1 field
   do k=1,nsig
      call nemsio_readrecv(gfile2,'du001','mid layer',k,temp1d,iret=iret)
      temp2d=reshape(temp1d,(/lonb,latb/))
      varval=temp2d(idx,idy)*w00+temp2d(idx,idyp)*w01+&
             temp2d(idxp,idy)*w10+temp2d(idxp,idyp)*w11
      revk=nsig-k+1
      dust1(revk,1)=varval*kgkg_kgm2(revk)
      dust1(revk,2)=GOCART_Aerosol_size(1,DUST_AEROSOL,rh(revk))
   end do   
!! Dust2 field
   do k=1,nsig
      call nemsio_readrecv(gfile2,'du002','mid layer',k,temp1d,iret=iret)
      temp2d=reshape(temp1d,(/lonb,latb/))
      varval=temp2d(idx,idy)*w00+temp2d(idx,idyp)*w01+&
             temp2d(idxp,idy)*w10+temp2d(idxp,idyp)*w11
      revk=nsig-k+1
      dust2(revk,1)=varval*kgkg_kgm2(revk)
      dust2(revk,2)=GOCART_Aerosol_size(2,DUST_AEROSOL,rh(revk))
   end do   
!! Dust3 field
   do k=1,nsig
      call nemsio_readrecv(gfile2,'du003','mid layer',k,temp1d,iret=iret)
      temp2d=reshape(temp1d,(/lonb,latb/))
      varval=temp2d(idx,idy)*w00+temp2d(idx,idyp)*w01+&
             temp2d(idxp,idy)*w10+temp2d(idxp,idyp)*w11
      revk=nsig-k+1
      dust3(revk,1)=varval*kgkg_kgm2(revk)
      dust3(revk,2)=GOCART_Aerosol_size(3,DUST_AEROSOL,rh(revk))
   end do   
!! Dust4 field
   do k=1,nsig
      call nemsio_readrecv(gfile2,'du004','mid layer',k,temp1d,iret=iret)
      temp2d=reshape(temp1d,(/lonb,latb/))
      varval=temp2d(idx,idy)*w00+temp2d(idx,idyp)*w01+&
             temp2d(idxp,idy)*w10+temp2d(idxp,idyp)*w11
      revk=nsig-k+1
      dust4(revk,1)=varval*kgkg_kgm2(revk)
      dust4(revk,2)=GOCART_Aerosol_size(4,DUST_AEROSOL,rh(revk))
   end do   
!! Dust5 field
   do k=1,nsig
      call nemsio_readrecv(gfile2,'du005','mid layer',k,temp1d,iret=iret)
      temp2d=reshape(temp1d,(/lonb,latb/))
      varval=temp2d(idx,idy)*w00+temp2d(idx,idyp)*w01+&
             temp2d(idxp,idy)*w10+temp2d(idxp,idyp)*w11
      revk=nsig-k+1
      dust5(revk,1)=varval*kgkg_kgm2(revk)
      dust5(revk,2)=GOCART_Aerosol_size(5,DUST_AEROSOL,rh(revk))
   end do   
!! Seas1 field ss001 and ss002 in NGAC
   allocate(temp1d1(lonb*latb))
   do k=1,nsig
      call nemsio_readrecv(gfile2,'ss001','mid layer',k,temp1d,iret=iret)
           temp1d1=temp1d
      call nemsio_readrecv(gfile2,'ss002','mid layer',k,temp1d,iret=iret)
           temp1d=temp1d+temp1d1
      temp2d=reshape(temp1d,(/lonb,latb/))
      varval=temp2d(idx,idy)*w00+temp2d(idx,idyp)*w01+&
             temp2d(idxp,idy)*w10+temp2d(idxp,idyp)*w11
      revk=nsig-k+1
      seas1(revk,1)=varval*kgkg_kgm2(revk)
      seas1(revk,2)=GOCART_Aerosol_size(1,SEASALT_SSAM_AEROSOL,rh(revk))
   end do   
!! Seas2 field ss003 in NGAC
   do k=1,nsig
      call nemsio_readrecv(gfile2,'ss003','mid layer',k,temp1d,iret=iret)
      temp2d=reshape(temp1d,(/lonb,latb/))
      varval=temp2d(idx,idy)*w00+temp2d(idx,idyp)*w01+&
             temp2d(idxp,idy)*w10+temp2d(idxp,idyp)*w11
      revk=nsig-k+1
      seas2(revk,1)=varval*kgkg_kgm2(revk)
      seas2(revk,2)=GOCART_Aerosol_size(2,SEASALT_SSCM1_AEROSOL,rh(revk))
   end do   
!! Seas3 field ss004 in NGAC
   do k=1,nsig
      call nemsio_readrecv(gfile2,'ss004','mid layer',k,temp1d,iret=iret)
      temp2d=reshape(temp1d,(/lonb,latb/))
      varval=temp2d(idx,idy)*w00+temp2d(idx,idyp)*w01+&
             temp2d(idxp,idy)*w10+temp2d(idxp,idyp)*w11
      revk=nsig-k+1
      seas3(revk,1)=varval*kgkg_kgm2(revk)
      seas3(revk,2)=GOCART_Aerosol_size(3,SEASALT_SSCM2_AEROSOL,rh(revk))
   end do   
!! Seas4 field ss005 in NGAC
   do k=1,nsig
      call nemsio_readrecv(gfile2,'ss005','mid layer',k,temp1d,iret=iret)
      temp2d=reshape(temp1d,(/lonb,latb/))
      varval=temp2d(idx,idy)*w00+temp2d(idx,idyp)*w01+&
             temp2d(idxp,idy)*w10+temp2d(idxp,idyp)*w11
      revk=nsig-k+1
      seas4(revk,1)=varval*kgkg_kgm2(revk)
      seas4(revk,2)=GOCART_Aerosol_size(4,SEASALT_SSCM3_AEROSOL,rh(revk))
   end do   

!! Write out the CRTM profile
write(clnum,'(I3)') nsig
write(clnum1,'(I3)') nsig+1
r3doutfmt="(A24,1x,"//trim(adjustl(clnum))//"(ES14.7,1x))"
r3doutfmt1="(A24,1x,"//trim(adjustl(clnum1))//"(ES14.7,1x))"

   open(27,file=trim(filenameout),form="formatted")
     write(27,r3doutfmt1) "LevelPressure=",prsi
       write(6,*) "Writing out Level Pressure"
     write(27,r3doutfmt) "Pressure=",prsl
       write(6,*) "Writing out mid-Layer Pressure"
     write(27,r3doutfmt) "Temperature=",tmp
       write(6,*) "Writing out Temperature"
     write(27,r3doutfmt) "WaterVaporMixingRatio=",wvmr
       write(6,*) "Writing out Water Vapor Mixing Ratio"
     write(27,r3doutfmt) "Ozone_MixingRatio=",o3mr
       write(6,*) "Writing out Ozone Mixing Ratio"
     write(27,r3doutfmt) "Sulfate_MixingRatio=",so4(:,1)
       write(6,*) "Writing out Sulfate Mixing Ratio"
     write(27,r3doutfmt) "Sulfate_Reff=",so4(:,2)
       write(6,*) "Writing out Sulfate Reff"
     write(27,r3doutfmt) "OCPHOBIC_MixingRatio=",oc1(:,1)
       write(6,*) "Writing out OCPHOBIC Mixing Ratio"
     write(27,r3doutfmt) "OCPHOBIC_Reff=",oc1(:,2) ! OCPHOBIC Reff 
       write(6,*) "Writing out OCPHOBIC Reff"
     write(27,r3doutfmt) "OCPHILIC_MixingRatio=",oc2(:,1) ! OCPHILIC mixing ratio
       write(6,*) "Writing out OCPHILIC Mixing Ratio"
     write(27,r3doutfmt) "OCPHILIC_Reff=",oc2(:,2) ! OCPHILIC Reff 
       write(6,*) "Writing out OCPHILIC Reff"
     write(27,r3doutfmt) "BCPHOBIC_MixingRatio=",bc1(:,1) ! BCPHOBIC mixing ratio
       write(6,*) "Writing out BCPHOBIC Mixing Ratio"
     write(27,r3doutfmt) "BCPHOBIC_Reff=",bc1(:,2) ! BCPHOBIC Reff 
       write(6,*) "Writing out BCPHOBIC Reff"
     write(27,r3doutfmt) "BCPHILIC_MixingRatio=",bc2(:,1) ! BCPHILIC mixing ratio
       write(6,*) "Writing out BCPHILIC Mixing Ratio"
     write(27,r3doutfmt) "BCPHILIC_Reff=",bc2(:,2) ! BCPHILIC Reff 
       write(6,*) "Writing out BCPHILIC Reff"

     write(27,r3doutfmt) "DUST1 mixing ratio=",dust1(:,1) ! DUST1 mixing ratio
       write(6,*) "Writing out DUST1 Mixing Ratio"
     write(27,r3doutfmt) "DUST1_Reff=",dust1(:,2) ! DUST1 Reff 
       write(6,*) "Writing out DUST1 Reff"
     write(27,r3doutfmt) "DUST2_MixingRatio=",dust2(:,1) ! DUST2 mixing ratio
       write(6,*) "Writing out DUST2 Mixing Ratio"
     write(27,r3doutfmt) "DUST2_Reff=",dust2(:,2) ! DUST2 Reff 
       write(6,*) "Writing out DUST2 Reff"
     write(27,r3doutfmt) "DUST3_MixingRatio=",dust3(:,1) ! DUST3 mixing ratio
       write(6,*) "Writing out DUST3 Mixing Ratio"
     write(27,r3doutfmt) "DUST3_Reff=",dust3(:,2) ! DUST3 Reff 
       write(6,*) "Writing out DUST3 Reff"
     write(27,r3doutfmt) "DUST4_MixingRatio=",dust4(:,1) ! DUST4 mixing ratio
       write(6,*) "Writing out DUST4 Mixing Ratio"
     write(27,r3doutfmt) "DUST4_Reff=",dust4(:,2) ! DUST4 Reff 
       write(6,*) "Writing out DUST4 Reff"
     write(27,r3doutfmt) "DUST5_MixingRatio=",dust5(:,1) ! DUST5 mixing ratio
       write(6,*) "Writing out DUST5 Mixing Ratio"
     write(27,r3doutfmt) "DUST5_Reff=",dust5(:,2) ! DUST5 Reff 
       write(6,*) "Writing out DUST5 Reff"

     write(27,r3doutfmt) "SEAS1_MixingRatio=",seas1(:,1) ! SEAS1 mixing ratio
       write(6,*) "Writing out SEAS1 Mixing Ratio"
     write(27,r3doutfmt) "SEAS1_Reff=",seas1(:,2) ! SEAS1 Reff 
       write(6,*) "Writing out SEAS1 Reff"
     write(27,r3doutfmt) "SEAS2_MixingRatio=",seas2(:,1) ! SEAS2 mixing ratio
       write(6,*) "Writing out SEAS2 Mixing Ratio"
     write(27,r3doutfmt) "SEAS2_Reff=",seas2(:,2) ! SEAS2 Reff 
       write(6,*) "Writing out SEAS2 Reff"
     write(27,r3doutfmt) "SEAS3_MixingRatio=",seas3(:,1) ! SEAS3 mixing ratio
       write(6,*) "Writing out SEAS3 Mixing Ratio"
     write(27,r3doutfmt) "SEAS3_Reff=",seas3(:,2) ! SEAS3 Reff 
       write(6,*) "Writing out SEAS3 Reff"
     write(27,r3doutfmt) "SEAS4_MixingRatio=",seas4(:,1) ! SEAS4 mixing ratio
       write(6,*) "Writing out SEAS4 Mixing Ratio"
     write(27,r3doutfmt) "SEAS4_Reff=",seas4(:,2) ! SEAS4 Reff 
       write(6,*) "Writing out SEAS4 Reff"
   close(27)
   call nemsio_close(gfile1,iret=iret)

end program crtmprofile
