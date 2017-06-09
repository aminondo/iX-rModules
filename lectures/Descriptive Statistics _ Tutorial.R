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

#create a scatter plot 
library(ggplot2)
ggplot(iris, aes(x=iris$Sepal.Length, y=iris$Sepal.Width, color=Species, shape=Species, alpha=.5)) + geom_point() + labs(x = "Sepal Length", y="Sepal Width", title="Width vs Length")


# Q. Calculate the average Sepal.Length broken down by Species using tapply()?
avg = tapply(iris$Sepal.Length,iris$Species,mean)
stan_d = tapply(iris$Sepal.Length,iris$Species,sd)

ggplot(iris, aes(x=Sepal.Length, fill=Species)) + geom_histogram(alpha=.5, binwidth=.2) + facet_grid(Species~.)
ggplot(iris, aes(x=Sepal.Length, fill=Species, alpha=.5)) + geom_density()


# Q. Find the Species with the largest variance in Petal.Width using dplyr.

# Median and Quantiles ------------------------------------------------------------------------------------------------

# Median Sepal.Length in iris
#
median(iris$Sepal.Length)

# Quartiles of Petal.Width in iris
# divides range into 4 different intervals, a way to divide data into 
quantile(iris$Petal.Width)

# Q. (i)  Find the deciles of Sepal.Length broken down by Species using tapply().
deciles = tapply(iris$Sepal.Length, iris$Species, quantile, probs=seq(0,1,.1))

#    (ii) Bind the deciles together to form a single data frame.
deciles=rbind(rbind(deciles[[1]],deciles[[2]],deciles[[3]]))
#better way to do this, this dynamically builds the function call, essentially builds ^^ dynamically
do.call(rbind, deciles)
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