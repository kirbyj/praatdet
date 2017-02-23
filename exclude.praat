## exclude.praat: procedure to safely remove periods from matrices

## James Kirby <j.kirby@ed.ac.uk>
## 4 Jan 2017

procedure exclude

    .excludePeriods = 1
	while .excludePeriods == 1

        ## Plot current OQ values
        @plotoq

        ## Ask if the user wants to exclude periods
        beginPause: "Exclude periods"
            comment: "Do you want to manually exclude any periods?"
            comment: "WARNING! Cannot be undone!!"
            comment: "If yes, enter the period numbers separated by spaces."
            comment: "If no, leave blank and click Continue."
            text: "to_exclude", ""
        endPause: "Continue", 1

        ## Check if there is anything to do
        if to_exclude$ != ""

            ## Split out
            @splitstring: to_exclude$, " "

            ## First, check that each period is <= the max number of matrix rows
			.badPeriod = 0

			## Both matrices should have the same length, so it 
			## shouldn't matter which one we choose
			select Matrix 'name$'_degg
			.maxRows = Get number of rows

			## Need to loop through as this isn't a 'real' array...
            for i from 1 to splitstring.strLen
				.thisPeriod = number(splitstring.array$[i])
				if .thisPeriod > .maxRows
					pauseScript: "Period ", .thisPeriod, " does not exist. Please try again."
					.badPeriod = 1
				endif
			endfor

			if .badPeriod != 1
				for i from 1 to splitstring.strLen
					## Set everything to 0 for this row of DEGG matrix
					select Matrix 'name$'_degg
					Set value: number(splitstring.array$[i]), 2, 0
					Set value: number(splitstring.array$[i]), 3, 0
					Set value: number(splitstring.array$[i]), 4, 0
					Set value: number(splitstring.array$[i]), 5, 0

					## Set everything to 0 for this row of Howard matrix
					select Matrix 'name$'_howard
					Set value: number(splitstring.array$[i]), 2, 0
					Set value: number(splitstring.array$[i]), 3, 0
					Set value: number(splitstring.array$[i]), 4, 0
					Set value: number(splitstring.array$[i]), 5, 0
				endfor
			## else do nothing, go back to top of loop and start again
			endif
        else
            ## Set flag to leave while loop; otherwise plot and ask again
            .excludePeriods = 0
        endif
    endwhile
endproc
