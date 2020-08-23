- Currently, the "leave blank for all" design does not work from the shell. Moreover, it's overall a poor design: if you want to look at interval labeled "ons" and interval labeled "nuc" you have to run praatdet twice. 

- Potentially want to allow manual checking even if no periods have been detected in the PointProcess.

- If "use PP from disk" is checked, Praatdet will fail if there is no PP for some files - maybe have a fallback to create if it doesn't exist?

