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




;;; Inspiration from http://www.ncl.ucar.edu/Applications/skewt.shtml

; Include files
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"

begin

    ;;;  These values are obtained from pre-set environment variables


;;;;;;;;  These are used for operational - comment out when testing ;;;;;;;
    WRF_SOUNDING = "wrfctl2009112421.csv"
    VAR_SOUNDING = "wrfall2009112421.csv"
    WRF_NUM_LEVELS = stringtoint("35")    
    RAOBS_SOUNDING = "raobs.txt"
    RAOBS_NUM_LEVELS = stringtoint("50")  
    PLOT_TITLE = "Jeddah 2009-11-24_21UTC"
    PLOT_NAME = "Skew-T21Z24NOV"
    GRAPHICS_TYPE = "ps"
;;;''''    GRAPHICS_TYPE = "x11"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;  These are used for testing - comment out when operational  ;;;;;;;
;   WRF_SOUNDING = "/wrkdir/morton/ARSCHRRR-v2-OPNL-SCRATCH/filevRUsPT/wrf.txt"
;   WRF_NUM_LEVELS = stringtoint("50")
;   RAOBS_SOUNDING = "/wrkdir/morton/ARSCHRRR-v2-OPNL-SCRATCH/filevRUsPT/raobs.txt"
;   RAOBS_NUM_LEVELS = stringtoint("56")
;   PLOT_TITLE = "PAFA     2010-07-28_12Z"    
;   PLOT_NAME = "Test"    
;   GRAPHICS_TYPE = "ps"   ;  [ eps | x11 | ps | ... ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    ;;;;;; Read in wrfsound data
    wrfsound = asciiread(WRF_SOUNDING, (/WRF_NUM_LEVELS,6/), "float")
    wrf_p = wrfsound(:,0)
    wrf_tc = wrfsound(:,1)
    wrf_tdc = wrfsound(:,2) 
    wrf_z = wrfsound(:,3)
    wrf_wv = wrfsound(:,4) * 1.94  ; convert from m/s to kts (1 m/s = 1.94 kts)
    wrf_wd = wrfsound(:,5)

    varsound = asciiread(VAR_SOUNDING, (/WRF_NUM_LEVELS,6/), "float")
    var_p = varsound(:,0)
    var_tc = varsound(:,1)
    var_tdc = varsound(:,2)
    var_z = varsound(:,3)
    var_wv = varsound(:,4) * 1.94  ; convert from m/s to kts (1 m/s = 1.94 kts)
    var_wd = varsound(:,5)



    ;;;;;; Read in raobs data
    sounding = asciiread(RAOBS_SOUNDING, (/RAOBS_NUM_LEVELS,6/), "float")
    sounding_p = sounding(:,0)
    sounding_tc = sounding(:,1)
    sounding_td = sounding(:,2)
    sounding_z = sounding(:,3)
    sounding_wv = sounding(:,4)   ; this should come in as knots
    sounding_wd = sounding(:,5)   


    ;*************************
    ; create plot
    ;*************************
    wks  = gsn_open_wks (GRAPHICS_TYPE, PLOT_NAME)

; --- Create background skew-T and plot sounding----------------

    skewtOpts                 = True
    skewtOpts@DrawColAreaFill = True    ; default is False
    skewtOpts@DrawFahrenheit   = False    ; default is True
    skewtOpts@tiMainString    = PLOT_TITLE 

    skewt_bkgd = skewT_BackGround(wks, skewtOpts)
    draw (skewt_bkgd)

    dataOpts                  = True     ; options describing data and ploting
    dataOpts@DrawFahrenheit   = False    ; default is True
    dataOpts@PrintZ           = False    ; do not print Z 
    dataOpts@ThermoInfo       = True     ; print thermodynamic info

;*****************************************************************
; First sounding (WRF)
;*****************************************************************
    dataOpts@colTemperature   = "black"
;;    dataOpts@colTemperature   = "blue"
    dataOpts@colDewPt         = dataOpts@colTemperature
;;    dataOpts@colWindP        = dataOpts@colTemperature
    dataOpts@linePatternDewPt = 1
    dataOpts@xpWind           = 48.     ; move to left [default is 45]
    skewt_data = skewT_PlotData(wks, skewt_bkgd, wrf_p, wrf_tc,wrf_tdc,wrf_z, wrf_wv,wrf_wd, dataOpts)
    draw (skewt_data)
                                       
;*****************************************************************
; Second sounding (WRF)
;*****************************************************************
   dataOpts@colTemperature   = "blue"
    dataOpts@colDewPt         = dataOpts@colTemperature
    dataOpts@colWindP        = dataOpts@colTemperature
    dataOpts@linePatternDewPt = 1
    dataOpts@xpWind           = 56.     ; move to left [default is 45]
    skewt_data = skewT_PlotData(wks, skewt_bkgd, var_p, var_tc,var_tdc,var_z, var_wv,var_wd, dataOpts)
    draw (skewt_data)
;*****************************************************************
; Second sounding (raobs)
;*****************************************************************

  dataOpts@Wthin     = 3        ; plot every n-th wind barb
  dataOpts@xpWind    = 40.      ; new location for winds [default 45]
  dataOpts@colTemperature  = "red"
  dataOpts@colDewPt        = dataOpts@colTemperature
  dataOpts@colWindP        = dataOpts@colTemperature
  
  skewt_data = skewT_PlotData(wks, skewt_bkgd, sounding_p,sounding_tc,sounding_td,sounding_z, sounding_wv,sounding_wd, dataOpts)


    ; Legend
     colorList = (/"red", "black", "blue"/)
    legendList = (/"Raobs", "CTL", "VARALL"/)
    lgres = True
;   lgres@gsnMaximize = True
    lgres@lgLineColors     = colorList
    lgres@lgItemType         = "Lines"        ; show lines only (default)
    lgres@lgLabelFontHeightF = 0.05           ; set the legend label font thickness
    lgres@lgMonoLineDashSegLen = True
    lgres@lgLineDashSegLenF = 5.00
    lgres@lgLineThicknessF = 4.00
    lgres@vpWidthF           = 0.22           ; width of legend (NDC)
    lgres@vpHeightF          = 0.07           ; height of legend (NDC)
    lgres@lgPerimColor       = "white"         ; draw the box perimeter
    lgres@lgPerimThicknessF  = 1.0            ; thicken the box perimeter

    ; create legend
    lbid = gsn_create_legend(wks, 3, legendList,lgres)

    amres = True
;   amres@gsnMaximize = True
    amres@amParallelPosF   =  0.33            ; move legend (-left/+right)
    amres@amOrthogonalPosF = -0.54            ; move legend (-up/+down)
    annoid1 = gsn_add_annotation(skewt_data,lbid,amres)   ; add legend to plot

  draw (skewt_data) 
  

  frame(wks)

;;;;system("convert -trim -density 100x100 "+wks_name+".png "+wks_name+".png")

end
