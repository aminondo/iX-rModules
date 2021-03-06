# =====================================================================================================================
# TIDY TEXT MINING
# =====================================================================================================================

# This tutorial is based on the excellent talk given by Julia Silge (https://www.youtube.com/watch?v=0poJP8WQxew).

library(RCurl)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)

library(gutenbergr)
library(tidytext)

# GET DATA ------------------------------------------------------------------------------------------------------------

# Project Gutenberg [https://www.gutenberg.org/] is a repository of books that are in the public domain.
#
# Using the gutenbergr package it's very simple to access these books.
#
# We'll start with "A Tale of Two Cities" by Charles Dickens [https://www.gutenberg.org/ebooks/98].
#
book <- gutenberg_download(98)
book = gutenberg_download(229)
#
class(book)
head(book)
#
# The text is broken down into a data frame with one line per record. Normally your text data will not be in this
# format.

# Add in line numbers.
#
book <- book %>% mutate(line = 1:nrow(.))

# And since we only have one book we'll drop the identifier column.
#
book <- book %>% select(-gutenberg_id)

# Q. How do we get data into that format? Convert the following text into a similar data frame.
#
text = " Jabberwocky
 LEWIS CARROLL

'Twas brillig, and the slithy toves 
Did gyre and gimble in the wabe: 
All mimsy were the borogoves, 
And the mome raths outgrabe. 

'Beware the Jabberwock, my son! 
The jaws that bite, the claws that catch! 
Beware the Jubjub bird, and shun 
The frumious Bandersnatch!'

He took his vorpal sword in hand; 
Long time the manxome foe he sought— 
So rested he by the Tumtum tree 
And stood awhile in thought. 

And, as in uffish thought he stood, 
The Jabberwock, with eyes of flame, 
Came whiffling through the tulgey wood, 
And burbled as it came! 

One, two! One, two! And through and through 
The vorpal blade went snicker-snack! 
He left it dead, and with its head 
He went galumphing back. 

'And hast thou slain the Jabberwock? 
Come to my arms, my beamish boy! 
O frabjous day! Callooh! Callay!'
He chortled in his joy. 

'Twas brillig, and the slithy toves 
Did gyre and gimble in the wabe: 
All mimsy were the borogoves, 
And the mome raths outgrabe. "

text_df = data.frame( text = str_split(text, "\n")[[1]])

# SPLITTING LINES INTO WORDS ------------------------------------------------------------------------------------------

# The data format is not really what we are looking for though! Sure it's a data frame, but we can't yet do simple
# things like count the number of times a particular word has been used.

# Now we split each line into words.
#
(book_tidy <- book %>% unnest_tokens(word, text))
#
# Now we have one word per row.
#
# A couple of other things have happened in the process:
#
# - text has been converted to lowercase and
# - punctuation has been removed.

# REMOVE STOP WORDS ---------------------------------------------------------------------------------------------------

# Text is dominated by unimportant "stop" words.
#
book_tidy %>% count(word, sort = TRUE)

# A collection of stop words.
# 
stop_words

# Now let's remove them from our data.
#
book_tidy <- book_tidy %>% anti_join(stop_words)

# What remains are the words with real information content!
#
# Q. What's the most common word now?

# Let's make a simple visualisation.
#
book_tidy %>%
  count(word, sort = TRUE) %>%
  filter(n > 130) %>%
  #
  # Change the order of factor levels.
  #
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip()

# SENTIMENT ANALYSIS --------------------------------------------------------------------------------------------------

# Sentiment lexicons.
#
get_sentiments("afinn")
get_sentiments("bing")
get_sentiments("nrc")

# Add sentiment data using an inner join.
#
book_tidy %>% inner_join(get_sentiments("bing")) %>%
  count(sentiment)
#
# That's an indication of overall sentiment.
#
# How does sentiment change through the course of the book? We'll divide the book up into blocks of 100 lines each.
#
sentiment <- book_tidy %>% inner_join(get_sentiments("bing")) %>%
  count(index = line %/% 100, sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  transmute(sentiment = positive - negative)
#
sentiment

#
# Would be easier to make sense of that with a visualisation.
#
ggplot(sentiment, aes(x = index, y = sentiment)) +
  geom_bar(stat = "identity")

# Which words make the strongest contributions to the overall sentiment of the book?
#
book_tidy %>% inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE)

book_tidy %>% inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  group_by(sentiment) %>%
  top_n(15) %>%
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(x = word, y = n, fill = sentiment)) +
  geom_col() +
  facet_wrap(~ sentiment, scales = "free_y") +
  coord_flip() +
  labs(x = "", y = "Sentiment count") +
  theme(legend.position = "none")

# Note: Assessment of sentiment can vary substantially depending on what lexicon you are using!

# MULTIPLE BOOKS ------------------------------------------------------------------------------------------------------

gutenberg_id = c(98, 1400, 4300, 2814, 209, 1093, 829, 1080, 120, 42, 35, 36)

# Let's grab a bunch of books.
#
books <- gutenberg_download(gutenberg_id)
#
books

# Add in columns with title and author.
#
books_details <- data.frame(gutenberg_id = gutenberg_id,
                            author = rep(c("Charles Dickens", "James Joyce", "Henry James", "Jonathan Swift",
                                           "Robert Louis Stevenson", "H. G. Wells"), each = 2),
                            title = c("A Tale of Two Cities", "Great Expectations",
                                      "Ulysses", "Dubliners",
                                      "The Turn of the Screw", "The Beast in the Jungle",
                                      "Gulliver's Travels", "A Modest Proposal",
                                      "Treasure Island", "Strange Case of Dr Jekyll and Mr Hyde",
                                      "The Time Machine", "The War of the Worlds"))

books <- inner_join(books, books_details) %>% select(-gutenberg_id)

# Add in line numbers (per book!).
#
books <- books %>% group_by(title) %>% mutate(line = row_number()) %>% ungroup()

# GET TIDY ------------------------------------------------------------------------------------------------------------

(books_tidy <- books %>% unnest_tokens(word, text))

# REMOVE STOP WORDS ---------------------------------------------------------------------------------------------------

# Q. Remove the stop words from each of the books.
books_tidy <- books_tidy %>% anti_join(stop_words)

# SENTIMENT ANALYSIS --------------------------------------------------------------------------------------------------

# Q. Generate a multi-panel plot which shows the evolution of sentiment thoughout each of the books.
sentiment <- books_tidy %>% inner_join(get_sentiments("bing")) %>%
  count(title,author,index = line %/% 100, sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  transmute(sentiment = positive - negative)
#
View(sentiment)


#
# Would be easier to make sense of that with a visualisation.
#
dubliners = sentiment[sentiment$title=="Dubliners",]

ggplot(sentiment, aes(x = index, y = sentiment, color=title)) +
  geom_bar(stat = "identity") + facet_wrap(~title)




# TERM FREQUENCY / INVERSE DOCUMENT FREQUENCY -------------------------------------------------------------------------

# This part of the analysis only makes sense when you have multiple documents.

# TFIDF is a statistic which can be used to identify words that are common and important in a text but not TOO common!

# Term Frequency
#
books_words <- books_tidy %>% count(title, word, sort = TRUE)
books_words


books_words_totals <- books_words %>% group_by(title) %>% summarise(total = sum(n)) %>% ungroup()
#
books_words <- left_join(books_words, books_words_totals)

# Add in TF, IDF and TFIDF.
#
books_words <- books_words %>% bind_tf_idf(word, title, n)

# Q. Create a multi-panel plot showing histograms of term frequency for each book.

#books_words %>% arrange(desc(tf_idf))

 


books_words[books_words$n>5,] %>% 
  ggplot(aes(x=reorder(word, -n),y=n)) +
  geom_bar(stat="identity", fill="darkred", colour="darkgreen") + facet_wrap(~title)+
  theme(axis.text.x=element_text(angle=45, hjust=1))

# General observations:
#
# - there are a lot of words that are used relatively seldom and
# - a few words which are used very frequently.
#
# IDF = 0 -> this word is present in ALL of the documents.

# Let's flip these data around so that the words with highest TFIDF are at the top.
#
books_words %>% arrange(desc(tf_idf))

# Q. Create a multi-panel plot showing bars plts of words with largest TFIDF for each book.
books_words %>%
  group_by(title) %>%
  top_n(20,tf_idf) %>%
  ungroup() %>%
  mutate(word = reorder(word, tf_idf)) %>%
  ggplot(aes(word, tf_idf,fill = title)) +
  geom_bar(stat = "identity") +  
  facet_wrap(~ title, scales = "free") + theme(axis.text.x = element_blank(),
                                               strip.text.y = element_blank(),
                                               strip.background = element_blank())
