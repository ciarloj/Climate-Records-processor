;----------------------------------------------------------------------
; Procedure to attach a horizontal labelbar to the bottom of plot.
;----------------------------------------------------------------------
load "tools/trimPNG.ncl"
load "tools/add_labelbar.ncl"

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  nry = 10 ; number of years of running mean
  user = "lbelleri"
  user2 = "jciarlo"

  subj = "models"
  stat = "runmax-30"
  rcp  = "26"
  if ( subj.eq."models" .and. rcp.eq."85" ) then
    yr1 = "2005"
    yr2 = "2099"
  end if
  if ( subj.eq."models" .and. rcp.eq."26" ) then
    yr1 = "2005"
    yr2 = "2098"
  end if
  if ( subj.eq."reanalysis-3" ) then
    yr1 = "1980"
    yr2 = "2020"
  end if
  if ( subj.eq."reanalysis-2" ) then
    yr1 = "1950"
    yr2 = "2020"
  end if
  hdir = "/home/netapp-clima-scratch/"+user+"/records/"
  idir = "trim/"+stat+"/records/sum/"
  frm = "png"
  if ( subj.eq."models" ) then
    suffix = subj+"-rcp"+rcp+"-"+yr1+"-"+yr2
  else
    suffix = subj+"-"+yr1+"-"+yr2
  end if
  img = hdir+"../../"+user2+"/records/"+"table-"+suffix

  if ( subj.eq."models" ) then
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
  else
    if ( subj.eq."reanalysis-3" ) then
      clabs = (/"ERA5","MERRA","JRA"/)
    else 
      clabs = (/"ERA5","JRA"/)
    end if
    c_sz = dimsizes(clabs)
  end if

  doms = (/"NAM","CAM","SAM","EUR","AFR","CAS","WAS","EAS","SEA","AUS"/)
  rlabs = doms
  r_sz = dimsizes(doms)

  vals_flt = new((/r_sz,c_sz/),"float")
  vals_txt = new((/r_sz,c_sz/),"string")

  do i=0, r_sz-1
    nr = doms(i)
    do mi=0, c_sz-1
      m = clabs(mi)
      if ( subj.eq."models" ) then
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
      else
        mlab = m
        if ( m.eq."JRA" ) then
          mlab = "JRA-55"
        end if
        ddir = hdir+nr+"-"+mlab+"/"+idir
      end if
      fnam = ddir+"index_fld_norm.nc"

      misdat = "N"
      if ( subj.eq."models" ) then
        if ( rcp.eq."26" .and. nr.eq."NAM" .and. rnam.eq."REGCM" ) then
          misdat = "Y"
        end if
        if ( nr.eq."CAS" .and. rnam.eq."REGCM" ) then
          misdat = "Y"
        end if
      end if

      if ( misdat.eq."N" ) then
        f = addfile(fnam,"r")
        v = f->n(:,0,0)
        t := cd_calendar(f->time,0)
        t := t(:,0)

        pdim = dimsizes(v)
        nbins = pdim(0)
        y1 = stringtointeger(yr1)
        y2 = stringtointeger(yr2)
        bins := ispan(y1,y1-1+nbins,1)

        ; find integer values of common years
        dszn = dimsizes(t)
        do n = 0, dszn-1
          tn = t(n)
          if ( tn.eq.yr1 ) then
            n1 = n
          end if
          if ( tn.eq.yr2 ) then
            n2 = n
          end if
        end do

        recs := new ((/3,nbins/), "float")
        recs(1,:) = v(:)
        do k =1, nbins
          recs(0,k-1) = 1.0/k
        end do

        rat = recs(1,:)/recs(0,:)
        rat := rat(n1:n2)
        run = runave_n(rat,nry,0,0)
        rbins := bins(n1:n2)

        rcl = regline_stats(rbins,run)
        mval = rcl

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
  if ( subj.eq."models" ) then
    bwr_n = (/50, 54, 58, 62, 66, 70, 74, 78, 82, 86, 90, 94, 100/)
  else
    bwr_n = (/40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100/)
  end if
  bwr_q = dimsizes(bwr_n)
  colf = "tools/BlWhRe.rgb"
  do c=0 , bwr_q-1
    bwr_i = bwr_n(c)
    ac := asciiread(colf, (/bwr_i+3/), "string")
    ac := ac(bwr_i+2)
    nc := str_split(ac, " ")
    rd := stringtofloat(nc(0))/255
    gn := stringtofloat(nc(1))/255
    bl := stringtofloat(nc(2))/255
    rd := decimalPlaces(rd,2,True)
    gn := decimalPlaces(gn,2,True)
    bl := decimalPlaces(bl,2,True)
    colors(c+2) = "(/"+rd+", "+gn+", "+bl+"/)"
  end do
 ;print(colors)

  col_sz = dimsizes(colors)
  if ( subj.eq."models" ) then
    crange = (/0.,1,2,3,4,5,6,7,8,9,10,11,12/)
  else
    crange = (/-2,-1,0.,1,2,3,4,5,6,7,8,9,10/)
  end if
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
    labels(i-2) = sprintf("%3.0f",rng_end) 
                  ;sprintf("%3.1f", rng_beg) + " - " + \
                  ;sprintf("%3.1f",rng_end)
  end do

; cols_for_txt = where(cols_for_vals.eq."Navy" .or. \
;                     cols_for_vals.eq."MediumBlue" .or. \
;                     cols_for_vals.eq."blue4".or. \
;                     cols_for_vals.eq."blue3" .or. \
;                     cols_for_vals.eq."blue1" .or. \
;                     cols_for_vals.eq."Brown" .or. \
;                     cols_for_vals.eq."saddlebrown", "white","black")
  cols_for_txt(:,:) = "black"
  cols_for_vals = where(ismissing(cols_for_vals),"grey",cols_for_vals)
  cols_for_txt = where(ismissing(cols_for_txt),"white",cols_for_txt) 

; Start the graphics.
  wks = gsn_open_wks(frm,img)
  gsn_define_colormap(wks,colors) 

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
  resb@vpXF                    = 0.20
  resb@vpHeightF               = 0.85
  if ( subj.eq."models" ) then
    resb@vpWidthF              = 0.60
  else
    resb@vpWidthF              = 0.30
  end if

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
  if ( subj.eq."models" ) then
    res_text@txFontHeightF   = 0.018             ; change text size
  else
    res_text@txFontHeightF   = 0.015
  end if
  res_text@txJust            = "CenterLeft"      ; text justification
  dum = gsn_add_text(wks,blank,"(x10~S~-3~N~)",1.0,0.0,res_text)  ; add text

  draw(blank)
  
; Advance the frame.
  frame(wks)

  print("saved")
  trimPNG(img+"."+frm)

end

