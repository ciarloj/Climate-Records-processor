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
  var  = getenv("var")
  pxx  = getenv("pp")
  hdir = getenv("hdir")
  ddir = getenv("ddir")
  mdir = getenv("tdir")
  idir = getenv("idir")
  yr1  = getenv("y1") 
  yr2  = getenv("y2")
  dn   = getenv("dn")
  stt  = getenv("stat")

  if ( stt.eq."Rtot" ) then
    unit = "rainfall (mm)"
    desc = "Total Annual Rainfall (>1mm/day)"
    ymax = 1900.
    ymin = 0.
  end if
  if ( stt.eq.("R"+pxx) ) then
    unit = "rainfall (mm)"
    desc = "Total Annual Rainfall (>1mm/day) above p"+pxx
    ymax = 400.
    ymin = 0.
  end if
  if ( stt.eq.("Rm"+pxx) ) then
    unit = "rainfall (mm)"
    desc = "Total Annual Rainfall (>1mm/day) below p"+pxx
    ymax = 1800.
    ymin = 0.
  end if
  if ( stt.eq.("Rf"+pxx) ) then
    unit = "rainfall fraction (#)"
    desc = "Total Rainfall fraction (>1mm/day) above p"+pxx
    ymax = 0.3
    ymin = 0.
  end if
  if ( stt.eq."ndaytot" ) then
    unit = "days (#)"
    desc = "Total number of wet days (>1mm/day)"
    ymax = 300.
    ymin = 0.
  end if
  if ( stt.eq.("ndayR"+pxx) ) then
    unit = "days (#)"
    desc = "Total number of wet days (>1mm/day) above p"+pxx
    ymax = 4.
    ymin = 0.
  end if
  if ( stt.eq.("ndayRm"+pxx) ) then
    unit = "days (#)"
    desc = "Total number of wet days (>1mm/day) below p"+pxx
    ymax = 300.
    ymin = 0.
  end if
  if ( stt.eq.("ndayfR"+pxx) ) then
    unit = "fraction of days (#)"
    desc = "Fraction of total wet days (>1mm/day) above p"+pxx
    ymax = 0.04
    ymin = 0.
  end if
  

  outim = idir+"/rainy_"+dn+"_"+stt
  formo = "png"
  wks   = gsn_open_wks ("png",outim)             ; send graphics to PNG file

  domains = (/"land", "ocean"/)
  if ( dn.eq."CPC" ) then
    domains = (/"land"/)
  end if
  hemisph = (/"N", "S"/)
  latband = (/"tropics", "midlats", "polar"/)

  f = addfile(mdir+"/mergetime.nc", "r")
  v = f->$var$(:,0,0)

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
  gpercs := new((/3,nbins/), typeof(v))
  gpercs(0,:) = v(:)
 
  ndom = dimsizes(domains)
  do d=0, ndom-1
    dd = domains(d)
    f := addfile(hdir+"-"+dd+"/"+ddir+"/merge/mergetime.nc", "r")
    v := f->$var$(:,0,0)
    nd = d+1
    gpercs(nd,:) = v(:)
  end do

  gpercsL = gpercs(0:1,:)
  gpercsO = gpercsL
  if ( dn.eq."CPC" ) then
    gpercsO(1,:) = gpercs(1,:) - gpercs(1,0)
  else 
    gpercsO(1,:) = gpercs(2,:)
  end if

  res  = True
  res@tmXTOn = False
  res@tmYROn = False
  res@gsnFrame               = False
  res@gsnDraw                = False
  res@xyMarkLineModes        = "Lines" 
  res@xyLineColors           = (/"black","red"/) 
  res@xyLineThicknesses      = (/3,3/)
  res@xyDashPatterns         = (/0,0/)

  res@tiYAxisString          = unit
  res@tiYAxisFontHeightF     = 0.02
  res@tiXAxisString          = "year"
  res@tiXAxisFontHeightF     = 0.02
  res@gsnCenterStringFontHeightF = 0.025
  dnttl = dn
  res@gsnCenterString        = dnttl+" global-land"

  res@trYMaxF    = ymax
  res@trYMinF    = ymin 
  res@trXMinF    = y1f
  res@trXMaxF    = y2c
; res@tmYLMode = "Manual"
; res@tmYLTickStartF = 0.
; res@tmYLTickEndF = 2.
; res@tmYLTickSpacingF = 0.2
  plot = gsn_csm_xy (wks, bins, gpercsL, res)        ; create plot

;*****************************************************
; Manually create and attach legend
;*****************************************************
  res_text                   = True              ; text mods desired
  res_text@txFontHeightF     = 0.015             ; change text size
  res_text@txJust            = "CenterLeft"      ; text justification
  res_text@txPerimSpaceF     = 0.09

  res_line                   = True
  res_line@gsLineColor       = "Black"
  res_line@gsLineThicknessF  = 3

  ddy = (ymax-ymin)/30
  pos = "topleft"
  if ( pos.eq."topleft" ) then
    dy = (y2-y1)*0.5/7
    ym = ymax - ddy
; else if ( pos.eq."bottomleft" ) then
;   dy = (y2-y1)*0.5/7
;   ym = 0.86
; else
;   dy = (y2-y1)*2.5/7
;   ym = 0.95
; end if
  end if
  xm = y1+dy
  res_line@gsLineDashPattern = 0
  dum1 = gsn_add_polyline(wks,plot,(/xm-2,xm+1/),(/ym,ym/),res_line)
  dum2 = gsn_add_text(wks,plot,"Global",xm+2,ym,res_text)  ; add text

  ym = ym-ddy
  res_line@gsLineColor       = "red"
; res_line@gsLineDashPattern = 0
  dum3 = gsn_add_polyline(wks,plot,(/xm-2,xm+1/),(/ym,ym/),res_line)
  dum4 = gsn_add_text(wks,plot,"Global-Land",xm+2,ym,res_text)

  ym = ym-ddy
  res_line@gsLineColor       = "blue"
; res_line@gsLineDashPattern = 1
  dum7 = gsn_add_polyline(wks,plot,(/xm-2,xm+1/),(/ym,ym/),res_line)
  dum8 = gsn_add_text(wks,plot,"Global-Ocean",xm+2,ym,res_text)  ; add text

; **** prepare remaining plots

  plots = new((/6/),graphic)
  plots(0) = plot

  resO = res
  resO@xyLineColors           := (/"black","blue"/)
  resO@xyLineThicknesses      := (/3,3/)
  resO@xyDashPatterns         := (/0,0/)
  resO@gsnCenterString        = dnttl+" global-ocean"
  plots(3) = gsn_csm_xy (wks, bins, gpercsO, resO)        ; create plot

  resh = res
  resh@xyLineColors      := (/"red","darkgreen","blue"/)
  resh@xyLineThicknesses := (/3,3,3/)
  resh@xyDashPatterns    := (/0,0,0/)

  nhem = dimsizes(hemisph)
  nbnd = dimsizes(latband)

  dh=1
  nd=0
  do d=0, ndom-1
    dd = domains(d)
    if ( dd.eq."ocean" ) then
      dh=2
     ;resh@xyDashPatterns    := (/2,2,2/)
    end if

    do h=0, nhem-1
      hh = hemisph(h)
    
      hpercs := new((/3,nbins/), typeof(v)) 
      do b=0, nbnd-1
        bb = latband(b)

        f := addfile(hdir+"-"+hh+"-"+bb+"-"+dd+"/"+ddir+"/merge/mergetime.nc", "r")
        v := f->$var$(:,0,0)
    
        hpercs(b,:) = v(:)
      end do

      resh@gsnCenterString    := dnttl+" "+hh+"-hemisphere-"+dd
      plots(nd+dh) = gsn_csm_xy (wks, bins, hpercs, resh)

      if ( dd.eq."land" .and. hh.eq."N" ) then
        res_textB = res_text
        res_lineB = res_line

        if ( pos.eq."topleft" ) then
          ym = res@trYMaxF - ddy
        else if ( pos.eq."bottomleft" ) then
          ym = 0.86
        else
          ym = 0.95
        end if
        end if
        xm = y1+dy
        res_lineB@gsLineColor       = "red"
        dum9 = gsn_add_polyline(wks,plots(nd+dh),(/xm-2,xm+1/),(/ym,ym/),res_lineB)
        dum10= gsn_add_text(wks,plots(nd+dh),"tropics",xm+2,ym,res_textB)  ; add text

        ym = ym-ddy
        res_lineB@gsLineColor       = "darkgreen"
        dum11= gsn_add_polyline(wks,plots(nd+dh),(/xm-2,xm+1/),(/ym,ym/),res_lineB)
        dum12= gsn_add_text(wks,plots(nd+dh),"midlats",xm+2,ym,res_textB)

        ym = ym-ddy
        res_lineB@gsLineColor       = "blue"
        dum13= gsn_add_polyline(wks,plots(nd+dh),(/xm-2,xm+1/),(/ym,ym/),res_lineB)
        dum14= gsn_add_text(wks,plots(nd+dh),"polar",xm+2,ym,res_textB)  ; add text
      end if

      nd = nd + 1
      delete(hpercs)

    end do
  end do

;************************************************
; create panel
;************************************************
  resP                     = True                ; modify the panel plot
  resP@gsnMaximize         = True
  resP@gsnScale            = True
  resP@gsnPanelMainString  = "["+stt+"] "+desc
; resP@gsnPanelBottom      = 0.08
; resP@gsnPanelDebug  = True

  gsn_panel(wks,plots,(/2,3/),resP)

;*****************************************************
; save output image
;******************************************************
 
; resP                     = True

; maximize_output(wks,resP)

; print("saved "+outim+"."+formo)
  trimPNG(outim+"."+formo)

end
