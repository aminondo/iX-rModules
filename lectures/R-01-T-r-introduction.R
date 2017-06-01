# =====================================================================================================================
# INTRODUCTION TO R
# =====================================================================================================================

# R as a Scientific Calculator ----------------------------------------------------------------------------------------



# Q. Calculate the length of the hypotenuse of a triangle with perpendicular sides of length 7 and 17.

sqrt(7^2+17^2)

# Getting Help --------------------------------------------------------------------------------------------------------

# 1. You can access help using the `?` operator or `help()` function.

?lm
?'['
help("lm")

# 2. If you don't know what function you're after, using the `??` operator or `help.search()` to search the documentation.

??linear
??'linear'
help.search("linear model")

# 3. Within RStudio you can simply use the Help tab.
# 4. Stack Overflow (http://stackoverflow.com/questions/tagged/r).
#
# If you post a question on SO, ensure that you always:
#
#   - have a reproducible example;
#   - tag it with [r] as well as any other relevant tags; and
#   - have details of your working environment.

devtools::session_info()

# 5. Task Views
#
# Task Views break the myriad packages down by application domain. Look at https://cran.r-project.org/web/views/.

# Installing from CRAN ------------------------------------------------------------------------------------------------

# § Installing from CRAN

install.packages(c("stringr", "devtools"))

# Once installed the package is loaded into the interpreter using library() or require().
# in scripts load libraries first. good practice
library(stringr)

# Ways of getting help on a particular package:

help(package = "stringr")
library(help = "stringr")

# Q. Install and load the MASS package.
install.packages("MASS")

# Installing from GitHub ----------------------------------------------------------------------------------------------

# Install the ggplot2 package from https://github.com/hadley/ggplot2.
#
devtools::install_github("hadley/ggplot2")

# Q. Install the roxygen package from GitHub.

devtools::install_github("klutometis/roxygen")
# Variables -----------------------------------------------------------------------------------------------------------

# Assignment operator.
#
x <- 3
y = "Hello World!"

class(x)
class(y)

# Assign with echo.
#
(x <- 5)

# Variables are dynamically typed.
#
#static vs dynamic
#compiler - computer does processing, very very fast
#interpreter - no compiler no processing from our code to machine language, a little bit slower

x <- "foo"
class(x)

# Q. Create variables to store your first name, surname, height, gender and birth date.

first_name = "Antonio"
surname = "Minondo"
height_cm = 177
gender = "M"
birth_date = "23/06/1994"


# Q. Use ls() to list these variables.
ls()
# Q. Create a variable p with value 7. Delete p.
#variable names: instrinsic meaning
(p = 7)
rm(p)

# Type: Numeric -------------------------------------------------------------------------------------------------------

# R caters for integer, real or "numeric" (double precision floating point) and complex numbers.
#
# By default numbers are treated as real.

class(3)
class(3L) #L makes it an integer

# There are functions for creating and testing for integers.

as.integer(3.5)
is.integer(3L)



# There are analogous functions, as.numeric() and is.numeric(), for numerics and the same applies for most other data
# types.

# Q. Convert your height variable to metres.
(height_m = height_cm/100)
# Q. Find the data type for height. Try out class(), is.integer() and is.numeric().
class(height_m)
# Type: Logical -------------------------------------------------------------------------------------------------------

3 > 1
6 == 9

# Abbreviated versions.
#
T
F

# Q. Create a new logical variable, tall, which depends on whether or not you are taller than 1.85 m.
tall = height_m > 1.85

# Type: Character -----------------------------------------------------------------------------------------------------

# Strings are enclosed between either single or double quotation marks.

"This is a string"
name <- "John Smith"
class(name)

# There are a number of built-in functions for working with strings.

nchar(name)
substr(name, 1, 4)
paste("foo", "bar")
strsplit("foo bar", split = " ")
sprintf("I'm %s and I'm %d years old.", name, 23)

# The stringr package provides an alternative sets of functions for string manipulation.

# Q. Create a new variable, full_name, from your first name and surname.
full_name = paste(first_name, surname)
full_name = str_c(first_name, surname, sep=" ")
# Type: Dates and Times -----------------------------------------------------------------------------------------------

# There are a few types for handling date and time data:
# 
#   - POSIXlt,
#   - POSIXct and
#   - Date.

# Let's start by looking at `Date`.

today <- Sys.Date()
today - as.Date("1972-06-16") #subtraction

# The main difference between POSIXlt and POSIXct is their underlying representation:
#
#   - POSIXct (ct = compact type) - compact;
#   - POSIXlt (lt = long type)    - more informative representation.
#
# The as.POSIXlt() and as.POSIXct() functions convert between these types.

class(today)

today.ct <- as.POSIXct(today)
as.integer(today.ct)

today.lt <- as.POSIXlt(today)
unclass(today.lt)

# Parsing and formatting of time values are done with `strptime()` and `strftime()`.

# The `lubridate` package implements a powerful set of functions for dealing with imes.

# Q. Format today's date like "13 April 2017".
strftime(today, "%d %B %Y")
# Q. Parse "13/04/17 14h35" and convert to POSIXct.
time = strptime("13/04/17 14h35", "%d/%m/%y %Hh%M")
time = as.data.frame.POSIXct(time)
# Q. Calculate your age in days.
birth_date = "23/06/1994"
birth_date = strptime(birth_date, "%d/%m/%Y")
birth_date = as.Date(birth_date)
today - birth_date


# Type: Vectors -------------------------------------------------------------------------------------------------------

# Vectors are formed using the c() function (c = "concatenate").

x <- c(1, 1, 2, 3, 5, 8, 13, 21)

# Elements of a vector are referred to using the [] operator. The first element in a vector has index 1.

x[4]
x[9] = 34
(x = c(x, 55))
length(x)

# One vector can be used to index into another vector.

x[c(1, 3, 5, 7)]

# A vector can only contain elements of a single type. If not then they are coerced to the most general type.

(y <- c("John", 63, FALSE))

# Elements of a vector can be named.

c(one  = 1, two = 2, three = 3)

# § Missing Data

# Missing elements in a vector are denoted by NA.

x[3] = NA
x

# The is.na() function tests for missing values.

# Q. Use is.na() to fill in the missing value in x.
x[is.na(x)] = 0

# § Regular Sequences

# The : operator is used to generate regular sequences.

4:6

# These sequences can be used to index vectors.

x[4:6]

# A more flexible method to generate a sequence is provided by the `seq()` family of functions.

seq(-4,  length.out = 9)
seq(0, 10, 2)
seq(as.Date("2016/06/01"), as.Date("2016/07/01"), by = "week")

# § Repetition

# One commonly needs to build a vector by repeating a particular value a number of times.

rep(0, 5)

# If the first argument is a vector then there are two possible behaviours.

rep(1:3, 5)
rep(1:3, each = 5)

# § Unique Values and Sorting

# Use unique() to extract the distinct values from a vector.

unique(c(3, 2, 2, 2, 2, 3, 1, 1, 2, 3))

# Use sort() to impose order.

heights <- c(178.5, 170.8, 190.6, 192, 164.7, 168.7, 167.1, 186.4, 174.4, 175.2)
sort(heights)

# Whereas order() will give the indices for sorting the data.

order(heights)

# Both sort() and order() have a 'decreasing' parameter which allows you to reverse the sense of the sort.


# Q. Use order() to sort heights in descending order.

order(heights, decreasing=T)
# § Vectors of Logical

# Many operations in R are vectorised. When comparison operators are applied to a vector, the result is a vector of
# logical type.

x > 5

# The functions all() and any() can be used to check whether all or at least one of the elements in a logical vector is
# TRUE.

all(x > 5)
any(x > 5)

# The which() function returns the indices of the TRUE elements in a vector.

which(c(T, F, T, F, T))

# Logical vectors can also be used as indexes into other vectors.
x[c(T, T, F, F, T, T, F, F, T, T)]

# Logical vectors can be combined using the vectorised forms of the logical operators, `&` and `|`.

c(T, T, F) & c(T, F, T)
c(T, T, F) | c(T, F, T)

# Q. Create a vector which holds integers from 0 to 100.
seq(0, length.out = 101)
seq(0, 100)
# Q. Create a vector which holds odd integers between 0 and 100.
seq(1,100,2)
# Q. Create a vector which holds 50 repetitions of the number 5.
rep(5,50)
# Q. Create a vector which has 5 repeats of the items "red", "green" and "blue".
rep(c("red","green","blue"), each=5)
# Q. Create a vector with the first 10 elements of the Fibonacci Sequence.
fib = c(0,1)
for( i in 3:10) {
  fib[i] = fib[i-1]+fib[i-2]
}
# Q. Extract the seventh element of the sequence.
fib[7]
# Q. Extract the odd numbers from the sequence.
fib[fib%%2==1]
# Q. Find the inner product of these two vectors: [1, 3, 2] and [-1, 5, 1]
x = c(1,3,2)
y = c(-1,5,1)
z = c(x[1]*y[1], x[2]*y[2], x[3]*y[3])


#odd index in fib
fib[rep(c(F,T),5)]
fib[seq(from=2,to=10,2)]
# Type: Matrices ------------------------------------------------------------------------------------------------------

matrix(1:9, ncol = 3)

# Q. Create the following matrix:
#
#  1 0 1 0 1
#  0 1 0 1 0
#  1 0 1 0 1
#  0 1 0 1 0

matrix(rep(c(1,0),10),ncol=5, byrow =TRUE)
# Type: Factors -------------------------------------------------------------------------------------------------------

# Factors are used represent categorical data.

factor(c("R", "G", "R", "G", "G", "G"), levels = c("R", "G", "B"))
colours <- factor(c("R", "G", "R", "G", "G", "G"), levels = c("R", "G", "B"), labels = c("Red", "Green", "Blue"))

# The categories captured by a factor variable can be accessed via levels().

levels(colours)

# Factors are really a specialised form of integer vector. Each level of a factor corresponds to an integer value.
#
as.integer(colours) #casting as integer
#
# A factor is rather efficient because it stores these integer values rather than the string labels.

# A factor can also be used to represent categorical data where there is an ordinal relationship between the categories.

factor(c("S", "L", "XL", "M", "XL", "S"), levels = c("S", "M", "L", "XL"), ordered = TRUE)

# Numerical variables can be transformed into factors using `cut()`.

cut(heights, breaks = c(60, 165, 180, 240), labels = c("short", "regular", "tall"))

# Q. Convert your gender variable to a factor.
factor(gender, levels= c("M", "F"))
# Q. Label the levels in the gender data 'Male' and 'Female'.
factor(gender, levels= c("M", "F"), labels= c("Male", "Female"))
# Type: Lists ---------------------------------------------------------------------------------------------------------

# Lists are a generalisation of the vector in which the elements need not be of the same type.
#data frames
# In fact, elements of a list can have arbitrary type (they can even be other lists).

(stuff <- list(numbers = 1:5, names = c("Bob", "Mary", "Alice"), pi = 22 / 7))

# There are a variety of ways to index the elements of a list.

stuff$names
stuff["numbers"]
stuff[["numbers"]] #actually returns value

stuff[[2]][1:2]
stuff[[2:3]]
c(stuff[[1]][3], stuff[[2]][2])

(pi_list = stuff[3]); class(pi_list)
class(stuff$numbers)
(pi_numeric = stuff[[3]]); class(pi_numeric)

# Note the subtle difference between the results of the `[[]]` and `[]` operators: the former returns a item from the
# list and the latter returns a portion of the list (but as a list!).

# A list is a convenient structure to use for returning multiple values from a function.

rversion = R.Version()
class(rversion)

# We can find the labels for the various elements in the list using the `names()` function.

names(rversion)
rversion$nickname

# Q. Package up all of your personal information in a list.
my_info = list(first_name=first_name,surname=surname,height=height_cm, gender=gender, date=birth_date)

# Type: Data Frames ---------------------------------------------------------------------------------------------------

# Data frames represent data in tabular form.

# Many sets of data come along with R and the majority of them are stored as data frames.

class(airquality)

head(airquality)
tail(airquality, n = 10)

# We can build our own data frame using the `data.frame()` function.

folk <- data.frame(index = 1:3,
                   name = c("Bob", "Mary", "Alice"),
                   age = c(43, 25, 31),
                   height = c(1.82, 1.75, 1.77))
folk

# We can query the dimensions of the data frame and also find the names of the columns.

dim(folk)
nrow(folk)
ncol(folk)
names(folk)

# Columns are accessed using the `$` operator (a data frame is actually just a glorified list).

folk$names

# The [] operator can also be applied to a data frame to access columns, rows and individual cells.

folk[, 2]
folk[1:2,]
folk[2, 2]

# An alternative to using the `$` notation is to attach() a data frame.

attach(folk)
name
age
detach(folk)
a#
# When you are done it's *very* important to detach() the data frame. The same thing can be done with lists.

# Functions for joining data frames:
# 
#   - cbind()
#   - rbind()
#   - merge()

# Q. Look at the first and last six lines of the iris data frame.
head(iris)
tail(iris)
rbind(head(iris),tail(iris))
# Q. Slice out records 5, 11 and 27.
iris[c(5,11,27),]
# Q. Slice out records which have petal width less than 0.15.
iris[iris$Petal.Width<.15,]
# Q. Find the sepal length for record number 10.
iris[10,"Petal.Length"]
# Q. Find the largest value of petal width. Which record does it occur in?
iris[iris$Petal.Width==max(iris$Petal.Width),]

#use merge() to add a gender column to the folk data frame
merge(folk, gen, by.x = 'index', by.y = 'id' )
# && || for single elements vs | & for vectors

# Q. Create a data frame with the names and birth dates of The Beatles.
beatles = data.frame(id = 1:6,
                     names = c("John Lennon","Paul McCartney","George Harrison","Ringo Star", "Pete Best", "Stuart Sutcliffe"), 
                     birth_dates = c(as.Date("10/9/1940"),as.Date("06/18/1942"),as.Date("02/25/1943"), as.Date("07/07/1940"), as.Date("11/24/1941"), as.Date("06/23/1940")))
dead = data.frame(id=1:6,
                  dead = c(T,F,T,F,F,T))
beatles = merge(beatles,dead)
# Q. Who's the oldest and youngest in The Beatles (ignoring the fact John Lennon is deceased!)?
beatles[beatles$dead=="FALSE" & order(beatles$birth_dates),]
# =====================================================================================================================
# INTRODUCTION TO R SOLUTIONS
# =====================================================================================================================

# R as a Scientific Calculator ----------------------------------------------------------------------------------------

sqrt(7**2 + 17**2)

# Installing from CRAN ------------------------------------------------------------------------------------------------

install("dplyr")

# Installing from GitHub ----------------------------------------------------------------------------------------------

devtools::install_github("geoffjentry/twitteR")

# Variables -----------------------------------------------------------------------------------------------------------

first_name <- "Ronald"
last_name <- "Fisher"
height <- 182
gender <- "Male"
birth_date <- "17-02-1890"

ls()

x <- 3
rm(x)

# Type: Numeric -------------------------------------------------------------------------------------------------------

height = height / 100

class(height)
is.integer(height)
is.numeric(height)

# Type: Logical -------------------------------------------------------------------------------------------------------

tall = height > 1.85

# Type: Character -----------------------------------------------------------------------------------------------------

full_name = paste(first_name, last_name)

# Type: Dates and Times -----------------------------------------------------------------------------------------------

birth_date = as.Date(birth_date)
Sys.Date() - birth_date

# Type: Vectors -------------------------------------------------------------------------------------------------------

fibonacci = c(1, 1, 2, 3, 5, 8, 13, 21, 34, 55)
fibonacci[7]
fibonacci[fibonacci %% 2 == 1]

sum(c(1, 3, 2) * c(-1, 5, 1))

0:100
seq(1, 99, 2)
rep(5, 50)
rep(c("red", "green", "blue"), 5)
rep(c("red", "green", "blue"), each = 5)

# Type: Matrices ------------------------------------------------------------------------------------------------------

matrix(rep(c(1, 0), 10), ncol = 5, byrow = TRUE)

# Type: Factors -------------------------------------------------------------------------------------------------------

factor(gender, levels = c("Male", "Female"))

# Type: Lists ---------------------------------------------------------------------------------------------------------

ronald_fisher = list(first = first_name, last = last_name, height = height, sex = gender, birth = birth_date)

# Type: Data Frames ---------------------------------------------------------------------------------------------------

head(iris)
tail(iris)

iris[c(5, 11, 27),]

iris[iris$Petal.Width < 0.15,]

iris[10, "Sepal.Length"]

max(iris$Petal.Width)
which.max(iris$Petal.Width)

beatles <- data.frame(
  name = c("John Lennon", "Paul McCartney", "George Harrison", "Ringo Starr"),
  born = c("09-10-1940", "18-06-1942", "25-02-1943", "07-07-1940")
)
