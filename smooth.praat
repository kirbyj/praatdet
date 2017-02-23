## smooth.praat: computes weighted symmetrical moving average

## James Kirby <j.kirby@ed.ac.uk>
## 4 Jan 2017

## This script is released under the ?? license

## This basically constructs a Praat Formula... that works for moving window 
## averages of arbitrary length, to avoid having to manually average and 
## weight e.g. 1*( (i-10)+(i+10) ) + 2*( (i-9) + (i+9) ) + ... etc.

procedure smooth: .wS

    ## wS = window size = number of points on either side of point of interest to be taken into account
    ## slightly confusing but so too is allowing the user to specify the size of the window itself; 
    ## what does an even (=asymmetric) window size mean?
    
    # multipler of current value: wS+1
    .nMult = .wS+1

    # denominator: sum of weights
    .denom = .wS+1
    for i from 1 to .wS
        .denom = .denom + 2*i
    endfor

    # construct formula
    .formula$ = "(" + string$(.nMult) + " * self [col]"
    j = .wS
    while j > 0
        .formula$ = .formula$ + " + " + string$(j) + " * (self [col - " + string$(.nMult-j) + "] + self [col + " + string$(.nMult-j) + "])"
        j = j - 1 
    endwhile
    .formula$ = .formula$ + " ) / " + string$(.denom)

     # to access in main script body: use smooth.formula$
endproc

