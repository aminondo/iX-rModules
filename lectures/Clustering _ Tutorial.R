# =====================================================================================================================
# CLUSTERING TUTORIAL
# =====================================================================================================================
install.packages("cluster")
#install.packages("RDatasets")
library(cluster)
library(ggplot2)
library(dplyr)
# XCLARA --------------------------------------------------------------------------------------------------------------
View(xclara)
# Q. Plot the xclara data. How many clusters are there?
ggplot(xclara, aes(V1,V2)) + geom_point(aes(alpha=.5))

# Q. Use kmeans to cluster these data.
#first scale the data
xclara_sl = scale(xclara)
View(xclara_sl)
apply(xclara_sl,2,mean) #normalized, scale has mean o and standard deviation of 1
apply(xclara_sl,2,sd)
class(xclara_sl)
#set.seed(50)
xclara_sl = as.data.frame(xclara_sl)
ggplot(xclara_sl, aes(V1,V2)) + geom_point(aes(alpha=.5))

xclara.cl=kmeans(xclara_sl,3)
xclara_sl$cluster = xclara.cl$cluster
xclara$cluster = xclara.cl$cluster
# Q. Plot the cluster assignment.

xclara$cluster = as.factor(xclara$cluster)
ggplot(xclara, aes(V1,V2)) + geom_point(aes(alpha=.5,color=cluster))


# Q. Produce a plot which shows the quality of clustering as a function of the number of clusters.

variance_explained =lapply(1:10, function(x){
  kmeans(xclara_sl,x)
}) %>% sapply(function(cluster){
  cluster$betweenss/cluster$totss
})
class(variance_explained)
variance_explained = data.frame(x=1:10,y=variance_explained)
ggplot(variance_explained,aes(x,y)) +geom_point()+geom_line() + xlab("Number of Clusters (k)") +ylab("Variance Explained")# + geom_smooth(method="glm")
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