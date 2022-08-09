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
  ;stat = "day"
  outim = idir+"/ratios_"+dn+"_"+stat
  formo = "png"
  wks  = gsn_open_wks ("png",outim)             ; send graphics to PNG file
  nry = 10 ; number of years of running mean

  if ( stat .eq. "day" ) then
    snam = "daily pr (mm/day)"
  end if
  if ( stat .eq. "runmax-7" ) then
    snam = "weekly running max of daily pr (mm/day)"
  end if
  if ( stat .eq. "runsum-7" ) then
    snam = "weekly running total pr (mm/week)"
  end if
  if ( stat .eq. "runmax-30" ) then
    snam = "monthly running max of daily pr (mm/day)"
  end if
  if ( stat .eq. "runsum-30" ) then
    snam = "monthly running total pr (mm/mon)"
  end if
  if ( stat .eq. "timselmax-7" ) then
    snam = "weekly max of daily pr (mm/day)"
  end if
  if ( stat .eq. "timselsum-7" ) then
    snam = "weekly total pr (mm/week)"
  end if
  if ( stat .eq. "monmax" ) then
    snam = "monthly max of daily pr (mm/day)"
  end if
  if ( stat .eq. "monsum" ) then
    snam = "monthly total pr (mm/mon)"
  end if

  dnsplt = str_split(dn,"-")
  nnames := dimsizes(dnsplt)
 
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

 ;; where condition for single point testing - comment for analysis
 ;recs = where(recs.eq.0,recs@_FillValue,recs)

  rcl = regline_stats(bins,rat)
  ;print(rcl) 
  mval = rcl
  cval = rcl@yintercept
; rval = rcl@r2
; df   = rcl@N-2 ;rcl@nptxy-2
; ssig = betainc(df/(df+mval^2), df/2.0, 0.5)
  pval = rcl@pval(0)

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
  res@xyMarkerSizeF          = 0.005

  res@tiYAxisString          = "frequency ratio (actual/expected)"
  res@tiYAxisFontHeightF     = 0.03
  res@tiXAxisString          = "year"
  res@tiXAxisFontHeightF     = 0.03
; res@tiMainString           = "[Act./Est.] ann. freq. of records based on:"
  if ( dn .eq. "E_OBS" ) then
    dnttl = "E-OBS"
  else
    dnttl = dn
  end if
  if ( nnames.ge.3 ) then
    if ( dnsplt(2).eq."WAS" ) then
      dnttl = dnsplt(0)+"-"+dnsplt(1)+"-SAS"
    end if
  end if
  res@gsnCenterString        = dnttl  ;dn+" "+snam

  res@trYMaxF    = 2. 
  res@trYMinF    = 0.6 
  res@trXMinF    = y1f
  res@trXMaxF    = y2c
  res@tmYLMode = "Manual"
  res@tmYLTickStartF = 0.
  res@tmYLTickEndF = 2.
  res@tmYLTickSpacingF = 0.2
  plot = gsn_csm_xy (wks, bins, recs, res)        ; create plot

;*****************************************************
; Manually create and attach legend
;*****************************************************
  res_text                   = True              ; text mods desired
  res_text@txFontHeightF     = 0.022             ; change text size
  res_text@txJust            = "CenterLeft"      ; text justification
  res_text@txPerimSpaceF     = 0.09

  res_line                   = True
  res_line@gsLineColor       = "Black"
  res_line@gsLineThicknessF  = 3

  res_mark                   = True
  res_mark@gsMarkerIndex     = "dot"
  res_mark@gsMarkerColor     = "black"
  res_mark@gsMarkerSizeF     = 0.020

  pos = "bottomleft"
  if ( dnsplt(0).eq."APHRO" .and. dnsplt(1).eq."MA" ) then
    pos = "topleft"
  end if
  if ( dnsplt(0).eq."NAMEREXT" ) then
    pos = "topleft"
  end if
  if ( dn.eq."APHRO-MA-SEA" ) then
    pos = "bottomleft"
  end if
  if ( dn.eq."APHRO-ME" ) then
    pos = "topleft"
  end if
  if ( dn.eq."IMD" .or. dn.eq."NAMEREXT" .or. dn.eq."GCOSGHCN" ) then
    pos = "topleft"
  end if
  if ( pos.eq."topleft" ) then
    dy = (y2-y1)*0.5/7
    ym = 1.93
  else if ( pos.eq."bottomleft" ) then
    dy = (y2-y1)*0.5/7
    ym = 0.86
  else
    dy = (y2-y1)*2.5/7
    ym = 0.95
  end if
  end if
  xm = y1+dy
  res_line@gsLineDashPattern = 2
  dum1 = gsn_add_polyline(wks,plot,(/xm-2,xm+1/),(/ym,ym/),res_line)
  dum2 = gsn_add_text(wks,plot,"Expected",xm+2,ym,res_text)  ; add text

  ym = ym-.07
  res_line@gsLineColor       = "black"
  res_line@gsLineDashPattern = 1
  dum3 = gsn_add_polyline(wks,plot,(/xm-2,xm+1/),(/ym,ym/),res_line)

  mv_rnd = decimalPlaces(mval,5,True)
  mval = mv_rnd*1000
  mv_t = flt2string(mval)

  pv_rnd = decimalPlaces(pval,2,True)
  if ( pv_rnd .lt. 0.01 ) then
    pv_txt = "0.00"
  else
    pv_txt = ""+pv_rnd
  end if
  if ( pv_rnd .le. 0.05 ) then
    res_text@txBackgroundFillColor = "Gray"
  else
    res_text@txBackgroundFillColor = "Transparent"
  end if
  ststr = " ("+mv_t+", "+pv_txt+")" ; stat string
  dum4 = gsn_add_text(wks,plot,"Linear Trend"+ststr,xm+2,ym,res_text)

  res_text@txBackgroundFillColor = "Transparent"
  ym = ym-.07
  res_line@gsLineColor       = "black"
  res_line@gsLineDashPattern = 0
  dum7 = gsn_add_polyline(wks,plot,(/xm-2,xm+1/),(/ym,ym/),res_line)
  dum8 = gsn_add_text(wks,plot,nry+"y Run. Avg.",xm+2,ym,res_text)  ; add text

  ym = ym-.07
  res_mark@gsMarkerColor     = "blue"      
  dum9 = gsn_add_polymarker(wks,plot,xm,ym,res_mark)        ; add polyline
  dum10 = gsn_add_text(wks,plot,"Actual",xm+2,ym,res_text)  ; add text

  res_line@gsLineThicknessF  = 3
  res_line@gsLineDashPattern = 2
  dum11 = gsn_add_polyline(wks,plot,(/y1f,y2c/),(/1.0,1.0/),res_line)

;*****************************************************
; save output image
;******************************************************
 
  resP                     = True

  maximize_output(wks,resP)

; print("saved "+outim+"."+formo)
  trimPNG(outim+"."+formo)

end
