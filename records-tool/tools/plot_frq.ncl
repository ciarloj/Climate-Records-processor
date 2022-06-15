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
  ;idir = "images"
  ;stat = "day"
  ;fnam = "dir/index_fld_norm.nc"
  outim = idir+"/frq_"+dn+"_"+stat
  formo = "png"
  wks  = gsn_open_wks ("png",outim)             ; send graphics to PNG file

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
  recs := new ((/2,nbins/), "float")
  recs(1,:) = v(:)
  do k =1, nbins
    recs(0,k-1) = 1.0/k
   ;print("k="+k+" recs="+recs(0,k-1))
  end do

  res  = True
  res@tmXTOn = False
  res@tmYROn = False
  res@gsnFrame               = False
  res@gsnDraw                = False
  res@xyMarkLineModes        = (/"Lines","Markers"/)
  res@xyMarkers              = (/16,16/)
  res@xyMarkerColors         = (/"Black","Blue"/)
  res@xyMarkerSizeF          = 0.005
  res@xyLineColors           = (/"Black", "Blue"/)
  res@xyLineThicknesses      = (/3,3/)
  res@xyDashPatterns         = (/0,0/)

  res@tiYAxisString          = "frequency (#)"
  res@tiXAxisString          = "year"
; res@tiMainString           = "Annual frequency of records based on:"
  if ( dn .eq. "E_OBS" ) then
    dnttl = "E-OBS"
  else
    dnttl = dn
  end if
  res@gsnCenterString        = dnttl  ;dn+" "+snam

  res@trYLog = True
  res@trYMaxF    = 1. 
  res@trYMinF    = 1e-2 ;1e-10 
  res@trXMinF    = y1f
  res@trXMaxF    = y2c
  plot = gsn_csm_xy (wks, bins, recs, res)        ; create plot

;*****************************************************
; Manually create and attach legend
;*****************************************************
  res_text                   = True              ; text mods desired
  res_text@txFontHeightF     = 0.010             ; change text size
  res_text@txJust            = "CenterLeft"      ; text justification

  res_line                   = True
  res_line@gsLineColor       = "Black"
  res_line@gsLineThicknessF  = 3

  res_mark   = True
  res_mark@gsMarkerIndex     = "dot"
  res_mark@gsMarkerColor     = "black"
  res_mark@gsMarkerSizeF     = 0.020

  dy = (stringtointeger(yr2)-y1)*6/7
  xm = y1+dy
  ym = 0.8
  dum1 = gsn_add_polyline(wks,plot,(/xm-1,xm+1/),(/ym,ym/),res_line)
  dum2 = gsn_add_text(wks,plot,"Expected",xm+2,ym,res_text)  ; add text

  ym = 0.7
  res_mark@gsMarkerColor     = "blue"      
  dum3 = gsn_add_polymarker(wks,plot,xm,ym,res_mark)        ; add polyline
  dum4 = gsn_add_text(wks,plot,"Actual",xm+2,ym,res_text)  ; add text

;*****************************************************
; save output image
;******************************************************
 
  resP                     = True

  maximize_output(wks,resP)

; print("saved "+outim+"."+formo)
  trimPNG(outim+"."+formo)

end
