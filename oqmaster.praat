## oqmaster.praat

## James Kirby <j.kirby@ed.ac.uk>
## 4 January 2017

## Wrapper script to get OQ values for multiple files in a single directory

## If something goes wrong, you can stop the script and pick up where you 
## left off. However be sure to rename your output file, or rename it 
## something new when you restart, or you will overwrite your previous
## data! (If we save the PointProcess objects that's not so terribly horrible,
## but any manually removed points will need to be re-removed.)

#########################
## USER-DEFINED VARIABLES
#########################

## - minimum and maximum pitch values
## - filter minimum (or just use e.g. 1/2 of the pitch minimum?)
## - Howard's method threshold (default: 3/7)
## - graphic display of methods (or some %age of total?)
## - channel number of EGG signal
## - smoothing (wS = 0 is same as no smoothing)
## - name of output file? (see above)

## Set some variables
form File info
    comment Full path to EGG files 
   # sentence directory /Users/jkirby/Desktop/0010/
    sentence directory /Users/jkirby/Documents/Projects/madurese/egg/lab/egg/
    comment Name of output file (written to same path as above)
    word outfile egg_out.txt
    comment Channel of audio file containing EGG signal
    integer eggChan 1
    comment Start from a particular token?
    integer start_file 1
    comment Tier of interest
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
    #comment ("Give user option to exclude individual periods?")
    #boolean ("excludePeriods", 1)
endPause("Continue", 1)

## getoq.praat includes everything else
include getoq.praat

clearinfo

extension$ = ".wav"
Create Strings as file list... list 'directory$'*'extension$'

## parse token filename into Var1, Var2...
header$ = "filename"
select Strings list
sampleFileName$ = Get string... 1
currentField = 0
repeat
 currentField = currentField + 1
 check = index (sampleFileName$, separator$)
 if check <> 0
  header$ = "'header$',Var'currentField'"
  sampleFileName$ = mid$ (sampleFileName$, check+1, 10000)
 else
  header$ = "'header$',Var'currentField'"
 endif
until check = 0

## Create output file, overwriting if present
writeFileLine: "'directory$''outfile$'", "'header$',method,period,start,end,F0,OQ"

## loop through files
number_of_files = Get number of strings
for x from start_file to number_of_files
    select Strings list
    current_file$ = Get string... x
    Read from file... 'directory$''current_file$'
    filename$ = selected$("Sound")


    ## get corresponding TextGrid to determine correct time domain
    textgrid$ = "'directory$''filename$'.TextGrid"

    ## how best to do this is not clear
    ## one could say e.g. that you should handle the entire voiced sequence
    ## (of possibly many segments) and then figure out some way to infer the
    ## region of interest directly from the TextGrid in e.g. R
    
    ## currently the script assumes that you have a particular region you are
    ## interested in, and it will only deal with that region. That means that
    ## the PointProcess created will get over-written if you then return to the
    ## same data and want to get OQ for e.g. a voiced segment. this seems sub-optimal

    ## this should probably be changed so that we can just do hand-correcting once,
    ## but then when getting the output, be able to specify values for particular 
    ## *labels* on particular *tiers* - in other words, separate the "region of 
    ## hand-correcting" interest (which may be the entire voiced period) from the
    ## regions of "data analysis" interest (which may be on another tier)
    
    ## there may also be some better way of handling this e.g. in R
   
    ## default: process entire Sound
    select Sound 'filename$'
    start_time = Get start time
    end_time = Get end time
 
    ## ...but overwrite these if user has provided an interval label or number
    if interval_label$ <> ""
        ## if TextGrid exists, delimit 
        if fileReadable (textgrid$)
            Read from file... 'textgrid$'

            ## find start and end of interval of interest
            number_of_intervals = Get number of intervals... interval_tier
            for y from 1 to number_of_intervals
                select TextGrid 'filename$'
                tmp$ = Get label of interval... interval_tier y
                if tmp$ == interval_label$
                    start_time = Get start time of interval... interval_tier y
                    end_time = Get end time of interval... interval_tier y
                    #select Sound 'filename$'
                    #Extract part... start_time end_time rectangular 1.0 yes
                    #select Sound 'filename$'
                    #Remove
                    #select Sound 'filename$'_part
                    #Rename... 'filename$'
                endif
            endfor
        else
        ## there is no TextGrid, even though user provided an interval label
            pause No such TextGrid exists; using whole file as interval of interest.
        endif
    endif

    if interval_num <> 0
        ## if TextGrid exists, delimit 
        if fileReadable (textgrid$)
            Read from file... 'textgrid$'
            start_time = Get start time of interval... interval_tier interval_num
            end_time = Get end time of interval... interval_tier interval_num
        else
        ## there is no TextGrid, even though user provided an interval label
            pause No such TextGrid exists; using whole file as interval of interest.
        endif
    endif


    ## call getoq
    select Sound 'filename$'
    @getoq: manualCheck

    select all
    minus Strings list
    Remove

    clearinfo
endfor

select Strings list
Remove
