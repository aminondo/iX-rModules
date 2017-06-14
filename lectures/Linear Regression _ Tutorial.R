# =====================================================================================================================
# LINEAR REGRESSION
# =====================================================================================================================

# "All models are wrong but some are useful."
#                                                                                                          - George Box
#                                                                    https://en.wikipedia.org/wiki/All_models_are_wrong

# Linear Regression is a technique for modelling the relationship between a dependent variable and a number of
# independent variables.
#
# The regression line represents a conditional mean: it's the mean (expected value) of y conditional on a particular
# value of x.

library(dplyr)
library(ggplot2)
#
theme_set(theme_minimal())

set.seed(13)

# ---------------------------------------------------------------------------------------------------------------------
# Motivating Example
# ---------------------------------------------------------------------------------------------------------------------

# Create Dummy Data ---------------------------------------------------------------------------------------------------

# Manufacture some *completely bogus* data.

N <- 300
#
growing <- data.frame(
  age = runif(N, 0, 18),
  gender = sample(c("M", "F"), N, replace = TRUE)
) %>% mutate(
  height = ifelse(gender == "M", 25, 20) + ifelse(gender == "M", 8.9, 8.4) * age + rnorm(N, sd = 5)
)
#
# EXERCISES:
#
# 1. Explain what's going on in the code above.
ggplot(growing, aes(age,height, color=gender))+geom_point(size=2)

# 2. Produce a scatter plot (use base graphics).

# Fit Linear Regression Model -----------------------------------------------------------------------------------------

# There certainly seems to be a trend in these data: as age increases, so does height.
#
# It seems reasonable to fit a straight line through the data.
#
fit <- lm(height ~ age, growing)
#
# EXERCISES:
#
# 1. Use abline() to superimpose your fit on the scatter plot.
plot(height~age,data=growing)
abline(fit, col='red', lty="dashed")

# Let's interrogate the fit.
#
summary(fit)
#
# There are a number of important things in this output:
#
#   - the value for the intercept and it's associated p-value;
#   - the value for the slope and it's associated p-value (row starting with "age");
#   - R-squared statistic.

# Make Predictions ----------------------------------------------------------------------------------------------------

growing$predict = predict(fit)
View(growing)
ggplot(growing, aes(x=age)) +geom_point(aes(y=height), col="red")+geom_point(aes(y=predict), col="blue")


#
# These are the model values corresponding to each data point.
# Generate predictions over a wider range of x.
#
growing.newdata <- data.frame(age = seq(-2, 25, 0.5))
growing.prediction <- predict(fit, newdata = growing.newdata)

plot(height ~ age, growing, ylim = c(-30, 240), xlim = c(-2, 25))
lines(seq(-2, 25, 0.5), growing.prediction, col = "red")
# difference between interpolating and extrapolating

# Look critically at the model predictions.

# Related terms:
#
# interpolation - predictions inside the range of the data;
# extrapolation - predictions outside the range of the data.

# Generate Confidence Intervals ---------------------------------------------------------------------------------------

growing.ci <- predict(fit, newdata = growing.newdata, interval = "confidence", level = 0.95)
growing.pi <- predict(fit, newdata = growing.newdata, interval = "prediction", level = 0.95)
growing.uncertainty <- cbind(growing.newdata, growing.ci, growing.pi[, -1])
#
names(growing.uncertainty)[3:6] <- c("ci_lwr", "ci_upr", "pi_lwr", "pi_upr")

head(growing.uncertainty)

plot(height ~ age, growing, ylim = c(-30, 240), xlim = c(-2, 25))
lines(fit ~ age, data = growing.uncertainty, col = "red")
lines(ci_lwr ~ age, data = growing.uncertainty, lty = "dashed")
lines(ci_upr ~ age, data = growing.uncertainty, lty = "dashed")
lines(pi_lwr ~ age, data = growing.uncertainty, lty = "dotted")
lines(pi_upr ~ age, data = growing.uncertainty, lty = "dotted")
#
# Discuss: "prediction interval" versus "confidence interval".

# Interactions --------------------------------------------------------------------------------------------------------

# EXERCISES:
#
# 1. Fit the following models to the data. Compare and discuss.
#
#     height ~ age
fit = lm(height ~ age, growing)
fit

#     height ~ gender
fit_2 = lm(height ~ gender, growing)
fit_2

growing %>% group_by(gender) %>% summarize(mean(height))

#     height ~ age + gender
fit_3 = lm(height ~ (age+gender), growing)
fit_3

#     height ~ age + age:gender
fit_4 = lm(height ~ (age+age:gender), growing)
fit_4


#     height ~ age + gender + age:gender
fit_5 = lm(height ~ (age+gender + age:gender), growing)
fit_5
#     height ~ age*gender
fit_6 = lm(height ~ age*gender,growing)
fit_6

# LINEAR REGRESSION: PROSTATE CANCER DATA -----------------------------------------------------------------------------

library(ElemStatLearn)
head(prostate)

?prostate

# The prostate data have already been partitioned into training and testing sets.
#
# The train column is used to partition the data that are used to train the model.
#
# A model with all features.
#
fit <- lm(lpsa ~ . - train, data = prostate, subset = train)
summary(fit)
#
# EXERCISES:
#
# 1. Explain the model formula.
# 2. Find out what the subset parameter does.
# 3. Note which coefficients are statistically significant.

# Test the model.
#
# Let's use this model to make predictions on the test data.
#
lpsa.predict = predict(fit, subset(prostate, !train))
#
# Compare predictions to observations.
#
library(Metrics)
rmse(subset(prostate, !train)$lpsa, lpsa.predict)

# Let's go back and construct a more parsimonious model, retaining only the four significant coefficients.

fit = update(fit, . ~ . - age - lcp - gleason - pgg45)
summary(fit)
#
# EXERCISES:
#
# 1. What happened to R-squared? Is this important?

# We'll make a new set of predictions and see whether there is a deterioration in the results.

lpsa.predict = predict(fit, subset(prostate, !train))
rmse(subset(prostate, !train)$lpsa, lpsa.predict)
#
# EXERCISES:
#
# 1. What happened RMSE? Does this make sense?
#
# Wow! The results actually got better. Parsimony FTW.

# Model Diagnostics ---------------------------------------------------------------------------------------------------

# A plot of residuals versus fitted value.
#
plot(fit, which = 1)
#
# We're looking for a more or less uniform band of residuals across all fitted values.
#
# If there is a trend of increasing or decreasing residuals then it might indicate that one of the model assumptions
# is not satisfied.

# A quantile-quantile plot of residuals.
#
plot(fit, which = 2)
#
# We're looking for the points to be aligned close to the dashed reference line, which indicates that the residuals
# are normally distributed.

# This plot helps identify influential outliers.
#
# We'd like to exclude outliers if they have a large influence on the model.
#
plot(fit, which = 5, cook.levels = c(0.2))
#
# Points which lie outside the Cook's distance curves in the top/bottom right of the plot are potentially influential.

# LINEAR REGRESSION: PROSTATE CANCER DATA WITH INTERACTIONS -----------------------------------------------------------

# We've treated the svi feature as numerical. In fact it would make more sense to convert it to a factor.

prostate <- mutate(prostate, svi = factor(svi, labels = c("no", "yes")))

# Let's just go ahead and fit a model as before.

summary(lm(lpsa ~ lcavol + lweight + lbph + svi, data = prostate, subset = train))
#
# Here the levels of svi simply have different (constant) contributions to the intercept.

# Here we have linear coefficients for lcavol, lweight and lbph. The sviyes coefficient is an additional intercept term
# which is applied if svi has value yes. I don't know an awful lot about prostate cancer, but simply adding a constant
# offset doesn't seem to make sense.

# Suppose that we thought that the influence of lweight might depend on whether or not there had been seminal
# vesicle invasion (SVI). We can easily build this into the model by using an interaction.

summary(lm(lpsa ~ lcavol + svi:lweight + lbph, data = prostate, subset = train))

# Now there are two coefficients for lweight depending on the value of svi:
#
# svino:lweight  - the coefficient to be applied when svi is no, while
# sviyes:lweight - applied when svi is yes.

# Alternatively we could consider the influence of svi and lweight independently as well as their interaction. We'd do
# this by using a svi*lweight term in the model formula.

summary(lm(lpsa ~ lcavol + svi*lweight + lbph, data = prostate, subset = train))

# Look carefully at the model coefficients. How would you interpret the coefficients lweight and svi1:lweight?

# Of the two models with interactions, I'm more inclined towards the one with only the interaction terms. Why? Of
# couse, I also know very little about prostate cancer, so this bias might be completely unfounded. Perhaps the
# independent contributions of svi and lweight are significant from a medical perspective. This underscores one of the
# basic elements of Data Science: it's important to either have some domain knowledge or consult with somebody who
# does. It seems we might need to find a friendly Urologist for some domain insight.

# POLYNOMIAL REGRESSION -----------------------------------------------------------------------------------------------

# Generate parabolic data.
#
parabola <- data.frame(
  x = seq(-5, 5, 0.1)
) %>% mutate(
  y = 3 - x + x**2,
  noisy = y + rnorm(nrow(.), sd = 4)
)

# Linear
#
(fit.linear <- lm(noisy ~ x, data = parabola))

# Quadratic
#
(fit.poly <- lm(noisy ~ poly(x, 2), data = parabola))
(fit.quadratic <- lm(noisy ~ x + I(x**2), data = parabola))

parabola$linear    = predict(fit.linear, parabola)
parabola$quadratic = predict(fit.quadratic, parabola)

ggplot(parabola, aes(x = x)) +
  geom_point(aes(y = noisy)) +
  geom_line(aes(y = y)) +
  geom_line(aes(y = linear), lty = "dashed", col = "blue") +
  geom_line(aes(y = quadratic), lty = "dashed", col = "red") +
  labs(y = "")

# POLYNOMIAL REGRESSION (ANOTHER EXAMPLE) -----------------------------------------------------------------------------

library(ISLR)

# Sometimes a straight line is clear not the right model.
#
# Surely "Linear" Regression must always be about straight lines?
#
# Why not?

plot(mpg ~ horsepower, data = Auto)

# We're just going to sort these data on horsepower to facilitate plotting.
#
Auto = arrange(Auto, horsepower)

# A simple linear fit.
#
fit_1 = lm(mpg ~ horsepower, data = Auto)
abline(fit_1, col = "red", lty = "dashed")
#
# That seems inadequate. It's underfitting.

# Let's toss in a quadratic term.
#
fit_2 = lm(mpg ~ horsepower + I(horsepower^2), data = Auto)
#
summary(fit_2)
#
lines(Auto$horsepower, predict(fit_2), col = "blue", lty = "dashed")
#
# That seems to be a better description of the data.

# What about a cubic term?
#
fit_3 = lm(mpg ~ horsepower + I(horsepower^2) + I(horsepower^3), data = Auto)
#
summary(fit_3)
#
lines(Auto$horsepower, predict(fit_3), col = "green", lty = "dashed")
#
# The cubic term doesn't make a major difference to the model.

# Compare the models.
#
anova(fit_1, fit_2, fit_3)
#
# We see that the quadratic model is significantly different to the simple linear model, but that the cubic model is
# not significantly different to the quadratic model.

# WHY NOT TO RELY ON R^2 ----------------------------------------------------------------------------------------------

library(digest)

N <- 100

points <- data.frame(x = runif(N, 0, 10)) %>% mutate(y = 1 + 2 * x + rnorm(N, sd = 4)) %>% select(y, x)

plot(points)

fit.1 <- lm(y ~ ., data = points)

summary(fit.1)

random.columns <- function(ncol, N) {
  randcol = matrix(rnorm(ncol * N), nrow = N)
  colnames(randcol) = sapply(rnorm(ncol), function(x) digest(x, "crc32"))
  randcol
}

# Add columns of random data.
#
points <- cbind(points, random.columns(10, N))

fit.2 <- lm(y ~ ., data = points)

summary(fit.2)

# Add more columns of random data.
#
points <- cbind(points, random.columns(80, N))

fit.3 <- lm(y ~ ., data = points)

summary(fit.3)

do.call(rbind, lapply(list(fit.1, fit.2, fit.3), function(fit) {
  metrics = summary(fit)
  with(metrics, c(r.squared, adj.r.squared))
}))

# EXERCISES -----------------------------------------------------------------------------------------------------------

# 1. Use the Carseats data from the ISLR package to build a model to predict Sales.
#
#    a) Can you infer anything about the interaction of advertising and shelf location?
#    b) What about price and shelf location?
#    c) Is advertising more effective in urban or rural areas?
#    d) Build a parsimonious model.
#    e) Check model diagnostics.
#    f) Use a plot to check model on test data.
#
# 2. Use the Wage data from the ISLR package to build a model to predict wage.
#
#    a) Do some exploratory analysis. Are there any features which can be ignored?
#    b) For what marital status does age have the strongest effect on wage?
#    c) Is health insurance related to the rate at which wage increases with age? Comment on causality.
#    d) Is it better to model wage or logwage?
#    e) Check model diagnostics.
#    f) Use a plot to check model on test data.
#
# 3. Grab these wine data:
#
#    https://rawgit.com/DataWookie/training-r-machine-learning-introduction/master/data/wine.csv
#
#    Use them to build a regression model to predict wine quality.
#
#    a) Think carefully about how you will treat red versus white wine.
#    b) Consider using interactions.