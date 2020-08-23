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
	if useExistingPP
    	existing_pprocess$ = "'directory$''name$'_degg_both.PointProcess"
    	if fileReadable(existing_pprocess$)
        	Read from file... 'existing_pprocess$'
		endif
    else
		# get closing peaks
		To PointProcess (periodic, peaks)... minF0 maxF0 Yes No
		Rename... 'name$'_degg_closing

		# what is the time of the first closing point?
		closing_point_index = Get high index... start_time
		closing_point_time = Get time from index... closing_point_index
	
		# get opening peaks
		select Sound 'name$'_degg
		To PointProcess (periodic, peaks)... minF0 maxF0 No Yes
		Rename... 'name$'_degg_opening

		# what is the time of the first opening point?
		opening_point_index = Get high index... start_time
		opening_point_time = Get time from index... opening_point_index

		# before combining, make sure that the first peak is always a closing peak
		# this way we always measure closing->closing
		if closing_point_time > opening_point_time
			Remove point: opening_point_index
		endif
		
		# add them together 
		select PointProcess 'name$'_degg_opening
		plus PointProcess 'name$'_degg_closing
		Union
		Rename... 'name$'_degg_both

		# now go through remove orphan points
		# ensure that all point pairs are positive followed by 
		# negative and that closing-opening peak pairs occur within
		# 1/minF0 sec of one another
		num_points = Get number of points

		# initialize counter
		p = 1	

		while p < (num_points - 1)
			select PointProcess 'name$'_degg_both
			t_this = Get time from index... p
			t_next = Get time from index... p + 1
	
			select Sound 'name$'_degg

			val_this = Get value at time... 1 't_this' Sinc70
			val_next = Get value at time... 1 't_next' Sinc70

			select PointProcess 'name$'_degg_both

			# if next peak is too far away...
			if ((t_next - t_this) > 1/minF0)
				Remove point... p
				num_points = num_points - 1
				#pauseScript: "removed point 'p' at time 't_this:3' because next peak too far away"
			# if the next peak is close enough...
			else
				# ...but also positive, treat current peak as orphaned		
				if (val_next > 0)
					Remove point... p
					num_points = num_points - 1
					#pauseScript: "removed point 'p' at time 't_this:3' because next peak is also positive"
				# else move to next closing point
				else
					p = p + 2
				endif
			endif

		endwhile

	endif
endproc
