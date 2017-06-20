# =====================================================================================================================
# FEATURE ENGINEERING EXERCISES
# =====================================================================================================================

# RED/BLUE ------------------------------------------------------------------------------------------------------------

# a) Build a data set with the following specifications:
#    - points for x >= 0 and y >= 0 and y < 1 - x are red;
#    - points for x <= 1 and y <= 1 and y >= 1 - x are blue.
# b) Create a Decision Tree to classify points as red or blue.
# c) What is the accuracy of the model? Explain the performance. Draw out the decision regions.
# d) Create one or more new features which will improve the model.
library(dplyr)
library(ggplot2)
library(rpart)
library(rattle)
library(caret)
data = data.frame(x=runif(500,0,1),y=runif(500,0,1))
data
data = mutate(data,color = factor(ifelse(y<1-x,"Red","Blue"),levels=c("Red","Blue")))
ggplot(data, aes(x,y,color=color))+geom_point()
fit = rpart(color ~ .,data)
printcp(fit)
train(color ~ ., data, method = "rpart", trControl = trainControl(method = "cv",
                                                                           verboseIter = TRUE,
                                                                           number = 10))
fancyRpartPlot(fit)
#pred_fit = predict(fit)
#pred_fit
new_data = data %>% mutate(sep = y+x-1)
new_data
nfit = rpart(color ~ ., new_data)
fancyRpartPlot(nfit)
# SAUSAGE -------------------------------------------------------------------------------------------------------------
install.packages("SemiPar")
library(SemiPar)
data(sausage)
head(sausage)
tail(sausage)
# a) Generate a Decision Tree model to predict sausage type using the sausage data from the SemiPar package.
train(type ~ .,sausage,method="rpart", trControl=trainControl(method="cv",
                                                verboseIter=T,
                                                number=10))
# b) Assess the accuracy of the model.
#   45.8 %
# c) Add one or more new features to the data.
ggplot(sausage, aes(sodium,calories,color=type))+geom_point()
nsausage = sausage %>% mutate(ratio = calories/sodium) 

train(type ~ .,nsausage,method="rpart", trControl=trainControl(method="cv",
                                                              verboseIter=T,
                                                              number=10))
# d) Build a new model. Is the performance of the new model an improvement?
# added ratio accuracy imprived to 61.5%
# e) Plot out the resulting Decision Tree and interpret. What do you learn about sausages.
fit = rpart(type ~ ., nsausage, cp=.02941176)
fancyRpartPlot(fit)
# ABALONE -------------------------------------------------------------------------------------------------------------

# Construct a model to predict Abalone age.
#
# a) Get data from http://archive.ics.uci.edu/ml/datasets/Abalone.
# b) Engineer an "age" feature. Remove any resulting redundant features.
# c) Train a logistic regression reference model to predict age.
# d) Try to improve the reference model by using interactions.
# e) Try to improve the reference model by engineering new features.

# BIKE SHARING --------------------------------------------------------------------------------------------------------

# a) Grab the bike sharing data from http://bit.ly/29RVPlz.
# b) Build a model to predict the count of bikes rented (cnt).
# c) Add new features to improve the performance of the model. Ideas for new features:
#    - number of bikes rented in each of previous 12 hours (12 new features);
#    - number of bikes rented in same hour on each of previous 14 days (14 new features);
#    - number of bikes rented in same hour on same day of week for previous 8 days (8 new features).

# =====================================================================================================================
# FEATURE ENGINEERING SOLUTIONS
# =====================================================================================================================

library(dplyr)
library(ggplot2)
library(caret)

TRAINCONTROL <- trainControl(method = "repeatedcv", repeats = 5)

# RED/BLUE ------------------------------------------------------------------------------------------------------------

set.seed(13)

N <- 1000
#
points <- data.frame(
  x = runif(N, 0, 1),
  y = runif(N, 0, 1)
) %>% mutate(
  colour = factor(ifelse(y < 1 - x, "red", "blue"), levels = c("red", "blue"))
)

ggplot(points, aes(x = x, y = y)) + geom_point(aes(color = colour)) +
  theme_classic()

# A reference model.
#
(fit.rpart <- train(colour ~ ., data = points, method = "rpart"))
fit.rpart$finalModel

# Engineer new feature.
#
points <- mutate(points, above = x + y - 1)
#
# This new feature will change sign above and below the line y = 1 - x.

(fit.rpart <- train(colour ~ ., data = points, method = "rpart"))
fit.rpart$finalModel

# SAUSAGE -------------------------------------------------------------------------------------------------------------

library(SemiPar)

data(sausage)

(sausage.rpart <- train(type ~ ., data = sausage, method = "rpart"))

sausage <- mutate(sausage,
                  ratio = calories / sodium
                  )

(sausage.rpart <- train(type ~ ., data = sausage, method = "rpart"))

# ABALONE -------------------------------------------------------------------------------------------------------------

# http://archive.ics.uci.edu/ml/datasets/Abalone

abalone <- read.csv("http://archive.ics.uci.edu/ml/machine-learning-databases/abalone/abalone.data",
                    header = FALSE,
                    col.names = c("sex", "length", "diameter", "height", "whole", "shucked", "viscera", "shell", "rings"))

# Relevel sex factor.
#
abalone <- mutate(abalone,
                  sex = relevel(sex, "I")
)

# Features:
#
# sex              nominal			        M, F, and I (infant)
# length           continuous	    mm    longest shell measurement
# diameter         continuous	    mm    perpendicular to length
# height           continuous	    mm	  with meat in shell
# whole            continuous	    g	    whole abalone
# shucked          continuous     g	    mass of meat
# viscera          continuous     g	    gut mass (after bleeding)
# shell            continuous     g     after being dried
# rings		         integer              +1.5 gives the age in years

abalone <- mutate(abalone, age = rings + 1.5) %>% select(-rings)

# Reference model.
#
(abalone.lm <- train(age ~ ., data = abalone, method = "lm", trControl = TRAINCONTROL))

# New model (with interactions).
#
(abalone.lm <- train(age ~ . + length:sex + viscera:sex,
                     data = abalone.engineered, method = "lm", trControl = TRAINCONTROL))

# New features.
#
abalone.engineered = mutate(abalone,
                            whole_shucked = whole / shucked,
                            whole_length = whole / length
)

# New model (with engineered features).
#
(abalone.lm <- train(age ~ . + length:sex, data = abalone.engineered, method = "lm", trControl = TRAINCONTROL))

summary(abalone.lm$finalModel)

# BIKE SHARING --------------------------------------------------------------------------------------------------------

bikes <- read.csv("https://raw.githubusercontent.com/DataWookie/DataDiaspora/master/data/bike-sharing-hours.csv")

# PIMA INDIANS --------------------------------------------------------------------------------------------------------

library(mlbench)

data(PimaIndiansDiabetes)

head(PimaIndiansDiabetes)

# GLASS ---------------------------------------------------------------------------------------------------------------

# http://archive.ics.uci.edu/ml/datasets/Glass+Identification

# COVER TYPE ----------------------------------------------------------------------------------------------------------

# http://archive.ics.uci.edu/ml/datasets/Covertype

# CIGAR ---------------------------------------------------------------------------------------------------------------

library(Ecdat)

cigar.lm <- train(sales ~ ., data = Cigar, method = "lm")

# URINE ---------------------------------------------------------------------------------------------------------------

library(boot)

(urine.glm <- train(factor(r) ~ ., data = urine, method = "glm", trControl = TRAINCONTROL))