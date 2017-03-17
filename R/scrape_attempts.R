install.packages("htmltab")

library(XML)
library(RCurl)
library(httr)

url <- "http://en.wikipedia.org/wiki/Brazil_national_football_team"
url <- "https://ballotpedia.org/Alaska_House_of_Representatives_elections,_2006"
url <- "https://ballotpedia.org/Alaska_State_Senate_elections,_2016"

tabs_data <- GET(url)
tabs <- readHTMLTable(rawToChar(tabs_data$content), stringsAsFactors = F)

n.rows <- unlist(lapply(tabs, function(t) dim(t)[1]))



library(htmltab)
tabs <- htmltab(doc = rawToChar(tabs_data$content), which = "//th[text() = 'List_of_candidates']/ancestor::table")
tabs <- htmltab(doc = theurl, which = "//th[text() = 'Ability']/ancestor::table")
head(tabs)
