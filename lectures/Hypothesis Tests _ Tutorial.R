# =====================================================================================================================
# HYPOTHESIS TEST EXERCISES
# =====================================================================================================================

library(dplyr)
library(reshape2)
library(ggplot2)
library(rvest)
#
theme_set(theme_minimal())

set.seed(13)

# BINOMIAL TEST -------------------------------------------------------------------------------------------------------

# A gambler is playing European Roulette. He's wagering on the dozen 13 to 24.
#
# Q. Calculate his probability of winning.
# Q. Find the probability that he wins 0, 1, 2, ... 10 times on 10 consecutive spins.
# Q. What is the expected number of wins in 10 consecutive spins?
# Q. If he has won on 6 of those spins should we be concerned? What about if he has 7 wins?
# Q. If he did not win on any of those spins should we offer him a bonus?

# Let's take a different view on this problem. Use binom.test() to evaluate whether our observations are consistent
# with the theoretical value of the success probability.
#
# Q. If a gambler has won on the dozen 13 to 24 for 9 out of 10 spins, does this indicate a problem with the game?

# T-TEST --------------------------------------------------------------------------------------------------------------

# Q. Generate two samples of size 10 from a Normal Distribution with the following parameters.
#
#               mu sigma
#     sample 1: 10   3
#     sample 2: 15   3
#
# Q. Compare these samples using the t Test.
# Q. Repeat but with samples of size 100.
# Q. How do the test results differ? Look at the p-values and confidence intervals.

# Q. Test the following hypothesis: "The mean value of horse power in the mtcars data is 170".
# Q. Test the following hypothesis: "The mean value of horse power in the mtcars data is less than 170".
# Q. Test the following hypothesis: "The mean value of horse power in the mtcars data is greater than 170".

# PAIRED T-TEST--------------------------------------------------------------------------------------------------------

# Construct data.
#
N <- 30
#
couples <- data.frame(
  id = 1:N,
  male = rnorm(N, mean = 55, sd = 15)
) %>% mutate(
  female = round(male - rnorm(N, mean = 3, sd = 3)),
  male = round(male)
) %>% select(id, male, female)

# Take a look.
#
head(couples)

# Let's make that tidy.
#
couples = melt(couples, id.vars = "id", variable.name = "gender", value.name = "age") %>% mutate(
  gender = factor(gender, levels = c("female", "male"))
)

# Take another look.
#
head(couples)
#
ggplot(couples, aes(x = id)) +
  geom_point(aes(y = age, color = gender))
#
ggplot(couples) +
  geom_density(aes(x = age, fill = gender), alpha = 0.5)

# Test for difference in mean (two-sampled test)
#
t.test(age ~ gender, data = couples)

# Test for difference in mean (paired test)
#
t.test(age ~ gender, data = couples, paired = TRUE)

# =====================================================================================================================
# HYPOTHESIS TEST SOLUTIONS
# =====================================================================================================================

# BINOMIAL TEST -------------------------------------------------------------------------------------------------------

# Q. If he has won on 6 of those spins should we be concerned? What about if he has 7 wins?
#
sum(dbinom(6:10, 10, 12/37))                # Probability of 6 or more wins out of 10
sum(dbinom(7:10, 10, 12/37))                # Probability of 7 or more wins out of 10

# Q. If a gambler has won on the dozen 13 to 24 for 9 out of 10 spins, does this indicate a problem with the game?
#
binom.test(9, 10, 12/37)

# T-TEST --------------------------------------------------------------------------------------------------------------