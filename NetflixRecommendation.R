# Author: Nilesh Pawar

# Netflix is an online movie streaming service.  Their customers watching movies, and 
# subsequently rate them.  Netflix uses these ratings to inform other recommendations. 
# I will focus on the first 5 Rocky movies, starring Sylvester Stallone as a 
# boxer who fights to overcome the odds. 
# I will find the best model  to predict the rating of Rocky 5 given the ratings of the previous 4 films
# with neural nets using more than 1000 possible combinations of the predictor variables by mixing
# linear, quadratic, logarithmic and various interaction effects. 
# The best predtictive model is selected on the Mean Square Error
#
# DATASETS: 
# dfRecommend: consumerID, rating, rockyID
# This dataset contains some missing ratings. I will use this dataset to conduct some explanatory analysis
# and ultimately create a simple linear regression recommendation model and apply the best neural net model on 
# it that I find using the training and validation sets
# 
# dfRockyTrain: consumerID, Rocky.1, Rocky.2, Rocky.3, Rocky.4, Rocky.5
# This will be used for a more complex linear regression & neural net recommendation model
# 
# dfRockyValidation: consumerID, Rocky.1, Rocky.2, Rocky.3, Rocky.4, Rocky.5
# This will be used for a more complex linear regression & neural net recommendation model

rm(list=ls())

####Part 1: EXPLANATORY ANALYSIS with dfRecommend #####

dfRecommend <- read.csv(file.choose())
dfRockyTrain <- read.csv(file.choose())
dfRockyValidation <- read.csv(file.choose())

#Defining a data frame that has row for each consumer and fill it with NA.
 
ratingsDF <- data.frame(matrix(NA, nrow = nrow(unique(dfRecommend['consumerID'])), ncol = 6))
colnames(ratingsDF) <- 
    c('consumerID', 'Rocky.1', 'Rocky.2', 'Rocky.3', 'Rocky.4', 'Rocky.5')

# Filling the data frame from above using data from dfRecommend


library('reshape')

ratingsDF['consumerID'] <- unique(dfRecommend['consumerID'])
ratingsDF <- ratingsDF[order('consumerID'),]

ratingsDF2 = cast(dfRecommend, consumerID ~ rockyID, value = 'rating')
colnames(ratingsDF2) <- c('Consumer ID', 'Rocky.1', 'Rocky.2', 'Rocky.3', 'Rocky.4', 'Rocky.5')

# Comparing the correlations between the ratings of each of the five movies using the cor command 
# on the new data frame to find which movies are most similar and different in terms of ratings

dfWithoutID <- ratingsDF2[,-1]
correlationsDf <- cor(dfWithoutID, use = 'pairwise')
correlationsDf <- as.data.frame(correlationsDf)
colnames(correlationsDf) <- c('Rocky.1', 'Rocky.2', 'Rocky.3', 'Rocky.4', 'Rocky.5')

# Insights: The most similar movies are Rocky 2 and Rocky 3 since correlation is the highest with 0.7009378.
# The least similar movies are Rocky 1 and Rocky 5.

#Calculating the mean rating of each movie.  Which is the best? Which is the worst? Answer in the pdf.  

means <- colMeans(dfWithoutID, na.rm = TRUE)
meansdf <- as.data.frame(means)
  
#Insights: Best movie is Rocky 1 with an average rating of 3.771311 
# Worst movie is Rocky 5 with an average of 3.033660

#  Finding consumers who rated all movies. 


AllRatedDF <-
  subset(ratingsDF2,!is.na(Rocky.1 & Rocky.2 & Rocky.3 & Rocky.4 & Rocky.5))

##### Part 2: PREDICTIVE ANALYSIS for RECOMMENDATION #####

# Here I will try to determine whether Rocky 5 should be recommended to Netflix customers, based on their 
# ratings of Rocky 1 through 4.  The dependent variables is the rating of Rocky 5, and the independent 
# variables are the ratings of the previous 4 Rocky movies.  



# Simple linear regression using AllRatedDF

fit = lm(Rocky.5 ~ Rocky.1 + Rocky.2 + Rocky.3 + Rocky.4, data = AllRatedDF)
summary(fit)


# Using transformations of the predictor variables (polynomials, log, interactions) for complex models with training and validation datasets

rocky1Vec = c('', '+Rocky.1','+poly(Rocky.1,2)', '+log(Rocky.1)', '+sqrt(Rocky.1)')
rocky2Vec = c('', '+Rocky.2','+poly(Rocky.1,2)', '+log(Rocky.2)', '+sqrt(Rocky.2)')
rocky3Vec = c('', '+Rocky.3','+poly(Rocky.1,2)', '+log(Rocky.3)', '+sqrt(Rocky.3)')
rocky4Vec = c('', '+Rocky.4','+poly(Rocky.1,2)', '+log(Rocky.4)', '+sqrt(Rocky.4)')
formulaSet = paste('Rocky.5~1',
                   apply(
                     expand.grid(rocky1Vec, rocky2Vec, rocky3Vec, rocky4Vec),
                     1,
                     paste,
                     collapse = ''
                   ))

# Evaluating the out of sample MSE of each model above

MSE = function(x) {
  return(mean(x ^ 2))
}

MSEs = matrix(
  data = NA,
  nrow = length(formulaSet),
  ncol = 2,
  byrow = FALSE)

#linear regressions
for (i in 1:length(formulaSet)) {
  basicLM = lm(as.formula(formulaSet[i]), data = dfRockyTrain)
  MSEs[i, 1] = MSE(dfRockyValidation$Rocky.5 - predict(basicLM, dfRockyValidation))
  MSEs[i, 2] = formulaSet[i]
}

#Neural Nets

library(nnet)

nnetModels <- data.frame(formulaSet)
for(j in 1:length(formulaSet)) {
  set.seed(90)
  basicNNET = nnet(as.formula(formulaSet[j]),data=dfRockyTrain,size = 3, linout = 1,maxit = 1000 )
  nnetModels$mse[j] = MSE(dfRockyValidation$Rocky.5 - predict(basicNNET,dfRockyValidation))
}
nnet_min_mse <- nnetModels[which.min(nnetModels$mse),]

nnet_min_mse #model which performs best in terms of out of sampleMSE

#f) Estimate and store the best model using the full dataset.  

set.seed(90)
basicNNET = nnet(as.formula(formulaSet[407]),data=dfRockyTrain,size = 3, linout = 1,maxit = 1000 )
MSE(AllSeenDF$Rocky.5 - predict(basicNNET,AllSeenDF))

bestmodel <- as.character(formulaSet[407])

basicNNET
