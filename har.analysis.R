Title
=======================================================



```{r}
## run this to download the data
## originally from here:
##   http://groupware.les.inf.puc-rio.br/har
if (FALSE) {
     urltrain <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
     urltest <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"
     download.file(urltrain, "pml-training.csv")
     download.file(urltest, "pml-testing.csv")
}
```


load in dat datttaaaaaa
```{r}
library(caret)

pmltrain <- read.csv("pml-training.csv")
pmltest <- read.csv("pml-testing.csv")
```

columns 3,4, and 5 all describe the same time measurement. So we only need one of them. We should also exclude the name and index from the prediction.  
So we make formula to pass on later.

``` {r}
pmlformula <- formula(classe ~ . - train[,1:4])
```










