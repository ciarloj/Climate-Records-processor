;----------------------------------------------------------------------
;  maponly_2.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Turning on map country boundaries
;   - Changing the color of map outlines
;   - Changing the thickness of map outlines
;   - Zooming in on a particular area on the map
;   - Turning off map fill
;   - Enabling the most up-to-date country boundaries
;----------------------------------------------------------------------
;
; Note: in NCL V6.4.0, mpDataBaseVersion will default to "MediumRes" 
; if mpOutlineBoundarySets and/or mpFillBoundarySets is set to 
; something other than "Geophyiscal".
;
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;----------------------------------------------------------------------
load "tools/trimPNG.ncl"

begin
  formo = "png"
  focus = "eobs" ; "eobs" or "italy"
  outim = "maponly_"+focus
  wks   = gsn_open_wks(formo,outim)           ; send graphics to PNG file

  res                             = True
  res@gsnMaximize = True
  res@gsnDraw     = False
  res@gsnFrame    = False
; res@mpFillOn                    = False        ; turn off gray fill
; res@mpOutlineBoundarySets       = "National"   ; turn on country boundaries
; res@mpGeophysicalLineColor      = "Navy"       ; color of cont. outlines
; res@mpGeophysicalLineThicknessF = 1.5          ; thickness of outlines

  if ( focus .eq. "italy" ) then
    nstns = 3180
    res@mpMaxLatF              = 50           ; choose a different subregion
    res@mpMinLatF              = 35 
    res@mpMaxLonF              = 20
    res@mpMinLonF              =  6 
  end if
  if ( focus .eq. "eobs" ) then
    nstns = 14458 ;14479
    res@mpMaxLatF              = 75           ; choose a different subregion
    res@mpMinLatF              = 30
    res@mpMaxLonF              = 50
    res@mpMinLonF              = -12
  end if
 
  res@mpDataBaseVersion = "MediumRes"           ; choose higher resolution

  plot = gsn_csm_map(wks,res)                   ; draw map

  stnf = "tools/eobs-stations.txt"
  mkres = True
  mkres@gsMarkerIndex = 16 ; filled circle
  mkres@gsMarkerSizeF = 3.0
  mkres@gsMarkerColor = "black"

  tn = 20
  lons = new((/nstns/),float)
  lats = new((/nstns/),float)

  do n=0 , nstns-1
    print(n+"/"+nstns)
    nline = tn+n
    tline = nline+1
    delete(nline)
    system("sed -n "+tline+"p "+stnf+" > line.txt")
    delete(tline)
    mline := asciiread("line.txt", (/1/), "string")
    system("rm line.txt")
    dline = str_split(mline,",")
    delete(mline)
    tlat = dline(3)
    tlon = dline(4)
    delete(dline)
    dlat = stringtofloat(str_split(tlat,":"))
    dlon = stringtofloat(str_split(tlon,":"))
    delete(tlat)
    delete(tlon)
    lat = decimalPlaces(dlat(0)+((dlat(1)+(dlat(2)/60))/60),4,False)
    if ( lat.gt.res@mpMaxLatF .or. lat.lt.res@mpMinLatF ) then
      continue
    end if
    lon = decimalPlaces(dlon(0)+((dlon(1)+(dlon(2)/60))/60),4,False)
    if ( lon.gt.res@mpMaxLonF .or. lon.lt.res@mpMinLonF ) then
      continue
    end if
    delete(dlat)
    delete(dlon)
    lats(n) = lat
    lons(n) = lon
    delete(lat)
    delete(lon)
  end do

  marks  = gsn_add_polymarker(wks,plot,lons,lats,mkres)
  delete(lats)
  delete(lons)

  resP = True
  maximize_output(wks,resP)
 
  print("saved")
  trimPNG(outim+"."+formo)


  end
