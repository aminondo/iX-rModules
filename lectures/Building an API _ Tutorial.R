# To expose the API below do the following in the console:
#
# > library(plumber)
# > r <- plumb("___________________") # Insert correct file name here!
# > r$run(port = 8000)

# ---------------------------------------------------------------------------------------------------------------------

#* @get /date
function(){
  Sys.Date()
}

#* @post /echo
function(stuff){
  stuff
}

# GET -----------------------------------------------------------------------------------------------------------------

# GET interface:
#
# - http://localhost:8000/greeting
# - http://localhost:8000/random
# - http://localhost:8000/random?mean=10&samples=20

#* @get /greeting
function() {
  "Hello there! Welcome to my API."
}

#* @get /time
function(tz = "") {
  strftime(Sys.time(), format = "%x %X %Z", tz = tz)
}

#* @get /system
function() {
  paste(Sys.info()[c("sysname", "version")], collapse = " ")
}

# A list() response is serialised into a JSON document.
#
#* @get /random
function(samples = 10, mean = 0, sd = 1) {
  # All GET parameters are submitted as strings, so change to appropriate types.
  #
  samples = as.integer(samples)
  mean = as.numeric(mean)
  sd = as.numeric(sd)
  #
  random = rnorm(samples, mean, sd)
  #
  list(samples = random, mean = mean(random), median = median(random))
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
