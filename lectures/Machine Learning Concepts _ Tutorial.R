# =====================================================================================================================
# MACHINE LEARNING CONCEPTS EXERCISES
# =====================================================================================================================

# Grab data from lecture.

# TRAIN/TEST SPLIT ----------------------------------------------------------------------------------------------------

# Q. Split the data into train/test partitions.

# CARTESIAN SOLUTION --------------------------------------------------------------------------------------------------

# Q. Use a graphical approach to finding a threshold on x and y to differentiate between red/blue points.
#    - You should only do this with the train partition, right?
# Q. Write a function which will use x and y coordinates to differentiate between red/blue points.
# Q. Use this function to make predictions for the test partition.
#    - Calculate accuracy.
#    - Generate a confusion matrix.

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