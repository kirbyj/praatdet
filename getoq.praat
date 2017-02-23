## getoq.praat

## James Kirby <j.kirby@ed.ac.uk>
## 14 January 2017

## Given just the EGG signal (maybe smoothed, maybe not)... compute the OQ two ways

#########################
## NOTES AND ISSUES
#########################

## 1. Both the DEGG and Howard methods involve the determination of *periods*, 
## measured from (DEGG) closing peak to closing peak. So the first point in the 
## PointProcess needs to be a closing peak, as does the last. These are computed
## from the DEGG signal, so the only difference between the methods is in the 
## OQ (not F0) computation, in particular, with respect to how the start of the
## opening phase is determined.  It is very much up to the USER to insure that 
## the periods have been correctly selected. The PointProcess should BEGIN and 
## END with CLOSING (i.e. positive) peaks. 

## Note that it is not enough to simply remove the point of uncertain DEGG 
## opening peaks, because the algorithm expects opening-closing peak pairs. 

## 2. At present, nothing intelligent is done about multiple peaks: they
## are not detected, nor is there an option given to do anything about them...
## Currently we just determine maxima and minima using Praat's
## To PointProcess (periodic, peaks)... function as detailed here:
## http://www.fon.hum.uva.nl/praat/manual/Sound___Pitch__To_PointProcess__peaks____.html

## 3. It is possible to discard particular periods manually, a la peakdet. 
## This entails keeping track of the periods when adding/deleting points, and 
## then entering these in the next step. If periods are discarded, e.g. due to 
## the presence of multiple opening peaks, they are removed from BOTH methods' 
## matrices (or more precisely, set to 0).

## This is likely to be problematic only if the Oq of particular, individual
## periods is ultimately of interest. In most use cases, this probably won't 
## matter, because you will interpolate between the missing values at the analysis stage.

## I *think* what I recommend is trying to set points where you think there
## (should be) pulses, then explicitly removing the measures in the 2nd stage. 
### This will indicate that there 'was' a pulse there, but that it was 
## manually removed (i.e., set to 0).

## Dependencies
include splitstring.praat
include smooth.praat
include peakdet.praat
include degg.praat
include howard.praat
include writelns.praat
include plotoq.praat
include exclude.praat

procedure getoq: .manualCheck

    ## Clear windows
    Erase all

    ## Extract
    name$ = selected$ ("Sound", 1)
    Extract one channel... eggChan
  
    ## Rename
    ch$ = selected$ ("Sound", 1)
    select Sound 'name$'
    Remove
    select Sound 'ch$'
    Rename... 'name$'
    name$ = selected$ ("Sound", 1)

    ## Filter
    Copy: "'name$'_filtered"
    ## should change this to allow for different filter rates and frequencies
    Filter (pass Hann band)... 75 0 100

    ## Smooth the filtered signal
    Copy: "'name$'_fsmooth"
    @smooth: wS
    Formula... 'smooth.formula$'

    ## Get opening and closing peaks based on DEGG signal
    @peakdet

    ## Set flag to enter main loop
    .findOQ = 1

    #############
    ## Main loop
    #############

    while .findOQ <> 0

        ###############################
        ## Find peaks
        ###############################
       
        ## find total number of opening and closing peaks
        select PointProcess 'name$'_degg_both

        ## if we could assume the entire file was relevant than we could just say
        # nb_peaks = Get number of points
        
        ## but given we are potential interested in a sub-region then...
        ## get the first point *following the onset* of the region
        first_point  = Get high index... start_time
        ## get the last point *preceding the offset* of the region
        last_point = Get low index... end_time
        nb_peaks = (last_point - first_point) + 1

        ## get number of *periods* (close->close)
        nb_periods = (nb_peaks / 2) - 1

        ####################################
        ## Get Oq using DECOM method (dEGG)
        ####################################

        @degg

        ####################################
        ## Get Oq using Howard's method 
        ####################################
        
        @howard

        #####################
        ## Get skewness
        #####################
        
        #@skewness

        #####################
        ## Plot and check
        #####################
       
        if .manualCheck <> 0
            @plotoq

            beginPause: "Manual check options"
                comment: "Do you want to manually add/delete any points? (1=yes)"
                integer: ".manualCheck", .manualCheck
            endPause: "Continue", 1
    
            ################################
            ## Add/remove points if desired 
            ################################
            
            if .manualCheck == 1
                select PointProcess 'name$'_degg_both
                plus Sound 'name$'_degg
                View & Edit
                editor: "PointProcess 'name$'_degg_both"
                    Zoom: start_time, end_time
                endeditor
                pause Add missing peaks/delete spurious points
                editor: "PointProcess 'name$'_degg_both"
                    Close
                endeditor
            endif
           
            ################################
            ## Exclude periods, if desired
            ################################
            
            if .manualCheck == 0
                ## Call procedure to allow user to exclude periods
                @exclude 
                ## We're done with this file. Set flag and write results to disk
                .findOQ = 0
            endif

        endif 

    endwhile
    
    ##################################
    ## Write to file and save objects
    ##################################
    @writelns

    ###################
    ## Clean up 
    ###################
    select Matrix 'name$'_degg
    plus Matrix 'name$'_howard
    Remove

endproc 
