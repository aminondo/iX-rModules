# =====================================================================================================================
# PIPING IN R
# =====================================================================================================================

# Motivational Example
#
# Write code to evaluate this expression:
#
# \sum_{x = 1}^{10} \left(\frac{x}{x + 1}\right)^2
#
# You can format this LaTeX at https://www.codecogs.com/latex/eqneditor.php.



library(magrittr)
x=1:10
x=x/(x+1)
x=x^2
sum(x)

1:10 %>% (function(x) x / (x + 1)) %>% (function(x) x^2) %>% sum()

set.seed(13)

# Nested function calls.
#
which.max(apply(matrix(runif(24), nrow = 4), 2, sum))
#
# Using the pipe.
#
matrix(runif(24), nrow = 4) %>% apply(2, sum) %>% which.max()

# Anonymous functions.
#
mtcars %>% (function(df) {rbind(head(df), tail(df))})

# Q. Perform the following operation:
#
#     - generate 100 uniformly distributed random numbers;
x = runif(100)
#     - subtract 1 from each of them;
x = x-1
#     - calculate the range; and
range(x)
#     - find the sum of the largest and smallest numbers.
max(x)+min(x)
runif(100) %>% function(x) {x-1} %>% range %>% max+min
# =====================================================================================================================
# PIPING IN R SOLUTIONS
# =====================================================================================================================

1:10 %>% (function(x) x / (x + 1)) %>% (function(x) x^2) %>% sum()

runif(100) %>% (function(x) {x - 1}) %>% range %>% sum