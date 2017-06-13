# =====================================================================================================================
# MACHINE LEARNING CONCEPTS EXERCISES
# =====================================================================================================================

# Grab data from lecture.
load("~/Desktop/Data Science/iX-rModules/lectures/red-blue-points.RData")
View(known)
View(unknown)

known$predict = sapply(1:nrow(known), function(point){
  datum = known[point,]
  print(datum)
  r = sqrt(datum$x^2 + datum$y^2)
  color = ifelse(abs(r)<1,"red","blue")
})

known$correct = known$colour == known$predict
View(known)

library(ggplot2)

ggplot(known, aes(x,y, color=colour, shape = correct)) + geom_point()

count = sum(known$correct)
accuracy = count/nrow(known)
accuracy
# TRAIN/TEST SPLIT ----------------------------------------------------------------------------------------------------


# Q. Split the data into train/test partitions.
known$train = sample(c(T,F),300, prob=(c(.8,.2)), replace=TRUE)
View(known)
known$predict = NULL
known$correct = NULL
# CARTESIAN SOLUTION --------------------------------------------------------------------------------------------------

# Q. Use a graphical approach to finding a threshold on x and y to differentiate between red/blue points.
#    - You should only do this with the train partition, right?
ggplot(subset(known,train)) + geom_histogram(aes(x=x, color = colour))
# Q. Write a function which will use x and y coordinates to differentiate between red/blue points.
train = subset(known,train)
test = subset(known,train==F)
train$predict = sapply(1:nrow(train), function(point){
  datum = train[point,]
  print(datum)
  r = sqrt(datum$x^2 + datum$y^2)
  color = ifelse(abs(r)<1,"red","blue")
})

test$predict = sapply(1:nrow(test), function(point){
  datum = test[point,]
  print(datum)
  r = sqrt(datum$x^2 + datum$y^2)
  color = ifelse(abs(r)<1,"red","blue")
})
View(train)
accuracy = sum(train$colour==train$predict)/nrow(train)
accuracy

ggplot(subset(known,train)) + geom_histogram(aes(x=r, color = colour))

# Q. Use this function to make predictions for the test partition.
#    - Calculate accuracy.
#    - Generate a confusion matrix.

table(test$predict,test$colour)

# ENGINEER FEATURES ---------------------------------------------------------------------------------------------------

# Q. Add a new feature, r = sqrt(x**2 + y**2), to the data.

# POLAR SOLUTION ------------------------------------------------------------------------------------------------------

# Q. Use a graphical approach to finding a threshold on r.
# Q. Write a function which will use r to differentiate between red/blue points.
# Q. Use this function to make predictions for the test partition.
#    - Calculate accuracy.
#    - Generate a confusion matrix.

# CARTESIAN PREDICTED -------------------------------------------------------------------------------------------------

# POLAR PREDICTED -----------------------------------------------------------------------------------------------------

# =====================================================================================================================
# MACHINE LEARNING CONCEPTS SOLUTIONS
# =====================================================================================================================

# TRAIN/TEST SPLIT ----------------------------------------------------------------------------------------------------

head(known)

TFRAC = 0.2

index = sample(1:nrow(known), TFRAC * nrow(known))

test.data <- known[index,]
train.data <- known[-index,]

# CARTESIAN SOLUTION --------------------------------------------------------------------------------------------------

library(ggplot2)

# Find thresholds for x and y.
#
ggplot(train.data, aes(x)) + geom_histogram(binwidth = 0.1) + facet_wrap(~colour, ncol = 1)
ggplot(train.data, aes(y)) + geom_histogram(binwidth = 0.1) + facet_wrap(~colour, ncol = 1)

model.cartesian <- function(x, y) {
  ifelse(x >= -1 & x <= +1 & y >= -1 & y <= +1, "red", "blue")
}

# Make predictions.
#
cartesian.predicted = with(test.data, model.cartesian(x, y))

# Accuracy
#
sum(cartesian.predicted == test.data$colour) / length(cartesian.predicted)

# Confusion Matrix
#
table(cartesian.predicted, test.data$colour)

# ENGINEER FEATURES ---------------------------------------------------------------------------------------------------

library(dplyr)

known <- mutate(known, r = sqrt(x**2 + y**2))

nrow(known)

# POLAR SOLUTION ------------------------------------------------------------------------------------------------------

# Find thresholds for r.
#
ggplot(train.data, aes(x)) + geom_histogram(binwidth = 0.1) + facet_wrap(~colour, ncol = 1)

model.polar <- function(r) {
  ifelse(r <= 1, "red", "blue")
}

# Make predictions.
#
polar.predicted = model.polar(test.data$r)

# Accuracy
#
sum(polar.predicted == test.data$colour) / length(polar.predicted)

# Confusion Matrix
#
table(polar.predicted, test.data$colour)
