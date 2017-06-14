# =====================================================================================================================
# LOGISTIC REGRESSION EXERCISES
# =====================================================================================================================

library(ggplot2)
library(dplyr)

# A classification model is one which predicts an outcome with a finite number of discrete classes.
#
# So, for example, one could predict:
#
# - Customer gender based on spending habits.
# - Will a customer buy a particular product?
# - Will a lender default on a loan?

# GEDANKENEXPERIMENT --------------------------------------------------------------------------------------------------

# Q. Sketch what plots of the following data would look like:
# 
#    - height
#    - whether or they have driven a car
# 
#    as a function of age for children between ages of 0 and 18.
# 
# Q. How would these plots change if you included gender?
# Q. How would you model these data?

# ---------------------------------------------------------------------------------------------------------------------
# LOGISTIC REGRESSION
# ---------------------------------------------------------------------------------------------------------------------

# The simplest form of classification model is Logistic Regression.
#
# Logistic Regression is used to model a situation where there are two possible outcomes: positive and negative.
#
# If we denote by P the probability of a positive outcome, then we aim to build a model for
#
#   log[P / (1 - P)] = "log odds"
#
# where
#
#   P / (1 - P) = "odds".
#
# The log odds are modelled as a linear combination of features.

# If we denote the log odds by L then
#
#   exp(L) = odds
#   exp(L) / (1 + exp(L)) = probability.

# EXERCISES:
#
# 1. What are the odds of a coin coming up heads?
# 2. What are the odds of a dice landing on six?

# INTUITION -----------------------------------------------------------------------------------------------------------

# Generate the log odds.
#
x <- seq(-10, 10, 0.1)
#
# Transform to probability.
#
y <- exp(x) / (1 + exp(x))
#
plot(x, y, type = "l", xlab = "Log odds", ylab = "Probability")
abline(a = 0.5, b = 0, lty = "dashed")
#
# - If the log odds are greater than 0 then the probability is greater than 0.5.
# - Increasing log odds results in increased probability.

# ---------------------------------------------------------------------------------------------------------------------
# CREDIT DEFAULT
# ---------------------------------------------------------------------------------------------------------------------

library(ISLR)

?Default

# Exploratory analysis. These are "mosaic plots".
#
plot(default ~ student, data = Default)
plot(default ~ balance, data = Default)
plot(default ~ income, data = Default)

# Split data into train/test sets.
#
train.index = sample(c(T, F), nrow(Default), replace = TRUE, prob = c(0.8, 0.2))
#
default = split(Default, train.index)
names(default) = c("test", "train")
#
rm(train.index)

# Using only student feature.
#
fit <- glm(default ~ student, data = default$train, family = binomial)
#
summary(fit)
#
# EXERCISES:
#
# 1. Does being a student make you more or less likely to default?

# Using all features.
#
fit.default <- glm(default ~ ., data = default$train, family = binomial)
#
summary(fit.default)
#
# EXERCISES:
#
# 1. Do the extra features have an effect on the coefficient for student?
# 2. How do we interpret the coefficients for balance and income?

# PREDICT BY HAND -----------------------------------------------------------------------------------------------------

# In practice we'd probably never make predictions like this, but it's useful to know how it works.

coef(fit.default)

# What is the probability of default for a student with balance 2000 and income 10000?
#
lo = coef(fit.default)[1] + 1 * coef(fit.default)[2] + 2000 * coef(fit.default)[3] + 10000 * coef(fit.default)[4]
exp(lo) / (1 + exp(lo))
#
# EXERCISES:
#
# 1. How much does this probability change if the balance is 3000?
# 2. Is there a more compact way to evaluate the log odds? Think about vector operations.

# EVALUATION ----------------------------------------------------------------------------------------------------------

# Make predictions on the test data.
#
test.predict = ifelse(predict(fit.default, default$test, type = "response") > 0.5, "Yes", "No")
#
# Generate confusion matrix with test data.
#
table(test.predict, default$test$default)
#
# EXERCISES:
#
# 1. Calculate accuracy, sensitivity and specificity.
# 2. Where does this model work well? Where does it fail?
# 3. Is there any bias in the data? Could we "balance" the data to mitigate this bias?

# ---------------------------------------------------------------------------------------------------------------------
# TITANIC
# ---------------------------------------------------------------------------------------------------------------------

library(vcdExtra)

# EXERCISES:
#
# 1. Look at the Titanicp data and form some hypotheses.
# 2. Are the data types correct?

head(Titanicp)

sapply(Titanicp, class)

fit <- glm(survived ~ pclass + sex + age + sibsp + parch, data = Titanicp, family = binomial)
#
summary(fit)
#
# EXERCISES:
#
# 1. How would the model differ if pclass was an integer rather than a factor?
# 2. What does it mean for a coefficient to be "statistically significant"?
#
#    - Illustrate with height gedankenexperiment: distribution of heights around mean? Where's the giant?
#
# 3. How do we interpret the coefficients for the following features?
#
#    a) pclass
#    b) sex
#    c) age
#
# 4. Are there any terms that we can leave out of our model?

# PREDICTIONS ---------------------------------------------------------------------------------------------------------

# Have a look at ?predict.glm.

predict.link     = predict(fit, Titanicp)
predict.response = predict(fit, Titanicp, type = "response")

hist(predict.link)
hist(predict.response)

# We need to threshold the predictions.
#
predict.response = ifelse(predict.response > 0.5, 1, 0)
#
rm(predict.link)

# EVALUATION ----------------------------------------------------------------------------------------------------------

# The first step in assessing a classification model is to form a confusion matrix.
#
#               +-----------+
#               |  Observed |
#               |  0  |  1  |
# +-------------+-----+-----+
# | Predicted 0 | TN  | FN  | Negative Prediction
# |           1 | FP  | TP  | Positive Prediction
# +-------------+-----+-----+
#
# Ideally one would want to maximise the number of TP and TN, while minimising the number of FP and FN.
#
# In practice there is always a compromise between these two goals.

# There are a selection of metrics derived from the confusion matrix. The most important are:
#
# accuracy    = (TP + TN) / (TP + FN + TN + FP)
# sensitivity = TP / (TP + FN) = "true positive rate"
# specificity = TN / (TN + FP) = "true negative rate"

table(predict.response, Titanicp$survived)
#
# EXERCISES:
#
# 1. Fix the confusion matrix so that labels of rows and columns are consistent.
#
#    - Go back to where we applied a threshold to the predictions.
#
# 2. Calculate accuracy, sensitivity and specificity.
# 3. That looks remarkably good! Is there a potential problem with this?
#
#    - Think about whether this is really an objective test of the model.

# ---------------------------------------------------------------------------------------------------------------------
# BIRTHS
# ---------------------------------------------------------------------------------------------------------------------

library(Epi)
#
# We'll be using the data from births in a London Hospital.
#
data(births)

?births
#
# Hypotheses: How do we predict baby gender?

dim(births)

head(births)

# EXPLORATORY ANALYSIS ------------------------------------------------------------------------------------------------

pairs(births)

hist(births$gestwks)

plot(sex ~ bweight, data = births)
#
# Q. Generate a faceted histogram of birth weight broken down by sex.

# CLEAN DATA ----------------------------------------------------------------------------------------------------------

births = select(births, -id)

# Drop records with missing data.
#
births = na.omit(births)

# Create factors.
#
births = mutate(births,
                lowbw = factor(lowbw, labels = c(FALSE, TRUE)),
                preterm = factor(preterm, labels = c(FALSE, TRUE)),
                hyp = factor(hyp, labels = c(FALSE, TRUE)),
                sex = factor(sex, labels = c("Male", "Female"))
)

# MORE EXPLORATORY ANALYSIS -------------------------------------------------------------------------------------------

pairs(births)

plot(sex ~ bweight, data = births)
plot(sex ~ lowbw, data = births)
plot(sex ~ gestwks, data = births)
plot(sex ~ preterm, data = births)
plot(sex ~ matage, data = births)
plot(sex ~ hyp, data = births)

# Q. Make a scatter plot of sex versus birth weight.

# HYPOTHESIS TESTS ----------------------------------------------------------------------------------------------------

# Q. Use a t test to see whether there is a difference in birth weight of male and female babies. Conclusions?

# LOGISTIC MODEL ------------------------------------------------------------------------------------------------------

# Q. Fit a logistic regression model for sex against all other features. Use all of the data for the moment.
#
# births.glm <- glm()

# FEATURE SELECTION ---------------------------------------------------------------------------------------------------

library(MASS)

# The stepwise procedure is going to try to minimise AIC.
#
births.glm <- stepAIC(births.glm, direction = "both")

summary(births.glm)

# PREDICTIONS ---------------------------------------------------------------------------------------------------------

head(predict(births.glm, type = "link"))                # log odds
head(predict(births.glm, type = "response"))            # probability

# TRAIN/TEST SPLIT ----------------------------------------------------------------------------------------------------

TFRAC = 0.2

index = sample(1:nrow(births), TFRAC * nrow(births))

# CARET ---------------------------------------------------------------------------------------------------------------

library(caret)

births.glm <- train(sex ~ ., data = births[-index,], method = "glm")

summary(births.glm)

# ASSESSMENT ----------------------------------------------------------------------------------------------------------

# Q. Generate a confusion matrix manually.
# Q. Use confusionMatrix().

# =====================================================================================================================
# LOGISTIC REGRESSION SOLUTIONS
# =====================================================================================================================

ggplot(births, aes(x = bweight)) + geom_histogram() + facet_wrap(~ sex, ncol = 1)

ggplot(births, aes(x = bweight, y = sex)) +
  geom_jitter(aes(col = factor(sex)), width = 0, height = 0.125, alpha = 0.25) +
  theme_classic()

t.test(subset(births, sex = "Male")$bweight, subset(births, sex = "Female")$bweight)

births.glm <- glm(sex ~ ., data = births, family = binomial)
#
summary(births.glm)

table(predict(births.glm, births[index,]), births[index,]$sex)
#
confusionMatrix(predict(births.glm, births[index,]), births[index,]$sex)
