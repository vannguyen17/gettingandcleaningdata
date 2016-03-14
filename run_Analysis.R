#Download the data into the data folder and unzip it

if(!file.exists("./data")) {dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/data.zip")
unzip(zipfile = "./data/data.zip",exdir = "./data")

#List files

filepath <- file.path("./data/UCI HAR Dataset")
files <- list.files(filepath, recursive=TRUE)
files

#Import training and test data
activitytrain <- read.table(file.path(filepath, "train", "Y_train.txt"))
activitytest <- read.table(file.path(filepath, "test" , "Y_test.txt" ))

subjecttrain <- read.table(file.path(filepath, "train", "subject_train.txt"))
subjecttest <- read.table(file.path(filepath, "test" , "subject_test.txt"))

featurestrain <- read.table(file.path(filepath, "train", "X_train.txt"))
featurestest <- read.table(file.path(filepath, "test" , "X_test.txt" ))

#Combine rows of training and test dataframes
activityfull <- rbind(activitytrain, activitytest)
subjectfull <- rbind(subjecttrain, subjecttest)
featuresfull <- rbind(featurestrain, featurestest)

#Set names to variables
names(activityfull) <- c("activity")
names(subjectfull) <- c("subject")
featuresnames <- read.table(file.path(filepath, "features.txt"))
names(featuresfull) <- featuresnames$V2

#Merge columns to get full dataframe
subjectactivity <- cbind(subjectfull, activityfull)
data <- cbind(featuresfull, subjectactivity)

#Subset names of features by mean or standard deviation
subfeaturesnames <- featuresnames$V2[grep("mean\\(\\)|std\\(\\)", featuresnames$V2)]

#Subset the full dataframe by seleted names of features
selectednames <- c(as.character(subfeaturesnames), "subject", "activity" )
datameanstd <- subset(data, select = selectednames)

#Load activity names and replace in full dataframe
activitylabels <- read.table(file.path(filepath, "activity_labels.txt"))
datameanstd$activity <- gsub("1", "WALKING", datameanstd$activity)
datameanstd$activity <- gsub("2", "WALKING_UPSTAIRS", datameanstd$activity)
datameanstd$activity <- gsub("3", "WALKING_DOWNSTAIRS", datameanstd$activity)
datameanstd$activity <- gsub("4", "SITTING", datameanstd$activity)
datameanstd$activity <- gsub("5", "STANDING", datameanstd$activity)
datameanstd$activity <- gsub("6", "LAYING", datameanstd$activity)

#Label the data set with descriptive variable names
names(datameanstd) <- gsub("^t", "time", names(datameanstd))
names(datameanstd) <- gsub("^f", "frequency", names(datameanstd))
names(datameanstd) <- gsub("Acc", "Accelerometer", names(datameanstd))
names(datameanstd) <- gsub("Gyro", "Gyroscope", names(datameanstd))
names(datameanstd) <- gsub("Mag", "Magnitude", names(datameanstd))
names(datameanstd) <- gsub("BodyBody", "Body", names(datameanstd))

#Create independent tidy data set with the average of each variable for each activity and each subject
tidydata <- aggregate(. ~subject + activity, datameanstd, mean)
tidydata <- tidydata[order(tidydata$subject, tidydata$activity), ]
write.table(tidydata, file = "tidydata.txt", row.name = FALSE)