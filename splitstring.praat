## splitstring.praat

## Parse a string into an "array".
## (adapted from a procedure by Paul Boersma)

procedure splitstring: .string$, .sep$
    .strLen = 0
    repeat
        .sepIndex = index (.string$, .sep$)
        if .sepIndex <> 0
            .value$ = left$ (.string$, .sepIndex - 1)
            .string$ = mid$ (.string$, .sepIndex + 1, 10000)
        else
            .value$ = .string$
        endif
        .strLen = .strLen + 1
        .array$[.strLen] = .value$
    until .sepIndex = 0
endproc
