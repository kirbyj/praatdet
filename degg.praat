## degg.praat: compute Oq for each period based on dEGG signal (method of Henrich et al., 2004)

## James Kirby <j.kirby@ed.ac.uk>
## 4 Jan 2017

procedure degg

    ## create matrix with five cols:
    ## period_num, period_start, period_end, f0, oq
    Create simple Matrix... 'name$'_degg nb_periods 5 0
    
    # .i: points counter
    #.i = 1
    .i = first_point
 
    # .j: periods counter
    .j = 1

    #while .i < nb_peaks - 2
    while .i < last_point - 2
        select PointProcess 'name$'_degg_both
        .period_start = Get time from index... .i
        .period_open = Get time from index... .i+1
        .period_end = Get time from index... .i+2
        .oq = (.period_end - .period_open) / (.period_end - .period_start)
        .f0 = 1 / (.period_end - .period_start)

        # store info for this period
        select Matrix 'name$'_degg
        Set value... .j 1 .j
        Set value... .j 2 .period_start 
        Set value... .j 3 .period_end
        Set value... .j 4 .f0
        Set value... .j 5 .oq

        .i = .i + 2
        .j = .j + 1
    endwhile
endproc

