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
;stat = "day"
;fnam = "dir/index_fld_norm.nc"
; yr1 = "1950"
; yr2 = "2100"
; dn = "t"
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
 
  f = addfile(fnam, "r")
  n = f->n(:,:,:)
  p = f->p(:,:,:)
  rg = f->n(0,:,:)
  rg = rg-rg

  xlat = f->lat
  xlon = f->lon
  dims = dimsizes(xlat)
  nlat = dims(1)
  nlon = dims(0)

  pdim = dimsizes(n)
  nbins = pdim(0)
  y1 = stringtointeger(yr1)
  y2 = stringtointeger(yr2)
  bins := tofloat(ispan(y1,y1-1+nbins,1))

  ny = pdim(1)
  nx = pdim(2)

  est = new ((/nbins/), "float")
  do k =1, nbins
    est(k-1) = 1.0/k
  end do

  do iy=0, ny-1
    do jx=0, nx-1
      i_n = n(:,iy,jx)
      if ( ismissing(i_n(0)) ) then
        continue
      end if
      i_p = p(:,iy,jx)
      fq = i_n/i_p
      rt = fq/est

      rcl = regline(bins,rt)
      delete_VarAtts(rcl,(/"yintercept","yave","xave","nptxy","rstd","tval"/))
     ;print (rcl)

      rg(iy,jx) = rcl
    end do
  end do

 ;***********************
 ; plot
 ;***********************

  res  = True
  res@gsnDraw             = True              ; don't draw yet
  res@gsnFrame            = True              ; don't advance frame yet

  res@mpLimitMode       = "Corners"            ; choose range of map
  res@mpLeftCornerLatF  = xlat(0,0)
  res@mpLeftCornerLonF  = xlon(0,0)
  res@mpRightCornerLatF = xlat(nlon-1,nlat-1)
  res@mpRightCornerLonF = xlon(nlon-1,nlat-1)

  prj = "LAMCON" ; f@projection
  clon = 9.75 ; f@longitude_of_projection_origin
  if (prj .eq. "LAMCON") then
   ;trlats = f@standard_parallel
    res@mpProjection        = "LambertConformal"
    res@mpLambertParallel1F = 30. ;trlats(0)
    res@mpLambertParallel2F = 65. ;trlats(1)
    res@mpLambertMeridianF  = clon
  end if

  ; usually, when data is placed onto a map, it is TRANSFORMED to the specified
  ; projection. Since this model is already on a native lambert conformal grid,
  ; we want to turn OFF the tranformation.

  res@tfDoNDCOverlay         = True      ; do not transform
  res@cnFillOn               = True      ; color plot desired
  res@cnLinesOn              = False       ; no contour lines
  res@mpFillOn               = False

  res@mpGeophysicalLineColor = "black"     ; color of continental outlines
  res@mpPerimOn              = True      ; draw box around map
  res@mpGridLineDashPattern  = 5         ; lat/lon lines as dashed

  res@gsnAddCyclic           = False     ; regional data don't add
  res@pmTickMarkDisplayMode  = "Always"  ;
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
  res@gsnCenterString        = dn+"("+yr1+"-"+yr2+")"  ;+" "+snam

  res@cnLevelSelectionMode   = "ExplicitLevels"
  res@cnLevels = (/-.035,-.03,-.025,-.02,-.015,-.01,-.005,.005,.01,.015,.02,.025,.03,.035/) ; "mm/day"
  cmap = read_colormap_file("hotcold_18lev")
  res@cnFillPalette = cmap


  plot = gsn_csm_contour_map(wks,rg,res)

;*****************************************************
; save output image
;******************************************************
 
;  resP                     = True
;
;  maximize_output(wks,resP)
;
   print("saved "+outim+"."+formo)


end