library(httr)
mailtest = GET("https://api.mailtest.in/v1/totallyinvaliddomain.com")
http_status(mailtest)
beer = GET("https://api.punkapi.com/v2/beers/1")
beer
#gets content and stores in string

beer_json = content(beer, as="text", encoding="utf-8")
library(jsonlite)
prettify(beer_json) #makes JSON more legible
beer_df = fromJSON(beer_json) #converts to data frame
class(beer_df)
View(beer_df) #notice that some columns are returned as lists, make more sense to get results back as list rather than data frame
beer_list = fromJSON(beer_json, simplifyVector = F)[[1]]
class(beer_list)
beer_list
# =====================================================================================================================
# DATA FROM API EXERCISES
# =====================================================================================================================

# GET REQUESTS --------------------------------------------------------------------------------------------------------

# Sign up at www.quandl.com and get yourself an API key. Enter the key below.
#
QUANDLKEY = NA

# Q. Retrieve the WIKI/FB data as a JSON document. You'll need to send a GET request to a URL that looks something
#    like this:
#
#      https://www.quandl.com/api/v3/datasets/WIKI/FB.json?api_key=QH2odbmPdS3piCMSWNfJ
#
#    - First do this directly in your browser.
#    - Now retrieve the data within R.
#    - Parse the resulting JSON document.
# Q. Generate a plot of the Adjusted Close price versus Date.

# TWITTER PACKAGE -----------------------------------------------------------------------------------------------------

library(twitteR)
library(tm)
library(wordcloud)
library(RColorBrewer)
library(ggmap)

consumer_key = "P1dgY0b1Ghe6OFoBODWspKgcb"
consumer_secret = "Z5UF5fR8EwMsLGQLkK4IsNV6wNg73kWd7rnixv7HRepJaX8gkv"
access_token = "3320318445-DP90vcJ2EPozjVkXoALtzdyklnghTr4hPfWwFsA"
access_secret = "cei83YlJ59rfg07StBVr6ANT6slDW1kyOuGkAq8LRoZFR"
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

# Choose an interesting search term.
#
tweets = searchTwitter("trump", n = 100, lang = "en")

# Extract text
#
twitter.text = sapply(tweets, function(x) x$getText())

# Convert to data frame
#
tweets_df = do.call(rbind, lapply(tweets, function(x) x$toDataFrame()))
View(tweets_df)
# Remove unprintable characters
#
twitter.text= gsub("[^[:print:]]", "", twitter.text)

# Remove URLs
#
twitter.text = gsub("http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+", "", twitter.text)

# Remove truncated text
#
twitter.text = gsub("[^[:space:]]*…$", "", twitter.text)
#a corpus does all the words that are used in all the tweets and consolidates them to make a lannguage
twitter.corpus = Corpus(VectorSource(twitter.text))

# If any of the below commands break with an error that mentions "mclapply" then try adding either
#
#   mc.cores = 1
#
# or
#
#   lazy = TRUE
#
# as additional parameters to the tm_map() call.
#
twitter.corpus <- tm_map(twitter.corpus, stripWhitespace)
twitter.corpus <- tm_map(twitter.corpus, content_transformer(tolower))
twitter.corpus <- tm_map(twitter.corpus, removePunctuation)
twitter.corpus <- tm_map(twitter.corpus, removeNumbers)
#
# Remove frequent terms with low information.
#
twitter.corpus <- tm_map(twitter.corpus, removeWords, c("rt", "comrades", stopwords("english")))

# Create a TDM.
#
twitter.tdm = TermDocumentMatrix(twitter.corpus)

twitter.tdm = as.matrix(twitter.tdm)
twitter.word_freq = sort(rowSums(twitter.tdm), decreasing = TRUE)
twitter.word_freq = data.frame(word = names(twitter.word_freq), freq = twitter.word_freq)

# Create a word cloud. Change the resolution to get a good fit.
#
png("twitter-word-cloud.png", width = 1200, height = 1200, res = 175)
wordcloud(twitter.word_freq$word, twitter.word_freq$freq, random.order = TRUE, colors = rev(brewer.pal(8, "Dark2")),
          min.freq = 2)
dev.off()
#
# That's a little plain.
#
# Try https://github.com/Lchiffon/wordcloud2 for more exciting word clouds.

# Looking at users.
#
crantastic <- getUser('crantastic')
#
# Location.
#
crantastic$location
geocode(crantastic$location)

# =====================================================================================================================
# DATA FROM API SOLUTIONS
# =====================================================================================================================

# GET REQUESTS --------------------------------------------------------------------------------------------------------

# This is the "long and hard" way to get these data. There are definitely easier and quicker ways to do this, but the
# idea with the code below is to illustrate a number of useful steps along the way.

URL = sprintf("https://www.quandl.com/api/v3/datasets/WIKI/FB.json?api_key=%s", QUANDLKEY)

library(httr)

facebook <- GET(URL)
#
# Check status of HTTP request.
#
http_status(facebook)
#
# Look at the JSON contents of the response.
#
content(facebook, as = "text")
#
# Parse the JSON.
#
library(jsonlite)
facebook <- fromJSON(content(facebook, as = "text"))
#
names(facebook$dataset)
#
facebook.data <- data.frame(facebook$dataset$data, stringsAsFactors = FALSE)
colnames(facebook.data) <- gsub("[\\. -]", "", facebook$dataset$column_names)
#
facebook.data = transform(facebook.data,
                          Date = as.Date(Date),
                          AdjClose = as.numeric(AdjClose)
                          )
#
library(ggplot2)
#
ggplot(facebook.data, aes(x = Date, y = AdjClose)) + geom_line()