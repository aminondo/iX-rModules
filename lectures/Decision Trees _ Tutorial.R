# =====================================================================================================================
# DECISION TREE TUTORIAL
# =====================================================================================================================

set.seed(1)

library(dplyr)
library(rattle)

library(rpart)
library(party)
library(caret)

# ---------------------------------------------------------------------------------------------------------------------
# TITANIC
# ---------------------------------------------------------------------------------------------------------------------

library(vcdExtra)

fit <- rpart(survived ~ ., data = Titanicp)
#
fit

plot(fit)
text(fit)
#
# That's ugly!

# Let's beautify.
#
fancyRpartPlot(fit)
#
# That seems very complicated!

# Train again with larger Complexity Parameter.
#
fit <- rpart(survived ~ ., data = Titanicp, control = rpart.control(cp = 0.015))
#
fit

# EXERCISES:
#
# 1. Summarise the decision tree in words.

fit <- ctree(survived ~ ., data = Titanicp)
#
fit

plot(fit)

# EXERCISES:
#
# 1. Summarise this conditional inference tree in words.
# 2. Estimate the survival probability for the following passengers:
#
#    a) a seven year old boy travelling in second class without any siblings;
#    b) a lady travelling in second class with her husband and two sisters.

# ---------------------------------------------------------------------------------------------------------------------
# IRIS
# ---------------------------------------------------------------------------------------------------------------------

head(iris)

fit <- rpart(Species ~ ., data = iris)
#
fancyRpartPlot(fit)

# EXERCISES:
#
# 1. Summarise this decision tree in words.
# 2. Classify these irises:
#
#    Petal.Length Petal.Width
#        2.0          0.3
#        3.0          1.5
#        2.8          2.0

fit <- ctree(Species ~ ., data = iris)
#
plot(fit)

# ---------------------------------------------------------------------------------------------------------------------
# LONDON BIRTHS
# ---------------------------------------------------------------------------------------------------------------------

library(Epi)
#
data(births)

# CLEAN DATA ----------------------------------------------------------------------------------------------------------

births = dplyr::select(births, -id) %>%
  na.omit %>%
  mutate(
    lowbw = factor(lowbw, labels = c(FALSE, TRUE)),
    preterm = factor(preterm, labels = c(FALSE, TRUE)),
    hyp = factor(hyp, labels = c(FALSE, TRUE)),
    sex = factor(sex, labels = c("Male", "Female"))
  )

# DECISION TREE -------------------------------------------------------------------------------------------------------

(births.rpart <- rpart(sex ~ ., data = births))

summary(births.rpart)

# Simple plot.
#
plot(births.rpart)
text(births.rpart)

# Better plot.
#
fancyRpartPlot(births.rpart, sub = "")
#
# Whoaaah! That seems very complicated, right?

# A simpler model (with non-default hyperparameter).
#
(births.rpart <- rpart(sex ~ ., data = births, control = rpart.control(cp = 0.02)))
#
fancyRpartPlot(births.rpart, sub = "")
#
# This is much too simple, but it's rather informative.

ggplot(births, aes(x = bweight)) +
  geom_histogram() +
  facet_wrap(~ sex, ncol = 1) +
  theme_minimal()

# TRAIN/TEST SPLIT ----------------------------------------------------------------------------------------------------

TFRAC = 0.2

index = sample(1:nrow(births), TFRAC * nrow(births))

# CARET ---------------------------------------------------------------------------------------------------------------


# Optimise hyperparameter.
#
(births.rpart <- train(sex ~ ., data = births[-index,], method = "rpart"))

births.rpart
births.rpart$finalModel

# PREDICTIONS ---------------------------------------------------------------------------------------------------------

predict(births.rpart, births[index,])

# We can also get the class probabilities.
#
predict(births.rpart, births[index,], type = "prob")

# ASSESSMENT ----------------------------------------------------------------------------------------------------------

confusionMatrix(predict(births.rpart, births[index,]), births[index,]$sex)

# CONDITIONAL INFERENCE TREE ------------------------------------------------------------------------------------------

births.ctree <- ctree(sex ~ ., data = births)

plot(births.ctree)

# ---------------------------------------------------------------------------------------------------------------------
# EXERCISES
# ---------------------------------------------------------------------------------------------------------------------

# 1. Build a conditional inference tree to predict the likelihood of credit default using the Default data from ISLR.
#
#    a) What is the general relationship between balance and likelihood of default?
#    b) For a loan of balance 1850, is default more or less likely for an income of 30000 versus 20000?
#
# 2. Build a conditional inference tree to predict the likelihood of heart disease.
#
# Use data from http://archive.ics.uci.edu/ml/datasets/heart+Disease.
#
#    a) Evaluate the accuracy of the model.
#    b) What's the most important feature for determining the outcome?
#    c) Estimate the probability of heart disease for these patients:
#
#       - a 53 year old woman with atypical angina;
#       - a 60 year old man with non-anginal pain;
#       - a 43 year old man with asymptomatic pain;
#       - a 47 year old woman with asymptomatic pain and resting blood pressure of 150 mm Hg.