## SearchAndStoreTweets.R
#' This script is intended to:
#'  (1) search Twitter for a keyword or set of keywords
#'  (2) download all matching Tweets
#'  (3) save the output to a SQLite database

# load packages
library(RSQLite)
library(rtweet)
library(lubridate)
library(DBI)

## search string: what will you search twitter for?
# test search strings with the file TestSearchStrings.R to decide
search.text <- "(high water) OR (heavy rain) OR (flash flooding) OR (hail flooding) OR (street flooding) OR (road flooding) OR (urban flooding)"

# search any time period
start_date <- "2019-07-10"
end_date <- "2019-07-13"

# combine text and dates into a string for rtweet
search.str <- paste0(search.text, " since:", as.character(start_date), " until:", as.character(end_date))

# output directory: save to Dropbox, not git repository, so it's automatically backed up
# this is also where authentication info is stored
out.dir <- "C:/Users/rbaird18/Google Drive/CSU/Research/FloodTweeter/"
out.dir2 <- "C:/Users/rbaird18/Google Drive/CSU/Research/FloodTweeter/FloodTweeter_OutputScreen/"

# path to save output data
path.out <- paste0(out.dir, "FloodTweeter_archive.sqlite")
db <- DBI::dbConnect(RSQLite::SQLite(), path.out)  # will be created if doesn't exist

# path to save the screen output
path.sink <- paste0(out.dir2, "FloodTweeterOut_Screen_", start_date, "_", format(Sys.time(), "%H%M"), ".txt")

# read in token which was created with script rtweet_SetUpToken.R
r.token <- readRDS(file.path(out.dir, "twitter_token2.Rds"))

## launch sink file, which will store screen output 
# this is useful when automating, so it can be double-checked later
# to make sure nothing weird happened
s <- file(path.sink, open="wt")
sink(s, type="message")

# status update
print(paste0("starting, from ", start_date, " to ", end_date))

# USA bounding box for search, determined using `lookup_coords("usa")`
usa_coords <- structure(list(place = "usa", box = c(sw.lng = -124.848974, sw.lat = 24.396308, 
                                                    ne.lng = -66.885444, ne.lat = 49.384358), 
                             point = c(lat = 36.89, 
                                       lng = -95.867)), 
                        class = c("coords", "list"))

# search twitter!
tweet_archive <- rtweet::search_fullarchive("flooding",
                                n = 100,
                                env_name = "street_flooding",
                                fromDate = "201907100000",
                                toDate = "201907130000",
                                token=r.token)
                               
                                


# subset to yesterday only, just in case...
#tweet_archive <- subset(tweet_archive, created_at >= start_date & created_at < end_date)

# get rid of duplicates just in case
tweet_archive <- unique(tweet_archive)

# put in order
tweet_archive <- tweet_archive[order(tweet_archive$status_id), ]

# convert dates to character string for database
tweet_archive$created_at <- as.character(tweet_archive$created_at)

## convert columns that are lists to text strings separated by _<>_
# find list columns
cols.list <- which(lapply(tweet_archive, class) == "list")
for (col in cols.list){
  tweet_archive[,col] <- apply(tweet_archive[,col], 1, function(x) as.character(paste(x, collapse="_<>_")))
}

## put into database
# add data frame to database (if it doesn't exist, it will be created)
dbWriteTable(db, "tweet_archive", tweet_archive, append=T)

# when you're done, disconnect from database (this is when the data will be written)
dbDisconnect(db)

# print status update
print(paste0(dim(tweet_archive)[1], " tweets added to database"))

# close sink
close(s)
sink()
sink(type="message")
close(s)

