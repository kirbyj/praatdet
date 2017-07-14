## howard.praat: compute Oq for each period based on Howard's method (Howard, 1995)

## James Kirby <j.kirby@ed.ac.uk>
## 4 Jan 2017

procedure howard
    
    ## create matrix with five cols:
    ## period_num, period_start, period_end, f0, oq 
    Create simple Matrix... 'name$'_howard nb_periods 5 0
   
    # .i: points counter
    #.i = 1
    .i = first_point

    # .j: periods counter
    .j = 1

    #for .i from 1 to nb_periods - 1
    #while .i < nb_peaks - 2
    while .i < last_point - 2

        #select PointProcess 'name$'_degg_closing
        select PointProcess 'name$'_degg_both
        .period_start = Get time from index... .i
        #.period_end = Get time from index... .i+1
        .period_end = Get time from index... .i+2

        # select original (filtered, smoothed) signal
        select Sound 'name$'_fsmooth
        Extract part... .period_start .period_end rectangular 1 yes
        
        # normalize this period
        .min = Get minimum... 0 0 Sinc70
        .max = Get maximum... 0 0 Sinc70
        Formula... (self[col]-.min) / (.max-.min)

        # open phase begins with the first sample below the threshold
        Copy: "'name$'_band_part_zeroed"
        .nsamp = Get number of samples
        for .k from 1 to .nsamp
            .si = Get value at sample number... eggChan .k
            if .si < threshold
            ## set all values below threshold to zero
                Set value at sample number... 1 .k 0
            endif
        endfor
       
        # open period starts sometime after the peak 
        .local_max = Get time of maximum... 0 0 Sinc70
        .first_zero = Get time of minimum... .local_max 0 Sinc70

        # back up one sample for maxmimum explicitness
        .zero_samp = Get sample number from time... .first_zero
        .open_start = Get time from sample number... .zero_samp-1

        ## Optional: draw each period, with a dotted line representing the 
        ## beginning of the open phase
        #Erase all
        #Select outer viewport: 0, 6, 0, 4
        #select Sound 'name$'_fsmooth_part
        #Solid line
        #Draw... 0 0 0 0 Yes Curve
        #Dotted line
        #Draw line... .period_start threshold .period_end threshold
        #Draw line... .open_start 0 .open_start 1
        #pause 

        # compute oq and f0
        .oq = (.period_end - .open_start) / (.period_end - .period_start)
        .f0 = 1 / (.period_end - .period_start)

        # store info for this period
        select Matrix 'name$'_howard
        Set value... .j 1 .j
        Set value... .j 2 .period_start
        Set value... .j 3 .period_end
        Set value... .j 4 .f0
        Set value... .j 5 .oq

        #appendInfoLine: .period_start, ",", .period_end, ",", .f0, ",", .oq
        #appendFileLine: "egg_out.txt", .i, ",", name$, ",howard,", .period_start, ",", .period_end, ",", .f0, ",", .oq

        # clean up
        #select Sound 'name$'_band_part
        select Sound 'name$'_fsmooth_part
        plus Sound 'name$'_band_part_zeroed
        Remove

    .i = .i + 2
    .j = .j + 1
    endwhile
endproc

