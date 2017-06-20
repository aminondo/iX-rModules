# To expose the API below do the following in the console:
#
#setwd("API")
#library(plumber)
#r <- plumb("api_tutorial.R") 
# > r$run(port = 8000)

# GLOBAL ---------------------------------------------------------------------------------------------------------------------
library(rpart)
library(rattle)
library(vcdExtra)
fit = rpart(Species ~ Petal.Length + Petal.Width, data=iris)

# GET -----------------------------------------------------------------------------------------------------------------

#* @get /predict
#* @param pl = petal length
#* @param pw = petal width
function(pl = 0,pw=0){
  newdata = data.frame(
    Petal.Length = as.numeric(pl),
    Petal.Width = as.numeric(pw)
  )
  predict(fit, newdata, type = "class")
  
}


#* @serializer contentType list(type="application/pdf")
#* @get /tree
function(){
  plotfile <- tempfile()
  pdf(plotfile)
  fancyRpartPlot(fit)
  dev.off()
  
  readBin(plotfile, "raw", n = file.info(plotfile)$size)
}

#* @serializer contentType list(type="application/pdf")
#* @get /titanic

function(cp=.5){
  local.fit = rpart(survived ~ ., data=Titanicp, control=rpart.control(as.numeric(cp)))
  plotfile <- tempfile()
  pdf(plotfile)
  fancyRpartPlot(local.fit)
  dev.off()
  
  readBin(plotfile, "raw", n = file.info(plotfile)$size)
}

# POST ----------------------------------------------------------------------------------------------------------------

# POST interface:
#
# $ curl --data "a=4,3&b=5" "http://localhost:8000/sum"
#
# > library(httr)
# > response = POST("http://localhost:8000/sum", body = list(a = 3, b = 5), encode = "form")
# > response
# > content(response)

#* @post /sum
function(a, b) {
  do.call("+", lapply(strsplit(c(a, b), ","), as.numeric))
}

# GLOBALS -------------------------------------------------------------------------------------------------------------

# Global variables allow you to persist state.

values <- c()

#* @get /append
function(x) {
  x <- as.numeric(x)
  if (is.na(x)) {
    return("Parameter x must be a number.")
  }
  values <<- c(values, x)
  
  list(result = values, count = length(values))
}

# RESPONSE FORMATS ----------------------------------------------------------------------------------------------------

#* @png
#* @get /histogram
function(n = 10000) {
  hist(rnorm(n), col = "lightblue", main = "", xlab = "x", probability = TRUE, breaks = 50)
}

#* @serializer contentType list(type="application/pdf")
#* @get /pdf
function(){
  plotfile <- tempfile()
  pdf(plotfile)
  plot(sin((0:50) / 10 * pi), type = "b", ylab = "y", xlab = "x")
  dev.off()
  
  readBin(plotfile, "raw", n = file.info(plotfile)$size)
}

#* @serializer contentType list(type="text/plain")
#* @get /text
function(){
  "A simple text string."
}

#* @serializer contentType list(type="text/html")
#* @get /html
function(){
  "<html><h1>H1 Header</h1><p>Content goes here...</p></html>"
}
