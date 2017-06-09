# =====================================================================================================================
# STATISTICAL DISTRIBUTIONS EXERCISES
# =====================================================================================================================

# DISCRETE DISTRIBUTION -----------------------------------------------------------------------------------------------

# Q. Shuffling a deck of cards.
#
# (i)  Create string vector representing deck.
# (ii) Use sample() to shuffle it.

# Q. (i)   Generate 10 samples from c("H", "T") for a fair coin.
#    (ii)  Generate 10 samples from c("H", "T") for a biased coin (p = 0.55 for "H").
#    (iii) Find the number of "H" and "T" from 1000 tosses of the biased coin.

# BINOMIAL DISTRIBUTION -----------------------------------------------------------------------------------------------

# What is the probability of getting 5 successes from 10 trials if there is a 50% chance of success on each trial?

dbinom(5, 10, 0.5)

dbinom(0:10, 10, 0.5)
#
# What would we get if we summed those values?

# Q. What is the probability of getting 5 or more successes in the above scenario?
# Q. What is the median number of successes in the above scenario?

# UNIFORM DISTRIBUTION ------------------------------------------------------------------------------------------------

# Have a look at ?runif.

dunif(0.5, min = 0, max = 2)      # PDF
punif(0.5, 0, 2)                  # CDF

qunif(seq(0, 1, 0.25), 0, 2)      # Quantiles

set.seed(3)

runif(5, 0, 2)                    # Samples

# The Poisson Distribution --------------------------------------------------------------------------------------------

# The Poisson Distribution is used to model the number of occurrences per unit time.

# Suppose that we have a chunk of radioactive stuff that emits beta particles as an average rate of 100 per second.
#
# Q. What is the probability that fewer than 80 beta particles are emitted in a given second?

# Q. Simulate the number of decays per second for every second in a minute. What's the average and variance?

# NORMAL DISTRIBUTION -------------------------------------------------------------------------------------------------

x = seq(-5, 5, 0.1)

plot(x, pnorm(x), type = "l", lty = "dashed")
lines(x, dnorm(x))

qnorm(c(0.005, 0.025, 0.975, 0.995))

rnorm(5)

# Standardising.
#
# Q. Generate 100 samples from a Normal distribution with mean 50 and standard deviation 10.
# Q. Standardise those data. These are z scores.
# Q. Calculate the mean and standard deviation of the standardised data.

# Distribution of human heights (in inches):
#
#            mu  sigma
# Male      70.0  4.0
# Female    65.0  3.5
#
# Q. Find the probability of a man's height exceeding 80.0.
# Q. Find the probability that a woman's height is between 60.0 and 65.0.

# =====================================================================================================================
# STATISTICAL DISTRIBUTIONS SOLUTIONS
# =====================================================================================================================
