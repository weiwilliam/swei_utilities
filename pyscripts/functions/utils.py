__all__ = ['ndate','setup_cmap','cnbestF','latlon_news','gen_eqs_by_stats']

def ndate(hinc,cdate):
    from datetime import datetime
    from datetime import timedelta
    yy=int(str(cdate)[:4])
    mm=int(str(cdate)[4:6])
    dd=int(str(cdate)[6:8])
    hh=int(str(cdate)[8:10])
    dstart=datetime(yy,mm,dd,hh)
    dnew=dstart+timedelta(hours=hinc)
    dnewint=int(str('%4.4d' % dnew.year)+str('%2.2d' % dnew.month)+
                str('%2.2d' %dnew.day)+str('%2.2d' % dnew.hour))
    return dnewint
#
# Set colormap through NCL colormap and index
#
def setup_cmap(name,idxlst):
    import platform
    os_name=platform.system()
    if (os_name=='Darwin'):
        rootpath='/Users/weiwilliam'
    elif (os_name=='Windows'):
        rootpath='F:\GoogleDrive_NCU\Albany'    
    import matplotlib.colors as mpcrs
    import numpy as np
    nclcmap=rootpath+'/AlbanyWork/Utility/colormaps'
    
    cmapname=name
    f=open(nclcmap+'/'+cmapname+'.rgb','r')
    a=[]
    for line in f.readlines():
        if ('ncolors' in line):
            clnum=int(line.split('=')[1])
        a.append(line)
    f.close()
    b=a[-clnum:]
    c=[]
    selidx=np.array(idxlst,dtype='int')
    if ('MPL' in name):
       for i in selidx[:]:
          if (i==0):
             c.append(tuple(float(y) for y in [1,1,1]))
          elif (i==1):
             c.append(tuple(float(y) for y in [0,0,0]))
          else:
             c.append(tuple(float(y) for y in b[i-2].split('#',1)[0].split()))
    else:
       for i in selidx[:]:
          if (i==0):
             c.append(tuple(float(y)/255. for y in [255,255,255]))
          elif (i==1):
             c.append(tuple(float(y)/255. for y in [0,0,0]))
          else:
             c.append(tuple(float(y)/255. for y in b[i-2].split('#',1)[0].split()))

    d=mpcrs.LinearSegmentedColormap.from_list(name,c,selidx.size)
    return d

def cnbestF(data):
    import numpy as np
    std=np.nanstd(data)
    mean=np.nanmean(data)
    vmax=np.nanmax(abs(data))
    if (vmax>5*(mean+std*3)):
        cnvmax=mean+std*4
    else:
        cnvmax=vmax
    ccnvmax='%e'%(cnvmax)
    tmp1=ccnvmax.find('-')
    tmp2=ccnvmax.find('+')
    if (tmp1<0):
        tmp=tmp2
    if (tmp2<0):
        tmp=tmp1
    d=int(ccnvmax[tmp:])
    cnmaxF=np.ceil(float(ccnvmax[:tmp-1]))*10**d
    return cnmaxF

def latlon_news(plat,plon):
    deg_sym=u'\u00B0'
    if (plat >= 0.):
        ns='N'
    else:
        ns='S'
    if (plon >= 0.):
       we='E'
    else:
       we='W'
    txlat='%.2f%s %s'%(abs(plat),deg_sym,ns)
    txlon='%.2f%s %s'%(abs(plon),deg_sym,we)
    return txlat,txlon

def gen_eqs_by_stats(stats_in):
    if (stats_in.intercept<0):
       fiteqs='$y=%.2fx–%.2f$' %(stats_in.slope,abs(stats_in.intercept))
    elif (stats_in.intercept>0):
       fiteqs='$y=%.2fx+%.2f$' %(stats_in.slope,abs(stats_in.intercept))
    else:
       fiteqs='y=%.2f*x' %(stats_in.slope)
    return fiteqs
