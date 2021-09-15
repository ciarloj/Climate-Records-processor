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
;idir = "images"
; dn = "t"
; v = "pr"
  tdim  = "1d"      ; type of dimensions for lat/lon = "1d" or "2d"
  outim = idir+"/change_"+dn+"_"+tpo+"_"+tpn
  formo = "png"
  wks  = gsn_open_wks (formo,outim)             ; send graphics to PNG file

  f = addfile(fnam, "r")
  pv = f->$v$(0,:,:)

  if ( tdim.eq."2d" ) then
    xlat = f->lat
    xlon = f->lon
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
  res@gsnCenterString        = dnttl+" ~F33~D~F21~ ("+tpn+")-("+tpo+")"  

  res@cnLevelSelectionMode   = "ExplicitLevels"
  res@cnConstFLabelFormat    = "0f1"
  res@cnLevels = (/-2,-1.6,-1.2,-.8,-.4,-.1,.1,.4,.8,1.2,1.6,2/) 
;;  res@lbLabelStrings         = sprintf("%4.3f",res@cnLevels)   ; Format the labels
  cmap = read_colormap_file("cmocean_curl")
  res@cnFillPalette = cmap

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


end
