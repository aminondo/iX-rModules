# File System Interation ----------------------------------------------------------------------------------------------

getwd()

list.files()

# Create a temporary directory.
#
tempdir()

# Change the working directory to the temporary working directory.
#
setwd(tempdir())                   # This is normally done directly via RStudio

file.path(tempdir(), "some-arbitrary-file.txt")

# CSV (direct route) --------------------------------------------------------------------------------------------------

# Grab some sample data (https://github.com/fivethirtyeight/data/tree/master/unisex-names)
#
download.file("https://rawgit.com/fivethirtyeight/data/master/unisex-names/unisex_names_table.csv", "names.csv")
#
# Take a look at the contents of this file.

names <- read.csv("names.csv")

head(names)

# Q. Check column classes and fix.

# CSV (better route) --------------------------------------------------------------------------------------------------

library(readr)

names <- read_csv("names.csv")

# Q. Check column classes and fix.
# Q. Fix name for first column. Possibly delete this column?
# Q. Write these data to a pipe-delimited file.

# XLS -----------------------------------------------------------------------------------------------------------------

# Grab some sample data (http://www.sample-videos.com/download-sample-xls.php)
#
download.file("http://www.sample-videos.com/xls/Sample-Spreadsheet-1000-rows.xls", "sample-data.xls")

library(readxl)

sales <- read_excel("sample-data.xls")

# Q. Fix the column names.