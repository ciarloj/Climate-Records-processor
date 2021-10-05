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

  var = "n"
  idir = "/home/netapp-clima-scratch/jciarlo/records/images"
  sdir = "/home/netapp-clima-scratch/jciarlo/records/"
  stat = "runmax-30"
  yr1 = "1970"
  yr2 = "2100"
  outim = idir+"/fig7_ratio_rcm_rcps"
  formo = "png"
  wks  = gsn_open_wks ("png",outim)             ; send graphics to PNG file
  nry = 10 ; number of years of running mean

  dns = (/"REGCM-MPI-85","REMO-MPI-85","REGCM-MPI-26","REMO-MPI-26"/)
  plot = new((/4/),graphic)
  dum1 = new((/4/),graphic)
  dum2 = new((/4/),graphic)
  dum3 = new((/4/),graphic)
  dum4 = new((/4/),graphic)
  dum5 = new((/4/),graphic)
  dum6 = new((/4/),graphic)
  dum7 = new((/4/),graphic)
  dum8 = new((/4/),graphic)
  dum9 = new((/4/),graphic)
  dum10 = new((/4/),graphic)
  dum11 = new((/4/),graphic)
  
  i = 0
  do m=0, 3
    dn = dns(m)

    fnam = sdir+dn+"/trim/"+stat+"/records/sum/index_fld_norm.nc"
    f = addfile(fnam, "r")
    v = f->n(:,0,0)

    pdim = dimsizes(v)
    nbins = pdim(0)
    y1 = stringtointeger(yr1)
    y2 = stringtointeger(yr2)
    bins := ispan(y1,y1-1+nbins,1)
    y1f = floattointeger(floor(int2flt(y1)/10)*10)
    y2c = floattointeger(ceil(int2flt(y2)/10)*10)
;------------------------------------------------
; Plot each PDF
;------------------------------------------------
    recs := new ((/3,nbins/), "float")
    recs(1,:) = v(:)
    do k =1, nbins
      recs(0,k-1) = 1.0/k
     ;print("k="+k+" recs="+recs(0,k-1))
    end do
 
    rat = recs(1,:)/recs(0,:)
    run = runave_n(rat,nry,0,0)
    recs(0,:) = (/rat(:)/)
    recs(1,:) = (/run(:)/)

    rcl = regline_stats(bins,run)
   ;print(rcl) 
    mval = rcl
    cval = rcl@yintercept
    rval = rcl@r2
    df   = rcl@N-2 ;rcl@nptxy-2
    ssig = betainc(df/(df+mval^2), df/2.0, 0.5)

    ratv = bins ;ispan(1,nbins,1)
    ratv := (ratv*mval)+cval
    recs(2,:) = (/ratv(:)/)

    res  = True
    res@tmXTOn = False
    res@tmYROn = False
    res@gsnFrame               = False
    res@gsnDraw                = False
    res@xyMarkLineModes        = (/"Markers","Lines","Lines"/) 
    res@xyMarkers              = 16 
    res@xyLineColors           = (/"black","black","black"/) 
    res@xyLineThicknesses      = (/3,3,2/)
    res@xyDashPatterns         = (/0,0,1/)
    res@xyMarkerColors         = (/"blue","blue","blue"/) 
    res@xyMarkerSizeF          = 0.004

    if ( i .eq. 1 .or. i .eq. 3 ) then
      res@tiYAxisString = ""
      res@tmYLOn = False
    else
      res@tiYAxisString = "frequency ratio (actual/expected)"
      res@tmYLOn = True
    end if 
    if (i .lt. 2 ) then
      res@tiXAxisString = ""
      res@tmXBOn = False
    else
      res@tiXAxisString = "year"
      res@tmXBOn = True
    end if

    res@vpWidthF  = 0.405887
    res@vpHeightF = res@vpWidthF
    if ( i .eq. 0 .or. i .eq. 2 ) then
      res@vpXF = 0.0892111
    else 
      res@vpXF = 0.50 ;; 0.589211  ;; mod target
    end if
    if ( i .lt. 2 ) then
      res@vpYF = 0.91 ;; 0.942743  ;; mod target
    else
      res@vpYF = 0.472826 
    end if

;   res@tiMainString           = "[Act./Est.] ann. freq. of records based on:"
    if ( dn .eq. "E_OBS" ) then
      dnttl = "E-OBS"
    else
      dnttl = dn
    end if
    res@gsnCenterString        = dnttl  ;dn+" "+snam

    res@trYMaxF    = 2. 
    res@trYMinF    = 0.6 ;1e-10
    res@trXMinF    = y1f
    res@trXMaxF    = y2c
    res@tmYLMode = "Manual"
    res@tmYLTickStartF = 0.
    res@tmYLTickEndF = 1.99
    res@tmYLTickSpacingF = 0.2
    plot(i) = gsn_csm_xy (wks, bins, recs, res)        ; create plot

;*****************************************************
; Manually create and attach legend
;*****************************************************
    res_text                   = True              ; text mods desired
    res_text@txFontHeightF     = 0.008             ; change text size
    res_text@txJust            = "CenterLeft"      ; text justification

    res_line                   = True
    res_line@gsLineColor       = "Black"
    res_line@gsLineThicknessF  = 3

    res_mark                   = True
    res_mark@gsMarkerIndex     = "dot"
    res_mark@gsMarkerColor     = "black"
    res_mark@gsMarkerSizeF     = 0.015

    tl = 0 ; target panel for legend

    dy = (y2-y1)*5.5/7
    xm = y1+dy
    if ( i .eq. tl ) then
      ym = 0.90
    else
      ym = 0.80
    end if
    res_line@gsLineDashPattern = 2
    if ( i .eq. tl ) then
      dum1(i) = gsn_add_polyline(wks,plot(i),(/xm-2,xm+1/),(/ym,ym/),res_line)
      dum2(i) = gsn_add_text(wks,plot(i),"Expected",xm+2,ym,res_text)  ; add text
    end if

    ym = ym-.05
    res_line@gsLineColor       = "black"
    res_line@gsLineDashPattern = 1
    if ( i .eq. tl ) then
      dum3(i) = gsn_add_polyline(wks,plot(i),(/xm-2,xm+1/),(/ym,ym/),res_line)
      dum4(i) = gsn_add_text(wks,plot(i),"Linear Trend",xm+2,ym,res_text)  ; add text
    end if

    ym = ym-.05
    mv_mul = mval*1000000
    mv_rnd = round(mv_mul,1)
    mval = mv_rnd/10000
    mv_t = flt2string(mval)
    dum5(i) = gsn_add_text(wks,plot(i),"m  = "+mv_t+"x10~S~-3~N~",xm,ym,res_text)  ; add text

    ym = ym-.05
    rv_mul = rval*10000
    rv_rnd = round(rv_mul,1)
    rval = rv_rnd/10000
    rv_t = flt2string(rval)
    dum6(i) = gsn_add_text(wks,plot(i),"R~S~2~N~ = "+rv_t,xm,ym,res_text)  ; add text

    ym = ym-.05
    res_line@gsLineColor       = "black"
    res_line@gsLineDashPattern = 0
    if ( i .eq. tl ) then
      dum7(i) = gsn_add_polyline(wks,plot(i),(/xm-2,xm+1/),(/ym,ym/),res_line)
      dum8(i) = gsn_add_text(wks,plot(i),nry+"y Run. Avg.",xm+2,ym,res_text)  ; add text
    end if

    ym = ym-.05
    res_mark@gsMarkerColor     = "blue"      
    if ( i .eq. tl ) then
      dum9(i) = gsn_add_polymarker(wks,plot(i),xm,ym,res_mark)        ; add polyline
      dum10(i) = gsn_add_text(wks,plot(i),"Actual",xm+2,ym,res_text)  ; add text
    end if

    res_line@gsLineThicknessF  = 3
    res_line@gsLineDashPattern = 2
    dum11(i) = gsn_add_polyline(wks,plot(i),(/y1f,y2c/),(/1.0,1.0/),res_line)

    i = i + 1
  end do

;*****************************************************
; save output image
;******************************************************
 
  resP                     = True
; resP@gsnFrame            = False
; resP@gsnPanelDebug  = True
; resP@gsnPanelLeft = 0.05

;  gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot
;  frame(wks)
;  draw(wks)

  maximize_output(wks,resP)

  print("saved "+outim+"."+formo)
  trimPNG(outim+"."+formo)

end
