###1. Download and descompress the file data
if(!file.exists("./homework")){dir.create("./homework")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./homework/data.zip",method="curl")

unzip(zipfile="./homework/data.zip",exdir="./homework")

pathfl <- file.path("./homework" , "UCI HAR Dataset")
files<-list.files(pathfl, recursive=TRUE)

###2. Read and merge data

# train data
x_train <- read.table(paste(sep = "", pathfl, "/train/X_train.txt"))
y_train <- read.table(paste(sep = "", pathfl, "/train/Y_train.txt"))
s_train <- read.table(paste(sep = "", pathfl, "/train/subject_train.txt"))

# test data
x_test <- read.table(paste(sep = "", pathfl, "/test/X_test.txt"))
y_test <- read.table(paste(sep = "", pathfl, "/test/Y_test.txt"))
s_test <- read.table(paste(sep = "", pathfl, "/test/subject_test.txt"))

# merge train and test data
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
s_data <- rbind(s_train, s_test)

#3. load feature & activity info
# feature
feature <- read.table(paste(sep = "", pathfl, "/features.txt"))

# activity labels
activity_label <- read.table(paste(sep = "", pathfl, "/activity_labels.txt"))
activity_label[,2] <- as.character(activity_label[,2])

# extract feature cols & names named "mean|std"
SCols <- grep("-(mean|std).*", as.character(feature[,2]))
SColN <- feature[SCols, 2]
SColN <- gsub("-mean", "Mean", SColN)
SColN <- gsub("-std", "Std", SColN)
SColN <- gsub("[-()]", "", SColN)

###4. Extract data by cols & using descriptive name
x_data <- x_data[SCols]
allData <- cbind(s_data, y_data, x_data)
colnames(allData) <- c("Subject", "Activity", SColN)

allData$Activity <- factor(allData$Activity, levels = activity_label[,1], labels = activity_label[,2])
allData$Subject <- as.factor(allData$Subject)

### 5. Generate tidy data
library(plyr)
pretidydata <- aggregate(.~Subject + Activity, allData, mean)
pretidydata <- pretidydata[order(pretidydata$Subject, pretidydata$Activity),]
write.table(pretidydata, file = "tidy_data.txt", row.names = FALSE)
