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
  yo1 = "1970"
  yo2 = "2100"
  yr1 = "2010"
  yr2 = "2100"
  tdim  = "1d"      ; type of dimensions for lat/lon = "1d" or "2d"
  outim = idir+"/fig8_ltrend_rcm_rcps"
  formo = "png"
  wks  = gsn_open_wks ("png",outim)             ; send graphics to PNG file

  y1 = stringtointeger(yr1)
  y2 = stringtointeger(yr2)
  c = 0
  do y=y1, y2
    n1 = c
    c = c + 1
  end do
  n2 = y2 - 1970

  dns = (/"REGCM-MPI-85","REMO-MPI-85","REGCM-MPI-26","REMO-MPI-26"/)
  plot = new((/4/),graphic)

  i = 0
 ;do s=0, 1
  do m=0, 3
    dn = dns(m)
   ;ssn = sns(s)
    dd = dn ;+"/"+ssn
    dn = dn ;+"-"+ssn
    fnam = sdir+dd+"/trim/"+stat+"/records/sum/index.nc"

    f = addfile(fnam, "r")
    n = f->n(n1:n2,:,:)
    p = f->p(n1:n2,:,:)

    if ( tdim.eq."2d" ) then
      xlat = f->lat
      xlon = f->lon
      dims = dimsizes(xlat)
      nlat = dims(1)
      nlon = dims(0)
    end if
    rg = n(0,:,:)
    rg = rg-rg                   ; empty field for regression gradients
    ss = rg                      ; empty field for statistical significance

    pdim = dimsizes(n)
    nbins = pdim(0)
    bins := tofloat(ispan(y1,y1-1+nbins,1))
    ny = pdim(1)
    nx = pdim(2)

    ;setting expected start year from initial analysis year (in namelist)
    yro1 = stringtointeger(yo1)
    yro2 = stringtointeger(yo2)
    yr_orig := ispan(yro1,yro2,1)
    nyr_orig = dimsizes(yr_orig)

    esto = new ((/nyr_orig/), "float")
    do k =1, nyr_orig
      esto(k-1) = 1.0/k
    end do
    est = esto(n1:n2)

    np = ny*nx
    print("ny x nx = "+ny+" x "+nx+" = "+np)
    print("dt = "+nbins)
    c = 0
    do iy=0, ny-1
      do jx=0, nx-1
        c = c + 1
        ;print("i = "+c+"/"+np)
        i_n = n(:,iy,jx)
        if ( ismissing(i_n(0)) ) then
          continue
        end if
        i_p = p(:,iy,jx)
        fq = i_n/i_p
        rt = fq/est
  
        rcl = regline(yr_orig(n1:n2),rt)
        tval = rcl@tval
        df = rcl@nptxy-2
        ssig = betainc(df/(df+tval^2), df/2.0, 0.5)
        delete_VarAtts(rcl,(/"yintercept","yave","xave","nptxy","rstd","tval"/))
       ;print (rcl)
       ;print (ssig)

        ss(iy,jx) = ssig
        rg(iy,jx) = rcl
      end do
    end do

    delete(n)
    delete(p)
    delete(c)
    delete(i_n)
    delete(i_p)
    delete(fq)
    delete(rt)
    delete(rcl)
    delete(est)

   ;***********************
   ; plot
   ;***********************

    res  = True
    res@gsnDraw             = False             ; don't draw yet
    res@gsnFrame            = False             ; don't advance frame yet

    res@mpLimitMode       = "Corners"            ; choose range of map
    if ( tdim.eq."2d" ) then
      res@mpLeftCornerLatF  = xlat(0,0)
      res@mpLeftCornerLonF  = xlon(0,0)
      res@mpRightCornerLatF = xlat(nlon-1,nlat-1)
      res@mpRightCornerLonF = xlon(nlon-1,nlat-1)
      prj = "LAMCON" ; f@projection
      clon = 9.75    ; f@longitude_of_projection_origin
      if (prj .eq. "LAMCON") then
        ;trlats = f@standard_parallel
        res@mpProjection        = "LambertConformal"
        res@mpLambertParallel1F = 30. ;trlats(0)
        res@mpLambertParallel2F = 65. ;trlats(1)
        res@mpLambertMeridianF  = clon
      end if
    end if
    if ( tdim.eq."1d" ) then
      res@mpLeftCornerLatF  = min(rg&latitude)
      res@mpLeftCornerLonF  = min(rg&longitude)
      res@mpRightCornerLatF = max(rg&latitude)
      res@mpRightCornerLonF = max(rg&longitude)
    end if

  ; usually, when data is placed onto a map, it is TRANSFORMED to the specified
  ; projection. Since this model is already on a native lambert conformal grid,
  ; we want to turn OFF the tranformation.

    res@tfDoNDCOverlay         = True      ; do not transform
    res@cnFillOn               = True      ; color plot desired
    res@cnFillMode             = "RasterFill"
    res@cnLinesOn              = False       ; no contour lines
    res@mpFillOn               = False

    res@mpGeophysicalLineColor = "black"     ; color of continental outlines
    res@mpPerimOn              = True      ; draw box around map
    res@mpGridLineDashPattern  = 5         ; lat/lon lines as dashed

;   res@gsnAddCyclic           = False     ; regional data don't add
;   res@pmTickMarkDisplayMode  = "Always"  ;
    res@mpGridAndLimbOn        = False               ; turn on grid lines
    res@lbLabelBarOn           = False
    res@lbOrientation          =   "vertical"
   ;res@lbLabelFontHeightF   = 0.02
   ;res@lbTitleFontHeightF   = 0.02                 ; make title smaller
   ;res@lbTitleString    = unit
   ;res@lbTitlePosition      = "Top"
    res@tmYROn = False            ; Turn off right tickmarks.
    res@tmXTOn = False            ; Turn off top tickmarks.
    res@tmYLOn = False
    res@tmXBOn = False
    if ( dn .eq. "E_OBS" ) then
      dnttl = "E-OBS"
    else
      dnttl = dn
    end if
    res@gsnCenterString        = dnttl+" ("+yr1+"-"+yr2+")"  ;+" "+snam

    res@cnLevelSelectionMode   = "ExplicitLevels"
    res@cnConstFLabelFormat    = "0f3"
    res@cnLevels = (/-.035,-.030,-.025,-.020,-.015,-.010,.010,.015,.020,.025,.030,.035/) 
    res@lbLabelStrings         = sprintf("%4.3f",res@cnLevels)   ; Format the labels
    cmap = read_colormap_file("hotcold_18lev")
    res@cnFillPalette = cmap
 
    sres = True
    sres@cnLineLabelsOn       = False
    sres@cnLineThicknessF     = 2.0
    sres@tfDoNDCOverlay       = True             ; do not transform
    sres@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
    sres@cnLevels             = 0.05             ; set the contour levels
    sres@cnInfoLabelOn        = False

  ; plot = gsn_csm_contour_map(wks,rg,res)
    plot(i) = gsn_csm_contour_map_overlay(wks,rg,ss,res,sres)  ; create the overlay plot
    i = i + 1

  end do
; end do

;*****************************************************
; save output image
;******************************************************

  resP                     = True                ; modify the panel plot
  resP@gsnFrame            = False
; resP@gsnPanelDebug  = True
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.010               ; make labels smaller
  resP@lbLabelFontColor    = 1
; resP@gsnPanelLeft = 0.05

  gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot
  frame(wks)
  draw(wks)

;  maximize_output(wks,resP)

   print("saved "+outim+"."+formo)

   trimPNG(outim+"."+formo)

end
