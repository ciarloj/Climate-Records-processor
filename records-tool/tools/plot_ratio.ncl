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

begin
  var = "n"
  ;stat = "day"
  outim = idir+"/ratios_"+dn+"_"+stat
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
  bins := ispan(y1,y1-1+nbins,1)
;------------------------------------------------
; Plot each PDF
;------------------------------------------------
  recs := new ((/2,nbins/), "float")
  recs(1,:) = v(:)
  do k =1, nbins
    recs(0,k-1) = 1.0/k
   ;print("k="+k+" recs="+recs(0,k-1))
  end do
 
  rat = recs(1,:)/recs(0,:)
  run = runave_n(rat,5,0,0)
  recs(0,:) = (/rat(:)/)
  recs(1,:) = (/run(:)/)
 
  res  = True
  res@tmXTOn = False
  res@tmYROn = False
  res@gsnFrame               = False
  res@gsnDraw                = False
  res@xyMarkLineModes        = (/"Markers","Lines"/) 
  res@xyMarkers              = 16 
  res@xyLineColors           = "blue" 
  res@xyLineThicknesses      = (/3,4/)
  res@xyDashPatterns         = (/0,0/)
  res@xyMarkerColors         = (/"blue","blue"/) 
  res@xyMarkerSizeF          = 0.005

  res@tiYAxisString          = "frequency (#)"
  res@tiMainString           = "[Act./Est.] ann. freq. of records based on:"
  res@gsnCenterString        = dn+" "+snam

  res@trYMaxF    = 2. 
  res@trYMinF    = 0. ;1e-10
  res@tmYLMode = "Manual"
  res@tmYLTickStartF = 0.
  res@tmYLTickEndF = 2.
  res@tmYLTickSpacingF = 0.2
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

  res_mark                   = True
  res_mark@gsMarkerIndex     = "dot"
  res_mark@gsMarkerColor     = "black"
  res_mark@gsMarkerSizeF     = 0.020

  y2 = stringtointeger(yr2)
  dy = (y2-y1)*5/7
  xm = y1+dy
  ym = 1.9
  dum1 = gsn_add_polyline(wks,plot,(/xm-1,xm+1/),(/ym,ym/),res_line)
  dum2 = gsn_add_text(wks,plot,"Estimate",xm+2,ym,res_text)  ; add text

  ym = 1.85
  res_mark@gsMarkerColor     = "blue"      
  dum3 = gsn_add_polymarker(wks,plot,xm,ym,res_mark)        ; add polyline
  dum4 = gsn_add_text(wks,plot,"Actual",xm+2,ym,res_text)  ; add text

  res_line                   = True
  res_line@xyMarkLineMode    = "Lines" 
  res_line@xyLineColors      = "Black"
  res_line@xyLineThicknesses = 3
  res_line@xyDashPatterns    = 1
  dum5 = gsn_add_polyline(wks,plot,(/y1,y2/),(/1.0,1.0/),res_line)

;*****************************************************
; save output image
;******************************************************
 
  resP                     = True

  maximize_output(wks,resP)

  print("saved "+outim+"."+formo)


end
