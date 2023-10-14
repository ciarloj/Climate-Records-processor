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
  m1id = getenv("mod1id")
  coyr = getenv("cutoff")

  fno0  = getenv("fno0")
  yr1o0 = getenv("yr1o0")
  yr2o0 = getenv("yr2o0")
  dno0  = getenv("dno0")
  n1o0  = getenv("n1o0")
  n2o0  = getenv("n2o0")
  yo1o0 = getenv("yo1o0")
  yo2o0 = getenv("yo2o0")

  var = "n"
  outim = idir+"/ratios_"+dom+"_models_plus_reanalysis_"+stat
  formo = "png"
  wks  = gsn_open_wks ("png",outim)             ; send graphics to PNG file
  nry = 10 ; number of years of running mean

  gfn  = (/fno0,  fnr1,  fnr2,  fnr3 , fnm1 , fnm2 , fnm3 /)    ; file names
  gyr1 = (/yr1o0, yr1r1, yr1r2, yr1r3, yr1m1, yr1m2, yr1m3/)    ; data year start
  gyr2 = (/yr2o0, yr2r1, yr2r2, yr2r3, yr2m1, yr2m2, yr2m3/)    ; data year end
  gdn  = (/dno0,  dnr1,  dnr2,  dnr3 , dnm1 , dnm2 , dnm3 /)    ; data name
  gn1  = (/n1o0,  n1r1,  n1r2,  n1r3 , n1m1 , n1m2 , n1m3 /)    ; time step number 1
  gn2  = (/n2o0,  n2r1,  n2r2,  n2r3 , n2m1 , n2m2 , n2m3 /)    ; time step number 2
  gyo1 = (/yo1o0, yo1r1, yo1r2, yo1r3, yo1m1, yo1m2, yo1m3/)    ; year 1
  gyo2 = (/yo2o0, yo2r1, yo2r2, yo2r3, yo2m1, yo2m2, yo2m3/)    ; year 2
  con  = (/"999", "999", "999", "999", com1 , com2 , com3 /)    ; cutoff time step number

  yr1A = min(stringtointeger(gyo1))  ; group common years
  yr2A = max(stringtointeger(gyo2))
  nyrA = yr2A - yr1A + 1
  tbins = ispan(yr1A,yr1A-1+nyrA,1)

  con  := stringtointeger(con)
  nmod := stringtointeger(nmod)
  mval = new ((/nmod/), "float")
  pval = new ((/nmod/), "float")
  mvalf= new ((/nmod/), "float")
  pvalf= new ((/nmod/), "float")


  do nm=0, nmod-1
    fnam = gfn(nm)
    yr1  = gyr1(nm)
    yr2  = gyr2(nm)
    dn   = gdn(nm)
    n1   := gn1(nm)
    n2   := gn2(nm)
    yo1  = gyo1(nm)
    yo2  = gyo2(nm)
    co   = con(nm)

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
    recs := new ((/3,nbins/), "float")
    expc := new ((/1,nyr_orig/), "float")
    recs(1,:) = v(:)
    do k =1, nyr_orig
      expc(0,k-1) = 1.0/k
     ;print("k="+k+" recs="+recs(0,k-1))
    end do
    recs(0,:) = (/expc(0,n1:n2)/)

    rat := recs(1,:)/recs(0,:)
    run := runave_n(rat,nry,0,0)
    recs(0,:) = (/rat(:)/)
    recs(1,:) = (/run(:)/)

   ;; where condition for single point testing - comment for analysis
   ;recs = where(recs.eq.0,recs@_FillValue,recs)

    if ( nm.eq.0 ) then
      allrats = new ((/nmod*2,nyrA/),"float")
    end if

    nf = n2
    nmp1 = nm+1
    if ( nmp1.ge.m1id ) then
      nf = co
    end if
    rcl = regline_stats(yr_orig(n1:nf),rat(n1:nf))
    mval(nm) = rcl
    cval = rcl@yintercept
    pval(nm) = rcl@pval(0)

    if ( nmp1.ge.m1id ) then
      rclf = regline_stats(yr_orig(nf+1:n2),rat(nf+1:n2))
      mvalf(nm) = rclf
      cvalf = rclf@yintercept
      pvalf(nm) = rclf@pval(0)

      ratv = bins(n1:nf)
      ratv := (ratv*mval(nm))+cval
      ratv := where(run(n1:nf).eq.run@_FillValue,ratv@_FillValue,ratv)
      ratvf = bins(nf+1:n2)
      ratvf := (ratvf*mvalf(nm))+cvalf
      ratvf := where(run(nf+1:n2).eq.run@_FillValue,ratv@_FillValue,ratvf)
      recs(2,n1:nf) = (/ratv(:)/)
      recs(2,nf+1:n2) = (/ratvf(:)/)
      recs(2,nf) = ratv@_FillValue
    else
      ratv = bins
      ratv := (ratv*mval(nm))+cval
      ratv := where(run.eq.run@_FillValue,ratv@_FillValue,ratv)
      recs(2,:) = (/ratv(:)/)
    end if

    delete(ratv)

    allrats(nm,n1A:n1A+nbins-1) = (/recs(1,:)/)
    allrats(nm+nmod,n1A:n1A+nbins-1) = (/recs(2,:)/)
    delete(rcl)
;   delete(df)

    delete(recs)
    delete(expc)
    delete(rat)
    delete(run)
    delete(v)

  end do

  res  = True
  res@tmXTOn = False
  res@tmYROn = False
  res@gsnFrame               = False
  res@gsnDraw                = False
  lm = "Lines"
  c1 = "transparent"
  c2 = "blue"
  c3 = "red"
  c4 = "forestgreen"
  c5 = "black"
  c6 = "orangered"
  c7 = "transparent"
  res@xyMarkLineModes   = (/lm,lm,lm,lm,lm,lm,lm,lm,lm,lm,lm,lm,lm,lm/)
  res@xyLineColors      = (/c1,c2,c3,c4,c5,c6,c7,c1,c2,c3,c4,c5,c6,c7/)
  res@xyLineThicknesses = (/ 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3/)
  res@xyDashPatterns    = (/ 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1/)

  res@tiYAxisString          = "frequency ratio (actual/reference)"
  res@tiYAxisFontHeightF     = 0.03
  res@tiXAxisString          = "year"
  res@tiXAxisFontHeightF     = 0.03

  dnttl =dom;+"-REANALYSIS"
  res@gsnCenterString        = dnttl  

  res@trYMaxF    = 2.6
  res@trYMinF    = 0.70 
  res@trXMinF    = y1f
  res@trXMaxF    = y2c
  res@tmYLMode = "Manual"
  res@tmYLTickStartF = 0.
  res@tmYLTickEndF = res@trYMaxF
  res@tmYLTickSpacingF = 0.2
  plot = gsn_csm_xy (wks, tbins, allrats, res)        ; create plot

;*****************************************************
; Manually create and attach legend
;*****************************************************
  res_text                   = True              ; text mods desired
  res_text@txFontHeightF     = 0.011             ; change text size
  res_text@txJust            = "CenterLeft"      ; text justification
  res_text@txPerimSpaceF     = 0.09

  res_line                   = True
  res_line@gsLineColor       = c1
  res_line@gsLineThicknessF  = 3

  mv_rnd = decimalPlaces(mval,3,True)
  mval = mv_rnd*10
  mv_t = flt2string(mval)

  mvf_rnd = decimalPlaces(mvalf,3,True)
  mvalf = mvf_rnd*10
  mvf_t = flt2string(mvalf)

  pv_rnd = decimalPlaces(pval,2,True)
  pv_txt = where(pv_rnd.lt.0.005,"0.00",""+pv_rnd)
  
  pvf_rnd = decimalPlaces(pvalf,2,True)
  pvf_txt = where(pvf_rnd.lt.0.005,"0.00",""+pvf_rnd)

  dy = (yr2A-yr1A)*0.3/7
  xm = yr1A+dy
  ym = res@trYMaxF - (res@trYMaxF/65)
  res_line@gsLineDashPattern = 0

  ;tstring := ""
  ;tstring@tstringFontColor = "White"
  ;tstring := obn+" ("+mv_t(0)+"/"+pv_txt(0)+")"

  ;dum1 = gsn_add_polyline(wks,plot,(/xm-3,xm+1/),(/ym,ym/),res_line)
  ;dum2 = gsn_add_text(wks,plot,tstring,xm+3,ym,res_text) ;add text

  dyv= .06
  ym = ym-dyv
  res_line@gsLineColor       = c2
  ;tstring@tstringFontColor = "Black"
  tstring := "ERA5 ("+mv_t(1)+"/"+pv_txt(1)+")"
  tstring@tstringFontColor = "Black"
  dum3 = gsn_add_polyline(wks,plot,(/xm-3,xm+1/),(/ym,ym/),res_line)
  dum4 = gsn_add_text(wks,plot,tstring,xm+3,ym,res_text) ;add text

  ym = ym-dyv
  res_line@gsLineColor     = c3 
  tstring := "MERRA ("+mv_t(2)+"/"+pv_txt(2)+")"
  dum5 = gsn_add_polyline(wks,plot,(/xm-3,xm+1/),(/ym,ym/),res_line)
  dum6 = gsn_add_text(wks,plot,tstring,xm+3,ym,res_text) ;add text

  ym = ym-dyv
  res_line@gsLineColor     = c4
  tstring := "JRA55 ("+mv_t(3)+"/"+pv_txt(3)+")"
  dum7 = gsn_add_polyline(wks,plot,(/xm-3,xm+1/),(/ym,ym/),res_line)
  dum8 = gsn_add_text(wks,plot,tstring,xm+3,ym,res_text) ;add text

  ym = ym-dyv
  res_line@gsLineColor     = c5
  ;tstring := "MPI-26 ("+mv_t(4)+"/"+pv_txt(4)+","+mvf_t(4)+"/"+pvf_txt(4)+")"
  tstring := "MPI-26 ("+mv_t(4)+"/"+pv_txt(4)+")"
  dum9 = gsn_add_polyline(wks,plot,(/xm-3,xm+1/),(/ym,ym/),res_line)
  dum10= gsn_add_text(wks,plot,tstring,xm+3,ym,res_text) ;add text
  tstring := "MPI-26 ("+mvf_t(4)+"/"+pvf_txt(4)+")"
  dum901 = gsn_add_polyline(wks,plot,(/xm+50,xm+54/),(/ym,ym/),res_line)
  dum101 = gsn_add_text(wks,plot,tstring,xm+56,ym,res_text) ;add text to right side 

  ym = ym-dyv
  res_line@gsLineColor     = c6
  ;tstring := "REMO-MPI-85 ("+mv_t(5)+"/"+pv_txt(5)+","+mvf_t(5)+"/"+pvf_txt(5)+")"
  tstring := "REMO-MPI-26 ("+mv_t(5)+"/"+pv_txt(5)+")"
  dum11= gsn_add_polyline(wks,plot,(/xm-3,xm+1/),(/ym,ym/),res_line)
  dum12= gsn_add_text(wks,plot,tstring,xm+3,ym,res_text) ;add text
  tstring := "REMO-MPI-26 ("+mvf_t(5)+"/"+pvf_txt(5)+")"
  dum110 = gsn_add_polyline(wks,plot,(/xm+50,xm+54/),(/ym,ym/),res_line)
  dum120 = gsn_add_text(wks,plot,tstring,xm+56,ym,res_text) ;add text to right side

;  ym = ym-dyv
;  res_line@gsLineColor     = c7
;  ;tstring := "REGCM-MPI-85 ("+mv_t(6)+"/"+pv_txt(6)+", "+mvf_t(6)+"/"+pvf_txt(6)+")"
;  tstring := "REGCM-MPI-26 ("+mv_t(6)+"/"+pv_txt(6)+")"
;  dum13= gsn_add_polyline(wks,plot,(/xm-3,xm+1/),(/ym,ym/),res_line)
;  dum14= gsn_add_text(wks,plot,tstring,xm+3,ym,res_text) ;add text
;  tstring := "REGCM-MPI-26 ("+mvf_t(6)+"/"+pvf_txt(6)+")"
;  dum130 = gsn_add_polyline(wks,plot,(/xm+50,xm+54/),(/ym,ym/),res_line)
;  dum140 = gsn_add_text(wks,plot,tstring,xm+56,ym,res_text) ;add text to right side

  ; add vertical line to separate graphs
  res_line@gsLineColor = "black"
  res_line@gsLineDashPattern = 1
  res_line@gsLineThicknessF = 1
  vline_x := xm+44.5
  vline_y_start := res@trYMinF
  vline_y_end := res@trYMaxF
  vline = gsn_add_polyline(wks,plot,(/vline_x,vline_x/),(/vline_y_start,vline_y_end/),res_line)
;*****************************************************
; save output image
;******************************************************
 
  resP                     = True

  maximize_output(wks,resP)

; print("saved "+outim+"."+formo)
  trimPNG(outim+"."+formo)

end
