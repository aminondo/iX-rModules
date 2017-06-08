library(rvest)
library(dplyr)
library(reshape2)
library(ggplot2)
# ---------------------------------------------------------------------------------------------------------------------
# WORLD UNIVERSITY RANKINGS
# ---------------------------------------------------------------------------------------------------------------------

# We'll start by scraping World University Rankings from http://cwur.org/2015/.

rankings <- read_html("http://cwur.org/2015.php") %>% html_nodes("table") %>% .[[1]] %>% html_table(trim = TRUE)
rankings <- read_html("http://cwur.org/2015.php") %>% html_node("table") %>% html_table(trim = TRUE)
rankings <- read_html("http://cwur.org/2015.php") %>% html_node("body > div > div.row > div > div > table") %>% html_table(trim = TRUE)

#body > div > div.row > div > div > table
# Q. Use the browser to get a more specific CSS selector for this table.
#right click element > copy > select css selector
# Q. Is the .[[1]] necessary?
#no you can use html_node instead

# Clean up the column names.

names(rankings)

library(stringr)

names(rankings) <- str_replace_all(names(rankings), "[/[:space:]]", "")


# Use filter() to find the ranking of your university.
rankings[rankings$Institution=="University of Notre Dame",]$WorldRank
filter(rankings, grepl("University of Notre Dame", Institution))

# ---------------------------------------------------------------------------------------------------------------------
# POPULAR R JOBS
# ---------------------------------------------------------------------------------------------------------------------

# Extract the text and links from the Popular Jobs Today section at http://www.r-users.com/.

rusers <- read_html("http://www.r-users.com/")

# METHOD 1

# Grab the <li> nodes. #top_listings-2 > div.widget_content > ul
#
rusers.li <- html_nodes(rusers, xpath = '//*[@id="top_listings-2"]/div[2]/ul/li')
rusers.li <- html_nodes(rusers, '#top_listings-2 > div.widget_content > ul > li')

# Grab the child nodes (could have done this directly with more specific XPath above).
#
rusers.a <- html_children(rusers.li)

# METHOD 2

rusers.a <- html_nodes(rusers, xpath = '//*[@id="top_listings-2"]/div[2]/ul/li/a')

html_attr(rusers.a, name = "href")
html_text(rusers.a)


#create data frame
job_data = data.frame(job = html_text(rusers.a), desc = html_attr(rusers.a, name = "href"))
# =====================================================================================================================
# SCRAPING EXERCISES
# =====================================================================================================================

# ---------------------------------------------------------------------------------------------------------------------
# CAPE TOWN
# ---------------------------------------------------------------------------------------------------------------------

# Get the Climate data for Cape Town from Cape Town's Wikipedia entry.
#
# Format these data like this:
#
#      Average high °C Average low °C Daily mean °C Record high °C Record low °C
# Jan             26.1           15.7          20.4           39.3           7.4
# Feb             26.5           15.6          20.4           38.3           6.4
# Mar             25.4           14.2          19.2           42.4           4.6
# Apr             23.0           11.9          16.9           38.6           2.4
# May             20.3            9.4          14.4           33.5           0.9
# Jun             18.1            7.8          12.5           29.8          −1.2
# Jul             17.5            7.0          11.9          29.02          −4.3
# Aug             17.8            7.5          12.4           32.0          −0.4
# Sep             19.2            8.7          13.7           33.1           0.2
# Oct             21.3           10.6          15.6           37.2           1.0
# Nov             23.5           13.2          17.9           39.9           3.9
# Dec             24.9           14.9          19.5           41.4           6.2
# Year            22.0           11.4          16.2           42.4          −4.3

# ---------------------------------------------------------------------------------------------------------------------
# BASEBALL BIRTHDAYS
# ---------------------------------------------------------------------------------------------------------------------

# According to Malcolm Gladwell in "Outliers":
#
# "The cutoff date for almost all nonschool baseball leagues in the United States
# is July 31, with the result that more major league players are born in August
# than in any other month."

# Birthdays for Baseball Players can be scraped from http://www.baseball-reference.com/.
#
# For example, http://www.baseball-reference.com/friv/birthdays.cgi?month=6&day=16 is list of players born on 16 June.
#
# Scrape data for every day of the year and use this to check whether there is evidence to suggest that these dates
# are not uniformly distributed across the year.


days = c(31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
year = lapply(1:12, function(m){
          lapply(1:days[m], function(d){
            if(d%%5==0) {Sys.sleep(5)}
            url = sprintf("http://www.baseball-reference.com/friv/birthdays.cgi?month=%d&day=%d",m,d)
            tb1 = read_html(url) %>% html_node("table") %>% html_table(trim=T) %>% plyr::mutate(month = m, day = d)
            #print(sprintf('month:%d day:%d',m,d))
            })
      })
#right now data is a list of months, that each contain a list of days, that each contain a dataframe
temp = unlist(year, recursive=F) #this will give me a list of days
temp = do.call(rbind, temp) #this will merge each day's dataframe
write.csv(temp,file="baseball.csv")

temp$month = factor(temp$month, labels=month.abb)

ggplot(temp, aes(x = month)) + geom_bar() +
  labs(x = "", y = "Count", title = "Major League Baseball Birthdays") +
  theme_classic()



jan = lapply(1:31, function(d){
  if(d==15) {Sys.sleep(10)}
  url = sprintf("http://www.baseball-reference.com/friv/birthdays.cgi?month=01&day=%d",d)
  tb1 = read_html(url) %>% html_node("table") %>% html_table(trim=T) %>% plyr::mutate(month = 1, day = d)
})
jan = do.call(rbind,jan)


# =====================================================================================================================
# SCRAPING SOLUTIONS
# =====================================================================================================================

# ---------------------------------------------------------------------------------------------------------------------
# CAPE TOWN
# ---------------------------------------------------------------------------------------------------------------------

cape.town <- read_html("https://en.wikipedia.org/wiki/Cape_Town")

weather <- html_nodes(cape.town, "table") %>% .[[3]] %>% html_table()

colnames(weather) <- weather[1,]
weather <- weather[-1,]
#
weather <- weather[-10,]

weather <- melt(weather, id.vars = "Month")
#
weather <- mutate(weather,
                  Month = sub(" \\((°F|inches)\\)", "", Month),
                  value = sub(",", "", sub("\n.*$", "", weather$value))
                  )
#
weather <- dcast(weather, variable ~ Month)
#
rownames(weather) <- weather$variable

weather <- select(weather, ends_with("C"))

# ---------------------------------------------------------------------------------------------------------------------
# BASEBALL BIRTHDAYS
# ---------------------------------------------------------------------------------------------------------------------

month <- data.frame(month = 1:12, length = c(31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31))

baseball <- with(month,
     lapply(1:12, function(m) {
       lapply(1:length[m], function(d) {
         URL = sprintf("http://www.baseball-reference.com/friv/birthdays.cgi?month=%d&day=%d", m, d)
         baseball = read_html(URL) %>% html_nodes("table") %>%
           .[[1]] %>% html_table() %>%
           .[,names(.) != ""] %>% mutate(month = m, day = d)
       })
     })
)
baseball = unlist(baseball, recursive = FALSE)
baseball = do.call(rbind, baseball)
#
baseball = mutate(baseball,
                  month = factor(month, labels = month.abb)
                  )

ggplot(temp, aes(x = month)) +
  geom_bar(fill = "#A8DDB5", col = "#4DA664") +
  labs(x = "", y = "Count", title = "Major League Baseball Birthdays") +
  theme_classic()

# Is the difference statistically significant?
#
# * Naive approach
#
chisq.test(table(baseball$month))
#
# * Better approach (taking into account days in each month)
#
chisq.test(table(baseball$month), p = month$length / sum(month$length))
