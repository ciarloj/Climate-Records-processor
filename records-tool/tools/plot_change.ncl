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
; dn = "t"
; v = "pr"
; tdim  = "1d"      ; type of dimensions for lat/lon = "1d" or "2d"

  dn_str = str_split(dn,"-")
  outim = idir+"/change_"+v+"_"+dn+"_"+tpo+"_"+tpn
  formo = "png"
  wks  = gsn_open_wks (formo,outim)             ; send graphics to PNG file

  f = addfile(fnam, "r")
  pv = f->$v$(0,:,:)

  if ( dn_str(1).eq."MERRA" .or. dn_str(1).eq."JRA" ) then
    n!1 = "latitude"
    n!2 = "longitude"
    p!1 = "latitude"
    p!2 = "longitude"
  end if
  if ( tdim.eq."1d" .and. dn_str(1).eq."ERA5" ) then
    n = n(:,::-1,:)
    p = p(:,::-1,:)
  end if
  if ( tdim.eq."2d" ) then
    if ( dn_str(1).eq."REGCM" ) then
      ilat = "lat"
      ilon = "lon"
    end if
    if ( dn_str(1).eq."REMO" ) then
      ilat = "rlat"
      ilon = "rlon"
    end if
    xlat = f->$ilat$
    xlon = f->$ilon$
    dims = dimsizes(xlat)
    nlat = dims(1)
    nlon = dims(0)
  end if

 ;***********************
 ; plot
 ;***********************

  res  = True
  res@gsnDraw             = True              ; don't draw yet
  res@gsnFrame            = True              ; don't advance frame yet

  res@mpLimitMode       = "Corners"            ; choose range of map
  if ( tdim.eq."2d" ) then
    res@mpLeftCornerLatF  = xlat(0,0)
    res@mpLeftCornerLonF  = xlon(0,0)
    res@mpRightCornerLatF = xlat(nlon-1,nlat-1)
    res@mpRightCornerLonF = xlon(nlon-1,nlat-1)
    if ( dn_str(1) .eq. "REMO" ) then
      res@mpProjection        = "CylindricalEquidistant"
      rll = f->rotated_latitude_longitude
      plat = rll@grid_north_pole_latitude
      plon = rll@grid_north_pole_longitude
      res@mpCenterLonF = 180.0+plon
      res@mpCenterLatF = 90.0-plat
    else
      if ( dn_str(0) .eq. "NAM" ) then
        rm = f->rotated_mercator
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
    res@mpLeftCornerLatF  = min(pv&latitude)
    res@mpLeftCornerLonF  = min(pv&longitude)
    res@mpRightCornerLatF = max(pv&latitude)
    res@mpRightCornerLonF = max(pv&longitude)
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

; res@gsnAddCyclic           = False     ; regional data don't add
; res@pmTickMarkDisplayMode  = "Always"  ;
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
  res@gsnLeftString          = ""
  res@gsnRightString         = ""
  res@gsnCenterString        = dnttl+" ~F33~D~F21~ ("+tpn+")-("+tpo+")"  

  res@cnLevelSelectionMode   = "ExplicitLevels"
  res@cnConstFLabelFormat    = "0f1"
  if ( v .eq. "pr" ) then
    res@cnLevels = (/-2,-1,-.5,-.4,-.3,-.2,-.1,.1,.2,.3,.4,.5,1,2/) 
;;  res@lbLabelStrings         = sprintf("%4.3f",res@cnLevels)   ; Format the labels
    cmap = read_colormap_file("cmocean_curl")
    cmap = cmap(::-1,:) ; reverse the color map
    res@cnFillPalette = cmap
  end if
  if ( v .eq. "tas" ) then
    res@cnLevels = (/-3,-2,-1.6,-1.2,-.8,-.4,-.2,.2,.4,.8,1.2,1.6,2,3/)
    cmap = read_colormap_file("cmp_b2r")
    res@cnFillPalette = cmap
  end if

  sres = True
  sres@cnLineLabelsOn       = False
  sres@cnLineThicknessF     = 2.0
  sres@tfDoNDCOverlay       = True             ; do not transform
  sres@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  sres@cnLevels             = 0.05             ; set the contour levels
  sres@cnInfoLabelOn        = False

  plot = gsn_csm_contour_map(wks,pv,res)

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
