;----------------------------------------------------------------------
; Procedure to attach a horizontal labelbar to the bottom of plot.
;----------------------------------------------------------------------
load "tools/trimPNG.ncl"

undef("add_labelbar")
procedure add_labelbar(wks,plot,colors,labels)
local vph, vpw, nboxes, lbres, lbid, amres, annoid
begin
  getvalues plot                      ; Get plot size for use in
    "vpHeightF" : vph                 ; creating labelbar.
    "vpWidthF"  : vpw
  end getvalues

  nboxes = dimsizes(colors)

  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = True          ; Necessary to control sizes
  lbres@vpWidthF           = 0.15 * vpw    ; labelbar width
  lbres@vpHeightF          = 0.95 * vph    ; labelbar height
  lbres@lbFillColors       = colors        ; labelbar colors
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.05          ; font height. default is small
  lbres@lbLabelAlignment   = "BoxCenters"  ; center of box
  lbres@lbOrientation      = "Vertical"
  lbres@lbPerimOn          = False

  lbres@lbLabelAlignment   = "InteriorEdges"
  lbres@lbBoxEndCapStyle   = "TriangleBothEnds"

  lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)
   
;
; Now, create some annotation resources indicating how we want to
; attach the labelbar to the plot. Here, we are using the top right
; corner of the labelbar as the point which we are going to position
; it, and then we use amParallelPosF and amOrthogonalPosF to indicate
; where we want to place it.
;
; amParallelPosF/amOrthogonalPosF                                       ;
;    0.0/ 0.0  -  annotation in dead center of plot
;    0.5/ 0.5  -  annotation at bottom right of plot
;    0.5/-0.5  -  annotation at top right of plot
;   -0.5/-0.5  -  annotation at top left of plot
;   -0.5/ 0.5  -  annotation at bottom left of plot
;                                                                 
  amres                  = True
  amres@amJust           = "CenterLeft"
  amres@amParallelPosF   =  0.52
  amres@amOrthogonalPosF =  0.0
  plot@annoid = gsn_add_annotation(plot,lbid,amres)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;;yr="2000"

; idir = "images"
; stat = "day"
; fnam = "dir/index_fld_norm.nc"
  yr1 = "2005"
  yr2 = "2099"
; dn = "t"
  nry = 10 ; number of years of running mean

  stat = "runmax-30"
  rcp  = "85"
  hdir = "/home/netapp-clima-scratch/lbelleri/records/"
  idir = "trim/"+stat+"/records/sum/"
  frm = "png"
  img = hdir+"../../jciarlo/records/"+"table-rcp"+rcp

  rcms=(/"R1","R2"/)
  gcms=(/"GH","GM","GL"/)
  mr_sz = dimsizes(rcms)
  mg_sz = dimsizes(gcms)
  c_sz = mr_sz*mg_sz
  clabs = new((/c_sz/),"string")
  r = 0
  g = 0
  do ii=0, c_sz-1
    rcm = rcms(r)
    gcm = gcms(g)
    clabs(ii) = rcm+"-"+gcm
    if ( g.lt.2 ) then
      g = g + 1
    else
      g = 0
      r = r + 1
    end if
  end do

  doms = (/"NAM","CAM","SAM","EUR","AFR","CAS","WAS","EAS","SEA","AUS"/)
  rlabs = doms
  r_sz = dimsizes(doms)

  vals_flt = new((/r_sz,c_sz/),"float")
  vals_txt = new((/r_sz,c_sz/),"string")

  do i=0, r_sz-1
    nr = doms(i)
    do mi=0, c_sz-1
      m = clabs(mi)
      ms = str_split(m,"-")
      rlab = ms(0)
      if ( rlab.eq."R1" ) then
        rnam = "REGCM"
      end if
      if ( rlab.eq."R2" ) then
        rnam = "REMO"
      end if
      glab = ms(1)
      if ( glab.eq."GH" ) then
        gnam = "HADGEM"
        if ( rnam.eq."REGCM" .and. nr.eq."WAS" ) then
          gnam = "MIROC"
        end if
      end if
      if ( glab.eq."GM" ) then
        gnam = "MPI"
      end if
      if ( glab.eq."GL" ) then
        gnam = "NORESM"
        if ( nr.eq."NAM" .or. nr.eq."CAM" ) then
          if ( rnam.eq."REGCM" ) then
            gnam = "GFDL"
          end if
        end if
      end if
      ddir = hdir+nr+"-"+rnam+"-"+gnam+"-"+rcp+"/"+idir
      fnam = ddir+"index_fld_norm.nc"

      misdat = "N"
      if ( rcp.eq."26" .and. nr.eq."NAM" .and. rnam.eq."REGCM" ) then
        misdat = "Y"
      end if
      if ( nr.eq."CAS" .and. rnam.eq."REGCM" ) then
        misdat = "Y"
      end if

      if ( misdat.eq."N" ) then
        f = addfile(fnam,"r")
        v = f->n(:,0,0)

        pdim = dimsizes(v)
        nbins = pdim(0)
        y1 = stringtointeger(yr1)
        y2 = stringtointeger(yr2)
        bins := ispan(y1,y1-1+nbins,1)

        recs := new ((/3,nbins/), "float")
        recs(1,:) = v(:)
        do k =1, nbins
          recs(0,k-1) = 1.0/k
        end do

        rat = recs(1,:)/recs(0,:)
        run = runave_n(rat,nry,0,0)

        rcl = regline_stats(bins,run)
        mval = rcl
       ;cval = rcl@yintercept
       ;rval = rcl@r2
       ;df   = rcl@N-2 ;rcl@nptxy-2
       ;ssig = betainc(df/(df+mval^2), df/2.0, 0.5)

       ;ratv = bins ;ispan(1,nbins,1)
       ;ratv := (ratv*mval)+cval

        mv_mul = mval*1000000
        mv_rnd = round(mv_mul,1)
        mval = mv_rnd/1000 ; value is at x10^-3

        vals_flt(i,mi) = mval
        vals_txt(i,mi) = ""+mval ;decimalPlaces(v,3,True)

        delete(v)
        delete(rat)
        delete(run)
      end if
    end do

  end do

  ncr    = dimsizes(vals_flt)
  ; Count rows and columns of actual data.
  ncols = ncr(1)
  nrows = ncr(0) 

  col_width  = 1./ncols
  row_width  = 1./nrows
  col_width2 = col_width/2.
  row_width2 = row_width/2.

  ncol_labels = clabs
  nrow_labels = rlabs

;
; Define colors to use for the table. Be sure to include white and black for background
; and foreground.
;
  colors = (/"White","Black","blue4","blue3","blue1","dodgerblue",\
             "MediumTurquoise","paleturquoise2","aliceblue","rosybrown1",\
             "indianred1","orangered","orangered3","Brown","saddlebrown"/)
  col_sz = dimsizes(colors)
  crange = (/-5.,-2.5,-2,-1.5,-1,-.1,.1,1,1.5,2,2.5,5/)
  labels = new(dimsizes(colors)-1,"string")    ; for labelbar

; Assign a color to a particular range of data.
  cols_for_vals = new(ncr,"string")
  cols_for_txt = new(ncr,"string")
  do i=2,col_sz-1
    if ( i.eq.2 ) then
      rng_beg = -100.
      rng_end = crange(i-2)
    end if
    if ( i.gt.2 .and. i.lt.(col_sz-1) ) then
      rng_beg = crange(i-3)
      rng_end = crange(i-2)
    end if
    if ( i.eq.(col_sz-1) ) then
      rng_beg = crange(i-3)
      rng_end = 100.
    end if

    cols_for_vals = where(rng_beg.le.vals_flt .and. vals_flt.lt.rng_end,\
                          colors(i),cols_for_vals)
    ;print(i+": "+rng_beg+" "+rng_end+": "+colors(i))
;---Create formatted labels for the labelbar
    labels(i-2) = sprintf("%3.1f",rng_end) 
                  ;sprintf("%3.1f", rng_beg) + " - " + \
                  ;sprintf("%3.1f",rng_end)
  end do

  cols_for_txt = where(cols_for_vals.eq."Navy" .or. \
                      cols_for_vals.eq."MediumBlue" .or. \
                      cols_for_vals.eq."blue4".or. \
                      cols_for_vals.eq."blue3" .or. \
                      cols_for_vals.eq."blue1" .or. \
                      cols_for_vals.eq."Brown" .or. \
                      cols_for_vals.eq."saddlebrown", "white","black")
  cols_for_vals = where(ismissing(cols_for_vals),"grey",cols_for_vals)
  cols_for_txt = where(ismissing(cols_for_txt),"white",cols_for_txt) 

; Start the graphics.
  wks = gsn_open_wks(frm,img)
  gsn_define_colormap(wks,colors) ;"BlueDarkRed18")

; Create a blank plot so we can get some tickmarks.
;
; Do the blank plot before the table, so we can maximize
; the blank plot. Later we'll make sure the table goes
; in the same location as the blank plot.
;
  resb                         = True
  resb@gsnDraw                 = False
  resb@gsnFrame                = False

  resb@vpYF                    = 0.92
  resb@vpXF                    = 0.20 ;0.10
  resb@vpHeightF               = 0.85
  resb@vpWidthF                = 0.60 ;0.75

; Explicitly label X axis. The blank plot goes from 0 to 1, by default.
  resb@tmXBMode                = "Explicit"
  resb@tmXBValues              = fspan(col_width2,1.-col_width2,ncols)
  resb@tmXBLabels              = ncol_labels
  resb@tmXBLabelFontHeightF    = 0.015            ; Make font a little smaller

; Explicitly label Y axis.
  resb@tmYLMode                = "Explicit"
  resb@tmYLValues              = fspan(row_width2,1.-row_width2,nrows)
;
; The Y labels need to be reversed, because the label in the first
; row in the ASCII file is associated with the top of the plot.
;
  resb@tmYLLabels              = nrow_labels(::-1)
  resb@tmYLLabelFontHeightF    = 0.015            ; Make font a little smaller

; Rotate the X axis labels 90 degrees.
;  resb@tmXBLabelAngleF         = 90.
;  resb@tmXBLabelJust           = "CenterRight"

; Turn off right and top tickmarks
  resb@tmYROn                  = False
  resb@tmXTOn                  = False

  blank = gsn_csm_blank_plot(wks,resb)
  add_labelbar(wks,blank,colors(2:),labels)   ; Attach labelbar

;
; Get position and size of the blank plot so we can
; be sure to draw the table in same location.
;
  getvalues blank
    "vpXF"      : vpx
    "vpYF"      : vpy
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues

; Start and end coordinates for table.
  x = (/vpx,vpx+vpw/)
  y = (/vpy-vph,vpy/)

; Set up resources for table
  rest               = True
  rest@gsLineColor   = -1               ; No border lines
  rest@gsLineThicknessF = 0.001
  rest@gsFillColor   = cols_for_vals     ; Each cell of table
  rest@txFontColor   = cols_for_txt
  rest@txFontHeightF = 0.015             ; Size of centered text

  gsn_table(wks,ncr,x,y,vals_txt,rest)    ; Draw table

  res_text                   = True              ; text mods desired
  res_text@txFontHeightF     = 0.020             ; change text size
  res_text@txJust            = "CenterLeft"      ; text justification
  dum = gsn_add_text(wks,blank,"(x10~S~-3~N~)",1.0,0.0,res_text)  ; add text
  
  draw(blank)

; Advance the frame.
  frame(wks)

  print("saved")
  trimPNG(img+"."+frm)

end

