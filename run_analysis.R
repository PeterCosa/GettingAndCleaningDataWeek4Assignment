### This is the script for merging and tidying data for Week 4 assignment 

### Load the dplyr package
library(dplyr)
## read Activity names in from activity_labels.txt file 
  my.activity.names <- read.table("activity_labels.txt", header = FALSE)
##change column headings ready for merge or join
colnames(my.activity.names) <- c("activity.id", "activity.description")

## read X_train into data.frame using read.table
my.X.train_set <- read.table("train/X_train.txt", header = FALSE)
my.y.train_labels <- read.table("train/y_train.txt", header = FALSE)
my.subject_train <- read.table("train/subject_train.txt", header = FALSE)


my.colnames <- read.table("features.txt", header = FALSE, stringsAsFactors = FALSE)


## create vector for name insert
Vcreatenamesvector <- my.colnames[,2]
## append additional variable(column) heading "subject" to the vector 
Vcreatenamesvector <- append(Vcreatenamesvector, "subject", after = length(Vcreatenamesvector)) 

## append additional variable(column) heading "subject" to the vector 
Vcreatenamesvector <- append(Vcreatenamesvector, "activity.id", after = length(Vcreatenamesvector)) 


### repeat for training data 
my.X.test_set <- read.table("test/X_test.txt", header = FALSE)
my.subject_test <- read.table("test/subject_test.txt", header = FALSE)
my.y.test_labels <- read.table("test/y_test.txt", header = FALSE)

## add subject columns

###get subject observation as a vector
Vsubject_test <- my.subject_test$V1
Vsubject_train <- my.subject_train$V1
## add the extra Subject column using the mutate function
my.X.test_set <- mutate(my.X.test_set, subject = Vsubject_test)
my.X.train_set <- mutate(my.X.train_set, subject = Vsubject_train)


###get Activity observation as a vector
Vactivity_test <- my.y.test_labels$V1
Vactivity_train <- my.y.train_labels$V1
### add the extra column for Activity using the mutate function
my.X.test_set <- mutate(my.X.test_set, Activity = Vactivity_test)
my.X.train_set <- mutate(my.X.train_set, Activity = Vactivity_train)

##add headings
colnames(my.X.train_set) <- Vcreatenamesvector
##add headings
colnames(my.X.test_set) <- Vcreatenamesvector
## merge the train and test to create on edataset
my.merged.data <- rbind(my.X.train_set, my.X.test_set)

## use plyr package to join activity data frame on activity.id to get activity description variable
library(plyr)
my.merged.data <- join(my.merged.data, my.activity.names)

### get index values for columns that are duplicates so that we can remove them
my.duplicate.variables <- which(duplicated(my.colnames$V2))
### subset out the duplicates from above
my.merged.data <- my.merged.data[, -my.duplicate.variables]
### subset out only mean and std variables
my.merged.data <- select(my.merged.data, grep("subject|activity|mean|std", colnames(my.merged.data)))


##create second data set average of each variable for each activity
##make it a tbl
my.merged.tbl <- tbl_df(my.merged.data)
my.tidy.average <- my.merged.tbl %>% group_by(subject, activity.description) %>% summarise_all(funs(mean))