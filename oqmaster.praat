## oqmaster.praat: wrapper script to get Oq values for multiple files in a single directory
#
## James Kirby <j.kirby@ed.ac.uk>
## 23 February 2017

## If something goes wrong, you can stop the script and pick up where you 
## left off, by noting the last file in the Strings list that was correctly 
## processed. However be sure to rename your output file, or rename it 
## something new when you restart, or you will overwrite your previous data.

#########################
## USER-DEFINED VARIABLES
#########################

## - directory: path to EGG files
## - outfile: name of output file (saved in directory$)
## - extension: file extension for EGG files (.wav, .egg...)
## - eggChan: channel number of EGG signal
## - interval_tier, interval_label, interval_num: used to specify a specific
##   portion of the file to edit/extract from. if interval_num <> 0, this 
##   will take precedence over interval_label. if interval_label == "" and
##   interval_num == 0, entire file will be processed.

## - minF0, maxF0: minimum and maximum pitch values
## - wS: used to calculate window size for smoothing.
##   wS = 0 is same as no smoothing.
##   wS = 2 > 5-point window; ws = 3 > 7-point window; etc.
## - threshold: Howard's method threshold (default: 3/7)

form File info
    comment Full path to EGG files 
    sentence directory /Users/jkirby/Documents/Projects/madurese/egg/lab/egg/
    comment Name of output file (written to same path as above)
    word outfile egg_out.txt
    comment Extension for audio file (.wav, .egg, etc.)
    text extension .wav
    comment Channel of audio file containing EGG signal
    integer eggChan 1
    comment Start from a particular token?
    integer start_file 1
    comment Tier of interest (if irrelevant, leave as default)
    integer interval_tier 3
    comment Label of interval of interest (blank for none/all)
    sentence interval_label v
    comment Number of interval interest (0 for none/all)
    integer interval_num 0
    comment Separator ("-", "_"...) when parsing token names for linguistic variables
    sentence separator _
endform

beginPause("Parameters")
    comment ("Minimum and maximum F0 thresholds")
    integer ("minF0", 75)
    integer ("maxF0", 600)
    comment ("wS: Smoothing window size (points on each side)")
    integer ("wS", 10)
    comment ("Threshold for Howard's method")
    real    ("threshold", 3/7) 
    comment ("Manual check everything the first time through?")
    boolean ("manualCheck", 1)
endPause("Continue", 1)

## including getoq.praat includes everything else
include getoq.praat

clearinfo

Create Strings as file list... list 'directory$'*'extension$'

## parse token filename into var1, var2...
header$ = "filename"
select Strings list
## NB: assumes all filenames have same structure, so any file will do
sampleFileName$ = Get string... 1
@splitstring: sampleFileName$, separator$
for i from 1 to splitstring.strLen
  header$ = "'header$',var'i'"
endfor

## Create output file, overwriting if present
writeFileLine: "'directory$''outfile$'", "'header$',method,period,start,end,f0,Oq"

## loop through files in directory$
number_of_files = Get number of strings
for x from start_file to number_of_files
    select Strings list
    current_file$ = Get string... x
    Read from file... 'directory$''current_file$'
    filename$ = selected$("Sound")

    ## default: process entire file
    select Sound 'filename$'
    start_time = Get start time
    end_time = Get end time
 
    ## ...but if user has provided an interval label or number, use that instead
    if interval_label$ <> "" or interval_num <> 0
        ## use TextGrid to delimit, if it exists/is readable
        textgrid$ = "'directory$''filename$'.TextGrid"
        if fileReadable (textgrid$)
            Read from file... 'textgrid$'

			## first try to use interval_label, if provided
			if interval_label$ <> ""
            	## find start and end of interval of interest
            	number_of_intervals = Get number of intervals... interval_tier
				for y from 1 to number_of_intervals
					select TextGrid 'filename$'
					tmp$ = Get label of interval... interval_tier y
					if tmp$ == interval_label$
						start_time = Get start time of interval... interval_tier y
						end_time = Get end time of interval... interval_tier y
					endif
				endfor

			## if interval_num is given, use that instead
			elsif interval_num <> 0
            	start_time = Get start time of interval... interval_tier interval_num
            	end_time = Get end time of interval... interval_tier interval_num
			endif

        else
        	## if there is no TextGrid, even though user provided an interval label/number,
			## fail semi-gracefully
            beginPause: "No such file"
                comment: "File <'filename$'.TextGrid> does not exist in directory"
                comment: "'directory$'"
                comment: "Using whole file as region of interest."
            endPause: "Continue", 1
        endif
    endif

    ## call main getoq function
    select Sound 'filename$'
    @getoq: manualCheck

    select all
    minus Strings list
    Remove

    clearinfo
endfor

## clean up
select Strings list
Remove

printline "All done."
