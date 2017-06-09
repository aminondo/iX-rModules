# =====================================================================================================================
# DESCRIPTIVE STATISTICS EXERCISES
# =====================================================================================================================

# Mean, Standard Deviation and Variance -------------------------------------------------------------------------------

# Average Sepal.Length in iris
#
mean(iris$Sepal.Length)

# Variance and Standard Deviation of Petal.Width in iris
#
var(iris$Petal.Width)
sd(iris$Petal.Width)

# Q. Calculate the average Sepal.Length broken down by Species using tapply()?

# Q. Find the Species with the largest variance in Petal.Width using dplyr.

# Median and Quantiles ------------------------------------------------------------------------------------------------

# Median Sepal.Length in iris
#
median(iris$Sepal.Length)

# Quartiles of Petal.Width in iris
#
quantile(iris$Petal.Width)

# Q. (i)  Find the deciles of Sepal.Length broken down by Species using tapply().
#    (ii) Bind the deciles together to form a single data frame.

# Q. (i)  Use dplyr to find the median and 75% percentile of Petal.Width broken down by Species.
#    (ii) Sort the data in descending order by median Petal.Width.

# =====================================================================================================================
# DESCRIPTIVE STATISTICS SOLUTIONS
# =====================================================================================================================

# Mean, Standard Deviation and Variance -------------------------------------------------------------------------------

tapply(iris$Sepal.Length, iris$Species, mean)

group_by(iris, Species) %>% summarise(variance = var(Petal.Width)) %>% arrange(desc(variance)) %>% head(1)
group_by(iris, Species) %>% summarise(variance = var(Petal.Width)) %>% filter(variance == max(variance))

# Median and Quantiles ------------------------------------------------------------------------------------------------

iris.decile <- tapply(iris$Sepal.Length, iris$Species, quantile, seq(0, 1, 0.1))
do.call(rbind, iris.decile)

group_by(iris, Species) %>% summarise(median = median(Petal.Width), seventyfive = quantile(Petal.Width, 0.75)) %>%
  arrange(desc(median))