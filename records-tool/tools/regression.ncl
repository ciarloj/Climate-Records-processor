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
;idir = "images"
;stat = "day"
;fnam = "dir/index_fld_norm.nc"
; yr1 = "1950"
; yr2 = "2100"
; dn = "t"
; tdim  = "2d"      ; type of dimensions for lat/lon = "1d" or "2d"

  dn_str = str_split(dn,"-")
  nd_str = dimsizes(dn_str) ; number of delimiter entries in name
  outim = idir+"/regr_"+dn+"_"+stat
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

  n1 := stringtointeger(n1)
  n2 := stringtointeger(n2)
 
  f = addfile(fnam, "r")
  n = f->n(n1:n2,:,:)
  p = f->p(n1:n2,:,:)

  ilat = dim1
  ilon = dim2
  if ( nd_str .gt. 1 ) then
    if ( tdim.eq."1d" .and. dn_str(1).eq."ERA5" ) then
      n = n(:,::-1,:)
      p = p(:,::-1,:)
    end if  
    if ( tdim.eq."1d" .and. dn_str(1).eq."JRA" ) then
      n = n(:,::-1,:)
      p = p(:,::-1,:)
    end if
  end if
  if ( tdim.eq."2d" ) then
    if ( dn_str(1).eq."REMO" ) then
      xlat = f->$ilat$
      xlon = f->$ilon$
      rpol = f->rotated_latitude_longitude
      plat = rpol@grid_north_pole_latitude
      plon = rpol@grid_north_pole_longitude
      n@lat2d = xlat
      n@lon2d = xlon
      p@lat2d = xlat
      p@lon2d = xlon
    else 
      xlat = f->$ilat$
      xlon = f->$ilon$
    end if
    dims = dimsizes(xlat)
    if ( dn_str(1).eq."REMO" ) then
      nlat = dims(0)
      nlon = dims(1)
    else
      nlat = dims(1)
      nlon = dims(0)
    end if
  end if
  rg = n(0,:,:)
  rg = rg-rg                   ; empty field for regression gradients
  ss = rg                      ; empty field for statistical significance

  pdim = dimsizes(n)
  nbins = pdim(0)
  y1 = stringtointeger(yr1)
  y2 = stringtointeger(yr2)
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

; rsmth = smth9_Wrap(rg,0.50,-0.25,False) ; light local smoothing
  rsmth = smth9_Wrap(rg,0.50,0.25,False) ; heavy local smoothing
  rg := rsmth

 ;***********************
 ; plot
 ;***********************

  res  = True
  sres = True
  res@gsnDraw             = True              ; don't draw yet
  res@gsnFrame            = True              ; don't advance frame yet

  res@mpLimitMode       = "Corners"            ; choose range of map
  res@tfDoNDCOverlay         = True      ; do not transform
  sres@tfDoNDCOverlay        = True
  if ( tdim.eq."2d" ) then
    if ( dn_str(1) .eq. "REMO" ) then
      res@tfDoNDCOverlay        = False      ; do not transform
      sres@tfDoNDCOverlay       = False
     ;res@mpProjection        = "CylindricalEquidistant"
      if ( dn_str(0).ne."AUS" .and.  dn_str(0).ne."EAS" ) then
        xlon = where(xlon.gt.180,xlon-360,xlon)
      end if
      res@mpLeftCornerLatF  = xlat(0,0)  
      res@mpLeftCornerLonF  = xlon(0,0) 
      res@mpRightCornerLatF = xlat(nlat-1,nlon-1)  
      res@mpRightCornerLonF = xlon(nlat-1,nlon-1) 
     ;llon = res@mpLeftCornerLonF
     ;rlon = res@mpRightCornerLonF
     ;tlat = res@mpRightCornerLatF
     ;blat = res@mpRightCornerLatF
      res@mpCenterLonF = xlon(nlat/2,nlon/2) ; llon + ((rlon - llon)/2)
      res@mpCenterLatF = xlat(nlat/2,nlon/2) ;tlat - ((tlat - blat)/2)
     ;print(llon+" "+rlon)
     ;print(blat+" "+tlat)
    else
      res@mpLeftCornerLatF  = xlat(0,0)
      res@mpLeftCornerLonF  = xlon(0,0)
      res@mpRightCornerLatF = xlat(nlon-1,nlat-1)
      res@mpRightCornerLonF = xlon(nlon-1,nlat-1)
      if ( dn_str(0) .eq. "NAM" ) then
        if ( dn.eq."NAM-REGCM-MPI-85" ) then
          rv="oblique_mercator"
        else
          rv="rotated_mercator" 
        end if
        rm = f->$rv$
        prj = "ROTMER"
        clon = rm@longitude_of_projection_origin
        ff = rm
      else
        prj = f@projection
        clon = f@longitude_of_projection_origin
        ff = f
      end if
      if (prj .eq. "LAMCON") then
        trlats = f@standard_parallel
        res@mpProjection        = "LambertConformal"
        res@mpLambertParallel1F = trlats(0)
        res@mpLambertParallel2F = trlats(1)
        res@mpLambertMeridianF  = clon
      end if
      if (prj .eq. "NORMER") then
        res@mpProjection        = "Mercator"
      end if
      if (prj .eq. "POLSTR") then
        clat = f@latitude_of_projection_origin
        res@mpProjection        = "Stereographic"
        res@mpRelativeCenterLon = True
        res@mpCenterLonF = clon
        res@mpRelativeCenterLat = True
        res@mpCenterLatF = clat
      end if
      if (prj .eq. "ROTMER") then
        clat = ff@latitude_of_projection_origin
        res@mpProjection        = "Mercator"
        res@mpCenterLonF = clon
        res@mpCenterLatF = clat
      end if
    end if
  end if
  if ( tdim.eq."1d" ) then
    res@mpLeftCornerLatF  = min(rg&$ilat$)
    res@mpLeftCornerLonF  = min(rg&$ilon$)
    res@mpRightCornerLatF = max(rg&$ilat$)
    res@mpRightCornerLonF = max(rg&$ilon$)
  end if

  ; usually, when data is placed onto a map, it is TRANSFORMED to the specified
  ; projection. Since this model is already on a native lambert conformal grid,
  ; we want to turn OFF the tranformation.

  res@cnFillOn               = True      ; color plot desired
  res@cnFillMode             = "RasterFill"
  res@cnLinesOn              = False       ; no contour lines
  res@mpFillOn               = True 

  res@mpGeophysicalLineColor = "black"     ; color of continental outlines
  res@mpPerimOn              = True      ; draw box around map
  res@mpGridLineDashPattern  = 5         ; lat/lon lines as dashed

 ;res@gsnAddCyclic           = False     ; regional data don't add
 ;res@pmTickMarkDisplayMode  = "Always"  ;
  res@mpGridAndLimbOn        = False               ; turn on grid lines
  res@lbLabelBarOn           = True 
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

  sres@cnFillOn             = True
  sres@cnLineLabelsOn       = False
  sres@cnLineThicknessF     = 2.0
  sres@cnFillPatterns       = (/6,-1/)
  sres@cnMonoFillPattern    = False
  sres@cnMonoFillColor      = True
  sres@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  sres@cnLevels             = 0.05             ; set the contour levels
  sres@cnInfoLabelOn        = False

; plot = gsn_csm_contour_map(wks,rg,res)
  plot = gsn_csm_contour_map_overlay(wks,rg,ss,res,sres)  ; create the overlay plot

;*****************************************************
; save output image
;******************************************************
 
;  resP                     = True
;
;  maximize_output(wks,resP)
;
   print("saved "+outim+"."+formo)
   trimPNG(outim+"."+formo)

end
