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
class(names$name)
nrows(names)
length(unique(names$name))
#no reason to have names$name as a factor variable, factors used to define categorical set
names$name = as.character(names$name)


# CSV (better route) --------------------------------------------------------------------------------------------------

library(readr)

names <- read_csv("names.csv")

# Q. Check column classes and fix.
#     no need
# Q. Fix name for first column. Possibly delete this column?
names$id = names$X1
names$X1 = NULL # names = names[,-1]
#colnames(names)[1] = "id"
names = names[, c("id", "name", "total", "male_share", "female_share", "gap")]
# Q. Write these data to a pipe-delimited file.
write.table(names, file="names-delim.csv", sep="|", quote=F, row.names=F)
write_delim(names, "names-delim2.csv", delim="|")

# XLS -----------------------------------------------------------------------------------------------------------------

# Grab some sample data (http://www.sample-videos.com/download-sample-xls.php)
#
download.file("http://www.sample-videos.com/xls/Sample-Spreadsheet-1000-rows.xls", "sample-data.xls")

library(readxl)

sales <- read_excel("sample-data.xls")

#best way to do this is actually turn it into csv and then import it

# Q. Fix the column names.