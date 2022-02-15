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
  sdir = "/home/netapp-clima-scratch/jciarlo/tas-rec/"
  stat = "runmax-30"
  tpo = "1970-2000"
  tpn = "2070-2100"
  v = "tas"
  tdim  = "1d"      ; type of dimensions for lat/lon = "1d" or "2d"
  outim = idir+"/figS3_change_rcms_tas"
  formo = "png"
  wks  = gsn_open_wks (formo,outim)             ; send graphics to PNG file

  dns = (/"REGCM-MPI-85","REMO-MPI-85","REGCM-MPI-26","REMO-MPI-26"/)
  plot = new((/4/),graphic)

  i = 0
  do m=0, 3
    dn = dns(m)

    fnam = sdir+dn+"/means/change/"+tpo+"_"+tpn+".nc"
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
    res@mpFillOn               = True 

    res@mpGeophysicalLineColor = "black"     ; color of continental outlines
    res@mpPerimOn              = True      ; draw box around map
    res@mpGridLineDashPattern  = 5         ; lat/lon lines as dashed

;   res@gsnAddCyclic           = False     ; regional data don't add
;   res@pmTickMarkDisplayMode  = "Always"  ;
    res@mpGridAndLimbOn        = False               ; turn on grid lines
    res@lbLabelBarOn           = False
   ;res@lbOrientation          =   "vertical"
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
    res@gsnCenterString        = dnttl  ;+" ~F33~D~F21~ ("+tpn+")-("+tpo+")"  

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
      res@cnLevels = (/0,.3,.6,.9,1.2,1.5,1.8,2,2.5,3,3.5,4,4.5,5,5.5,6/)
      cmap = read_colormap_file("WhiteYellowOrangeRed")
      res@cnFillPalette = cmap
    end if
    res@cnLineLabelsOn = False

    sres = True
    sres@cnLineLabelsOn       = False
    sres@cnLineThicknessF     = 2.0
    sres@tfDoNDCOverlay       = True             ; do not transform
    sres@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
    sres@cnLevels             = 0.05             ; set the contour levels
    sres@cnInfoLabelOn        = False

    plot(i) = gsn_csm_contour_map(wks,pv,res)
    i = i + 1

  end do

;*****************************************************
; save output image
;******************************************************

  resP                     = True                ; modify the panel plot
  resP@gsnFrame            = False
; resP@gsnPanelDebug  = True
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelStrings      = sprintf("%4.1f",res@cnLevels)   ; Format the labels
  resP@lbLabelFontHeightF  = 0.010               ; make labels smaller
  resP@lbLabelFontColor    = 1
; resP@gsnPanelLeft = 0.05
  resP@gsnPanelMainString = "~F33~D~F21~ temperature (~F34~0~F~C) "+tpo+" to "+tpn

  gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot
  frame(wks)
  draw(wks)

  print("saved "+outim+"."+formo)
  trimPNG(outim+"."+formo)

end
