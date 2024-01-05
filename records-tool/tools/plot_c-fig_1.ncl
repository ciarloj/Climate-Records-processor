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
  ddir = getenv("ddir")
  dfil = getenv("dfil")
  yr1  = getenv("y1") 
  yr2  = getenv("y2")
  idir = getenv("idir")
  nry = 10 ; number of years of running mean

; hd1 = ; era5
; hd2 = ; merra
; hd3 = ; jra-55
; hd4 = ; mswep 

  outim = idir+"/c-fig1"
  formo = "png"
  wks   = gsn_open_wks ("png",outim)             ; send graphics to PNG file

  fe    = addfile(hd1+ddir+dfil, "r")
  ve    = fe->$var$(:,0,0)
  fel   = addfile(hd1+"-land"+ddir+dfil, "r")
  vel   = fel->$var$(:,0,0)
  felnp = addfile(hd1+"-N-polar-land"+ddir+dfil, "r")
  velnp = felnp->$var$(:,0,0)
  felnm = addfile(hd1+"-N-midlats-land"+ddir+dfil, "r")
  velnm = felnm->$var$(:,0,0)
  felnt = addfile(hd1+"-N-tropics-land"+ddir+dfil, "r")
  velnt = felnt->$var$(:,0,0)
  felst = addfile(hd1+"-S-tropics-land"+ddir+dfil, "r")
  velst = felst->$var$(:,0,0)
  felsm = addfile(hd1+"-S-midlats-land"+ddir+dfil, "r")
  velsm = felsm->$var$(:,0,0)
  felsp = addfile(hd1+"-S-polar-land"+ddir+dfil, "r")
  velsp = felsp->$var$(:,0,0)
  feo   = addfile(hd1+"-ocean"+ddir+dfil, "r")
  veo   = feo->$var$(:,0,0)
  feonp = addfile(hd1+"-N-polar-ocean"+ddir+dfil, "r")
  veonp = felnp->$var$(:,0,0)
  feonm = addfile(hd1+"-N-midlats-ocean"+ddir+dfil, "r")
  veonm = felnm->$var$(:,0,0)
  feont = addfile(hd1+"-N-tropics-ocean"+ddir+dfil, "r")
  veont = felnt->$var$(:,0,0)
  feost = addfile(hd1+"-S-tropics-ocean"+ddir+dfil, "r")
  veost = felst->$var$(:,0,0)
  feosm = addfile(hd1+"-S-midlats-ocean"+ddir+dfil, "r")
  veosm = felsm->$var$(:,0,0)
  feosp = addfile(hd1+"-S-polar-ocean"+ddir+dfil, "r")
  veosp = felsp->$var$(:,0,0)

  fm    = addfile(hd2+ddir+dfil, "r")
  vm    = fm->$var$(:,0,0)
  fml   = addfile(hd2+"-land"+ddir+dfil, "r")
  vml   = fml->$var$(:,0,0)
  fmlnp = addfile(hd2+"-N-polar-land"+ddir+dfil, "r")
  vmlnp = fmlnp->$var$(:,0,0)
  fmlnm = addfile(hd2+"-N-midlats-land"+ddir+dfil, "r")
  vmlnm = fmlnm->$var$(:,0,0)
  fmlnt = addfile(hd2+"-N-tropics-land"+ddir+dfil, "r")
  vmlnt = fmlnt->$var$(:,0,0)
  fmlst = addfile(hd2+"-S-tropics-land"+ddir+dfil, "r")
  vmlst = fmlst->$var$(:,0,0)
  fmlsm = addfile(hd2+"-S-midlats-land"+ddir+dfil, "r")
  vmlsm = fmlsm->$var$(:,0,0)
  fmlsp = addfile(hd2+"-S-polar-land"+ddir+dfil, "r")
  vmlsp = fmlsp->$var$(:,0,0)
  fmo   = addfile(hd2+"-ocean"+ddir+dfil, "r")
  vmo   = fmo->$var$(:,0,0)
  fmonp = addfile(hd2+"-N-polar-ocean"+ddir+dfil, "r")
  vmonp = fmlnp->$var$(:,0,0)
  fmonm = addfile(hd2+"-N-midlats-ocean"+ddir+dfil, "r")
  vmonm = fmlnm->$var$(:,0,0)
  fmont = addfile(hd2+"-N-tropics-ocean"+ddir+dfil, "r")
  vmont = fmlnt->$var$(:,0,0)
  fmost = addfile(hd2+"-S-tropics-ocean"+ddir+dfil, "r")
  vmost = fmlst->$var$(:,0,0)
  fmosm = addfile(hd2+"-S-midlats-ocean"+ddir+dfil, "r")
  vmosm = fmlsm->$var$(:,0,0)
  fmosp = addfile(hd2+"-S-polar-ocean"+ddir+dfil, "r")
  vmosp = fmlsp->$var$(:,0,0)

  fj    = addfile(hd3+ddir+dfil, "r")
  vj    = fj->$var$(:,0,0)
  fjl   = addfile(hd3+"-land"+ddir+dfil, "r")
  vjl   = fjl->$var$(:,0,0)
  fjlnp = addfile(hd3+"-N-polar-land"+ddir+dfil, "r")
  vjlnp = fjlnp->$var$(:,0,0)
  fjlnm = addfile(hd3+"-N-midlats-land"+ddir+dfil, "r")
  vjlnm = fjlnm->$var$(:,0,0)
  fjlnt = addfile(hd3+"-N-tropics-land"+ddir+dfil, "r")
  vjlnt = fjlnt->$var$(:,0,0)
  fjlst = addfile(hd3+"-S-tropics-land"+ddir+dfil, "r")
  vjlst = fjlst->$var$(:,0,0)
  fjlsm = addfile(hd3+"-S-midlats-land"+ddir+dfil, "r")
  vjlsm = fjlsm->$var$(:,0,0)
  fjlsp = addfile(hd3+"-S-polar-land"+ddir+dfil, "r")
  vjlsp = fjlsp->$var$(:,0,0)
  fjo   = addfile(hd3+"-ocean"+ddir+dfil, "r")
  vjo   = fjo->$var$(:,0,0)
  fjonp = addfile(hd3+"-N-polar-ocean"+ddir+dfil, "r")
  vjonp = fjlnp->$var$(:,0,0)
  fjonm = addfile(hd3+"-N-midlats-ocean"+ddir+dfil, "r")
  vjonm = fjlnm->$var$(:,0,0)
  fjont = addfile(hd3+"-N-tropics-ocean"+ddir+dfil, "r")
  vjont = fjlnt->$var$(:,0,0)
  fjost = addfile(hd3+"-S-tropics-ocean"+ddir+dfil, "r")
  vjost = fjlst->$var$(:,0,0)
  fjosm = addfile(hd3+"-S-midlats-ocean"+ddir+dfil, "r")
  vjosm = fjlsm->$var$(:,0,0)
  fjosp = addfile(hd3+"-S-polar-ocean"+ddir+dfil, "r")
  vjosp = fjlsp->$var$(:,0,0)

  fw    = addfile(hd4+ddir+dfil, "r")
  vw    = fw->$var$(:,0,0)
  fwl   = addfile(hd4+"-land"+ddir+dfil, "r")
  vwl   = fwl->$var$(:,0,0)
  fwlnp = addfile(hd4+"-N-polar-land"+ddir+dfil, "r")
  vwlnp = fwlnp->$var$(:,0,0)
  fwlnm = addfile(hd4+"-N-midlats-land"+ddir+dfil, "r")
  vwlnm = fwlnm->$var$(:,0,0)
  fwlnt = addfile(hd4+"-N-tropics-land"+ddir+dfil, "r")
  vwlnt = fwlnt->$var$(:,0,0)
  fwlst = addfile(hd4+"-S-tropics-land"+ddir+dfil, "r")
  vwlst = fwlst->$var$(:,0,0)
  fwlsm = addfile(hd4+"-S-midlats-land"+ddir+dfil, "r")
  vwlsm = fwlsm->$var$(:,0,0)
  fwlsp = addfile(hd4+"-S-polar-land"+ddir+dfil, "r")
  vwlsp = fwlsp->$var$(:,0,0)
  fwo   = addfile(hd4+"-ocean"+ddir+dfil, "r")
  vwo   = fwo->$var$(:,0,0)
  fwonp = addfile(hd4+"-N-polar-ocean"+ddir+dfil, "r")
  vwonp = fwlnp->$var$(:,0,0)
  fwonm = addfile(hd4+"-N-midlats-ocean"+ddir+dfil, "r")
  vwonm = fwlnm->$var$(:,0,0)
  fwont = addfile(hd4+"-N-tropics-ocean"+ddir+dfil, "r")
  vwont = fwlnt->$var$(:,0,0)
  fwost = addfile(hd4+"-S-tropics-ocean"+ddir+dfil, "r")
  vwost = fwlst->$var$(:,0,0)
  fwosm = addfile(hd4+"-S-midlats-ocean"+ddir+dfil, "r")
  vwosm = fwlsm->$var$(:,0,0)
  fwosp = addfile(hd4+"-S-polar-ocean"+ddir+dfil, "r")
  vwosp = fwlsp->$var$(:,0,0)

  pdim = dimsizes(ve)
  nbins = pdim(0)
  y1 = stringtointeger(yr1)
  y2 = stringtointeger(yr2)
  bins := ispan(y1,y1-1+nbins,1)
  y1f = floattointeger(floor(int2flt(y1)/10)*10)
  y2c = floattointeger(ceil(int2flt(y2)/10)*10)

  expc = new((/nbins/),typeof(ve))
  do k=1, nbins-1
    expc(k-1) = 1.0/k
  end do

;------------------------------------------------
; Plot each PDF
;------------------------------------------------
;;; some mods needed from here
  gpercs := new((/8,nbins/), typeof(ve))
  rve = ve(:)/expc(:)
  rvm = vm(:)/expc(:)
  rvj = vj(:)/expc(:)
  rvw = vw(:)/expc(:)
  rcle = regline_stats(bins,rve)
  rclm = regline_stats(bins,rvm)
  rclj = regline_stats(bins,rvj)
  rclw = regline_stats(bins,rvw)
  mvale = rcle
  mvalm = rclm
  mvalj = rclj
  mvalw = rclw
  cvale = rcle@yintercept
  cvalm = rclm@yintercept
  cvalj = rclj@yintercept
  cvalw = rclw@yintercept
  pvale = rcle@pval(0)
  pvalm = rclm@pval(0)
  pvalj = rclj@pval(0)
  pvalw = rclw@pval(0)
  line = (bins*mvale)+cvale
  linm = (bins*mvalm)+cvalm
  linj = (bins*mvalj)+cvalj
  linw = (bins*mvalw)+cvalw

  mvrde = flt2string(decimalPlaces(mvale,4,True)*10)
  mvrdm = flt2string(decimalPlaces(mvalw,4,True)*10)
  mvrdj = flt2string(decimalPlaces(mvalj,4,True)*10)
  mvrdw = flt2string(decimalPlaces(mvalw,4,True)*10)
  pvrde = decimalPlaces(pvale,2,True)
  pvrdm = decimalPlaces(pvalm,2,True)
  pvrdj = decimalPlaces(pvalj,2,True)
  pvrdw = decimalPlaces(pvalw,2,True)
  pvtxe = where(pvrde.lt.0.01,"0.00",""+pvrde)
  pvtxm = where(pvrdm.lt.0.01,"0.00",""+pvrdm)
  pvtxj = where(pvrdj.lt.0.01,"0.00",""+pvrdj)
  pvtxw = where(pvrdw.lt.0.01,"0.00",""+pvrdw)
  smrye = " ("+mvrde+", "+pvtxe+")"
  smrym = " ("+mvrdm+", "+pvtxm+")"
  smryj = " ("+mvrdj+", "+pvtxj+")"
  smryw = " ("+mvrdw+", "+pvtxw+")"

  gpercs(0,:) = runave_n(rve(:),nry,0,0)
  gpercs(1,:) = runave_n(rvm(:),nry,0,0)
  gpercs(2,:) = runave_n(rvj(:),nry,0,0)
  gpercs(3,:) = runave_n(rvw(:),nry,0,0)
; gpercs(4,4:nbins-7) = line(4:nbins-7)
; gpercs(5,4:nbins-7) = linm(4:nbins-7)
; gpercs(6,4:nbins-7) = linj(4:nbins-7)
; gpercs(7,4:nbins-7) = linw(4:nbins-7)

  res  = True
  res@tmXTOn = False
  res@tmYROn = False
  res@gsnFrame               = False
  res@gsnDraw                = False
  res@xyMarkLineModes        = "Lines" 
  res@xyLineColors           = (/"black","red","blue","green4","black","red","blue","green4"/) 
  res@xyLineThicknesses      = (/3,3,3,3,3,3,3,3/)
  res@xyDashPatterns         = (/0,0,0,0,1,1,1,1/)

  res@tiYAxisString          = "RAtR"
  res@tiYAxisFontHeightF     = 0.02
  res@tiXAxisString          = "year"
  res@tiXAxisFontHeightF     = 0.02
  res@gsnCenterStringFontHeightF = 0.025
  res@gsnCenterString        = "global"

  ymax = max(gpercs)+(max(gpercs)*0.08)
  ymin = max((/min(gpercs)-(max(gpercs)*0.08),0.0/))
  res@trYMaxF    = ymax
  res@trYMinF    = ymin 
  res@trXMinF    = y1f
  res@trXMaxF    = y2c
; res@tmYLMode = "Manual"
; res@tmYLTickStartF = 0.
; res@tmYLTickEndF = 2.
; res@tmYLTickSpacingF = 0.2
  plot = gsn_csm_xy (wks, bins, gpercs, res)        ; create plot

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
  dum2 = gsn_add_text(wks,plot,"ERA5"+smrye,xm+2,ym,res_text)  ; add text

  ym = ym-ddy
  res_text@txFontColor       = "red"
  res_line@gsLineColor       = "red"
  dum3 = gsn_add_polyline(wks,plot,(/xm-2,xm+1/),(/ym,ym/),res_line)
  dum4 = gsn_add_text(wks,plot,"MERRA"+smrym,xm+2,ym,res_text)

  ym = ym-ddy
  res_text@txFontColor       = "blue"
  res_line@gsLineColor       = "blue"
  dum7 = gsn_add_polyline(wks,plot,(/xm-2,xm+1/),(/ym,ym/),res_line)
  dum8 = gsn_add_text(wks,plot,"JRA-55"+smryj,xm+2,ym,res_text)  ; add text

  ym = ym-ddy
  res_text@txFontColor       = "green4"
  res_line@gsLineColor       = "green4"
  dum9  = gsn_add_polyline(wks,plot,(/xm-2,xm+1/),(/ym,ym/),res_line)
  dum10 = gsn_add_text(wks,plot,"MSWEP"+smryw,xm+2,ym,res_text)  ; add text

  res_line@gsLineDashPattern = 1
  res_line@gsLineThicknessF  = 1
  res_line@gsLineColor       = "black"
  dumB  = gsn_add_polyline(wks,plot,(/y1,y2/),(/1,1/),res_line)

; **** prepare remaining plots

  plots = new((/3/),graphic)
  plots(0) = plot

  resL = res
  resL@gsnCenterString        = "land"
  gpercsL := new((/8,nbins/), typeof(ve))
  rvel = vel(:)/expc(:)
  rvml = vml(:)/expc(:)
  rvjl = vjl(:)/expc(:)
  rvwl = vwl(:)/expc(:)
  rclel = regline_stats(bins,rvel)
  rclml = regline_stats(bins,rvml)
  rcljl = regline_stats(bins,rvjl)
  rclwl = regline_stats(bins,rvwl)
  mvalel = rclel
  mvalml = rclml
  mvaljl = rcljl
  mvalwl = rclwl
  cvalel = rclel@yintercept
  cvalml = rclml@yintercept
  cvaljl = rcljl@yintercept
  cvalwl = rclwl@yintercept
  pvalel = rclel@pval(0)
  pvalml = rclml@pval(0)
  pvaljl = rcljl@pval(0)
  pvalwl = rclwl@pval(0)
  linel = (bins*mvalel)+cvalel
  linml = (bins*mvalml)+cvalml
  linjl = (bins*mvaljl)+cvaljl
  linwl = (bins*mvalwl)+cvalwl
  mvrdel = flt2string(decimalPlaces(mvalel,4,True)*10)
  mvrdml = flt2string(decimalPlaces(mvalwl,4,True)*10)
  mvrdjl = flt2string(decimalPlaces(mvaljl,4,True)*10)
  mvrdwl = flt2string(decimalPlaces(mvalwl,4,True)*10)
  pvrdel = decimalPlaces(pvalel,2,True)
  pvrdml = decimalPlaces(pvalml,2,True)
  pvrdjl = decimalPlaces(pvaljl,2,True)
  pvrdwl = decimalPlaces(pvalwl,2,True)
  pvtxel = where(pvrdel.lt.0.01,"0.00",""+pvrdel)
  pvtxml = where(pvrdml.lt.0.01,"0.00",""+pvrdml)
  pvtxjl = where(pvrdjl.lt.0.01,"0.00",""+pvrdjl)
  pvtxwl = where(pvrdwl.lt.0.01,"0.00",""+pvrdwl)
  smryel = "("+mvrdel+", "+pvtxel+")"
  smryml = "("+mvrdml+", "+pvtxml+")"
  smryjl = "("+mvrdjl+", "+pvtxjl+")"
  smrywl = "("+mvrdwl+", "+pvtxwl+")"
  gpercsL(0,:) = runave_n(rvel(:),nry,0,0)
  gpercsL(1,:) = runave_n(rvml(:),nry,0,0)
  gpercsL(2,:) = runave_n(rvjl(:),nry,0,0)
  gpercsL(3,:) = runave_n(rvwl(:),nry,0,0)
; gpercsL(4,4:nbins-7) = linel(4:nbins-7)
; gpercsL(5,4:nbins-7) = linml(4:nbins-7)
; gpercsL(6,4:nbins-7) = linjl(4:nbins-7)
; gpercsL(7,4:nbins-7) = linwl(4:nbins-7)
  plots(1) = gsn_csm_xy (wks, bins, gpercsL, resL)        ; create plot
  resL_line = True
  resL_line@gsLineDashPattern = 1
  resL_line@gsLineThicknessF  = 1
  resL_line@gsLineColor       = "black"
  dumBl  = gsn_add_polyline(wks,plots(1),(/y1,y2/),(/1,1/),resL_line)
  resL_text                   = True              ; text mods desired
  resL_text@txFontHeightF     = 0.015             ; change text size
  resL_text@txJust            = "CenterLeft"      ; text justification
  resL_text@txPerimSpaceF     = 0.09
  if ( pos.eq."topleft" ) then
    ym = ymax - ddy
  end if
  xm = y1+dy
  dumLe = gsn_add_text(wks,plots(1),smryel,xm+2,ym,resL_text)  ; add text
  ym = ym-ddy
  resL_text@txFontColor       = "red"
  dumLm = gsn_add_text(wks,plots(1),smryml,xm+2,ym,resL_text)
  ym = ym-ddy
  resL_text@txFontColor       = "blue"
  dumLj = gsn_add_text(wks,plots(1),smryjl,xm+2,ym,resL_text)  ; add text
  ym = ym-ddy
  resL_text@txFontColor       = "green4"
  dumLw = gsn_add_text(wks,plots(1),smrywl,xm+2,ym,resL_text)  ; add text

  resO = res
  resO@gsnCenterString        = "ocean"
  gpercsO := new((/8,nbins/), typeof(ve))
  rveo = veo(:)/expc(:)
  rvmo = vmo(:)/expc(:)
  rvjo = vjo(:)/expc(:)
  rvwo = vwo(:)/expc(:)
  rcleo = regline_stats(bins,rveo)
  rclmo = regline_stats(bins,rvmo)
  rcljo = regline_stats(bins,rvjo)
  rclwo = regline_stats(bins,rvwo)
  mvaleo = rcleo
  mvalmo = rclmo
  mvaljo = rcljo
  mvalwo = rclwo
  cvaleo = rcleo@yintercept
  cvalmo = rclmo@yintercept
  cvaljo = rcljo@yintercept
  cvalwo = rclwo@yintercept
  pvaleo = rcleo@pval(0)
  pvalmo = rclmo@pval(0)
  pvaljo = rcljo@pval(0)
  pvalwo = rclwo@pval(0)
  lineo = (bins*mvaleo)+cvaleo
  linmo = (bins*mvalmo)+cvalmo
  linjo = (bins*mvaljo)+cvaljo
  linwo = (bins*mvalwo)+cvalwo
  mvrdeo = flt2string(decimalPlaces(mvaleo,4,True)*10)
  mvrdmo = flt2string(decimalPlaces(mvalwo,4,True)*10)
  mvrdjo = flt2string(decimalPlaces(mvaljo,4,True)*10)
  mvrdwo = flt2string(decimalPlaces(mvalwo,4,True)*10)
  pvrdeo = decimalPlaces(pvaleo,2,True)
  pvrdmo = decimalPlaces(pvalmo,2,True)
  pvrdjo = decimalPlaces(pvaljo,2,True)
  pvrdwo = decimalPlaces(pvalwo,2,True)
  pvtxeo = where(pvrdeo.lt.0.01,"0.00",""+pvrdeo)
  pvtxmo = where(pvrdmo.lt.0.01,"0.00",""+pvrdmo)
  pvtxjo = where(pvrdjo.lt.0.01,"0.00",""+pvrdjo)
  pvtxwo = where(pvrdwo.lt.0.01,"0.00",""+pvrdwo)
  smryeo = "("+mvrdeo+", "+pvtxeo+")"
  smrymo = "("+mvrdmo+", "+pvtxmo+")"
  smryjo = "("+mvrdjo+", "+pvtxjo+")"
  smrywo = "("+mvrdwo+", "+pvtxwo+")"
  gpercsO(0,:) = runave_n(rveo(:),nry,0,0)
  gpercsO(1,:) = runave_n(rvmo(:),nry,0,0)
  gpercsO(2,:) = runave_n(rvjo(:),nry,0,0)
  gpercsO(3,:) = runave_n(rvwo(:),nry,0,0)
; gpercsO(4,4:nbins-7) = lineo(4:nbins-7)
; gpercsO(5,4:nbins-7) = linmo(4:nbins-7)
; gpercsO(6,4:nbins-7) = linjo(4:nbins-7)
; gpercsO(7,4:nbins-7) = linwo(4:nbins-7)
  plots(2) = gsn_csm_xy (wks, bins, gpercsO, resO)        ; create plot
  resO_line = True
  resO_line@gsLineDashPattern = 1
  resO_line@gsLineThicknessF  = 1
  resO_line@gsLineColor       = "black"
  dumBo  = gsn_add_polyline(wks,plots(2),(/y1,y2/),(/1,1/),resO_line)
  resO_text                   = True              ; text mods desired
  resO_text@txFontHeightF     = 0.015             ; change text size
  resO_text@txJust            = "CenterLeft"      ; text justification
  resO_text@txPerimSpaceF     = 0.09
  if ( pos.eq."topleft" ) then
    ym = ymax - ddy
  end if
  xm = y1+dy
  dumOe = gsn_add_text(wks,plots(2),smryeo,xm+2,ym,resO_text)  ; add text
  ym = ym-ddy
  resO_text@txFontColor       = "red"
  dumOm = gsn_add_text(wks,plots(2),smrymo,xm+2,ym,resO_text)
  ym = ym-ddy
  resO_text@txFontColor       = "blue"
  dumOj = gsn_add_text(wks,plots(2),smryjo,xm+2,ym,resO_text)  ; add text
  ym = ym-ddy
  resO_text@txFontColor       = "green4"
  dumOw = gsn_add_text(wks,plots(2),smrywo,xm+2,ym,resO_text)  ; add text

;************************************************
; create panel
;************************************************
  resP                     = True                ; modify the panel plot
  resP@gsnMaximize         = True
  resP@gsnScale            = True
; resP@gsnPanelMainString  = "[] "
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
