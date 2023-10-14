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

  idir = getenv("idir")
  stat = getenv("stat")
  nmod = getenv("nmod")
  dom  = getenv("dom")
  obn  = getenv("obsn")

  fno0  = getenv("fno0")
  yr1o0 = getenv("yr1o0")
  yr2o0 = getenv("yr2o0")
  dno0  = getenv("dno0")
  n1o0  = getenv("n1o0")
  n2o0  = getenv("n2o0")
  yo1o0 = getenv("yo1o0")
  yo2o0 = getenv("yo2o0")

  var = "n"
  outim = idir+"/frq_"+dom+"_masked_reanalysis_"+stat
  formo = "png"
  wks  = gsn_open_wks ("png",outim)             ; send graphics to PNG file
  nry = 10 ; number of years of running mean

  gfn  = (/fno0,  fnr1,  fnr2,  fng1 /)    ; file names
  gyr1 = (/yr1o0, yr1r1, yr1r2, yr1g1/)    ; data year start
  gyr2 = (/yr2o0, yr2r1, yr2r2, yr2g1/)    ; data year end
  gdn  = (/dno0,  dnr1,  dnr2,  dng1/)     ; data name
  gn1  = (/n1o0,  n1r1,  n1r2,  n1g1/)     ; time step number 1
  gn2  = (/n2o0,  n2r1,  n2r2,  n2g1/)     ; time step number 2
  gyo1 = (/yo1o0, yo1r1, yo1r2, yo1g1/)    ; year 1
  gyo2 = (/yo2o0, yo2r1, yo2r2, yo2g1/)    ; year 2

  yr1A = min(stringtointeger(gyo1))  ; group common years
  yr2A = max(stringtointeger(gyo2))
  nyrA = yr2A - yr1A + 1
  tbins = ispan(yr1A,yr1A-1+nyrA,1)

  nmod := stringtointeger(nmod)
  mval = new ((/nmod/), "float")
; rval = new ((/nmod/), "float")
  pval = new ((/nmod/), "float")
; ssig = new ((/nmod/), "float")

  do nm=0, nmod-1
    fnam = gfn(nm)
    yr1  = gyr1(nm)
    yr2  = gyr2(nm)
    dn   = gdn(nm)
    n1   := gn1(nm)
    n2   := gn2(nm)
    yo1  = gyo1(nm)
    yo2  = gyo2(nm)

    n1 := stringtointeger(n1)
    n2 := stringtointeger(n2)

    dnsplt := str_split(dn,"-")

    f := addfile(fnam, "r")
    v := f->n(n1:n2,0,0)
    if ( nm.eq.2 ) then
      v := tofloat(v)
    end if
 
    pdim := dimsizes(v)
    nbins = pdim(0)
    y1 = stringtointeger(yr1)
    y2 = stringtointeger(yr2)
    bins := ispan(y1,y1-1+nbins,1)

    y1f = floattointeger(floor(int2flt(yr1A)/10)*10)
    y2c = floattointeger(ceil(int2flt(yr2A)/10)*10)
    n1A := y1 - yr1A     ; time step 1 wrt common start year

    ;setting expected start year from initial analysis year (in namelist)
    yro1 = stringtointeger(yo1)
    yro2 = stringtointeger(yo2)
    yr_orig := ispan(yro1,yro2,1)
    nyr_orig = dimsizes(yr_orig)
    ;------------------------------------------------
    ; Plot each PDF
    ;------------------------------------------------
    recs := new ((/2,nbins/), "float")
    expc := new ((/1,nyr_orig/), "float")
    recs(1,:) = v(:)
    do k =1, nyr_orig
      expc(0,k-1) = 1.0/k
     ;print("k="+k+" recs="+recs(0,k-1))
    end do
    recs(0,:) = (/expc(0,n1:n2)/)

;;  rat := recs(1,:)/recs(0,:)
;;  run := runave_n(rat,nry,0,0)
;;  recs(0,:) = (/rat(:)/)
;;  recs(1,:) = (/run(:)/)

;  ;; where condition for single point testing - comment for analysis
;  ;recs = where(recs.eq.0,recs@_FillValue,recs)

    if ( nm.eq.0 ) then
      allrats = new ((/nmod*2,nyrA/),"float")
    end if

;   rcl = regline_stats(yr_orig(n1:n2),rat)
;   ;print(rcl) 
;   mval(nm) = rcl
;   cval = rcl@yintercept
; ; rval(nm) = rcl@r2
; ; df   = rcl@N-2 ;rcl@nptxy-2
; ; pval(nm) = decimalPlaces(rcl@pval(0),3,True)
;   pval(nm) = rcl@pval(0)
; ; ssig(nm) = betainc(df/(df+mval(nm)^2), df/2.0, 0.5)
; ; ssig not used, because betainc uses method that does not correspond to regline_stats 

;   ratv = bins 
;   ratv := (ratv*mval(nm))+cval
;   ratv := where(run.eq.run@_FillValue,ratv@_FillValue,ratv)
;   recs(2,:) = (/ratv(:)/)
;   delete(ratv)

    allrats(nm,n1A:n1A+nbins-1) = (/recs(0,:)/)
    allrats(nm+nmod,n1A:n1A+nbins-1) = (/recs(1,:)/)
;   delete(rcl)
;;  delete(df)

;   delete(recs)
    delete(expc)
;   delete(rat)
;   delete(run)
    delete(v)

  end do

  res  = True
  res@tmXTOn = False
  res@tmYROn = False
  res@gsnFrame               = False
  res@gsnDraw                = False
  res@xyMarkLineModes = (/"Lines","Lines","Lines","Lines","Markers","Markers","Markers","Markers"/)
  res@xyLineColors    = (/"black","blue","red","forestgreen","black","blue","red","forestgreen"/)
  res@xyLineThicknesses = (/3,3,3,3,3,3,3,3/)
  res@xyDashPatterns    = (/1,1,1,1,0,0,0,0/)
  res@xyMarkers         = (/16,16,16,16,16,16,16,16/)
  res@xyMarkerColors    = (/"black","blue","red","forestgreen","black","blue","red","forestgreen"/)
  res@xyMarkerSizeF     = 0.005


  res@tiYAxisString          = "frequency (#)"
  res@tiYAxisFontHeightF     = 0.03
  res@tiXAxisString          = "year"
  res@tiXAxisFontHeightF     = 0.03

  dnttl = "SAS" ;dom;+"-REANALYSIS"
  res@gsnCenterString        = dnttl  

  res@trYLog = True
  res@trYMaxF    = 1.
  res@trYMinF    = 1e-2
  res@trXMinF    = y1f
  res@trXMaxF    = y2c
; res@tmYLMode = "Manual"
; res@tmYLTickStartF = 0.
; res@tmYLTickEndF = res@trYMaxF
; res@tmYLTickSpacingF = 0.2
  plot = gsn_csm_xy (wks, tbins, allrats, res)        ; create plot

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

  res_mark   = True
  res_mark@gsMarkerIndex     = "dot"
  res_mark@gsMarkerColor     = "black"
  res_mark@gsMarkerSizeF     = 0.020

  dy = (yr2A-yr1A)*1.6/7
  xm = yr2A-dy
  ym = 0.85
  res_line@gsLineDashPattern = 1
  dum0A = gsn_add_polyline(wks,plot,(/xm-2,xm+1/),(/ym,ym/),res_line)
  dum0B = gsn_add_text(wks,plot,"Reference",xm+2,ym,res_text)  ; add text

  dyv = .14
  ym = ym-dyv
  dum0C = gsn_add_polymarker(wks,plot,xm,ym,res_mark)        ; add polyline
  dum0D = gsn_add_text(wks,plot,"Actual",xm+2,ym,res_text)  ; add text

  dyv = .21
  ym = ym-dyv
;  tstring := obn
;  dum1 = gsn_add_polyline(wks,plot,(/xm-2,xm+1/),(/ym,ym/),res_line)
;  dum2 = gsn_add_text(wks,plot,tstring,xm+2,ym,res_text) ;add text

;  dyv = .08
;  ym = ym-dyv
  res_line@gsLineColor       = "Blue"
  tstring := "ERA5"
  dum3 = gsn_add_polyline(wks,plot,(/xm-2,xm+1/),(/ym,ym/),res_line)
  dum4 = gsn_add_text(wks,plot,tstring,xm+2,ym,res_text) ;add text

  dyv = .08
  ym = ym-dyv
  res_line@gsLineColor     = "Red" 
  tstring := "MERRA"
  dum5 = gsn_add_polyline(wks,plot,(/xm-2,xm+1/),(/ym,ym/),res_line)
  dum6 = gsn_add_text(wks,plot,tstring,xm+2,ym,res_text) ;add text

  dyv = .06
  ym = ym-dyv
  res_line@gsLineColor     = "forestgreen"
  tstring := "JRA55"
  dum7 = gsn_add_polyline(wks,plot,(/xm-2,xm+1/),(/ym,ym/),res_line)
  dum8 = gsn_add_text(wks,plot,tstring,xm+2,ym,res_text) ;add text


;*****************************************************
; save output image
;******************************************************
 
  resP                     = True

  maximize_output(wks,resP)

  trimPNG(outim+"."+formo)

end
