# praatdet

A suite of Praat scripts for analyzing EGG waveforms.

## Background

This set of scripts was originally inspired by my attempts to use the [**peakdet**](http://voiceresearch.free.fr/egg/) tools developed by Nathalie Henrich, Cédric Grendrot, and Alexis Michaud. As I began to modify their code for my own purposes, I became sufficiently frustrated with certain aspects of the workflow that I decided to try and implement something similar in Praat. Praat comes with its own set of problems and I in no way claim it is superior to Matlab for this purpose, but I have learned a great deal about the EGG signal in the process.


## Warning

I make no claims that the implementations here are correct, or that they will give the same results as some other set of EGG tools, etc. I developed them primarily for my own use case, and because I wanted to have a better understanding of the issues involved; I find that implementing things myself can be helpful in this regard.


## Comments, suggestions, requests

Please send any comments, etc. to [j.kirby@ed.ac.uk](j.kirby@ed.ac.uk).

## General structure

The scripts assume that the user has some number of EGG recordings for which s/he would like to obtain OQ estimates. These recordings may either by part of a stereo file (with e.g. a microphone recording on the other channel) or could be mono EGG files. 

The user may or may not have accompying TextGrids where regions of interest have been indicated. In the interest of file management simplicity, ```praatdet``` keeps just one (user-corrected) PointProcess per file, but permits the user to only annotate/display OQ values for a particular region. For example, you may have an utterance with 

From the user's perspective there are two important scripts. The first allows you to edit the PointProcess objects and get an idea of what the resulting Oq values will look like. The second script actually extracts the values based on the existing PointProcess objects. By separating these processes 

### Other assumptions
- your filenames contain useful metadata about the token (e.g. speaker code, gender, token number, etc.). These will be parsed based on a user-defined delimiter and included in the output file as generic columns named *Var1, Var2...VarN*.

- you will do normalization, etc. at the analysis stage, e.g. in R or elsewhere. these scripts really just pull out the Oq information.

### Philosophy

Nothing intelligent is done about multiple peaks. One could imagine implementing something more sophisticated, as **peakdet** does, to identify instances of double peaks and then select the first peak, second peak, use barycenter method... 

I have tried to encapsulate pieces of the script as functions. Praat does not really have functions, so this is kind of a mess. Note that local variables are globally available. (I know.)

## Prepping the EGG signal

Highpass filtering gets rid of some of the larynx movement component - I *think* this is has a similar effect to Mooshammer's normalization procedure. However, we don't get rid of *all* of it. We are potentially interested in shape differences, so I don't think we want to throw away the shape data by linearly time-normalizing to a uniform length. However we do need to think carefully about how this data will be analysed. 

Mooshammer: `...the data were also amplitude normalized to an amplitude of 1 for the first glottal closure. In order to compensate for vertical larynx movements a line connecting the minima of the first and second periods was subtracted from all values' (2010:1052). She only examined two periods per utterance, but we can extend this line of thinking I think. 

One thing to do may be to (as I think Abramson et al 2015 do) average over regions of the vowel (or consonant or whatever). This way it can all be done at the R/analysis stage and doesn't have to involve any explicit (pre-)normalization. 

## Praat-based

- Low-pass filter EGG channel (need to select threshold; maybe have options to either use a fixed, user-defined value, or let it select automatically based on the minimum F0 > 0 detected in the signal?

- Take derivative; use this to find closing peaks:

            To PointProcess (periodic, peaks)... min max Yes No
            Rename... 'name$'_degg_closing 

    with user-defined min and max. This includes maxima, but not minima, and so finds the closing peaks. These are the most reliable. We could do this on the raw signal or on a smoothed signal; for more on smoothing see below.

- Now try to find the opening peaks:

            To PointProcess (periodic, peaks)... min max No Yes
            Rename... 'name$'_degg_opening

- Combine these and pause so the user can add missing peaks by hand if deemed necessary:

            plus PointProcess 'name$'_degg_closing
            Union
            Rename... 'name$'_degg_both
            plus Sound 'name$'
            Pause Add missing/delete spurious points
            Edit

- This gives the user a great deal of control actually: it doesn't use a barycenter method, or anything like that; if it doesn't get a clear min/max, it doesn't do anything, and it's up to the user to decide what to do and to add these points in by hand. The tiny, tiny amounts that they may be off I don't think will amount to much.

- That's your basic DEGG-based process. It should work the same on both the smoothed and unsmoothed signal. It's very much like Alexis' method but I find it much faster to add points in the Praat PointProcess then having to enter numbers by hand in Matlab...

- To determine OQ, we have to do something like: starting from peak i, divide the duration from i+1 to i+2 by the duration of i to i+2; then advance to i+2. (Or get CQ. same difference)

### Howard's method

- To do this, we just take the closing peaks:

            Select Sound 'name$'
            plus PointProcess 'name$'_degg_closing

- Then, for each period, extract it, normalize to the range [0,1], and use the 3/7ths method:

            Down to Matrix
            min = Get minimum
            max = Get maximum
            d = max-min
            Formula... (self[col]-min) / d
            To Sound
            Rename... 'name$'_1period_scaled

- Basically you check if the sample is below the threshold or not. The threshold is set to 3/7ths by default but can be changed. 
 
### Smoothing

The signal can be smoothed by calculating a *linearly weighted symmetric moving average*

\begin{equation}
\hat{f}(t) = \sum_{j=-k}^k
\end{equation}

where

It is possible to efficiently compute these as convolutions but here we just do it the clunky way, constructing the equation based on the smoothing window size wS.

### Time-normalization

No time normalization is done at the Praat script stage. The output includes the start and end times of each pulse in the segment. If normalization is necessary later, this can be done at the R-stage, either by linear interpolation, windowing, or some other method of the analysts's choosing. 

An outstanding question is whether these start and end times should be relative to 0 for each interval, or relativized to some common starting point, e.g. the closure release (which can be measured in both the isolation and carrier phrase contexts). 

### Output format


## Known issues

- In the OQ plot, the first and last values overlap with the plot border. I'm not sure how to fix this beyond padding the matrices on either end, which means copying the matrices, etc.