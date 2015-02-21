## You should create one R script called run_analysis.R that does the following. 
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names. 
## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Step 1) Obtain the source data
sourceFile <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
tempFile <- tempfile()
download.file(sourceFile, tempFile)
zipfileinfo <- unzip(tempFile,list=TRUE)

unzip(tempFile,exdir="zipdat")
#collect "train[ing]" subject record list 
trainingSubjectsFile <- "UCI HAR Dataset/train/subject_train.txt"
trainSubjectsDf <- read.csv(trainingSubjectsFile)
trainSubjectsIds <- unique(trainSubjectsDf)
nrow(trainSubjectsIds)
#collect "test" subject data record list
testSubjectsFile <- "UCI HAR Dataset/test/subject_test.txt"
testSubjectsDf <- read.csv(testSubjectsFile)
testSubIds <- unique(testSubjectsDf)
nrow(testSubIds)
nrow(testSubjectsDf)
#collect test group measurements
testDataFile <- "UCI HAR Dataset/test/X_test.txt"
testDataTbl <- read.table(testDataFile)
nrow(testDataTbl)
#collect test activity reports
testActivityFile <- "UCI HAR Dataset/test/y_test.txt"
testActivityDf <- read.csv(testActivityFile)
nrow(testActivityDf)

#read in feature labels
featurenames <- read.table("UCI HAR Dataset/features.txt", col.names = c('colnum','varname'))
#read in feature data for "test" set
testDataFile <- "UCI HAR Dataset/test/X_test.txt"
testDataTbl <- read.table(testDataFile, col.names=featurenames[,2])
nrow(testDataTbl)
#read in feature data for "train[ing]" set
trainDataFile <- "UCI HAR Dataset/train/X_train.txt"
trainDataTbl <- read.table(trainDataFile, col.names=featurenames[,2])
nrow(trainDataTbl)

#add subjects to test set
testSubjectsFile <- "UCI HAR Dataset/test/subject_test.txt"
testSubjectsTbl <- read.table(testSubjectsFile,col.names='SubjectId')

#add subjects to train set
trainSubjectsFile <- "UCI HAR Dataset/train/subject_train.txt"
trainSubjectsTbl <- read.table(trainSubjectsFile,col.names='SubjectId')

#add activity to test set
testActivityFile <- "UCI HAR Dataset/test/y_test.txt"
testActivityTbl <- read.table(testActivityFile,col.names='ActivityId')

#add activity to train set
trainActivityFile <- "UCI HAR Dataset/train/y_train.txt"
trainActivityTbl <- read.table(trainActivityFile,col.names='ActivityId')

#combine subjects, activities, and measurements records
allTrainDataTbl <- cbind(trainSubjectsTbl, trainActivityTbl, trainDataTbl)
allTestDataTbl <- cbind(testSubjectsTbl, testActivityTbl, testDataTbl)

#merge train[ing] and test sets of measurements
allDataTbl <- rbind(allTrainDataTbl, allTestDataTbl)

## RESULT #1:merge train and test sets of measurements
allDataTbl


##2. return only the mean and std columns
meanColNums <- grep('.mean.',names(allDataTbl), fixed=TRUE)
stdColNums <- grep('.std.',names(allDataTbl), fixed=TRUE)
meanAndStdCols <- c(meanColNums,stdColNums)
length(meanColNums) + length(stdColNums)
length(meanAndStdCols)
meanAndStdDataTbl <- allDataTbl[,c(1,2,meanAndStdCols)]

## RESULT #2:return only the mean and std columns
meanAndStdDataTbl


##3. Uses descriptive activity names to name the activities in the data set
activityDefsFile <- "zipdat/UCI HAR Dataset/activity_labels.txt"
labels <- c("ActivityId","ActivityLabel")
activityDefsTbl <- read.table(activityDefsFile,col.names=labels)

activityLabeledMeansAndStdsDataTbl <- merge(meanAndStdDataTbl,activityDefsTbl,by="ActivityId")

## RESULT #3:uses descriptive activity names
activityLabeledMeansAndStdsDataTbl


##4.  Appropriately labels the data set with descriptive variable names.
#apply more legible column names to data set
names(activityLabeledMeansAndStdsDataTbl) <- gsub("\\.\\.", '()', names(activityLabeledMeansAndStdsDataTbl))
names(activityLabeledMeansAndStdsDataTbl) <- gsub("\\.", '-', names(activityLabeledMeansAndStdsDataTbl))
names(activityLabeledMeansAndStdsDataTbl) <- gsub("mean", 'Avg', names(activityLabeledMeansAndStdsDataTbl))
names(activityLabeledMeansAndStdsDataTbl) <- gsub("std", 'StdDev', names(activityLabeledMeansAndStdsDataTbl))
names(activityLabeledMeansAndStdsDataTbl)

##5. From the data set in step 4, creates a second, independent tidy data set with 
##        the average of each variable for each activity and each subject.
#remove activity label to prepare data set for numerical processing
unLabeledMeansAndStdsDataTbl = activityLabeledMeansAndStdsDataTbl[1:ncol(activityLabeledMeansAndStdsDataTbl)-1]
#initialize the output data frame and assign column labels
outdf <- data.frame(matrix(ncol = length(names(unLabeledMeansAndStdsDataTbl)), nrow = 0));
colnames(outdf ) <- names(unLabeledMeansAndStdsDataTbl)

#split entire data set by ActivityId
activitySplitDataTbl <- split(unLabeledMeansAndStdsDataTbl,unLabeledMeansAndStdsDataTbl$ActivityId)
#determine unique SubjectId values for subsequent splits
subjectIds <- unique(allDataTbl$Subject)

#for each of the Activity categories
#   split the dataset by SubjectId values
for(i in seq_along(activitySplitDataTbl)) {
   nxtActivityDataTbl <- activitySplitDataTbl[[i]]
   print(summary(nxtActivityDataTbl))
   #print(names(nxtActivityDataTbl))
   # break up by Subject
   nxtActivityBySubjectSplitDataTbls <- split(nxtActivityDataTbl,nxtActivityDataTbl$Subject)
   print(summary(nxtActivityBySubjectSplitDataTbls))
   for(j in seq_along(nxtActivityBySubjectSplitDataTbls)) {
      #print(nxtActivityBySubjectSplitDataTbls[[j]])
      #print(colMeans(nxtActivityBySubjectSplitDataTbls[[j]]))
      nxtActivityBySubjectMeans <- colMeans(nxtActivityBySubjectSplitDataTbls[[j]])
      outdf <- rbind(outdf,nxtActivityBySubjectMeans)
   }
}

colnames(outdf) <- names(unLabeledMeansAndStdsDataTbl)  
finalResult <- merge(outdf,activityDefsTbl,by.x="ActivityId")
finalResult

