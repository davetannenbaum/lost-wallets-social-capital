### Code and Data for "What Do Cross-Country Surveys Tell Us About Social Capital?"

Code and data to reproduce all results and graphs reported in Tannenbaum et al. (2022). This folder contains data files (`.dta` files) and a Stata do-file (`code.do`) that stitches together the different data files and executes all analyses and produces all figures reported in the paper.

The do-file includes a number of user-written packages, which are listed below. Most of these can be installed using the `ssc install` command in Stata. Also, users will need to change the current directory path (at the start of the do-file) before executing the code.

Package name 	| Description
----|---------
`revrs` 		| reverse-codes variable
`ereplace` 		| extends the `egen` command to permit replacing
`grstyle`		| changes the settings for the overall look of graphs 
`spmap`			| used for graphing spatial data
`qqvalue`		| used for obtaining Benjamini-Hochberg corrected p-values
`parmby`		| creates a dataset by calling an estimation command for each by-group
`domin`			| used to perform dominance analyses
`coefplot`		| used for creating coefficient plots
`grc1leg`		| combine graphs with a single common legend
`xframeappend`	| append data frames to the end of the current data frame

