# =====================================================================================================================
# VALIDATION EXERCISES
# =====================================================================================================================

library(dplyr)
library(caret)
install.packages("caret")
install.packages("ggplot2")
library(vcdExtra)
library(Metrics)
library(ggplot2)
# BOOTSTRAPPING INTUITION ---------------------------------------------------------------------------------------------

set.seed(17)

# Q. Simulate height data. Generate 1000 samples with mean 180 and standard deviation 10.
height = rnorm(1000,180,10)
# Q. Make a quick visualisation.
hist(height)
# Q. Calculate the sample mean and standard deviation.
mean(height)
sd(height)
# Q. Estimate the standard deviation of the mean.



# Q. Generate a bootstrap estimate of the standard deviation of the mean.
#     - Generate a bootstrap sample from the data. Remember to sample with replacement.
#     - Calculate the mean of the bootstrap sample.
#     - Repeat to gather multiple bootstrap means.
#     - Write a neat chunk of code to do this automatically.
NBOOT=100
height_pop = sapply(1:NBOOT, function(s){
  sample(height,1000,replace=T)
})
mean_pop = apply(height_pop,2,mean)
mean_pop
sd_pop = sd(mean_pop)
# BOOTSTRAP VALIDATION ------------------------------------------------------------------------------------------------

# Q. Build a simple Decision Tree model using the rpart package to predict Species in the iris data.
NBOOT=100
iris_pop = sapply(1:NBOOT, function(s){
  sample(iris,300,replace=T)
})

bootstrap_idx = sample(1:nrow(iris), nrow(iris), replace=T)
train = iris[bootstrap_idx,]
test = iris[-bootstrap_idx,]
train_fit = rpart(Species ~ ., data=train)
pred_fit = predict(train_fit, newdata=test, type="class")
mean(pred_fit == test$Species)

accuracy = sapply(1:100, function(x){
  bootstrap_idx = sample(1:nrow(iris), nrow(iris), replace=T)
  train = iris[bootstrap_idx,]
  test = iris[-bootstrap_idx,]
  train_fit = rpart(Species ~ ., data=train)
  pred_fit = predict(train_fit, newdata=test, type="class")
  mean(pred_fit == test$Species)
})
hist(accuracy)
# Q. How can we assess the accuracy of this model? (Don't do it, just think about it.)
# Q. Generate a bootstrap estimate of the model accuracy.
#     - Generate a bootstrap sample from the iris data.
#     - Build a model using these data for training.
#     - Test the model on the remaining data and assess the accuracy.
#     - Repeat to gather multiple bootstrap estimates of the accuracy.
#     - Calculate the mean and standard deviation of the accuracy estimates.

# CROSS-VALIDATION ----------------------------------------------------------------------------------------------------

# Q. Using a Decision Tree model on the iris data, generate a cross-validation estimate of model accuracy.
#     - Create an index with values between 1 and 10 randomly assigned to the rows of the iris data.
#     - Train a model on all rows with indices except n = 1.
#     - Test the model on rows with index n = 1 and assess the accuracy.
#     - Repeat for n = 2 through n = 10.
#     - Calculate the mean and standard deviation of the accuracy estimates.

iris_cv = iris %>% mutate(
                      k = sample(1:10,nrow(.),replace=T))
iris_cv
View(iris_cv)
library(rpart)
library(rattle)

models = lapply(1:10, function(n){
  fit <- rpart(Species ~ ., data =filter(iris_cv, k!=n))
})
#fit <- rpart(k ~ ., data = iris_cv)
models
#fancyRpartPlot(models[[2]])

#n=1
#predict(models[[n]], filter(iris_cv, k==n), type="class")
meanCV =sapply(1:10, function(n){
  fold_pred = predict(models[[n]], filter(iris_cv, k==n), type="class")
  fold_ref = filter(iris_cv,k==n)$Species
  mean(fold_pred == fold_ref)
})
mean(meanCV)
sd(meanCV)
# REGRESSION: CARS ----------------------------------------------------------------------------------------------------

# We're going to model the stopping distance as a function of speed.
#
head(cars)

# First let's get some civilised units.
#
cars = transform(cars,
                 dist = 0.3048 * dist,                             # feet to metres
                 speed = 1.60934 * speed                           # miles/hour to km/hour
)

dim(cars)
#
# Since there are only 50 records in the data it seems extravagant to leave out 20% for testing, right?

# Let's start by doing it the "old" way.
#
cars = split(cars, sample(c(T, F), nrow(cars), replace = TRUE, prob = c(0.8, 0.2)))
names(cars) = c("test", "train")

fit <- lm(dist ~ speed, data = cars$train)

rmse(cars$test$dist, predict(fit, cars$test))
#
# But this is just a single estimate of the RMSE. Has it occurred to you that there might be uncertainty surrounding
# this estimate?

# Enter cross validation.
#
fit.cars <- train(dist ~ speed, data = cars$train, method = "lm",
                  trControl = trainControl(
                    method = "cv",
                    number = 10,
                    verboseIter = TRUE
                  ))
fit.cars
#
# But we can get more information relating to RMSE, specifically the associated standard deviation.
#
fit.cars$results
#
# Compare the simple RMSE we calculated above.

summary(fit.cars)
#
# Access the optimal model directly.
#
fit.cars$finalModel

# CLASSIFICATION: TITANIC ---------------------------------------------------------------------------------------------

fit.titanic <- train(survived ~ ., data = Titanicp, method = "glm",
                     na.action = na.omit,
                     trControl = trainControl(
                       method = "repeatedcv",
                       number = 10,
                       repeats = 5,
                       verboseIter = TRUE
                     ))
#
# Here we are doing 10 fold cross validation and the process is being repeated 5 times. This takes a little longer but
# gives an even more reliable estimate of the model performance.

fit.titanic
#
# Again we can get an indication of the uncertainty in the accuracy.
#
fit.titanic$results

# Can we estimate other (more useful) metrics than accuracy?
#
fit.titanic <- train(survived ~ ., data = Titanicp, method = "glm",
                     metric = "Sens",
                     na.action = na.pass,
                     trControl = trainControl(
                       method = "repeatedcv",
                       number = 10,
                       repeats = 5,
                       classProbs = TRUE,
                       summaryFunction = twoClassSummary,
                       verboseIter = TRUE
                     ))
#
fit.titanic
fit.titanic$results
#
# That looks too good to be true. When we modelled the Titanic data before the sensitivity was worse than the specificity.
#
# Cultivate your skepticism (the "jaundiced eye")!
#
# What's happening?

# Maybe this will provide a clue?
#
confusionMatrix(predict(fit.titanic, Titanicp), na.omit(Titanicp)$survived)

# caret treats the first factor level in the outcome as the positive class.
#
levels(Titanicp$survived)
#
# We need to relevel the factor.
#
Titanicp$survived = relevel(Titanicp$survived, "survived")
levels(Titanicp$survived)
#
# That looks better. Now train the model again and check the metrics.

# CARET: OPTIONS FOR VALIDATION ---------------------------------------------------------------------------------------

# CROSS-VALIDATION
#
train(Species ~ ., data = iris, method = "rpart", trControl = trainControl(method = "cv",
                                                                           verboseIter = TRUE,
                                                                           number = 10))

# REPEATED CROSS-VALIDATION
#
train(Species ~ ., data = iris, method = "rpart", trControl = trainControl(method = "repeatedcv",
                                                                           verboseIter = TRUE,
                                                                           number = 10,
                                                                           repeats = 5))

# BOOTSTRAPPING
#
train(Species ~ ., data = iris, method = "rpart", trControl = trainControl(method = "boot",
                                                                           verboseIter = TRUE,
                                                                           number = 50))

# CARET: PARAMETER TUNING ---------------------------------------------------------------------------------------------

# Recall that a Decision Tree has a complexity parameter which can be used to determine the depth of the tree.
#
# How does one objectively choose the best value for this parameter?

fit.titanic <- train(survived ~ ., data = Titanicp, method = "rpart",
                     metric = "Sens",
                     na.action = na.omit,
                     trControl = trainControl(
                       method = "cv",
                       number = 10,
                       classProbs = TRUE,
                       summaryFunction = twoClassSummary,
                       verboseIter = TRUE
                     ))

fit.titanic
#
# This gives us the values of AUC, sensitivity and specificity for a selection of complexity parameter values.
#
# A heuristic is used to determine the values assessed.
#
# What if we want to provide our own selection of values?

fit.titanic <- train(survived ~ ., data = Titanicp, method = "rpart",
                     tuneGrid = data.frame(cp = seq(0.00125, 0.05, 0.00125)),
                     metric = "Sens",
                     na.action = na.omit,
                     trControl = trainControl(
                       method = "repeatedcv",
                       number = 10,
                       repeats = 5,
                       classProbs = TRUE,
                       summaryFunction = twoClassSummary,
                       verboseIter = TRUE
                     ))
#
# This gives us the optimal value of the complexity parameter.
#
plot(fit.titanic)
#
# What does the "optimal" model look like?
#
fit.titanic$finalModel
#
# Bear in mind that this was to optimise for sensitivity. Run it again, but this time to optimise for
#
# a) accuracy and
# b) specificity.

# =====================================================================================================================
# VALIDATION SOLUTIONS
# =====================================================================================================================

# BOOTSTRAPPING INTUITION ---------------------------------------------------------------------------------------------

heights <- rnorm(1000, mean = 180, sd = 10)

# BOOTSTRAP VALIDATION ------------------------------------------------------------------------------------------------


# CROSS-VALIDATION ----------------------------------------------------------------------------------------------------


# =====================================================================================================================
# VALIDATION TUTORIAL (OLD)
# =====================================================================================================================

library(vcdExtra)
library(dplyr)
library(rpart)

# TITANIC: TRAIN/TEST -------------------------------------------------------------------------------------------------

index <- sample(1:nrow(Titanicp), 0.2 * nrow(Titanicp))

titanic.rpart <- rpart(survived ~ ., data = Titanicp[-index,])

# Estimate accuracy.
#
sum(predict(titanic.rpart, Titanicp[index,], type = "class") == Titanicp[index,]$survived) / length(index)
#
# What are the problems with this approach?

# TITANIC: CROSS-VALIDATION (MANUAL) ----------------------------------------------------------------------------------

# 1. Divide the data into K folds.
# 2. Repeat train/test for each fold.
# 3. Summarise the accuracy across folds.

K <- 10

fold <- (sample(1:nrow(Titanicp)) %% K) + 1
#
table(fold)

accuracy = sapply(1:K, function(n) {
  mask <- fold == n
  titanic.rpart <- rpart(survived ~ ., data = Titanicp[!mask,])
  sum(predict(titanic.rpart, Titanicp[mask,], type = "class") == Titanicp[mask,]$survived) / sum(mask)
})

mean(accuracy)
sd(accuracy)
sd(accuracy) / sqrt(10)

# TITANIC: CROSS-VALIDATION (CARET) -----------------------------------------------------------------------------------

titanic.rpart <- train(survived ~ ., data = Titanicp, method = "rpart",
                       trControl = trainControl(method = "cv",
                                                number = 10,
                                                verboseIter = TRUE))

titanic.rpart
titanic.rpart$results

# K-FOLD CROSS-VALIDATION ---------------------------------------------------------------------------------------------

library(aplore3)
library(caret)

# To mix things up a bit, let's look at a different data set.

# -> GLM | CV with Accuracy.
#
(myopia.glm <- train(myopic ~ ., data = myopia, method = "glm",
                     trControl = trainControl(method = "cv",
                                              number = 10,
                                              verboseIter = TRUE)))

names(myopia.glm)

# Summary of CV results.
#
myopia.glm$results

# Results for each fold.
#
myopia.glm$resample

# Details of folds.
#
myopia.glm$control$index$Fold10
myopia.glm$control$indexOut$Resample10

# -> GLM | CV with AUC.
#
(myopia.glm <- train(myopic ~ ., data = myopia, method = "glm", metric = "ROC",
                     trControl = trainControl(method = "cv",
                                              number = 10,
                                              classProbs = TRUE,
                                              summaryFunction = twoClassSummary)))

# -> Decision Tree | CV with AUC.
#
(myopia.rpart <- train(myopic ~ ., data = myopia, method = "rpart", metric = "ROC",
                       trControl = trainControl(method = "cv",
                                                number = 10,
                                                classProbs = TRUE,
                                                summaryFunction = twoClassSummary)))

plot(myopia.rpart)

library(rattle)

fancyRpartPlot(myopia.rpart$finalModel)

# -> Decision Tree | CV with Specificity and grid.
#
(myopia.rpart <- train(myopic ~ ., data = myopia, method = "rpart", metric = "Spec",
                       tuneGrid = expand.grid(cp = seq(0, 0.10, 0.02)),
                       trControl = trainControl(method = "cv",
                                                number = 10,
                                                classProbs = TRUE,
                                                summaryFunction = twoClassSummary)))

plot(myopia.rpart)

fancyRpartPlot(myopia.rpart$finalModel)

# LOOCV ---------------------------------------------------------------------------------------------------------------

(myopia.ctree <- train(myopic ~ ., data = myopia, method = "ctree", metric = "ROC",
                       trControl = trainControl(method = "LOOCV",
                                                number = 10,
                                                classProbs = TRUE,
                                                summaryFunction = twoClassSummary)))

plot(myopia.ctree)

plot(myopia.ctree$finalModel)
#
# Interpret this tree.

# REPEATED CROSS-VALIDATION -------------------------------------------------------------------------------------------

(myopia.svm <- train(myopic ~ ., data = myopia, method = "svmRadial",
                     tuneGrid = expand.grid(sigma = seq(0.01, 0.03, 0.01), C = seq(1, 10, 1)),
                     trControl = trainControl(method = "repeatedcv",
                                              number = 5,
                                              repeats = 3,
                                              verboseIter = TRUE)))

plot(myopia.svm)

# BOOTSTRAP -----------------------------------------------------------------------------------------------------------

(myopia.nnet <- train(myopic ~ ., data = myopia, method = "nnet",
                      tuneGrid = expand.grid(size = seq(1, 7, 2), decay = c(0.01, 0.1, 1, 10)),
                      trControl = trainControl(method = "boot",
                                               number = 10)))

plot(myopia.nnet)
