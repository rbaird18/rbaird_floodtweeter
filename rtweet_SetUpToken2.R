## rtweet_SetUpToken.R
#' This script is intended to set up the token necessary to access the
#' Twitter API, so it does not need to be completed each time.
#' 
#' Tutorial: http://rtweet.info/articles/auth.html

rm(list=ls())

require(rtweet)

## first: create app, get API key and secret from apps.twitter.com

## whatever name you assigned to your created app
appname <- "street_flooding"

## api key
# key <- "AAA"

## api secret
# secret <- "BBB"

## create token named "twitter_token2"
twitter_token2 <- create_token(
  app="street_flooding", 
  consumer_key = "t2pZbvDK0A3HZt5BAaTtN7nAU", 
  consumer_secret = "CvPaR1X2tQWGekOIpnIyFqUi3wGMdqfA9kVv9gquNC5g1ho9WN", 
  access_token = "3072873514-7l7ChkSbIdOp3WFmKts7aZsUTtaVn2FCmy0ULW0",
  access_secret = "6dRPfGarAl71nL0QXjBJz7xaE3txu3Pn7xxk7VMCAPdAV")

# twitter_token <- create_token(
#   app = appname,
#   consumer_key = key,
#   consumer_secret = secret)

# output directory: save to Dropbox, not git repository, so it's automatically backed up
# this is also where authentication info is stored
out.dir <- "C:/Users/rbaird18/Google Drive/CSU/Research/FloodTweeter/"

## combine with name for token
file_name <- file.path(out.dir, "twitter_token2.Rds")

## save token to home directory
saveRDS(twitter_token2, file = file_name)

