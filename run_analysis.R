library(dplyr)

# Download working files
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

# Unzip files to directory
unzip(zipfile="./data/Dataset.zip",exdir="./data")

# Read unzipped training tables
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

# Read unzipped testing tables
x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

# Read feature vector
features <- read.table('./data/UCI HAR Dataset/features.txt')

# Reading activity labels
activityLabels = read.table('./data/UCI HAR Dataset/activity_labels.txt')

# Assign trainigng column names
colnames(x_train) <- features[,2] 
colnames(y_train) <-"activityId"
colnames(subject_train) <- "subjectId"

# Assign testing column names
colnames(x_test) <- features[,2] 
colnames(y_test) <- "activityId"
colnames(subject_test) <- "subjectId"

# Finalise column names
colnames(activityLabels) <- c('activityId','activityType')

# Merges the training and the test sets to create one data set
training_merge <- cbind(y_train, subject_train, x_train)
testing_merge <- cbind(y_test, subject_test, x_test)
final_merge <- rbind(training_merge, testing_merge)

# Extract the measurements on the mean and standard deviation for each measurement
## Reading column names
col_names <- colnames(final_merge)

## Create vector for ID, Mean and SD
mean_SD <- (grepl("activityId" , col_names) |
            grepl("subjectId" , col_names) |
            grepl("mean.." , col_names) |
            grepl("std.." , col_names))

## Subset for final_merge
final_merge_sub <- final_merge[ , mean_SD == TRUE]

#Use descriptive activity names to name the activities and add descriptive variable names in the data set
activity_names <- merge(final_merge_sub, activityLabels,
                        by = 'activityId',
                        all.x = TRUE)

#Create a second, independent tidy data set with the average of each variable for each activity and each subject.
tidy_data <- aggregate(. ~subjectId + activityId, activity_names, mean)
tidy_data <- tidy_data[order(tidy_data$subjectId, tidy_data$activityId),]

##convert to txt file
write.table(tidy_data, "tidy_data.txt", row.name=FALSE)
