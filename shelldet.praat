## shelldet.praat: wrapper script to get Oq values for multiple files in a single directory
#
## James Kirby <j.kirby@ed.ac.uk>
## last update: 16 August 2018
##
## Designed to be called be a shell script with command line arguments
##
## If something goes wrong, you can stop the script and pick up where you 
## left off, by noting the last file in the Strings list that was correctly 
## processed. However be sure to rename your output file, or rename it 
## something new when you restart, or you will overwrite your previous data.

#########################
## USER-DEFINED VARIABLES
#########################

## - directory: path to EGG files
## - textgrid: path to TextGrids, if applicable (default: same as directory$)
## - outfile: name of output file (saved in directory$)
## - extension: file extension for EGG files (.wav, .egg...)
## - eggChan: channel number of EGG signal
## - intervalTier, intervalLabel, intervalNum: used to specify a specific
##   portion of the file to edit/extract from. if intervalNum <> 0, this 
##   will take precedence over intervalLabel. if intervalLabel == "" and
##   intervalNum == 0, entire file will be processed.

## - minF0, maxF0: minimum and maximum pitch values
## - k: used to calculate window size for smoothing.
##   k = 0 is same as no smoothing.
##   k = 2 > 5-point window; k = 3 > 7-point window; etc.
## - threshold: Howard's method threshold (default: 3/7)

form File info
    comment Full path to EGG files 
    text directory /Users/jkirby/Projects/egg/praatdet/examples/
    comment Full path to TextGrids
    text textgrids /Users/jkirby/Projects/egg/praatdet/examples/
    comment Name of output file (written to same path as above)
    word outfile egg_out.txt
    comment Extension for audio file (.wav, .egg, etc.)
    word extension .wav
    comment Channel of audio file containing EGG signal
    integer eggChan 1
    comment Start from a particular token?
    integer startFile 1
    comment Tier of interest (if irrelevant, leave as default)
    integer intervalTier 3
    comment Label of interval of interest (blank for none/all)
    word intervalLabel v
    comment Number of interval of interest (0 for none/all)
    integer intervalNum 0
    comment Separator (-, _ ...) when parsing token names
    word separator _
    comment Minimum and maximum f0 thresholds
    integer minF0 75
    integer maxF0 600
    comment k: Smoothing window size parameter (points on each side)
    integer k 10
    comment Threshold for Howard's method
    real    threshold 3/7 
    comment Filter frequency cutoff
    integer passFrequency 40
    comment Filter cutoff smoothing
    integer smoothHz 20
    comment Manually edit points and periods?
    boolean manualCheck 1
    comment Use existing PointProcess files, if available?
    boolean useExistingPP 0
    comment Invert signal (if your EGG has closed=down for some reason)
    boolean invertSignal 0
endform

## including getoq.praat includes everything else
include getoq.praat

clearinfo

Create Strings as file list... list 'directory$'*'extension$'

## parse token filename into var1, var2...
header$ = "filename"
select Strings list
## NB: assumes all filenames have same structure, so any file will do
sampleFileName$ = Get string... 1
sampleFileName$ = sampleFileName$ - extension$
@splitstring: sampleFileName$, separator$
for i from 1 to splitstring.strLen
  header$ = "'header$',var'i'"
endfor

## Create output file, overwriting if present
writeFileLine: "'directory$''outfile$'", "'header$',label,method,period,start,end,f0,Oq"

## loop through files in directory$
number_of_files = Get number of strings
for x from startFile to number_of_files
    select Strings list
    current_file$ = Get string... x
    Read from file... 'directory$''current_file$'
    filename$ = selected$("Sound")

    ## invert signal if necessary
    if invertSignal
        Formula... -self
    endif
    
    ## default: process entire file
    select Sound 'filename$'
    start_time = Get start time
    end_time = Get end time
 
    ## ...but if there is a TextGrid, try to use that instead
    gridname$ = current_file$ - extension$
    textgrid$ = "'textgrids$''gridname$'.TextGrid"
    if fileReadable (textgrid$)
        Read from file... 'textgrid$'

		## first try to use intervalLabel, if provided
		if intervalLabel$ <> ""
        	## find start and end of interval of interest
        	number_of_intervals = Get number of intervals... intervalTier
			for y from 1 to number_of_intervals
				select TextGrid 'gridname$'
				tmp$ = Get label of interval... intervalTier y
				if tmp$ == intervalLabel$
					start_time = Get start time of interval... intervalTier y
					end_time = Get end time of interval... intervalTier y
				endif
			endfor

		## if intervalNum is given, use that instead
		elsif intervalNum <> 0
        	start_time = Get start time of interval... intervalTier intervalNum
        	end_time = Get end time of interval... intervalTier intervalNum
            ## overwrite intervalLabel$ with something more useful
            ## problem: doing this means that we will not enter this condition next time
            #intervalLabel$ = Get label of interval... intervalTier intervalNum

        ## if nothing, just use the label of the first tier
        else
            intervalLabel$ = Get label of interval... intervalTier 1
		endif

    else
    	## if there is no TextGrid, even though user provided an interval label/number,
		## fail semi-gracefully
        beginPause: "No such file"
            comment: "File <'gridname$'.TextGrid> does not exist in directory"
            comment: "'textgrid$'"
            comment: "Using whole file as region of interest."
        endPause: "Continue", 1
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

printline All done.
