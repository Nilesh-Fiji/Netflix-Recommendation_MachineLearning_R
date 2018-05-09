Netflix-Recommendation_MachineLearning_R
Author: Nilesh Pawar

Netflix is an online movie streaming service.  Their customers watching movies, and subsequently rate them.  Netflix uses these ratings to inform other recommendations.  I will focus on the first 5 Rocky movies, starring Sylvester Stallone as a boxer who fights to overcome the odds.  I will find the best model  to predict the rating of Rocky 5 given the ratings of the previous 4 films  with neural nets using more than 1000 possible combinations of the predictor variables by mixing linear, quadratic, logarithmic and various interaction effects. The best predtictive model is selected on the Mean Square Error

 DATASETS: 
 dfRecommend: consumerID, rating, rockyID
 This dataset contains some missing ratings. I will use this dataset to conduct some explanatory analysis
 and ultimately create a simple linear regression recommendation model, as well as apply the best neural net model on 
 it that I find using the training and validation sets
 
 dfRockyTrain: consumerID, Rocky.1, Rocky.2, Rocky.3, Rocky.4, Rocky.5
 This training set will be used for a more complex linear regression & neural net recommendation model
 
 dfRockyValidation: consumerID, Rocky.1, Rocky.2, Rocky.3, Rocky.4, Rocky.5
 This validation set will be used for a more complex linear regression & neural net recommendation model
