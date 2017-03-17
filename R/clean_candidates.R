library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
  
votes <- function(acol){
  acol <- trimws(acol)
  
  #make numbers numbers
  acol <- gsub(",", "", acol)
  
  str_extract(acol, "[0-9]+") %>%
    sapply(function(x) ifelse(is.na(x), 0, x)) %>%
    as.numeric
}

candidates <- function(acol){
  acol <- trimws(acol)
  
  #clean the column
  acol_names <- acol %>% 
    str_replace(",", "") %>%
    str_replace("[0-9]+", "")%>% 
    str_replace("\\(I\\)", "")%>% 
    str_replace("\\:", "") %>%
    str_replace_na("No candidate") %>% 
    str_trim
    
  acol_names
}

#take a filename and make id info from it
make_id_info <- function(file_name, district){
  #State	Body	District	NextRace	Term
  state <- str_replace(file_name, "_(.)*", "") %>%
    str_to_title
  
  body <- str_replace(file_name, "(.*)_(.*)_(.)*", "\\2") %>%
    str_to_title
  
  yr =  as.numeric(str_extract(file_name, "[0-9]+"))
  
  data.frame(State = state, Body = body,
             District = district, Year = yr, Term = NA)
}
  
#### OK, let's get mutating to make a tidy data frame
clean_election_data  <- function(eData){
  clean_eData <- eData %>%
    gather(Party, Value, -District) %>%
    mutate(Candidate = candidates(Value),
           Votes = votes((Value))) %>%
    select(-Value)
  
  clean_eData
}

#### Make data in the  State Leg format
#State	Body	District	NextRace	Term	Name	Party	Prvote	Propvote	PrMargin	3PVote
make_leg_eData <- function(clean_eData){
leg_eData <- clean_eData %>% 
  group_by(District) %>%
  summarize(Name = Candidate[which.max(Votes)],
            Prvote = max(Votes),
            Propvote = sum(Votes) - Prvote - sum(Votes[which(Party=="Other")]),
            PrMargin = ifelse(sum(Votes)==Prvote, "Unopposed", 
                              paste0(100*round((Prvote-Propvote)/sum(Votes),4), "%")),
            ThreePVote = sum(Votes[which(Party=="Other")]),
            Party = Party[which.max(Votes)]) %>% 
  ungroup() %>%
  select(District, Party, Prvote, Propvote, PrMargin, ThreePVote)

leg_eData
}

#Master function to read in a file and output voter info file
make_votes <- function(file_name,
                       input_dir = "../raw_data/",
                       output_dir = "../clean_data/"){
  #  file_name = "alaska_house_2016.xlsx"
  #read in the file
  eData <- read_excel(paste0(input_dir, file_name))
  names(eData) <- str_trim(names(eData))
  
  #multiple other problem
  eData <- eData %>% fill(District, .direction="down")
  
  #clean it up
  clean_eData <- clean_election_data(eData)
  
  #Put it in the State Leg Project format
  leg_eData <- make_leg_eData(clean_eData)
  
  #make the identifying info based on the file name
  id_info <- make_id_info(file_name, leg_eData$District)
  
  leg_eData_combined <- cbind(id_info, leg_eData %>% select(-District))
  
  #write it out
  write.csv(leg_eData_combined,
            file = paste0(output_dir, gsub("xlsx", "csv", file_name)),
            row.names=FALSE)
  
  #return it
  return(leg_eData_combined)
}


## TEST
#file_name = "alaska_house_2016.xlsx"
#make_votes(file_name)
