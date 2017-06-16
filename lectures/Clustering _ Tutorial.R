# =====================================================================================================================
# CLUSTERING TUTORIAL
# =====================================================================================================================

library(cluster)

# XCLARA --------------------------------------------------------------------------------------------------------------

# Q. Plot the xclara data. How many clusters are there?
# Q. Use kmeans to cluster these data.
# Q. Plot the cluster assignment.
# Q. Produce a plot which shows the quality of clustering as a function of the number of clusters.

# PLUTONIUM -----------------------------------------------------------------------------------------------------------

# Q. Plot the pluton data. How many clusters are there? Is there an obvious way to answer this question?
# Q. Add a column for Pu-242. Note that the rows do not currently sum to 100%.
# Q. Do you need to do anything with the data before you cluster it?
# Q. Estimate a reasonable number of clusters.
# Q. Calculate the average concentration of Pu-242 per cluster.

# ALCOHOL CONSUMPTION -------------------------------------------------------------------------------------------------

# Q. Scrape the data from https://en.wikipedia.org/wiki/List_of_countries_by_alcohol_consumption_per_capita.
# Q. Do some pre-processing to get the data into shape.
# Q. Consider which features should be excluded from a clustering analysis.
# Q. Create a hierarchical cluster showing which countries have similar alcohol consumption patterns.
# Q. Cut the tree into two clusters and interpret.