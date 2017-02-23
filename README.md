# praatdet

A suite of Praat scripts to determine the open quotient (Oq) and fundamental frequency based on the EGG waveform.


## Background

This set of scripts was originally inspired by my attempts to use the [**peakdet**](http://voiceresearch.free.fr/egg/) tools developed by Nathalie Henrich, Cédric Grendrot, and Alexis Michaud. In the course of modifying their code to batch-process large numbers of files, I found myself wishing for a number of other modifications to the general [**peakdet**](http://voiceresearch.free.fr/egg/) workflow. Eventually I decided that the easiest solution would be try and implement something similar myself. I chose Praat for this primarily because it provides a relatively intuitive and easy-to-use graphical interface for editing pulse trains. Praat comes with its own set of problems and I in no way claim it is superior to Matlab for this purpose; however, I have learned a great deal about working with EGG signals in the process of developing these tools.

## Warning!

I make no claims that the implementations here are correct, or that they will give the same results as some other set of EGG tools, etc. I developed them primarily for my own use case, and because I wanted to have a better understanding of the issues involved; I find that implementing things myself can be helpful in this regard.


## Comments, suggestions, etc.

Please send any comments, etc. to [j.kirby@ed.ac.uk](j.kirby@ed.ac.uk).

## General structure

**praatdet** assume that the user has a number of EGG recordings for which s/he would like to obtain Oq estimates. These recordings may either be part of a stereo file (with e.g. a microphone recording on the other channel) or could be mono EGG files. **praatdet** determines opening and closing peaks using the dEGG signal, allows the user to add and delete points, permits the user to disregard particular periods (e.g., due to the presence of multiple opening peaks), and writes the output to a comma-delimited text file. Information about the peaks themselves is also saved in the form of a Praat ```PointProcess``` file.

Presently, Oq is determined using two methods:

1. detection of the opening and closing peaks on the derivative of the EGG signal ("dEGG method"), and
2. detection of the closing peak using the dEGG signal, and detection of the opening peak using an EGG-based threshold method ("Howard's method").

The physiological correlates of peaks in the dEGG signal were studied extensively by Donald Childers and colleagues (e.g. Childers et al. 1986, 1990). Closing peaks are generally easily identified from the dEGG signal, but opening peaks may be indeterminate (Henrich et al. 2004, Michaud 2004). For this reason, while the maximum positive peak in the dEGG is usually used as an indicator the closing instant, an EGG-based threshold method may be used to determine the opening instant. Howard (1995), following Davies et al. (1986) and others, suggest a point where the negative-going Lx cross an amplitude threshold of 3:7 of that cycle's peak-to-peak amplitude. These are the two methods currently implemented in **praatdet**.

The user may or may not have accompying TextGrids where regions of interest have been indicated. In the interest of file management simplicity, **praatdet** keeps just one (potentially user-corrected) PointProcess per file, but permits the user to only annotate/display Oq values for a particular region. For example, you may have a file containing a single word, segmented into onset, nucleus, and coda. In the first instance you may just want to determine Oq for the nucleus, but perhaps later you decide you are interested in the nasal coda as well. Since a single PointProcess object is associated with each EGG file, you can edit the detected peaks for the coda region while retaining your previous edits of the nucleus. For more details, see the [EXAMPLES](EXAMPLES.md) document.

From the user's perspective, the most important script is ```oqmaster.praat```. All other scripts simply encapsulate different aspects of the workflow.

### Requirements
- **praatdet** assumes your filenames contain useful metadata about the token (e.g. speaker code, gender, token number, etc.). These will be parsed based on a user-defined delimiter and included in the [output file](#output) as generic columns named *var1, var2...*.

- It is assumed that tasks such as normalization will happen in a different environemt (e.g. R). **praatdet** is narrowly focused on annotating/editing a pulse train object, and extracting Oq values based on it.

- **praatdet** requires Praat 6 or later. It has been tested with 6.0.24 on both macOS 10.12.3 and Windows 7. Find the latest version at [http://www.praat.org](http://www.praat.org).

## Usage

1. Run the ```oqmaster.praat``` script from within Praat. This will bring up a dialog window prompting you for 

	- the location of your EGG files
	- the name of your [output file](#output)
	- the channel of your audio files containing the EGG signal
	- which file in the list you wish to begin processing from
	- a delimiter separating meaningful elements of your filenames 

	If you are using an existing TextGrid to process just a portion of your files, you can also specify 

	- a tier of interest	
	- a label of interest on this tier
	- an interval number of interest

	If you specify both an interval label and an interval number, the number will take precedence, unless it is left as 0 (zero), the default. To process the entire file, set ```intervalLabel``` to be blank and ```intervalNum``` to 0.

2. The next options screen prompts you for

	- the minimum and maximum f0 thresholds used by Praat's autocorrelation-based pitch analysis algorithm
	- a parameter ```k``` which determines the size of the smoothing window (see [Smoothing](#smoothing) below)
	- a threshold for Howard's method (default: 3/7ths)
	- the pass frequency for the high-pass filter to remove the Gx signal component (default: 75 Hz)
	- the filter cutoff smooth (default: 20 Hz)
	- an option to manually edit points and periods

	If ```manualCheck``` is left unchecked, **praatdet** will simply parse all files in the directory, find Oq values, and write them to an [output file](#output). This means that semi-automatic, hand-corrected pitch period detection can be performed, possibly for the entire file, and then Oq values can be extracted for different subsets of each file. 

3. If manually checking points and periods, **praatdet** will now present the user with a plot of the Oq values for the region of interest, estimated using both the dEGG and Howard methods, and a prompt asking "Do you want to manually add/delete any points?"

	In general, the dEGG and Howard estimates of Oq should be similar. If they are not, or if the values are extremely close to 0 or 1, this usually means that either the first or the last peak detected was not a closing peak. To check this, click ```Continue``` in the **Pause: Manual check options** box. This will bring up an ```Edit``` window showing the dEGG signal and the detected points. **The first and last points should both be positive peaks!** This is because **praatdet** measures periods from closing peak to closing peak. It could have been done the other way, but it wasn't. 
	
	Note that the ```Edit``` window will automatically zoom in to the region of interest, and that this corresponds to the plot in the ```Picture``` window.
		
	To add a point, put your cursor where you would like to add a point and select *Add point at cursor* from the **Point** menu (or use the keyboard shortcut). To delete a point or points, select them using the mouse, then choose *Remove point(s)* from the **Point** menu (or use the keyboard shortcut). 
	
	When you are finished, click ```Continue``` in the **Pause: stop or continue** dialog box.
	
4. The Oq estimates will now be re-drawn in the ```Picture``` window, and you will have the option to repeat step 3. If the estimates still look incorrect or differ wildly from one another, you may have missed a point or points; repeat step 3. If the estimates look OK, enter 0 as the value for ```.manualCheck``` and click ```Continue```.

5. You will now have the opportunity to remove individual *periods* (not points) from consideration, a la [**peakdet**](http://voiceresearch.free.fr/egg/). You may wish to do this if, for example, you decide that the values at the edges of the utterance are invalid, or if you noticed periods containing double peaks in steps 3-4. I recommend inserting points (or leaving the ones that Praat finds) for double peaks, and then removing the entire period at this step. The advantage of this workflow is that the [output file](#output) will record the time and location of this period, but will not record Oq values for it. This is a simple way of indicating the existence of a double peak.

	To remove periods, enter the period numbers, separated by spaces, in the dialog box. The ```Picture``` display will then update to reflect your changes. Be careful; there is no 'undo' for this procedure, short of processing the file all over again! When you are finished, or if you do not wish to remove any periods, leave the dialog box blank, and click ```Continue```.
	
6. The Oq values as determined by both methods will now be appended to the [output file](#output), and steps 1-6 will be repeated for the next EGG file in the directory.

For more details and examples of common issues, see the [EXAMPLES](EXAMPLES.md) document.

<a name="output"></a>
## Output file format

The output file (named ```egg_out.txt``` by default) is a comma-delimted text file with a header row plus one row per measurement per period per file. Since at present **praatdet** only computes two Oq measures (dEGG and Howard's method), the header looks like

	filename,var1,var2,var3,var4,label,method,period,start,end,f0,Oq

where the ```var1,var2...``` columns represent variables parsed from your filename. The remaining rows of the output file will look like

	dhâlem_iso_1_mis,dhâlem,iso,1,mis,v,degg,1,0.12421257195168106,0.13106735443332038,145.88354957703206,0.7252252298951782
	dhâlem_iso_1_mis,dhâlem,iso,1,mis,v,howard,1,0.12421257195168106,0.13106735443332038,145.88354957703206,0.6982139033791485
	dhâlem_iso_1_mis,dhâlem,iso,1,mis,v,degg,2,0.13106735443332038,0.13806236081289922,142.959126230305,0.6938484647332952
	dhâlem_iso_1_mis,dhâlem,iso,1,mis,v,howard,2,0.13106735443332038,0.13806236081289922,142.959126230305,0.6745684788329395
	
Columns 2-5 contain the delimited information contained in the filename. In this example, these columns contain the word token, the context (isolation), the repetition (1), and the speaker code. The next column contains the TextGrid interval label; if the entire file was processed, this will be empty. Following this is the ```method``` (```degg``` or ```howard```, currently), the period number (starting at 1, relative to the region specified by the interval label), the start and end times of the period and the f0 (as determined from the location of the dEGG closing peaks), and the Oq (as determined by the ```method```).

## Behind the scenes

<a name="peakdet"></a>
### Peak detection

Peak detection proceeds in three strages:

1. First, take the derivative and use this to find closing peaks:

		Formula... self [col+1] - self [col]
		To PointProcess (periodic, peaks)... min max Yes No

    with user-defined min and max. This includes maxima, but not minima, and so finds the closing peaks. These are the most reliable. We could do this on the raw signal or on a smoothed signal; for more on smoothing see [here](#smoothing).

2. Next, try to find the opening peaks:

		To PointProcess (periodic, peaks)... min max No Yes

	For more details of Praat's ```To PointProcess (periodic, peaks)....``` algorithm, see [here](http://www.fon.hum.uva.nl/praat/manual/Sound__To_PointProcess__periodic__peaks____.html).
 
3. These are then combined into a single PointProcess object:

		select PointProcess 'name$'_degg_opening
      	plus PointProcess 'name$'_degg_closing
      	Union

	which is then used to subsequent analysis; this is also the object that is ultimately saved.

<a name="smoothing"></a>
### Smoothing

Both the Lx and dEGG signals can be smoothed by calculating a *linearly weighted symmetric moving average*

![](images/eqn1.png)

where $t_0$ is the time point to be smoothed, $k$ is the number of points preceding and following $t_0$ to be considered ($\propto$ window size), $x_t$ is the amplitude of the waveform at time $t$, and $\alpha_t$ is the weight at time $t$.

The smoothed value for a particular time point $t_0$ is found by multiplying each value $x_t$ in the sequence $t-k \ldots t+k$ by a weight $\alpha_t$ corresponding to its position in the series. The sum of the weighted values $\alpha_{t-k} x_{t-k} \ldots \alpha_{t+k} x_{t+k}$ is then divided by the sum of the weights. For example, if $k=3$ and $t_0$ = 16, the smoothed value $\hat{f}(t_0)$ will be

![](images/eqn2.png)
 
It is possible to efficiently compute these as convolutions but here I just do it the clunky way, constructing an equation like the above based on the user-defined value of $k$.

Both the Lx and dEGG signals are smoothed using the same function with the same window.

<a name="howard"></a>
### Howard's method

Howard's method (encapsulated in the file ```howard.praat```) determines the glottal opening instant by means of a thresholding method.

1. First we delimit the period of interest, for which we use the dEGG signal:

        select PointProcess 'name$'_degg_both
        .period_start = Get time from index... .i
        .period_end = Get time from index... .i+2

2. Then, each period is extracted and normalized:

        Extract part... .period_start .period_end rectangular 1 yes

        # normalize this period
        .min = Get minimum... 0 0 Sinc70
        .max = Get maximum... 0 0 Sinc70
        Formula... (self[col]-.min) / (.max-.min)

3. Next, loop through the sample, setting values below the threshold to zero:

        .nsamp = Get number of samples
        for .k from 1 to .nsamp
            .si = Get value at sample number... eggChan .k
            if .si < threshold
            ## set all values below threshold to zero
                Set value at sample number... 1 .k 0
            endif
        endfor
        
4. The open period will necessarily start at a point following the peak. We can find this by first determining the peak ```.local_max``` and find the time of the ```.first_zero``` that follows it, determine the sample number ```.zero_samp``` corresponding to the preceding timepoint:

        .local_max = Get time of maximum... 0 0 Sinc70
        .first_zero = Get time of minimum... .local_max 0 Sinc70
        
        # back up one sample for maxmimum explicitness
        .zero_samp = Get sample number from time... .first_zero
        .open_start = Get time from sample number... .zero_samp-1
 

## Known issues

- In the Oq plot, the first and last values overlap with the plot border. I'm not sure how to fix this beyond padding the matrices on either end, which means copying the matrices, etc.

- In the Oq plot, the x axis becomes unreadble for large files, and is uninformative for small files, due to the fixed value for distance of ```Marks bottom every...```

- Unlike [peakdet](http://voiceresearch.free.fr/egg/), **praatdet** has nothing intelligent to say about multiple peaks.

- I have tried to encapsulate different components of the script as functions (procedures). Praat does not really have functions, so this is kind of a mess. Note that local variables (e.g. ```.formula$```) are globally available. (I know.)

## References
 
Childers, D. G., Hicks, D. M., Moore, G. P., and Alsaka, Y. A. (**1986**). “A model for vocal fold vibratory motion, contact area, and the electroglottogram,” J. Acous. Soc. Am. 80, 1309–1320.

Childers, D. G., Hicks, D. M., Moore, G. P., Eskenazi, L., and Lalwani, A. L. (**1990**). “Electroglottography and vocal fold physiology,” J. Speech Hear. Res. 33, 245–254.

Henrich N., d'Alessandro C., Castellengo M. and Doval B.. (**2004**). "On the use of the derivative of electroglottographic signals for characterization of nonpathological voice phonation", J. Acous. Soc. Am. 115(3), 1321-1332.

Michaud, A. (**2004**). “Final consonants and glottalization: new perspectives from Hanoi Vietnamese,” Phonetica 61, 119–146.


