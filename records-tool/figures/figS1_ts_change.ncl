;***********************************************************
; pdf_1.ncl
;
; Concepts illustrated:
;   - Generating univariate probability distributions
;   - Generating PDFs of each sample distribution
;   - Paneling two plots horizontally on a page
;***********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "tools/trimPNG.ncl"

begin

  idir = "/home/netapp-clima-scratch/jciarlo/records/images"
  sdir = "/home/netapp-clima-scratch/jciarlo/records/"
  stat = "runmax-30"
  yr1 = "1950"
  yr2 = "2018"
  outim = idir+"/figS1_ts_change"
  formo = "png"
  wks  = gsn_open_wks ("png",outim)             ; send graphics to PNG file
  nry = 10 ; number of years of running mean

  dn = "E_OBS"
  vars = (/"pr","tas"/)
  dirs = (/"records","tas-rec"/)
  stts = (/"mean","mean"/)
  plot = new((/2/),graphic)
  dum1 = new((/2/),graphic)
  dum2 = new((/2/),graphic)
  dum3 = new((/2/),graphic)
  dum4 = new((/2/),graphic)
  
  i = 0
  do m=0, 1
    var = vars(m)
    d = dirs(m)
    ss = stts(m)

    sdir = "/home/netapp-clima-scratch/jciarlo/"+d+"/"  
    fnam = sdir+dn+"/fldtim"+ss+"/merge.nc"
    f = addfile(fnam, "r")
    v = f->$var$(:,0,0)

    pdim = dimsizes(v)
    nbins = pdim(0)
    y1 = stringtointeger(yr1)
    y2 = stringtointeger(yr2)
    bins := ispan(y1,y1-1+nbins,1)
    y1f = floattointeger(floor(int2flt(y1)/10)*10)
    y2c = floattointeger(ceil(int2flt(y2)/10)*10)
 
    vals := new ((/2,nbins/), "float")
    vals(0,:) = v(:)
    run = runave_n(v,nry,0,0)
    vals(1,:) = (/run(:)/)

    res  = True
    res@tmXTOn = False
    res@tmYROn = False
    res@gsnFrame               = False
    res@gsnDraw                = False
    res@xyMarkLineModes        = (/"Markers","Lines"/) 
    res@xyMarkers              = 16 
    res@xyLineColors           = (/"black","black"/) 
    res@xyLineThicknesses      = (/3,3,2/)
    res@xyDashPatterns         = (/0,0,1/)
    res@xyMarkerColors         = (/"blue","blue"/) 
    res@xyMarkerSizeF          = 0.004

    res@tiYAxisString = ""
    res@tiXAxisString = "year"

;   res@tiMainString           = "[Act./Est.] ann. freq. of records based on:"
    if ( dn .eq. "E_OBS" ) then
      dnttl = "E-OBS"
    else
      dnttl = dn
    end if
    if ( var .eq. "pr" ) then
      vn = "precipitation (mm/day)"
    else
      vn = "temperature (~F34~0~F~C)"
    end if
    res@gsnCenterString        = vn

  ; res@trYMaxF    = 2. 
  ; res@trYMinF    = 0.6 ;1e-10
    res@trXMinF    = y1f
    res@trXMaxF    = y2c
    plot(i) = gsn_csm_xy (wks, bins, vals, res)        ; create plot

;*****************************************************
; Manually create and attach legend
;*****************************************************
    res_text                   = True              ; text mods desired
    res_text@txFontHeightF     = 0.015             ; change text size
    res_text@txJust            = "CenterLeft"      ; text justification
 
    res_line                   = True
    res_line@gsLineColor       = "Black"
    res_line@gsLineThicknessF  = 3
 
    res_mark                   = True
    res_mark@gsMarkerIndex     = "dot"
    res_mark@gsMarkerColor     = "black"
    res_mark@gsMarkerSizeF     = 0.015
 
    tl = 1 ; target panel for legend
 
    dy = (y2-y1)*5.3/7
    xm = y1+dy
    ym = 7.5
    res_line@gsLineColor       = "black"
    res_line@gsLineDashPattern = 0
    if ( i .eq. tl ) then
      dum1(i) = gsn_add_polyline(wks,plot(i),(/xm-2,xm+1/),(/ym,ym/),res_line)
      dum2(i) = gsn_add_text(wks,plot(i),nry+"y Run. Avg.",xm+2,ym,res_text)  ; add text
    end if
 
    ym = ym-.2
    res_mark@gsMarkerColor     = "blue"      
    if ( i .eq. tl ) then
      dum3(i) = gsn_add_polymarker(wks,plot(i),xm,ym,res_mark)        ; add polyline
      dum4(i) = gsn_add_text(wks,plot(i),"Actual",xm+2,ym,res_text)  ; add text
    end if
 
    i = i + 1
  end do

;*****************************************************
; save output image
;******************************************************
 
  resP                     = True
  resP@gsnFrame            = False
; resP@gsnPanelDebug  = True
  resP@gsnPanelLeft = 0.05
  resP@gsnPanelMainString = dnttl 

  gsn_panel(wks,plot,(/1,2/),resP)               ; now draw as one plot
  frame(wks)
  draw(wks)

; maximize_output(wks,resP)

  print("saved "+outim+"."+formo)
  trimPNG(outim+"."+formo)

end
