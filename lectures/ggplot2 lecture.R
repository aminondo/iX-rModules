## IX Data Science, Week 1, Day 4 
## Data Visualization
## ggplot2 examples

# import data
library(readr)
movies <- read.csv("../Week 1/movies.csv")
movies2 = movies[movies$audience_rating!="",] #removed empty rating
View(movies)

#install package
#install.packages("ggplot2") 

#load package
library(ggplot2) 


# INITIAL VISUALIZATION
#aes stands for aesthetic
#geom_point editing geometric objects

ggplot(data = movies, aes(x = audience_score, y = critics_score)) + geom_point()

# ALTERING FEATURES
#alpha = opacity
ggplot(data = movies, aes(x = audience_score, y = critics_score)) +
  geom_point(alpha = 0.5, color = "blue")


# FACETING
ggplot(data = movies, aes(x = audience_score, y = critics_score, color = genre)) +
  geom_point(alpha = 0.5) +
  facet_grid(. ~ title_type)

# How did the plot change?
#make it horizontal
# ~ 'as a function of' 
# . stands for everything
ggplot(data = movies, aes(x = audience_score, y = critics_score, color = genre)) +
  geom_point(alpha = 0.5) +
  facet_grid(. ~ title_type ~ .)

# MORE FACETING
ggplot(data = movies, aes(x = audience_score, y = critics_score, color = genre)) +
  geom_point(alpha = 0.5) +
  facet_grid(audience_rating ~ title_type)

# EVEN MORE FACETING
ggplot(data = movies, aes(x = audience_score, y = critics_score, color = title_type)) +
  geom_point(alpha = 0.5) +
  facet_wrap(~genre)


## Anatomy of ggplot2 

# ggplot(
#   data = [dataframe], 
#   aes(
#     x = [var_x], y = [var_y], 
#     color = [var_for_color], 
#     fill = [var_for_fill], 
#     shape = [var_for_shape]
#   )
# ) +
#   geom_[some_geom]([geom_arguments]) +
#   ... # other geometries
# scale_[some_axis]_[some_scale]() +
#   facet_[some_facet]([formula]) +
#   ... # other options


# HISTOGRAMS
ggplot(data = movies2, aes(x = audience_score, color='red', fill=genre)) +
  geom_histogram(binwidth = 5) + facet_grid(( . ~ audience_rating))


# DENSITY PLOT
ggplot(data = movies2, aes(x = runtime, color = audience_rating)) +
  geom_density() 

# create a limit for y-axis and x-axis...     
ggplot(data = movies2, aes(x = runtime, fill = audience_rating)) +
  geom_density(alpha=.5) + ylim(0, .04) + xlim(0, 200)


# MORE SCATTER PLOTS
ggplot(data = movies, aes(x = imdb_rating, y = audience_score)) +
  geom_point(alpha = 0.5) 


# SMOOTHING
ggplot(data = movies, aes(x = imdb_rating, y = audience_score)) +
  geom_point(alpha = 0.5) +
  geom_smooth()

ggplot(data = movies, aes(x = imdb_rating, y = audience_score)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method="lm", show.legend = T)

# BAR PLOTS
ggplot(data = movies, aes(x = genre)) +
  geom_bar()

# format labels
ggplot(data = movies, aes(x = genre)) +
  geom_bar() + theme(axis.text.x=element_text(angle = 45))

# more so...
ggplot(data = movies, aes(x = genre)) +
  geom_bar() + theme(axis.text.x=element_text(angle = 45, hjust = 1))


## More to come...