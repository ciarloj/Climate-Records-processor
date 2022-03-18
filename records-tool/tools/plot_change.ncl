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

  ilat = dim1
  ilon = dim2
  if ( tdim.eq."2d" ) then
    if ( dn_str(1).eq."REMO" ) then
      xlat = f->$ilat$
      xlon = f->$ilon$
      rpol = f->rotated_latitude_longitude
      plat = rpol@grid_north_pole_latitude
      plon = rpol@grid_north_pole_longitude
      pv@lat2d = xlat
      pv@lon2d = xlon
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
      dllon = 0
      dllat = 0
      drlon = 0
      drlat = 0
      if ( dn_str(0).eq."WAS" ) then
        dllat = -6
        drlat =  1
        drlon =  9
      end if
      if ( dn_str(0).eq."SEA" ) then
        drlon =  5
        dllat = -2
      end if
      if ( dn_str(0).eq."EAS" ) then
        drlon =  2
        dllat = -2
      end if
      if ( dn_str(0).eq."EUR" ) then
        drlat = -3
        drlon =  8
        dllon = -2
      end if
      res@mpLeftCornerLatF  = xlat(0,0) + dllat
      res@mpLeftCornerLonF  = xlon(0,0) + dllon
      res@mpRightCornerLatF = xlat(nlat-1,nlon-1) + drlat
      res@mpRightCornerLonF = xlon(nlat-1,nlon-1) + drlon
      res@mpCenterLonF = xlon(nlat/2,nlon/2) 
      res@mpCenterLatF = xlat(nlat/2,nlon/2)
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
    res@mpLeftCornerLatF  = min(pv&$ilat$)
    res@mpLeftCornerLonF  = min(pv&$ilon$)
    res@mpRightCornerLatF = max(pv&$ilat$)
    res@mpRightCornerLonF = max(pv&$ilon$)
  end if

  ; usually, when data is placed onto a map, it is TRANSFORMED to the specified
  ; projection. Since this model is already on a native lambert conformal grid,
  ; we want to turn OFF the tranformation.

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

  sres@cnLineLabelsOn       = False
  sres@cnLineThicknessF     = 2.0
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
