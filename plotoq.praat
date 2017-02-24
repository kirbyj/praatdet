## plotoq.praat: plot Oq by period for dEGG and Howard methods

## James Kirby <j.kirby@ed.ac.uk>
## 4 Jan 2017

## Note that if you see periods plotted starting at 0, something is wrong

procedure plotoq: .plotName$

    Erase all
    
    Solid line
    12
    
    # scatterplots
    Select outer viewport: 0, 6, 0, 4

    select Matrix 'name$'_degg
    Red
    Scatter plot: 1, 5, 0, 0, 0, 1, 2, "+", "no"

    select Matrix 'name$'_howard
    Blue
    Scatter plot: 1, 5, 0, 0, 0, 1, 2, "+", "no"

    # axes
    Marks left: 6, "yes", "yes", "no"
    Marks bottom every: 1, 5, "yes", "yes", "no"
    Text left: "yes", "OQ"
    Text bottom: "yes", "period"
    Text top: "no", "'.plotName$'"

    # border
    Black
    Draw inner box

    # legend
    10
    Red
    Text: (nb_periods/10), "Left", 0.125, "Half", "+  dEGG" 

    Blue
    Text: nb_periods - (nb_periods/10), "Right", 0.125, "Half", "+  Howard" 

endproc

