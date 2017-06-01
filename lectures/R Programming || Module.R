# =====================================================================================================================
# PROGRAMMING IN R
# =====================================================================================================================

# CONTROL FLOW --------------------------------------------------------------------------------------------------------

x = 3
if (x %% 2 == 0) {
  print("Even!")
} else {
  print("Odd!")
}

# What happens if the logical condition is a vector?
#
x = 1:8
#
# Now try the conditional statement above.

# ifelse() is a vectorised conditional.
#
ifelse(x %% 2, "Odd!", "Even!")

# ITERATION -----------------------------------------------------------------------------------------------------------

# It's generally best to avoid explicit iteration in R because vectorised function calls are a lot more efficient.
folk <- data.frame(index = 1:3,
    name = c("Bob", "Mary", "Alice"),
    age = c(43, 25, 31),
    height = c(1.82, 1.75, 1.77))

folk$old = ifelse(age>30, "Yes", "No")
# § for

# The for loop uses a counter to determine the number of times a block of code is executed.

for (i in 1:10) {
  cat(sprintf("%d is %s.\n", i, ifelse(i %% 2, "Odd", "Even")))
}

# The values used for the loop counter need not be numbers. You can just as easily iterate over a vector of strings.

# § while

# There's also a while() loop which repeats a block of code while a logical condition is satisfied. It's generally used
# when the number of iterations is not known in advance.
#
# Use next and break to gain control over you while loops. These can be used with for loops too.
#
# Q. Write the loop above using while().
i=1
while (i<=10) {
  cat(sprintf("%d is %s.\n", i, ifelse(i %% 2, "Odd", "Even")))
  i=i+1
}
# A loop is generally used for side effects. With the foreach package, looping is about the return value.
#
library(foreach)

foreach (x = 1:3) %do% {
  x**2
}

# Now a nested loop.
#
foreach (x = 1:3, .combine = 'cbind') %:%
  foreach (y = c(10, 20, 30), .combine = 'c') %do% {
    x**2 + y
  }
#
# Note what the .combine parameter does!

# foreach also allows you to easily parallelise the execution of a loop.

# FUNCTIONS -----------------------------------------------------------------------------------------------------------

# Interrogating the contents of existing functions.

rownames

# Things to note:
#
# - first line specifies arguments;
# - body of function between {}.

args(rownames)
args(`/`)

body(rownames)

# § Roll your own Functions

circle_perimeter <- function(r) {
  C = 2 * pi * r
  return(C)
}
circle_perimeter(2)

# Our new function...
#
# - accepts a single arguments, r, being the radius of a circle;
# - calculates the circle's circumference and assigns the result to the local variable C;
# - returns the value of C.

# You'll note that there is no return() in the body of the rownames() function. Why?
#
# The last value calculated in a function is returned as the value.

circle_perimeter <- function(r) 2 * pi * r

# Reducing function noise (doesn't echo result to console).

silent_circle_perimeter <- function(r) invisible(2 * pi * r)
silent_circle_perimeter(2)

# § Default and Missing Arguments

# Let's implement a function to calculate the area of an ellipse.
#
# Check out https://en.wikipedia.org/wiki/Ellipse for reference.
#
# A circle is a special case of an ellipse. The eccentricity parameter should have a default value.

#' Calculate the area of an ellipse.
#'
#' @param r Length of the semi-major axis.
#' @param e The eccentricity.
#'
#' @return The area of the ellipse with specified semi-major axis and eccentricity.
#' @export
#'
#' @examples
#' ellipse_area(1, 0.5)
#' ellipse_area(1)
ellipse_area <- function(r, e = 0) {
  if (e < 0 || e > 1) stop("Invalid eccentricity!", call. = FALSE)
  pi * r^2 * sqrt(1 - e^2)
}

# You can create the framework for function documentation using Code -> Insert Roxygen Skeleton.

# The missing() function can be used within the body of a function to determine whether an argument was specified.

# § Vectorised Functions

# Here's a tiny bit of magic: user defined functions in R are (normally) fully vectorised without additional effort!

ellipse_area(1:5)

# Q. Write function to calculate the area of a rectangle. Check that arguments are valid. Allow for sensible default
#    arguments.
rect_area = function(w,h = w) {
  if (w<0 || h<0) stop("Invalid arguments. Arguments need to be positive", call = F)
  return(w*h)
}
# Q. Write a function to calculate Body Mass Index (BMI).
BMI = function(w_kg, h_m) {
  if(w_kg<0 || h_m<0) stop("Error: Arguments need to be positive", call = F)
  return(w_kg/h_m^2)
}
# Q. Write a function to calculate factorials.
factorial = function(n) {
  if(n<0) stop("Error: Arguments need to be positive", call=F)
  fac = n
  while (n>1) {
    fac = fac*(n-1)
    n = n-1
  }
  return(fac)
}

# BUFFON'S NEEDLE -----------------------------------------------------------------------------------------------------

# Background information: https://en.wikipedia.org/wiki/Buffon%27s_needle.

# Q. Write a function, buffon(), to simulate Buffon's needle experiment. The function should have the following
#    signature:
#
#      buffon(l,t)
#
#    where l is the needle length and t is the line spacing. The return value should be TRUE if the needle crosses a
#    line and false otherwise.

buffon = function(l,t) {
  P1 = l/t
}
#
# Q. Use this function to generate an estimate for pi.

montecarlo = function(n,h) {
  
}
# =====================================================================================================================
# PROGRAMMING IN R SOLUTIONS
# =====================================================================================================================

# FUNCTIONS -----------------------------------------------------------------------------------------------------------

rectangle_area <- function(width, height = width) {
  width * height
}

#' Body Mass Index
#'
#' @param height Height in m.
#' @param mass Mass in kg.
#'
#' @return Body mass index in kg / m^2.
#' @export
#'
#' @examples
#' bmi(1.8, 78)
bmi <- function(height, mass) {
  mass / height^2
}

# BUFFON'S NEEDLE -----------------------------------------------------------------------------------------------------

#' Exploit symmetry to limit range of centre position and angle.
#' 
#' @param l needle length.
#' @param t line spacing.
#' 
buffon <- function(l, t) {
  # Sample the location of the needle's centre.
  #
  x <- runif(1, min = 0, max = t / 2)
  #
  # Sample angle of needle with respect to lines.
  #
  theta = runif(1, 0, pi / 2)
  #
  # Does the needle cross a line?
  #
  x <= l / 2 * sin(theta)
}

set.seed(17)

L = 1
T = 2
#
N = 10000
#
cross = replicate(N, buffon(L, T))
#
crossfrac = sum(cross) / length(cross)
#
# Estimate pi.
#
2 * L / T / crossfrac

# Show convergence.
#
library(dplyr)
#
estimates = data.frame(
  n = 1:N,
  pi = 2 * L / T / cumsum(cross) * (1:N)
) %>% subset(is.finite(pi))
#
library(plotly)
#
plot_ly(estimates, x = n / 1000, y = pi, type = "scatter", name = "Estimate") %>%
  layout(
    title = "Estimating pi using Buffon's Needle",
    showlegend = F,
    xaxis = list(title = "Samples [thousands]"),
    yaxis = list(title = "Estimate of pi", range = c(2, 5))
  ) %>%
  add_trace(x = c(0, 10), y = c(3.1416, 3.1416), mode = "lines", opacity = 0.75)

