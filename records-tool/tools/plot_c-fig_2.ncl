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

  outim = idir+"/c-fig2"
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
  veonp = feonp->$var$(:,0,0)
  feonm = addfile(hd1+"-N-midlats-ocean"+ddir+dfil, "r")
  veonm = feonm->$var$(:,0,0)
  feont = addfile(hd1+"-N-tropics-ocean"+ddir+dfil, "r")
  veont = feont->$var$(:,0,0)
  feost = addfile(hd1+"-S-tropics-ocean"+ddir+dfil, "r")
  veost = feost->$var$(:,0,0)
  feosm = addfile(hd1+"-S-midlats-ocean"+ddir+dfil, "r")
  veosm = feosm->$var$(:,0,0)
  feosp = addfile(hd1+"-S-polar-ocean"+ddir+dfil, "r")
  veosp = feosp->$var$(:,0,0)

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
  vmonp = fmonp->$var$(:,0,0)
  fmonm = addfile(hd2+"-N-midlats-ocean"+ddir+dfil, "r")
  vmonm = fmonm->$var$(:,0,0)
  fmont = addfile(hd2+"-N-tropics-ocean"+ddir+dfil, "r")
  vmont = fmont->$var$(:,0,0)
  fmost = addfile(hd2+"-S-tropics-ocean"+ddir+dfil, "r")
  vmost = fmost->$var$(:,0,0)
  fmosm = addfile(hd2+"-S-midlats-ocean"+ddir+dfil, "r")
  vmosm = fmosm->$var$(:,0,0)
  fmosp = addfile(hd2+"-S-polar-ocean"+ddir+dfil, "r")
  vmosp = fmosp->$var$(:,0,0)

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
  vjonp = fjonp->$var$(:,0,0)
  fjonm = addfile(hd3+"-N-midlats-ocean"+ddir+dfil, "r")
  vjonm = fjonm->$var$(:,0,0)
  fjont = addfile(hd3+"-N-tropics-ocean"+ddir+dfil, "r")
  vjont = fjont->$var$(:,0,0)
  fjost = addfile(hd3+"-S-tropics-ocean"+ddir+dfil, "r")
  vjost = fjost->$var$(:,0,0)
  fjosm = addfile(hd3+"-S-midlats-ocean"+ddir+dfil, "r")
  vjosm = fjosm->$var$(:,0,0)
  fjosp = addfile(hd3+"-S-polar-ocean"+ddir+dfil, "r")
  vjosp = fjosp->$var$(:,0,0)

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
  vwonp = fwonp->$var$(:,0,0)
  fwonm = addfile(hd4+"-N-midlats-ocean"+ddir+dfil, "r")
  vwonm = fwonm->$var$(:,0,0)
  fwont = addfile(hd4+"-N-tropics-ocean"+ddir+dfil, "r")
  vwont = fwont->$var$(:,0,0)
  fwost = addfile(hd4+"-S-tropics-ocean"+ddir+dfil, "r")
  vwost = fwost->$var$(:,0,0)
  fwosm = addfile(hd4+"-S-midlats-ocean"+ddir+dfil, "r")
  vwosm = fwosm->$var$(:,0,0)
  fwosp = addfile(hd4+"-S-polar-ocean"+ddir+dfil, "r")
  vwosp = fwosp->$var$(:,0,0)

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
  rvelnt = velnt(:)/expc(:)
  rvmlnt = vmlnt(:)/expc(:)
  rvjlnt = vjlnt(:)/expc(:)
  rvwlnt = vwlnt(:)/expc(:)
  rveont = veont(:)/expc(:)
  rvmont = vmont(:)/expc(:)
  rvjont = vjont(:)/expc(:)
  rvwont = vwont(:)/expc(:)
  rclelnt = regline_stats(bins,rvelnt)
  rclmlnt = regline_stats(bins,rvmlnt)
  rcljlnt = regline_stats(bins,rvjlnt)
  rclwlnt = regline_stats(bins,rvwlnt)
  rcleont = regline_stats(bins,rveont)
  rclmont = regline_stats(bins,rvmont)
  rcljont = regline_stats(bins,rvjont)
  rclwont = regline_stats(bins,rvwont)
  mvalelnt = rclelnt
  mvalmlnt = rclmlnt
  mvaljlnt = rcljlnt
  mvalwlnt = rclwlnt
  mvaleont = rcleont
  mvalmont = rclmont
  mvaljont = rcljont
  mvalwont = rclwont
; cvalelnt = rclelnt@yintercept
  pvalelnt = rclelnt@pval(0)
  pvalmlnt = rclmlnt@pval(0)
  pvaljlnt = rcljlnt@pval(0)
  pvalwlnt = rclwlnt@pval(0)
  pvaleont = rcleont@pval(0)
  pvalmont = rclmont@pval(0)
  pvaljont = rcljont@pval(0)
  pvalwont = rclwont@pval(0)
; line = (bins*mvale)+cvale

  mvrdelnt = flt2string(decimalPlaces(mvalelnt,4,True)*10)
  mvrdmlnt = flt2string(decimalPlaces(mvalwlnt,4,True)*10)
  mvrdjlnt = flt2string(decimalPlaces(mvaljlnt,4,True)*10)
  mvrdwlnt = flt2string(decimalPlaces(mvalwlnt,4,True)*10)
  mvrdeont = flt2string(decimalPlaces(mvaleont,4,True)*10)
  mvrdmont = flt2string(decimalPlaces(mvalwont,4,True)*10)
  mvrdjont = flt2string(decimalPlaces(mvaljont,4,True)*10)
  mvrdwont = flt2string(decimalPlaces(mvalwont,4,True)*10)
  pvrdelnt = decimalPlaces(pvalelnt,2,True)
  pvrdmlnt = decimalPlaces(pvalmlnt,2,True)
  pvrdjlnt = decimalPlaces(pvaljlnt,2,True)
  pvrdwlnt = decimalPlaces(pvalwlnt,2,True)
  pvrdeont = decimalPlaces(pvaleont,2,True)
  pvrdmont = decimalPlaces(pvalmont,2,True)
  pvrdjont = decimalPlaces(pvaljont,2,True)
  pvrdwont = decimalPlaces(pvalwont,2,True)
  pvtxelnt = where(pvrdelnt.lt.0.01,"0.00",""+pvrdelnt)
  pvtxmlnt = where(pvrdmlnt.lt.0.01,"0.00",""+pvrdmlnt)
  pvtxjlnt = where(pvrdjlnt.lt.0.01,"0.00",""+pvrdjlnt)
  pvtxwlnt = where(pvrdwlnt.lt.0.01,"0.00",""+pvrdwlnt)
  pvtxeont = where(pvrdeont.lt.0.01,"0.00",""+pvrdeont)
  pvtxmont = where(pvrdmont.lt.0.01,"0.00",""+pvrdmont)
  pvtxjont = where(pvrdjont.lt.0.01,"0.00",""+pvrdjont)
  pvtxwont = where(pvrdwont.lt.0.01,"0.00",""+pvrdwont)
  smryent = " ("+mvrdelnt+", "+pvtxelnt+"/ "+mvrdeont+", "+pvtxeont+")"
  smrymnt = " ("+mvrdmlnt+", "+pvtxmlnt+"/ "+mvrdmont+", "+pvtxmont+")"
  smryjnt = " ("+mvrdjlnt+", "+pvtxjlnt+"/ "+mvrdjont+", "+pvtxjont+")"
  smrywnt = " ("+mvrdwlnt+", "+pvtxwlnt+"/ "+mvrdwont+", "+pvtxwont+")"

  gpercs(0,:) = runave_n(rvelnt(:),nry,0,0)
  gpercs(1,:) = runave_n(rvmlnt(:),nry,0,0)
  gpercs(2,:) = runave_n(rvjlnt(:),nry,0,0)
  gpercs(3,:) = runave_n(rvwlnt(:),nry,0,0)
  gpercs(4,:) = runave_n(rveont(:),nry,0,0)
  gpercs(5,:) = runave_n(rvmont(:),nry,0,0)
  gpercs(6,:) = runave_n(rvjont(:),nry,0,0)
  gpercs(7,:) = runave_n(rvwont(:),nry,0,0)

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
  res@gsnCenterString        = "NH-tropics"

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
  dum2 = gsn_add_text(wks,plot,"ERA5"+smryent,xm+2,ym,res_text)  ; add text

  ym = ym-ddy
  res_text@txFontColor       = "red"
  res_line@gsLineColor       = "red"
  dum3 = gsn_add_polyline(wks,plot,(/xm-2,xm+1/),(/ym,ym/),res_line)
  dum4 = gsn_add_text(wks,plot,"MERRA"+smrymnt,xm+2,ym,res_text)

  ym = ym-ddy
  res_text@txFontColor       = "blue"
  res_line@gsLineColor       = "blue"
  dum7 = gsn_add_polyline(wks,plot,(/xm-2,xm+1/),(/ym,ym/),res_line)
  dum8 = gsn_add_text(wks,plot,"JRA-55"+smryjnt,xm+2,ym,res_text)  ; add text

  ym = ym-ddy
  res_text@txFontColor       = "green4"
  res_line@gsLineColor       = "green4"
  dum9  = gsn_add_polyline(wks,plot,(/xm-2,xm+1/),(/ym,ym/),res_line)
  dum10 = gsn_add_text(wks,plot,"MSWEP"+smrywnt,xm+2,ym,res_text)  ; add text

  res_line@gsLineDashPattern = 1
  res_line@gsLineThicknessF  = 1
  res_line@gsLineColor       = "black"
  dumB  = gsn_add_polyline(wks,plot,(/y1,y2/),(/1,1/),res_line)

; **** prepare remaining plots

  plots = new((/6/),graphic)
  plots(0) = plot

  resNM = res
  resNM@gsnCenterString        = "NH-midlats"
  gpercsNM := new((/8,nbins/), typeof(ve))
  rvelnm = velnm(:)/expc(:)
  rvmlnm = vmlnm(:)/expc(:)
  rvjlnm = vjlnm(:)/expc(:)
  rvwlnm = vwlnm(:)/expc(:)
  rveonm = veonm(:)/expc(:)
  rvmonm = vmonm(:)/expc(:)
  rvjonm = vjonm(:)/expc(:)
  rvwonm = vwonm(:)/expc(:)
  rclelnm = regline_stats(bins,rvelnm)
  rclmlnm = regline_stats(bins,rvmlnm)
  rcljlnm = regline_stats(bins,rvjlnm)
  rclwlnm = regline_stats(bins,rvwlnm)
  rcleonm = regline_stats(bins,rveonm)
  rclmonm = regline_stats(bins,rvmonm)
  rcljonm = regline_stats(bins,rvjonm)
  rclwonm = regline_stats(bins,rvwonm)
  mvalelnm = rclelnm
  mvalmlnm = rclmlnm
  mvaljlnm = rcljlnm
  mvalwlnm = rclwlnm
  mvaleonm = rcleonm
  mvalmonm = rclmonm
  mvaljonm = rcljonm
  mvalwonm = rclwonm
; cvalel = rclelnm@yintercept
  pvalelnm = rclelnm@pval(0)
  pvalmlnm = rclmlnm@pval(0)
  pvaljlnm = rcljlnm@pval(0)
  pvalwlnm = rclwlnm@pval(0)
  pvaleonm = rcleonm@pval(0)
  pvalmonm = rclmonm@pval(0)
  pvaljonm = rcljonm@pval(0)
  pvalwonm = rclwonm@pval(0)
; linel = (bins*mvalel)+cvalel
  mvrdelnm = flt2string(decimalPlaces(mvalelnm,4,True)*10)
  mvrdmlnm = flt2string(decimalPlaces(mvalwlnm,4,True)*10)
  mvrdjlnm = flt2string(decimalPlaces(mvaljlnm,4,True)*10)
  mvrdwlnm = flt2string(decimalPlaces(mvalwlnm,4,True)*10)
  mvrdeonm = flt2string(decimalPlaces(mvaleonm,4,True)*10)
  mvrdmonm = flt2string(decimalPlaces(mvalwonm,4,True)*10)
  mvrdjonm = flt2string(decimalPlaces(mvaljonm,4,True)*10)
  mvrdwonm = flt2string(decimalPlaces(mvalwonm,4,True)*10)
  pvrdelnm = decimalPlaces(pvalelnm,2,True)
  pvrdmlnm = decimalPlaces(pvalmlnm,2,True)
  pvrdjlnm = decimalPlaces(pvaljlnm,2,True)
  pvrdwlnm = decimalPlaces(pvalwlnm,2,True)
  pvrdeonm = decimalPlaces(pvaleonm,2,True)
  pvrdmonm = decimalPlaces(pvalmonm,2,True)
  pvrdjonm = decimalPlaces(pvaljonm,2,True)
  pvrdwonm = decimalPlaces(pvalwonm,2,True)
  pvtxelnm = where(pvrdelnm.lt.0.01,"0.00",""+pvrdelnm)
  pvtxmlnm = where(pvrdmlnm.lt.0.01,"0.00",""+pvrdmlnm)
  pvtxjlnm = where(pvrdjlnm.lt.0.01,"0.00",""+pvrdjlnm)
  pvtxwlnm = where(pvrdwlnm.lt.0.01,"0.00",""+pvrdwlnm)
  pvtxeonm = where(pvrdeonm.lt.0.01,"0.00",""+pvrdeonm)
  pvtxmonm = where(pvrdmonm.lt.0.01,"0.00",""+pvrdmonm)
  pvtxjonm = where(pvrdjonm.lt.0.01,"0.00",""+pvrdjonm)
  pvtxwonm = where(pvrdwonm.lt.0.01,"0.00",""+pvrdwonm)
  smryenm = "("+mvrdelnm+", "+pvtxelnm+"/ "+mvrdeonm+", "+pvtxeonm+")"
  smrymnm = "("+mvrdmlnm+", "+pvtxmlnm+"/ "+mvrdmonm+", "+pvtxmonm+")"
  smryjnm = "("+mvrdjlnm+", "+pvtxjlnm+"/ "+mvrdjonm+", "+pvtxjonm+")"
  smrywnm = "("+mvrdwlnm+", "+pvtxwlnm+"/ "+mvrdwonm+", "+pvtxwonm+")"
  gpercsNM(0,:) = runave_n(rvelnm(:),nry,0,0)
  gpercsNM(1,:) = runave_n(rvmlnm(:),nry,0,0)
  gpercsNM(2,:) = runave_n(rvjlnm(:),nry,0,0)
  gpercsNM(3,:) = runave_n(rvwlnm(:),nry,0,0)
  gpercsNM(4,:) = runave_n(rveonm(:),nry,0,0)
  gpercsNM(5,:) = runave_n(rvmonm(:),nry,0,0)
  gpercsNM(6,:) = runave_n(rvjonm(:),nry,0,0)
  gpercsNM(7,:) = runave_n(rvwonm(:),nry,0,0)
  plots(1) = gsn_csm_xy (wks, bins, gpercsNM, resNM)        ; create plot
  resNM_line = True
  resNM_line@gsLineDashPattern = 1
  resNM_line@gsLineThicknessF  = 1
  resNM_line@gsLineColor       = "black"
  dumBnm  = gsn_add_polyline(wks,plots(1),(/y1,y2/),(/1,1/),resNM_line)
  resNM_text                   = True              ; text mods desired
  resNM_text@txFontHeightF     = 0.015             ; change text size
  resNM_text@txJust            = "CenterLeft"      ; text justification
  resNM_text@txPerimSpaceF     = 0.09
  if ( pos.eq."topleft" ) then
    ym = ymax - ddy
  end if
  xm = y1+dy
  dumNMe = gsn_add_text(wks,plots(1),smryenm,xm+2,ym,resNM_text)  ; add text
  ym = ym-ddy
  resNM_text@txFontColor       = "red"
  dumNMm = gsn_add_text(wks,plots(1),smrymnm,xm+2,ym,resNM_text)
  ym = ym-ddy
  resNM_text@txFontColor       = "blue"
  dumNMj = gsn_add_text(wks,plots(1),smryjnm,xm+2,ym,resNM_text)  ; add text
  ym = ym-ddy
  resNM_text@txFontColor       = "green4"
  dumNMw = gsn_add_text(wks,plots(1),smrywnm,xm+2,ym,resNM_text)  ; add text

  resNP = res
  resNP@gsnCenterString        = "NH-polar"
  gpercsNP := new((/8,nbins/), typeof(ve))
  rvelnp = velnp(:)/expc(:)
  rvmlnp = vmlnp(:)/expc(:)
  rvjlnp = vjlnp(:)/expc(:)
  rvwlnp = vwlnp(:)/expc(:)
  rveonp = veonp(:)/expc(:)
  rvmonp = vmonp(:)/expc(:)
  rvjonp = vjonp(:)/expc(:)
  rvwonp = vwonp(:)/expc(:)
  rclelnp = regline_stats(bins,rvelnp)
  rclmlnp = regline_stats(bins,rvmlnp)
  rcljlnp = regline_stats(bins,rvjlnp)
  rclwlnp = regline_stats(bins,rvwlnp)
  rcleonp = regline_stats(bins,rveonp)
  rclmonp = regline_stats(bins,rvmonp)
  rcljonp = regline_stats(bins,rvjonp)
  rclwonp = regline_stats(bins,rvwonp)
  mvalelnp = rclelnp
  mvalmlnp = rclmlnp
  mvaljlnp = rcljlnp
  mvalwlnp = rclwlnp
  mvaleonp = rcleonp
  mvalmonp = rclmonp
  mvaljonp = rcljonp
  mvalwonp = rclwonp
; cvaleo = rcleo@yintercept
  pvalelnp = rclelnp@pval(0)
  pvalmlnp = rclmlnp@pval(0)
  pvaljlnp = rcljlnp@pval(0)
  pvalwlnp = rclwlnp@pval(0)
  pvaleonp = rcleonp@pval(0)
  pvalmonp = rclmonp@pval(0)
  pvaljonp = rcljonp@pval(0)
  pvalwonp = rclwonp@pval(0)
; lineo = (bins*mvaleo)+cvaleo
  mvrdelnp = flt2string(decimalPlaces(mvalelnp,4,True)*10)
  mvrdmlnp = flt2string(decimalPlaces(mvalwlnp,4,True)*10)
  mvrdjlnp = flt2string(decimalPlaces(mvaljlnp,4,True)*10)
  mvrdwlnp = flt2string(decimalPlaces(mvalwlnp,4,True)*10)
  mvrdeonp = flt2string(decimalPlaces(mvaleonp,4,True)*10)
  mvrdmonp = flt2string(decimalPlaces(mvalwonp,4,True)*10)
  mvrdjonp = flt2string(decimalPlaces(mvaljonp,4,True)*10)
  mvrdwonp = flt2string(decimalPlaces(mvalwonp,4,True)*10)
  pvrdelnp = decimalPlaces(pvalelnp,2,True)
  pvrdmlnp = decimalPlaces(pvalmlnp,2,True)
  pvrdjlnp = decimalPlaces(pvaljlnp,2,True)
  pvrdwlnp = decimalPlaces(pvalwlnp,2,True)
  pvrdeonp = decimalPlaces(pvaleonp,2,True)
  pvrdmonp = decimalPlaces(pvalmonp,2,True)
  pvrdjonp = decimalPlaces(pvaljonp,2,True)
  pvrdwonp = decimalPlaces(pvalwonp,2,True)
  pvtxelnp = where(pvrdelnp.lt.0.01,"0.00",""+pvrdelnp)
  pvtxmlnp = where(pvrdmlnp.lt.0.01,"0.00",""+pvrdmlnp)
  pvtxjlnp = where(pvrdjlnp.lt.0.01,"0.00",""+pvrdjlnp)
  pvtxwlnp = where(pvrdwlnp.lt.0.01,"0.00",""+pvrdwlnp)
  pvtxeonp = where(pvrdeonp.lt.0.01,"0.00",""+pvrdeonp)
  pvtxmonp = where(pvrdmonp.lt.0.01,"0.00",""+pvrdmonp)
  pvtxjonp = where(pvrdjonp.lt.0.01,"0.00",""+pvrdjonp)
  pvtxwonp = where(pvrdwonp.lt.0.01,"0.00",""+pvrdwonp)
  smryenp = "("+mvrdelnp+", "+pvtxelnp+"/"+mvrdeonp+", "+pvtxeonp+")"
  smrymnp = "("+mvrdmlnp+", "+pvtxmlnp+"/"+mvrdmonp+", "+pvtxmonp+")"
  smryjnp = "("+mvrdjlnp+", "+pvtxjlnp+"/"+mvrdjonp+", "+pvtxjonp+")"
  smrywnp = "("+mvrdwlnp+", "+pvtxwlnp+"/"+mvrdwonp+", "+pvtxwonp+")"
  gpercsNP(0,:) = runave_n(rvelnp(:),nry,0,0)
  gpercsNP(1,:) = runave_n(rvmlnp(:),nry,0,0)
  gpercsNP(2,:) = runave_n(rvjlnp(:),nry,0,0)
  gpercsNP(3,:) = runave_n(rvwlnp(:),nry,0,0)
  gpercsNP(4,:) = runave_n(rveonp(:),nry,0,0)
  gpercsNP(5,:) = runave_n(rvmonp(:),nry,0,0)
  gpercsNP(6,:) = runave_n(rvjonp(:),nry,0,0)
  gpercsNP(7,:) = runave_n(rvwonp(:),nry,0,0)
  plots(2) = gsn_csm_xy (wks, bins, gpercsNP, resNP)        ; create plot
  resNP_line = True
  resNP_line@gsLineDashPattern = 1
  resNP_line@gsLineThicknessF  = 1
  resNP_line@gsLineColor       = "black"
  dumBnp  = gsn_add_polyline(wks,plots(2),(/y1,y2/),(/1,1/),resNP_line)
  resNP_text                   = True              ; text mods desired
  resNP_text@txFontHeightF     = 0.015             ; change text size
  resNP_text@txJust            = "CenterLeft"      ; text justification
  resNP_text@txPerimSpaceF     = 0.09
  if ( pos.eq."topleft" ) then
    ym = ymax - ddy
  end if
  xm = y1+dy
  dumNPe = gsn_add_text(wks,plots(2),smryenp,xm+2,ym,resNP_text)  ; add text
  ym = ym-ddy
  resNP_text@txFontColor       = "red"
  dumNPm = gsn_add_text(wks,plots(2),smrymnp,xm+2,ym,resNP_text)
  ym = ym-ddy
  resNP_text@txFontColor       = "blue"
  dumNPj = gsn_add_text(wks,plots(2),smryjnp,xm+2,ym,resNP_text)  ; add text
  ym = ym-ddy
  resNP_text@txFontColor       = "green4"
  dumNPw = gsn_add_text(wks,plots(2),smrywnp,xm+2,ym,resNP_text)  ; add text

  resST = res
  resST@gsnCenterString        = "ST-tropics"
  gpercsST := new((/8,nbins/), typeof(ve))
  rvelst = velst(:)/expc(:)
  rvmlst = vmlst(:)/expc(:)
  rvjlst = vjlst(:)/expc(:)
  rvwlst = vwlst(:)/expc(:)
  rveost = veost(:)/expc(:)
  rvmost = vmost(:)/expc(:)
  rvjost = vjost(:)/expc(:)
  rvwost = vwost(:)/expc(:)
  rclelst = regline_stats(bins,rvelst)
  rclmlst = regline_stats(bins,rvmlst)
  rcljlst = regline_stats(bins,rvjlst)
  rclwlst = regline_stats(bins,rvwlst)
  rcleost = regline_stats(bins,rveost)
  rclmost = regline_stats(bins,rvmost)
  rcljost = regline_stats(bins,rvjost)
  rclwost = regline_stats(bins,rvwost)
  mvalelst = rclelst
  mvalmlst = rclmlst
  mvaljlst = rcljlst
  mvalwlst = rclwlst
  mvaleost = rcleost
  mvalmost = rclmost
  mvaljost = rcljost
  mvalwost = rclwost
; cvalel = rclelnm@yintercept
  pvalelst = rclelst@pval(0)
  pvalmlst = rclmlst@pval(0)
  pvaljlst = rcljlst@pval(0)
  pvalwlst = rclwlst@pval(0)
  pvaleost = rcleost@pval(0)
  pvalmost = rclmost@pval(0)
  pvaljost = rcljost@pval(0)
  pvalwost = rclwost@pval(0)
; linel = (bins*mvalel)+cvalel
  mvrdelst = flt2string(decimalPlaces(mvalelst,4,True)*10)
  mvrdmlst = flt2string(decimalPlaces(mvalwlst,4,True)*10)
  mvrdjlst = flt2string(decimalPlaces(mvaljlst,4,True)*10)
  mvrdwlst = flt2string(decimalPlaces(mvalwlst,4,True)*10)
  mvrdeost = flt2string(decimalPlaces(mvaleost,4,True)*10)
  mvrdmost = flt2string(decimalPlaces(mvalwost,4,True)*10)
  mvrdjost = flt2string(decimalPlaces(mvaljost,4,True)*10)
  mvrdwost = flt2string(decimalPlaces(mvalwost,4,True)*10)
  pvrdelst = decimalPlaces(pvalelst,2,True)
  pvrdmlst = decimalPlaces(pvalmlst,2,True)
  pvrdjlst = decimalPlaces(pvaljlst,2,True)
  pvrdwlst = decimalPlaces(pvalwlst,2,True)
  pvrdeost = decimalPlaces(pvaleost,2,True)
  pvrdmost = decimalPlaces(pvalmost,2,True)
  pvrdjost = decimalPlaces(pvaljost,2,True)
  pvrdwost = decimalPlaces(pvalwost,2,True)
  pvtxelst = where(pvrdelst.lt.0.01,"0.00",""+pvrdelst)
  pvtxmlst = where(pvrdmlst.lt.0.01,"0.00",""+pvrdmlst)
  pvtxjlst = where(pvrdjlst.lt.0.01,"0.00",""+pvrdjlst)
  pvtxwlst = where(pvrdwlst.lt.0.01,"0.00",""+pvrdwlst)
  pvtxeost = where(pvrdeost.lt.0.01,"0.00",""+pvrdeost)
  pvtxmost = where(pvrdmost.lt.0.01,"0.00",""+pvrdmost)
  pvtxjost = where(pvrdjost.lt.0.01,"0.00",""+pvrdjost)
  pvtxwost = where(pvrdwost.lt.0.01,"0.00",""+pvrdwost)
  smryest = "("+mvrdelst+", "+pvtxelst+"/ "+mvrdeost+", "+pvtxeost+")"
  smrymst = "("+mvrdmlst+", "+pvtxmlst+"/ "+mvrdmost+", "+pvtxmost+")"
  smryjst = "("+mvrdjlst+", "+pvtxjlst+"/ "+mvrdjost+", "+pvtxjost+")"
  smrywst = "("+mvrdwlst+", "+pvtxwlst+"/ "+mvrdwost+", "+pvtxwost+")"
  gpercsST(0,:) = runave_n(rvelst(:),nry,0,0)
  gpercsST(1,:) = runave_n(rvmlst(:),nry,0,0)
  gpercsST(2,:) = runave_n(rvjlst(:),nry,0,0)
  gpercsST(3,:) = runave_n(rvwlst(:),nry,0,0)
  gpercsST(4,:) = runave_n(rveost(:),nry,0,0)
  gpercsST(5,:) = runave_n(rvmost(:),nry,0,0)
  gpercsST(6,:) = runave_n(rvjost(:),nry,0,0)
  gpercsST(7,:) = runave_n(rvwost(:),nry,0,0)
  plots(3) = gsn_csm_xy (wks, bins, gpercsST, resST)        ; create plot
  resST_line = True
  resST_line@gsLineDashPattern = 1
  resST_line@gsLineThicknessF  = 1
  resST_line@gsLineColor       = "black"
  dumBst  = gsn_add_polyline(wks,plots(3),(/y1,y2/),(/1,1/),resST_line)
  resST_text                   = True              ; text mods desired
  resST_text@txFontHeightF     = 0.015             ; change text size
  resST_text@txJust            = "CenterLeft"      ; text justification
  resST_text@txPerimSpaceF     = 0.09
  if ( pos.eq."topleft" ) then
    ym = ymax - ddy
  end if
  xm = y1+dy
  dumSTe = gsn_add_text(wks,plots(3),smryest,xm+2,ym,resST_text)  ; add text
  ym = ym-ddy
  resST_text@txFontColor       = "red"
  dumSTm = gsn_add_text(wks,plots(3),smrymst,xm+2,ym,resST_text)
  ym = ym-ddy
  resST_text@txFontColor       = "blue"
  dumSTj = gsn_add_text(wks,plots(3),smryjst,xm+2,ym,resST_text)  ; add text
  ym = ym-ddy
  resST_text@txFontColor       = "green4"
  dumSTw = gsn_add_text(wks,plots(3),smrywst,xm+2,ym,resST_text)  ; add text

  resSM = res
  resSM@gsnCenterString        = "SH-midlats"
  gpercsSM := new((/8,nbins/), typeof(ve))
  rvelsm = velsm(:)/expc(:)
  rvmlsm = vmlsm(:)/expc(:)
  rvjlsm = vjlsm(:)/expc(:)
  rvwlsm = vwlsm(:)/expc(:)
  rveosm = veosm(:)/expc(:)
  rvmosm = vmosm(:)/expc(:)
  rvjosm = vjosm(:)/expc(:)
  rvwosm = vwosm(:)/expc(:)
  rclelsm = regline_stats(bins,rvelsm)
  rclmlsm = regline_stats(bins,rvmlsm)
  rcljlsm = regline_stats(bins,rvjlsm)
  rclwlsm = regline_stats(bins,rvwlsm)
  rcleosm = regline_stats(bins,rveosm)
  rclmosm = regline_stats(bins,rvmosm)
  rcljosm = regline_stats(bins,rvjosm)
  rclwosm = regline_stats(bins,rvwosm)
  mvalelsm = rclelsm
  mvalmlsm = rclmlsm
  mvaljlsm = rcljlsm
  mvalwlsm = rclwlsm
  mvaleosm = rcleosm
  mvalmosm = rclmosm
  mvaljosm = rcljosm
  mvalwosm = rclwosm
; cvalel = rclelnm@yintercept
  pvalelsm = rclelsm@pval(0)
  pvalmlsm = rclmlsm@pval(0)
  pvaljlsm = rcljlsm@pval(0)
  pvalwlsm = rclwlsm@pval(0)
  pvaleosm = rcleosm@pval(0)
  pvalmosm = rclmosm@pval(0)
  pvaljosm = rcljosm@pval(0)
  pvalwosm = rclwosm@pval(0)
; linel = (bins*mvalel)+cvalel
  mvrdelsm = flt2string(decimalPlaces(mvalelsm,4,True)*10)
  mvrdmlsm = flt2string(decimalPlaces(mvalwlsm,4,True)*10)
  mvrdjlsm = flt2string(decimalPlaces(mvaljlsm,4,True)*10)
  mvrdwlsm = flt2string(decimalPlaces(mvalwlsm,4,True)*10)
  mvrdeosm = flt2string(decimalPlaces(mvaleosm,4,True)*10)
  mvrdmosm = flt2string(decimalPlaces(mvalwosm,4,True)*10)
  mvrdjosm = flt2string(decimalPlaces(mvaljosm,4,True)*10)
  mvrdwosm = flt2string(decimalPlaces(mvalwosm,4,True)*10)
  pvrdelsm = decimalPlaces(pvalelsm,2,True)
  pvrdmlsm = decimalPlaces(pvalmlsm,2,True)
  pvrdjlsm = decimalPlaces(pvaljlsm,2,True)
  pvrdwlsm = decimalPlaces(pvalwlsm,2,True)
  pvrdeosm = decimalPlaces(pvaleosm,2,True)
  pvrdmosm = decimalPlaces(pvalmosm,2,True)
  pvrdjosm = decimalPlaces(pvaljosm,2,True)
  pvrdwosm = decimalPlaces(pvalwosm,2,True)
  pvtxelsm = where(pvrdelsm.lt.0.01,"0.00",""+pvrdelsm)
  pvtxmlsm = where(pvrdmlsm.lt.0.01,"0.00",""+pvrdmlsm)
  pvtxjlsm = where(pvrdjlsm.lt.0.01,"0.00",""+pvrdjlsm)
  pvtxwlsm = where(pvrdwlsm.lt.0.01,"0.00",""+pvrdwlsm)
  pvtxeosm = where(pvrdeosm.lt.0.01,"0.00",""+pvrdeosm)
  pvtxmosm = where(pvrdmosm.lt.0.01,"0.00",""+pvrdmosm)
  pvtxjosm = where(pvrdjosm.lt.0.01,"0.00",""+pvrdjosm)
  pvtxwosm = where(pvrdwosm.lt.0.01,"0.00",""+pvrdwosm)
  smryesm = "("+mvrdelsm+", "+pvtxelsm+"/ "+mvrdeosm+", "+pvtxeosm+")"
  smrymsm = "("+mvrdmlsm+", "+pvtxmlsm+"/ "+mvrdmosm+", "+pvtxmosm+")"
  smryjsm = "("+mvrdjlsm+", "+pvtxjlsm+"/ "+mvrdjosm+", "+pvtxjosm+")"
  smrywsm = "("+mvrdwlsm+", "+pvtxwlsm+"/ "+mvrdwosm+", "+pvtxwosm+")"
  gpercsSM(0,:) = runave_n(rvelsm(:),nry,0,0)
  gpercsSM(1,:) = runave_n(rvmlsm(:),nry,0,0)
  gpercsSM(2,:) = runave_n(rvjlsm(:),nry,0,0)
  gpercsSM(3,:) = runave_n(rvwlsm(:),nry,0,0)
  gpercsSM(4,:) = runave_n(rveosm(:),nry,0,0)
  gpercsSM(5,:) = runave_n(rvmosm(:),nry,0,0)
  gpercsSM(6,:) = runave_n(rvjosm(:),nry,0,0)
  gpercsSM(7,:) = runave_n(rvwosm(:),nry,0,0)
  plots(4) = gsn_csm_xy (wks, bins, gpercsSM, resSM)        ; create plot
  resSM_line = True
  resSM_line@gsLineDashPattern = 1
  resSM_line@gsLineThicknessF  = 1
  resSM_line@gsLineColor       = "black"
  dumBsm  = gsn_add_polyline(wks,plots(4),(/y1,y2/),(/1,1/),resSM_line)
  resSM_text                   = True              ; text mods desired
  resSM_text@txFontHeightF     = 0.015             ; change text size
  resSM_text@txJust            = "CenterLeft"      ; text justification
  resSM_text@txPerimSpaceF     = 0.09
  if ( pos.eq."topleft" ) then
    ym = ymax - ddy
  end if
  xm = y1+dy
  dumSMe = gsn_add_text(wks,plots(4),smryesm,xm+2,ym,resSM_text)  ; add text
  ym = ym-ddy
  resSM_text@txFontColor       = "red"
  dumSMm = gsn_add_text(wks,plots(4),smrymsm,xm+2,ym,resSM_text)
  ym = ym-ddy
  resSM_text@txFontColor       = "blue"
  dumSMj = gsn_add_text(wks,plots(4),smryjsm,xm+2,ym,resSM_text)  ; add text
  ym = ym-ddy
  resSM_text@txFontColor       = "green4"
  dumSMw = gsn_add_text(wks,plots(4),smrywsm,xm+2,ym,resSM_text)  ; add text

  resSP = res
  resSP@gsnCenterString        = "SH-polar"
  gpercsSP := new((/8,nbins/), typeof(ve))
  rvelsp = velsp(:)/expc(:)
  rvmlsp = vmlsp(:)/expc(:)
  rvjlsp = vjlsp(:)/expc(:)
  rvwlsp = vwlsp(:)/expc(:)
  rveosp = veosp(:)/expc(:)
  rvmosp = vmosp(:)/expc(:)
  rvjosp = vjosp(:)/expc(:)
  rvwosp = vwosp(:)/expc(:)
  rclelsp = regline_stats(bins,rvelsp)
  rclmlsp = regline_stats(bins,rvmlsp)
  rcljlsp = regline_stats(bins,rvjlsp)
  rclwlsp = regline_stats(bins,rvwlsp)
  rcleosp = regline_stats(bins,rveosp)
  rclmosp = regline_stats(bins,rvmosp)
  rcljosp = regline_stats(bins,rvjosp)
  rclwosp = regline_stats(bins,rvwosp)
  mvalelsp = rclelsp
  mvalmlsp = rclmlsp
  mvaljlsp = rcljlsp
  mvalwlsp = rclwlsp
  mvaleosp = rcleosp
  mvalmosp = rclmosp
  mvaljosp = rcljosp
  mvalwosp = rclwosp
; cvalel = rclelnm@yintercept
  pvalelsp = rclelsp@pval(0)
  pvalmlsp = rclmlsp@pval(0)
  pvaljlsp = rcljlsp@pval(0)
  pvalwlsp = rclwlsp@pval(0)
  pvaleosp = rcleosp@pval(0)
  pvalmosp = rclmosp@pval(0)
  pvaljosp = rcljosp@pval(0)
  pvalwosp = rclwosp@pval(0)
; linel = (bins*mvalel)+cvalel
  mvrdelsp = flt2string(decimalPlaces(mvalelsp,4,True)*10)
  mvrdmlsp = flt2string(decimalPlaces(mvalwlsp,4,True)*10)
  mvrdjlsp = flt2string(decimalPlaces(mvaljlsp,4,True)*10)
  mvrdwlsp = flt2string(decimalPlaces(mvalwlsp,4,True)*10)
  mvrdeosp = flt2string(decimalPlaces(mvaleosp,4,True)*10)
  mvrdmosp = flt2string(decimalPlaces(mvalwosp,4,True)*10)
  mvrdjosp = flt2string(decimalPlaces(mvaljosp,4,True)*10)
  mvrdwosp = flt2string(decimalPlaces(mvalwosp,4,True)*10)
  pvrdelsp = decimalPlaces(pvalelsp,2,True)
  pvrdmlsp = decimalPlaces(pvalmlsp,2,True)
  pvrdjlsp = decimalPlaces(pvaljlsp,2,True)
  pvrdwlsp = decimalPlaces(pvalwlsp,2,True)
  pvrdeosp = decimalPlaces(pvaleosp,2,True)
  pvrdmosp = decimalPlaces(pvalmosp,2,True)
  pvrdjosp = decimalPlaces(pvaljosp,2,True)
  pvrdwosp = decimalPlaces(pvalwosp,2,True)
  pvtxelsp = where(pvrdelsp.lt.0.01,"0.00",""+pvrdelsp)
  pvtxmlsp = where(pvrdmlsp.lt.0.01,"0.00",""+pvrdmlsp)
  pvtxjlsp = where(pvrdjlsp.lt.0.01,"0.00",""+pvrdjlsp)
  pvtxwlsp = where(pvrdwlsp.lt.0.01,"0.00",""+pvrdwlsp)
  pvtxeosp = where(pvrdeosp.lt.0.01,"0.00",""+pvrdeosp)
  pvtxmosp = where(pvrdmosp.lt.0.01,"0.00",""+pvrdmosp)
  pvtxjosp = where(pvrdjosp.lt.0.01,"0.00",""+pvrdjosp)
  pvtxwosp = where(pvrdwosp.lt.0.01,"0.00",""+pvrdwosp)
  smryesp = "("+mvrdelsp+", "+pvtxelsp+"/ "+mvrdeosp+", "+pvtxeosp+")"
  smrymsp = "("+mvrdmlsp+", "+pvtxmlsp+"/ "+mvrdmosp+", "+pvtxmosp+")"
  smryjsp = "("+mvrdjlsp+", "+pvtxjlsp+"/ "+mvrdjosp+", "+pvtxjosp+")"
  smrywsp = "("+mvrdwlsp+", "+pvtxwlsp+"/ "+mvrdwosp+", "+pvtxwosp+")"
  gpercsSP(0,:) = runave_n(rvelsp(:),nry,0,0)
  gpercsSP(1,:) = runave_n(rvmlsp(:),nry,0,0)
  gpercsSP(2,:) = runave_n(rvjlsp(:),nry,0,0)
  gpercsSP(3,:) = runave_n(rvwlsp(:),nry,0,0)
  gpercsSP(4,:) = runave_n(rveosp(:),nry,0,0)
  gpercsSP(5,:) = runave_n(rvmosp(:),nry,0,0)
  gpercsSP(6,:) = runave_n(rvjosp(:),nry,0,0)
  gpercsSP(7,:) = runave_n(rvwosp(:),nry,0,0)
  plots(5) = gsn_csm_xy (wks, bins, gpercsSP, resSP)        ; create plot
  resSP_line = True
  resSP_line@gsLineDashPattern = 1
  resSP_line@gsLineThicknessF  = 1
  resSP_line@gsLineColor       = "black"
  dumBsp  = gsn_add_polyline(wks,plots(5),(/y1,y2/),(/1,1/),resSP_line)
  resSP_text                   = True              ; text mods desired
  resSP_text@txFontHeightF     = 0.015             ; change text size
  resSP_text@txJust            = "CenterLeft"      ; text justification
  resSP_text@txPerimSpaceF     = 0.09
  if ( pos.eq."topleft" ) then
    ym = ymax - ddy
  end if
  xm = y1+dy
  dumSPe = gsn_add_text(wks,plots(5),smryesp,xm+2,ym,resSP_text)  ; add text
  ym = ym-ddy
  resSP_text@txFontColor       = "red"
  dumSPm = gsn_add_text(wks,plots(5),smrymsp,xm+2,ym,resSP_text)
  ym = ym-ddy
  resSP_text@txFontColor       = "blue"
  dumSPj = gsn_add_text(wks,plots(5),smryjsp,xm+2,ym,resSP_text)  ; add text
  ym = ym-ddy
  resSP_text@txFontColor       = "green4"
  dumSPw = gsn_add_text(wks,plots(5),smrywsp,xm+2,ym,resSP_text)  ; add text

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
