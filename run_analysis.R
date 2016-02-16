library(reshape2)

### Set URL handle

if(!file.exists("./Course3Week4data")){dir.create("./Course3Week4data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

###Download Files
download.file(fileUrl,destfile="./Course3Week4data/Dataset.zip")
unzip(zipfile="./Course3Week4data/Dataset.zip",exdir="./Course3Week4data")

#### View files in directory
directory<-("./Course3Week4data/UCI HAR Dataset")
filelist <- list.files(directory, full.names = TRUE,recursive=TRUE)

### Read files
activityLabels <- read.table("./Course3Week4data/UCI HAR Dataset/activity_labels.txt")
activityLabelsNames <- as.character(activityLabels[,2])

features <- read.table("./Course3Week4data/UCI HAR Dataset/features.txt")
featuresNames <- as.character(features[,2])

### Extract only the data on mean and standard deviation

featuresNeeded <- grep(".*mean.*|.*std.*", featuresNames)
featuresNeeded.names <- features[featuresNeeded,2]

### Clean Names

featuresNeeded.names = gsub('-mean', 'Mean', featuresNeeded.names)
featuresNeeded.names = gsub('-std', 'Std', featuresNeeded.names)
featuresNeeded.names <- gsub('[-()]', '', featuresNeeded.names)

### Load the datasets

train <- read.table("./Course3Week4data/UCI HAR Dataset/train/X_train.txt")[featuresNeeded]
trainActivities <- read.table("./Course3Week4data/UCI HAR Dataset/train/y_train.txt")
trainSubjects <- read.table("./Course3Week4data/UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("./Course3Week4data/UCI HAR Dataset/test/X_test.txt")[featuresNeeded]
testActivities <- read.table("./Course3Week4data/UCI HAR Dataset/test/y_test.txt")
testSubjects <- read.table("./Course3Week4data/UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

### merge datasets and add labels

CombineData <- rbind(train, test)
colnames(CombineData) <- c("subject", "activity", featuresNeeded.names)

### turn activities & subjects into factors

CombineData$activity <- factor(CombineData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
CombineData$subject <- as.factor(CombineData$subject)

CombineData.melted <- melt(CombineData, id = c("subject", "activity"))
CombineData.mean <- dcast(CombineData.melted, subject + activity ~ variable, mean)

write.table(CombineData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)