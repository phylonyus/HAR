Training a Human Activity Recognition Model
=======================================================

## Data Origins  

This dataset originates from [here](http://groupware.les.inf.puc-rio.br/har) and you can read the original paper analysing this data [here](http://groupware.les.inf.puc-rio.br/public/papers/2013.Velloso.QAR-WLE.pdf).  
Switch the condition to `TRUE` to download the data.


```r
if (FALSE) {
    urltrain <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
    urltest <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"
    download.file(urltrain, "pml-training.csv")
    download.file(urltest, "pml-testing.csv")
}
```


## Loading Data/Segmenting Data  

Here we actually load in the data. The caret train function will handle cross validation for tuning parameters, but I was tinkering with a few models. So here we also split our training data into a train and cross-validation set of equal sizes to get a better estimation of our out of sample error. 


```r
suppressMessages(library(caret))

pmltrain <- read.csv("pml-training.csv")
pmltest <- read.csv("pml-testing.csv")

set.seed(98761234)

trainIndex <- createDataPartition(pmltrain$classe, p = 0.5, list = FALSE, times = 1)

subtrain <- pmltrain[trainIndex, -(1:7)]
cval <- pmltrain[-trainIndex, -(1:7)]
```


## Some cleaning and feature selection  

We are interested in predicting based on the movement measurements, not the test subject's name, time of day, or the window id assigned to each measurement. This dataset has a large volume of NA values, so we omit the columns containing any NA's. We also remove all features with near zero variance. Since these features were derived from others in the data set, we have not actually removed any information.


```r
subtrain[, -153] <- data.frame(sapply(subtrain[, -153], as.numeric))
cval[, -153] <- data.frame(sapply(cval[, -153], as.numeric))

subtrain <- subtrain[, apply(subtrain, 2, function(x) all(!is.na(x)))]
cval <- cval[, apply(cval, 2, function(x) all(!is.na(x)))]

nzv <- nearZeroVar(subtrain)
subtrain <- subtrain[, -nzv]
cval <- cval[, -nzv]
```


## Training  

We used a random forest model as our prediction algorithm. They utilize robust algorithms and should work with minimal parameter tuning. We utilized cross validation here again with 5-fold validation to override the bootstrapping that `rf` in the caret package usually defaults to. This was to lower computing time.


```r
trainctrl <- trainControl(method = "repeatedcv", number = 5, repeats = 5)
rffit1 <- train(classe ~ ., data = subtrain, method = "rf", trControl = trainctrl)
```


## Estimating out of sample error

With cross validation within the training set, we got 100% prediction accuracy, which could mean we are overfitting our data. Our trained model performed with 98.6% accuracy on our cross validation set, as seen belwo. Therefore, I suspect we aren't overfitting, but that we have an awesome trained model.
From the lower end of our 95% confidence interval of the accuracy, I would expect our out of sample error to be `1-.983=0.017` or `1.7%`.


```r

rffit1
```

```
## Random Forest 
## 
## 9812 samples
##   52 predictors
##    5 classes: 'A', 'B', 'C', 'D', 'E' 
## 
## No pre-processing
## Resampling: Cross-Validated (5 fold, repeated 5 times) 
## 
## Summary of sample sizes: 7850, 7851, 7850, 7848, 7849, 7849, ... 
## 
## Resampling results across tuning parameters:
## 
##   mtry  Accuracy  Kappa  Accuracy SD  Kappa SD
##   2     1         1      0.002        0.003   
##   30    1         1      0.004        0.005   
##   50    1         1      0.005        0.006   
## 
## Accuracy was used to select the optimal model using  the largest value.
## The final value used for the model was mtry = 27.
```

```r
pred <- predict(rffit1, cval)
confusionMatrix(pred, cval[, 53])
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction    A    B    C    D    E
##          A 2782   33    0    0    0
##          B    3 1846   19    0    2
##          C    3   11 1682   39    4
##          D    1    6   10 1569    7
##          E    1    2    0    0 1790
## 
## Overall Statistics
##                                         
##                Accuracy : 0.986         
##                  95% CI : (0.983, 0.988)
##     No Information Rate : 0.284         
##     P-Value [Acc > NIR] : < 2e-16       
##                                         
##                   Kappa : 0.982         
##  Mcnemar's Test P-Value : 2.29e-10      
## 
## Statistics by Class:
## 
##                      Class: A Class: B Class: C Class: D Class: E
## Sensitivity             0.997    0.973    0.983    0.976    0.993
## Specificity             0.995    0.997    0.993    0.997    1.000
## Pos Pred Value          0.988    0.987    0.967    0.985    0.998
## Neg Pred Value          0.999    0.993    0.996    0.995    0.998
## Prevalence              0.284    0.193    0.174    0.164    0.184
## Detection Rate          0.284    0.188    0.171    0.160    0.182
## Detection Prevalence    0.287    0.191    0.177    0.162    0.183
## Balanced Accuracy       0.996    0.985    0.988    0.986    0.996
```






