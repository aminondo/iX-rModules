# =====================================================================================================================
# EXPLORATORY DATA ANALYSIS EXERCISES
# =====================================================================================================================

library(dplyr)

# Grab the star catalog data.
#
library(moonsun)
#
# If you have trouble installing this package from CRAN then try using cran/moonsun from GitHub.

data(starcat)

head(starcat)

# Define a factor variable.
#
# Q. Define a "nakedeye", categorical variable which indicates whether or not a star is visible to the naked eye. You
#    might find https://en.wikipedia.org/wiki/Apparent_magnitude useful.

starcat = starcat %>% mutate(nakedeye = factor(ifelse(Vmag<=6.5,T,F)))

# Q. Create an overview of the data using summary().
#provides a sanity check, and checks for crazy outliers and understanding of contents of variables
summary(starcat)
# Q. By looking at the range for rrr (Declination) and resRA (Right Ascension) can we infer their meaning?
# latitude(rrr) longitude(resRA) in hours
# Q. Define a "hemisphere" categorical variable based on rrr.
starcat = starcat %>% mutate(hemisphere = factor(ifelse(rrr<=0,"Southern","Northern")))
summary(starcat)
# Q. Find the star which is closest to the Celestial Equator.
starcat %>% mutate(rrr_abs = abs(rrr)) %>% arrange(rrr_abs) %>% head(1)
# Class Summary -------------------------------------------------------------------------------------------------------

# Q. Find the number of stars in each hemisphere.
# Q. Use aggregate() to find the average visual magnitude of stars broken down by hemisphere...
# Q. ... and naked eye visibility.

# Q. Generate the above summary statistics using `dplyr`.
group_by(starcat,hemisphere,nakedeye) %>% summarize(count = n(),avgVmg = mean(Vmag))

# Tabulating ----------------------------------------------------------------------------------------------------------

table(starcat$hemisphere)
table(starcat$nakedeye)

starcat.table <- table(starcat[, c("hemisphere", "nakedeye")])

plot(starcat.table)

margin.table(starcat.table, 1)
margin.table(starcat.table, 2)

prop.table(starcat.table)

addmargins(prop.table(starcat.table))

# Plots ---------------------------------------------------------------------------------------------------------------

library(ggplot2)

# A simple scatter plot.
#
star.scatter <- ggplot(starcat, aes(x = resRA, y = rrr)) +
  geom_point() +
  labs(x = "Right Ascension", y = "Declination") +
  theme_minimal()
star.scatter
#
# Q. What do you see?
# Q. What can we do to make this more evident?

# EXPLORING ISLANDS ---------------------------------------------------------------------------------------------------

# The islands data gives the areas of major land masses in square miles.
#
?islands

# Q. Convert the data from square miles to square kilometres.
# Q. How many observations are there?
# Q. Find the mean and median area. Discuss.
# Q. Find the area of the largest and smallest land masses. There are multiple ways to do this.
# Q. Find the quartiles of area.
# Q. Create a histogram of area. Consider how you could make this more informative.

# =====================================================================================================================
# EXPLORATORY DATA ANALYSIS SOLUTIONS
# =====================================================================================================================

starcat <- mutate(starcat,
  nakedeye = factor(ifelse(Vmag <= 6.5, "visible", "invisible"))
)

# Stars which are North or South of the Celestial Equator.
#
starcat <- mutate(starcat,
  hemisphere = factor(ifelse(rrr < 0, "south", "north"))
)

aggregate(starcat$Vmag, by = starcat[, "hemisphere", drop = FALSE], length)
aggregate(starcat$Vmag, by = starcat[, "hemisphere", drop = FALSE], mean)
aggregate(starcat$Vmag, by = starcat[, c("nakedeye", "hemisphere"), drop = FALSE], mean)

star.scatter + geom_density_2d()
star.scatter + stat_density_2d(aes(fill = ..level..), geom = "polygon")
star.scatter + stat_density_2d(aes(fill = ..density..), geom = "raster", contour = FALSE)
star.scatter + geom_hex()
