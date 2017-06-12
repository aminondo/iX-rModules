# =====================================================================================================================
# WRANGLING EXERCISES
# =====================================================================================================================

# Where applicable, try to use both reshape2 and tidyr to complete the exercises below.

# Exercise 1 ----------------------------------------------------------------------------------------------------------

# 1. Use the Quandl package to grab the following data: WIKI/AAPL, WIKI/GOOGL and WIKI/EBAY.
library(Quandl)
library(dplyr)

Quandl.api_key("gGxxNWEPU_JrHvx4Jsxz")
fin = c("WIKI/AAPL","WIKI/GOOGL","WIKI/EBAY")
ticker = c("AAPL", "GOOGL", "EBAY")
stocks = lapply(fin, function(f){
  Quandl(f)})


# 2. Discard all columns except Date and "Adj. Close". You might need to use `Adj. Close` to index that column.
stk =  lapply(stocks, function(s){
  select(s,`Date`,`Adj. Close`)
})

#names(stk) = fin #rename indexes to tickers
# 3. Rename the "Adj. Close" column using the ticker name.
names(stk[[1]])[2] = "AAPL"
names(stk[[2]])[2] = "GOOGL"
names(stk[[3]])[2] = "EBAY"
#OR
stk$AAPL = rename(stk$AAPL, AAPL = `Adj. Close`)
stk$GOOGL = rename(stk$GOOGL, GOOGL = `Adj. Close`)
stk$EBAY = rename(stk$EBAY, EBAY = `Adj. Close`)
# 4. Merge these data into a single data frame. Assign this to variable stocks. Make sure that **all** data are
#    included!
tot_stk = merge(merge(stk[[1]],stk[[2]], all=T),stk[[3]])
# 5. Are these data tidy? Why?
#  NOOO, cols 2-4 all represent price
library(tidyr)
tot_stk_tidy = gather(tot_stk, ticker, close_price, -Date )

ggplot(tot_stk_tidy, aes(x = Date, y = close_price, color=ticker)) + geom_line()
# Exercise 2 ----------------------------------------------------------------------------------------------------------

# 1. Think about how you would calculate the average adjusted closing price of each stock broken down by year and month
#    with the data in the current format.
# 2. Think about how the data might be transformed to make this easier.

# Exercise 3 ----------------------------------------------------------------------------------------------------------

# 1. Convert stocks into a long (and tidy) format. Choose suitable column names.
# 2. Calculate the monthly average adjusted closing price of each stock broken down by year and month.

# Exercise 4 ----------------------------------------------------------------------------------------------------------

# 1. Calculate the annual maximum monthly average adjusted closing price of each stock. For clarity, this is the
#    maximum value achieved for each monthly average calculated above, broken down by year.
# 2. Create a faceted plot showing the average adjusted closing price of each stock versus year.

# Exercise 5 ----------------------------------------------------------------------------------------------------------

# 1. Convert the annual maximum monthly average adjusted closing price data into wide format. Retain only years from
#    2005 and later. The data should look something like this:
#
#      Ticker     2005    2006    2007    2008    2009    2010    2011    2012    2013    2014    2015    2016
#    1   AAPL   9.6005  11.371  25.052  24.296  26.342  42.276  52.236  90.010  76.120 110.051 126.076 106.088
#    2  GOOGL 209.4760 242.816 347.699 305.905 299.645 301.005 313.669 363.028 542.175 595.088 771.040 756.592
#    3   EBAY  48.6430  44.886  38.004  31.485  24.021  30.342  33.281  51.333  55.794  57.261  61.134  25.741

# =====================================================================================================================
# WRANGLING SOLUTIONS
# =====================================================================================================================

# Exercise 1 ----------------------------------------------------------------------------------------------------------

library(Quandl)
library(dplyr)
library(lubridate)
library(reshape2)
library(tidyr)

AAPL  <- Quandl("WIKI/AAPL")
GOOGL <- Quandl("WIKI/GOOGL")
EBAY  <- Quandl("WIKI/EBAY")

AAPL  <- select(AAPL, Date, AAPL = `Adj. Close`)
GOOGL <- select(GOOGL, Date, GOOGL = `Adj. Close`)
EBAY  <- select(EBAY, Date, EBAY = `Adj. Close`)

stocks <- merge(merge(AAPL, GOOGL, all = TRUE), EBAY, all = TRUE)

# Exercise 2 ----------------------------------------------------------------------------------------------------------

stocks <- mutate(stocks, Year = year(Date), Month = month(Date))
tapply(stocks$AAPL, list(stocks$Year, stocks$Month), mean)
#
# But that is just for a single stock and the results are messy (as opposed to tidy!).

stocks <- select(stocks, -Year, -Month)

# Exercise 3 ----------------------------------------------------------------------------------------------------------

# Using reshape2.
#
stocks.long <- melt(stocks, id.vars = "Date", variable.name = "Ticker", value.name = "AdjClose")

# Using tidyr.
#
stocks.long <- stocks %>% gather(Ticker, AdjClose, -Date)

stocks.monthly <- mutate(stocks.long, Year = year(Date), Month = month(Date)) %>% group_by(Year, Month, Ticker) %>%
  summarise(AvgAdjClose = mean(AdjClose, na.rm = TRUE))

# Exercise 4 ----------------------------------------------------------------------------------------------------------

stocks.annual <- group_by(stocks.monthly, Year, Ticker) %>% summarise(MaxAvgAdjClose = max(AvgAdjClose, na.rm = TRUE))

ggplot(stocks.annual, aes(x = Year, y = MaxAvgAdjClose)) +
  geom_line() +
  facet_wrap(~Ticker, ncol = 1, scales = "free_y") +
  theme_classic()

# Exercise 5 ----------------------------------------------------------------------------------------------------------

# Using reshape2.
#
filter(stocks.annual, Year >= 2005) %>% dcast(Ticker ~ Year)

# Using tidyr.
#
filter(stocks.annual, Year >= 2005) %>% spread(Year, MaxAvgAdjClose)
