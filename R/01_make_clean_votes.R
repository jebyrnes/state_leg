#Load up the relevant functions, libraries, etc.
source("./clean_candidates.R")

#What are the files
files <- list.files("../raw_data/")


#Loop over all files and make some output
#storing the results in an object for funsies (can not do this if you
#do not want)

#AK, AR, CA, IN

vote_tally <- lapply(files, make_votes)
