;*************************************************************************************************
; Adapted from polyg4.ncl - see https://www.ncl.ucar.edu/Applications/Scripts/polyg_4.ncl
;************************************************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;************************************************
begin
;************************************************

; Plot outputs
plotname="map_domains" ; name of output plot
plotout="png" ; format of output plot
;plotout="pdf"

; Domain for the map - global by default
latmax_map= 90.
latmin_map=-90.
lonmin_map=-180
lonmax_map=180

; Domain and string attached to each box domain

ypts = (/ 5.0,  5.0,  31.0,   31.0, 5.0/) ; all lat segments
xpts = (/-120.0, -40.0,-40.0, -120.0, -120.0/) ; all lon segments
npts=dimsizes(xpts)
label_loc=(/-106., 13./) ; where the text label is lon/lat
label_name="CAM"

ypts2 = (/ -51.0,  -51.0,  -8.0,  -8.0,  -51.0/)
xpts2 = (/109.0,  179.0,  179.0, 109.0, 109.0/)
label_loc2=(/ 122., -43./) ; where the text label is lon/lat
label_name2="AUS"

ypts3 = (/ 30.0,  30.0,  71.0,  71.0,  30.0/)
xpts3 = (/-12.0,  38.0,  38.0, -12.0, -12.0/)
label_loc3=(/ 1., 63./) ; where the text label is lon/lat
label_name3="EUR"

ypts4 = (/ -37.6,  -37.6,  42.0,  42.0,  -37.6/)
xpts4 = (/-26.7,  60.8,  60.8, -26.7, -26.7/)
label_loc4=(/ -14.0, -30.0/) ; where the text label is lon/lat
label_name4="AFR"

ypts5 = (/ 25.0,  25.0, 75.0, 75.0,  25.0/)
xpts5 = (/-169.0,  -47.0,  -47.0, -169.0, -169.0/)
label_loc5=(/ -155., 32./) ; where the text label is lon/lat
label_name5="NAM"

ypts6 = (/ -58.0,  -58.0, 14.0, 14.0,  -58.0/)
xpts6 = (/-89.0,  -30.0,  -30.0, -89.0, -89.0/)
label_loc6=(/ -76., -50./) ; where the text label is lon/lat
label_name6="SAM"

ypts7 = (/ 5.0,  5.0, 54.0, 54.0,  5.0/)
xpts7 = (/87.0,  166.0,  166.0, 87.0, 87.0/)
label_loc7=(/ 153., 47./) ; where the text label is lon/lat
label_name7="EAS"

ypts8 = (/ -12.0,  -12.0, 22.0, 22.0,  -12.0/)
xpts8 = (/88.0,  157.0,  157.0, 88.0, 88.0/)
label_loc8=(/ 144., 15./) ; where the text label is lon/lat
label_name8="SEA"

ypts9 = (/ 2.0,  2.0, 44.0, 44.0,  2.0/)
xpts9 = (/58.0,  95.0,  95.0, 58.0, 58.0/)
label_loc9=(/ 71., 37./) ; where the text label is lon/lat
label_name9="SAS"





;************************************************
; Create plot
;************************************************
  wks = gsn_open_wks(plotout,"map_domains")                 ; send graphics to PNG file

  res           = True                              ; plot mods desired
  res@gsnDraw   = False                             ; don't draw yet
  res@gsnFrame  = False                             ; don't advance yet

  res@mpMinLatF = latmin_map                               ; zoom in on a subregion
  res@mpMaxLatF = latmax_map
  res@mpMinLonF = lonmin_map
  res@mpMaxLonF = lonmax_map
  res@mpGridAndLimbOn        = False ; set to False to remove grid

;  res@tiMainString = "Title"
;  res@mpOutlineBoundarySets = "National"
  plot = gsn_csm_map(wks,res)

  res@mpOceanFillColor       = "steelblue"            ; array index in color map
  res@mpLandFillColor        = "seashell2"          ; for land, ocean, and inland h20
  res@mpInlandWaterFillColor = "steelblue"

  plot = gsn_csm_map(wks,res)          ; create the base map plot

;************************************************
; add the boxes
;************************************************
  resp                  = True                      ; polyline mods desired
  resp@gsLineColor      = "black"                     ; color of lines
  resp@gsLineThicknessF = 4.0                       ; thickness of lines
;  resp@gsLineLabelString= "BOX"

; create array of dummy graphic variables. This is required, b/c each line
; must be associated with a unique dummy variable.

  dum  = new(4,graphic) ; first box
  dum2 = new(4,graphic) ; second box
  dum3 = new(4,graphic) ; third box
  dum4 = new(4,graphic) ; fourth box
  dum5 = new(5,graphic) ; fifth box
  dum6 = new(6,graphic) ; sixth box
  dum7 = new(7,graphic) ; 
  dum8 = new(8,graphic) ; 
  dum9 = new(9,graphic) ; 



; draw each line separately. Each line must contain two points.
  do i = 0 , npts-2
    dum(i)=gsn_add_polyline(wks,plot,xpts(i:i+1),ypts(i:i+1),resp)     
    dum2(i)=gsn_add_polyline(wks,plot,xpts2(i:i+1),ypts2(i:i+1),resp)     
    dum3(i)=gsn_add_polyline(wks,plot,xpts3(i:i+1),ypts3(i:i+1),resp)     
    dum4(i)=gsn_add_polyline(wks,plot,xpts4(i:i+1),ypts4(i:i+1),resp)
    dum5(i)=gsn_add_polyline(wks,plot,xpts5(i:i+1),ypts5(i:i+1),resp)  
    dum6(i)=gsn_add_polyline(wks,plot,xpts6(i:i+1),ypts6(i:i+1),resp)
    dum7(i)=gsn_add_polyline(wks,plot,xpts7(i:i+1),ypts7(i:i+1),resp)
    dum8(i)=gsn_add_polyline(wks,plot,xpts8(i:i+1),ypts8(i:i+1),resp)
    dum9(i)=gsn_add_polyline(wks,plot,xpts9(i:i+1),ypts9(i:i+1),resp)
end do 


; Add text labels
  tres       =  True
  tres@txFontHeightF = 0.015
  tres@txFontColor = "black"
  tres@txPerimOn = True
  tres@txBackgroundFillColor = "white" 
  
  draw(plot)

; Add text labels - add 3 etc for more boxes 
  gsn_text(wks, plot, label_name,  label_loc(0),  label_loc(1), tres)
  gsn_text(wks, plot, label_name2, label_loc2(0), label_loc2(1), tres)
  gsn_text(wks, plot, label_name3, label_loc3(0), label_loc3(1), tres)
  gsn_text(wks, plot, label_name4, label_loc4(0), label_loc4(1), tres)
  gsn_text(wks, plot, label_name5, label_loc5(0), label_loc5(1), tres)
  gsn_text(wks, plot, label_name6, label_loc6(0), label_loc6(1), tres)
  gsn_text(wks, plot, label_name7, label_loc7(0), label_loc7(1), tres) 
  gsn_text(wks, plot, label_name8, label_loc8(0), label_loc8(1), tres)
  gsn_text(wks, plot, label_name9, label_loc9(0), label_loc9(1), tres)
  frame(wks)



end
