# =====================================================================================================================
# FUNCTIONAL PROGRAMMING IN R
# =====================================================================================================================

# BASE FUNCTIONALITY --------------------------------------------------------------------------------------------------

# -> apply()

(r = matrix(runif(12), nrow = 3))

apply(r, 1, min)
apply(r, 2, mean)

# -> sapply() and lapply()

# lapply() returns a list.
#
lapply(c(1, 4, 9, 16), sqrt)

# sapply() returns a "simplified" data structure.
#
sapply(c(1, 4, 9, 16), sqrt)

# Q. Before we run the code below, try to figure out what's going to happen. Use help if necessary.
#
lapply(list(first = 1:10, second = runif(5), third = rnorm(20)), function(x) {range(x)})

# Q. Repeat the last operation but using sapply().
sapply(list(first = 1:10, second = runif(5), third = rnorm(20)), function(x) {range(x)})

# -> tapply()

(gender = rep(c("M", "F"), each = 6))
(group <- rep(1:2, 6))
(height = c(rnorm(6, mean = 180), rnorm(6, mean = 170)))

tapply(height, gender, mean)
tapply(height, list(gender, group), mean)

# Q. Try to replicate this behaviour using split() and sapply().

# -> replicate()

replicate(10, runif(5))

# Q. How could you get the result as a list rather than an array?

# -> Map() and Reduce()

Map(function(x) x**2, list(x = 1:10, y = 1:3))

Reduce(`+`, 1:10)
Reduce(`+`, 1:10, accumulate = TRUE)

# PURRR ---------------------------------------------------------------------------------------------------------------

library(purrr)

# map() always returns a list.
#
map(c(1, 4, 9, 16), sqrt)

# There are specialised functions which return vectors.
#
map_dbl(c(1, 4, 9, 16), sqrt)

# The first argument to the mapping functions is a vector or list (remember that data frame is just a dressed up list!).

map(mtcars, mean)

# Q. Calculate the maximum value of each numeric column in the iris data. Get the result as a list and a vector.

# Additional arguments can be passed to the function.
#
list(c(1, 4, 9), c(16, NA, 36)) %>% map_dbl(mean)
#
# What happened there?
#
mean(c(1, 4, 9))
mean(c(16, NA, 36))
#
list(c(1, 4, 9), c(16, NA, 36)) %>% map_dbl(mean, na.rm = TRUE)

# What about mapping in parallel?
#
numerator <- c(1, 4, 6, 12)
denominator <- c(1, 2, 2, 3)
map2(numerator, denominator, function(x, y) x / y)
map2_dbl(numerator, denominator, `/`)

# Q. Calculate the ratio of power to weight for each vehicle in mtcars. Get the result as a vector.

# These functions also provide a handy shortcut for extracting elements from a list.
#
lapply(1:5, function(n) list(random = runif(n), letter = letters[n])) %>%
  map_chr("letter")

# Q. How would you do this in base R?

# =====================================================================================================================
# FUNCTIONAL PROGRAMMING IN R SOLUTIONS
# =====================================================================================================================

# BASE FUNCTIONALITY --------------------------------------------------------------------------------------------------

# -> apply()

# -> sapply() and lapply()

# -> tapply()

sapply(split(height, list(gender, group)), mean)

# PURRR ---------------------------------------------------------------------------------------------------------------

iris[, 1:4] %>% map(max)
iris[, 1:4] %>% map_dbl(max)

pmap_dbl(mtcars, function(hp, wt, ...) hp / wt)

lapply(1:5, function(n) list(random = runif(n), letter = letters[n])) %>% lapply(function(d) d$letter)