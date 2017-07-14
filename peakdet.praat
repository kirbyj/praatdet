## peakdet.praat: finding opening and closing peaks based on (possibly smoothed) DEGG signal

## James Kirby <j.kirby@ed.ac.uk>
## 22 Feb 2017

## computes the dEGG signal on the basis of a smoothed, filtered Sp waveform.
## dEGG signal is then further smoothed using the same window.

## there are other smoothing regimes would could entertain/test, but the real 
## problem is with double peaks, which even aggressive smoothing is unlikely to 'solve'.

procedure peakdet 

    # select (filtered, smoothed) Lx signal
    select Sound 'name$'_fsmooth

    # take first derivative of waveform
    Copy: "'name$'_degg"
    Formula... self [col+1] - self [col]
    
    # smooth this signal (if wS=0, no smoothing)
    Formula... 'smooth.formula$'
    
   ## If there is an existing PointProcess file, use that
    existing_pprocess$ = "'directory$''name$'_degg_both.PointProcess"
    if fileReadable(existing_pprocess$)
        Read from file... 'existing_pprocess$'
    else
		# get closing peaks
		To PointProcess (periodic, peaks)... minF0 maxF0 Yes No
		Rename... 'name$'_degg_closing

		# get opening peaks
		select Sound 'name$'_degg
		To PointProcess (periodic, peaks)... minF0 maxF0 No Yes
		Rename... 'name$'_degg_opening

		# add them together 
		select PointProcess 'name$'_degg_opening
		plus PointProcess 'name$'_degg_closing
		Union
		Rename... 'name$'_degg_both
	endif
endproc
