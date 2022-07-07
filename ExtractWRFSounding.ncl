;---------------------------------------------------;
;                                                   ;
;---------------------------------------------------;

;##############################################################
;                                                             #
;    Original Author contact information                      #
;                                                             #
;    Don Morton                                               #
;    Arctic Region Supercomputing Center                      #
;    University of Alaska Fairbanks                           #
;    Fairbanks, Alaska 99775                                  #
;    USA                                                      #
;                                                             #
;    Don.Morton@alaska.edu                                    #
;                                                             #
;    This software is presented freely to the public with     #
;    no restrictions on its use.  However, it would be        #
;    appreciated if any use of the software or methods in     #
;    part or in full acknowledges the source.                 #
;                                                             #
;##############################################################



; Include files
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "/home/viswany/wrfarw/Backup/softwares/ncl-tars/bin/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "/home/viswany/wrfarw/Backup/softwares/ncl-tars/bin/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "/home/viswany/wrfarw/Backup/softwares/ncl-tars/bin/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

    ;;;  These values are obtained from pre-set environment variables

;;;;;;;;  These are used for testing - comment out when operational ;;;;;;;
   wrfoutFile = "/home/nkv/Build_WRF/v4.0/WRF-4.0/test/em_real/lin-experiment/wrfout_d03_2019-08-06_18:00:00.nc"
   POINT_LAT = stringtofloat("9.948")
   POINT_LON = stringtofloat("76.267")
   asciiOutFile = "wrf2019080800_lin.txt"
;   wrfoutFile = "/wrkdir/morton/Temp/wrfout_d04_1995-10-11_16:00:00.nc"
;   wrfoutFile = "/wrkdir/morton/ICEFOG-Inversion1/2004010100/run/wrfout_d01_2004-01-01_12:00:00.nc"
;   POINT_LAT = stringtofloat("64.81")
;   POINT_LON = stringtofloat("-147.86")
;   asciiOutFile = "test.txt"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    These are used for operational - comment out when testing ;;;;;;;
;;    wrfoutFile = getenv("wrfoutFile")  ; Full path to the wrfout file  
;;    POINT_LAT = stringtofloat( getenv("POINT_LAT") )
;;    POINT_LON = stringtofloat( getenv("POINT_LON") )
;;    asciiOutFile = getenv("asciiOutFile")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    ; Need to open the input file to convert lat/lon to x/y
    f = addfile(wrfoutFile,"r")                  ; Opens the netCDF file

    ; Convert point coordinates to x/y
    xy_point = wrf_user_ll_to_ij(f, POINT_LON, POINT_LAT, False)
    POINTX = xy_point(0)
    POINTY = xy_point(1)

    ; Get the timestamp 
;   times = chartostring(f->Times)
;   timestamp = times(0)

    ; Testing - print lat/lon retrieved
    lat = wrf_user_getvar(f, "lat", 0)
    lon = wrf_user_getvar(f, "lon", 0)

    plat = lat(POINTY, POINTX)
    plon = lon(POINTY, POINTX)

    print(plat)
    print(plon)

;;;;;;;;;;;;;;;  Model data
    ; temperature (C)
    tc = wrf_user_getvar(f, "tc", 31)
    tc1d = tc(:, POINTY, POINTX)
    ;print(tc1d)

    ; dewpoint (C)
    td = wrf_user_getvar(f, "td", 31)
    td1d = td(:, POINTY, POINTX)
    ;;print(td1d)

    ; water vapor mixing ratio (kg kg-1)
    qv = wrf_user_getvar(f, "QVAPOR", 31)
    qv1d = qv(:, POINTY, POINTX)
    ;print(qv1d)

    ; height (m)
    z = wrf_user_getvar(f, "z", 31)
    z1d = z(:, POINTY, POINTX)
    print(z1d)

    ; pressure levels (hPa)
    p = wrf_user_getvar(f, "pressure", 31)
    p1d = p(:, POINTY, POINTX)
    ;print(p1d)

    ; u and v, rotated to earth coordinates
    uvmet = wrf_user_getvar(f, "uvmet", 31)
    ;printVarSummary(uvmet)
    umet1d = uvmet(0, :, POINTY, POINTX)
    vmet1d = uvmet(1, :, POINTY, POINTX)
    ;printVarSummary(umet1d)
    ;printVarSummary(vmet1d)

    ; Express as magnitude and direction
    ;************************************************************
    ; Define a radian to deg conversion factor for u,v wind dir computations
    ;************************************************************
    R2DConvFactor = 45.0/atan(1.0)

    Wv1d = sqrt( umet1d*umet1d + vmet1d*vmet1d )
    Wd1d = atan2(umet1d, vmet1d)*R2DConvFactor + 180.0

;    printVarSummary(Wv1d)
;    printVarSummary(Wd1d)
print(Wv1d)
print(Wd1d)
print(tc1d)

    fmtString = "f7.1, 2x, f6.1, 2x, f5.1, 2x, f5.1, 2x, E11.5, 2x, f4.1, 3x, f5.1"
    num_rows = dimsizes(tc1d)
    num_rowss = dimsizes(Wv1d)
    print(num_rows)
    print(num_rowss)
    output_matrix = new( (/39, 7/), float )
    output_matrix(:,0) = z1d
    output_matrix(:,1) = p1d
    output_matrix(:,2) = tc1d
    output_matrix(:,3) = td1d
    output_matrix(:,4) = qv1d
    output_matrix(:,5) = Wv1d
    output_matrix(:,6) = Wd1d

    res = True
    res@title = " z(m)   P(hPa)   T(C)  Td(C)  Qv(kgkg-1)  Wv(m/s) Wd(deg)"
    res@fout = asciiOutFile
    write_matrix(output_matrix, fmtString, res)
 
end


