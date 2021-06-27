# datasciencecoursera
CW for coursra

  # download the source and unzip into a data directory
  dataSrc <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  dataDir <- "data"
  zipFile <- "Dataset.zip" 

  # Checking if archieve already exists.
  if (!file.exists(dataDir)) { dir.create(dataDir) }
  setwd(dataDir)

  # skip download step if already done and identical
  download.file(dataSrc, destfile = zipFile, method = "curl")
  date()

  list.files(pattern = zipFile)
  unzip(zipFile)

  # check if the subdir really exists
  # something like if (file.access("data/UCI HAR Dataset"))  ...
  dataBaseDir <- "UCI HAR Dataset"

  setwd(baseDir)
  # Merge training and test set
  testDataDir <- paste(dataDir, "/", dataBaseDir, "/test", sep = "")
  trainingDataDir <- paste(dataDir, "/", dataBaseDir, "/train", sep = "")

  #1 get column names
  colNamesRaw <- read.table(paste(dataDir, "/", dataBaseDir, "/features.txt", sep = ""))
  # should be: 561 2
  dim(colNamesRaw)
  # remove first column and convert to a vector by transposing with t()
  colNames <- t(colNamesRaw[-1])
  # rm(colNamesRaw)

  # 1merge within training
  train1 <- read.table(paste(trainingDataDir, "/", "X_train.txt", sep = ""))
  # check to see if it is what we wanted, should return "[1] 7352  561"
  dim(train1)

  # train1 <- read.table(paste(trainingDataDir, "/", "X_train.txt", sep=""), col.names=colNames)
  # ane have meaningful column names
  # head(names(train1))
  # "-", "(" or ")" gets replaced in column names as "."

  train1subject <- read.table(paste(trainingDataDir, "/", "subject_train.txt", sep = ""))
  # should have: "[1] 7352    1"
  dim(train1subject)

  train1activity <- read.table(paste(trainingDataDir, "/", "y_train.txt", sep = ""))
  # should have: "[1] 7352    1"
  dim(train1activity)

  train <- cbind(train1, train1subject, train1activity)
  # should extend train1 with two columns and return "[1] 7352  563"
  dim(train)

  # 1 merge within test
  test1 <- read.table(paste(testDataDir, "/", "X_test.txt", sep = ""))
  # check to see if it is what we wanted, should return "[1] 2947  561"
  dim(test1)

  # test1 <- read.table(paste(testDataDir, "/", "X_test.txt", sep=""), col.names=colNames)
  # ane have meaningful column names
  # head(names(test1))
  # "-", "(" or ")" gets replaced in column names as "."

  test1subject <- read.table(paste(testDataDir, "/", "subject_test.txt", sep = ""))
  # should have: "[1] 2947    1"
  dim(test1subject)

  test1activity <- read.table(paste(testDataDir, "/", "y_test.txt", sep = ""))
  # should have: "[1] 2947    1"
  dim(test1activity)

  test <- cbind(test1, test1subject, test1activity)
  # should extend test1 with two columns and return "[1] 2947  563"
  dim(test)


  # 1merge training with test

  data <- rbind(train, test)
  # should return "[1] 10299   563"
  dim(data)

  # 2Extracts only the measurements on the mean and standard deviation for each measurement. 
  # I assume that this are only those columns where "mean()" or "std()" is explicitely in the column name
  # It is not sufficient to just include the word "mean" as in "fBodyBodyGyroJerkMag-meanFreq()"

  usedCols <- colNamesRaw[which(grepl(pattern = "std\\(\\)|mean\\(\\)", x = colNamesRaw[, 2])), ]
  # should return 66 rows in 2 cols: "[1] 66  2"
  dim(usedCols)

  # now using column 1 of usedCols as index into the data
  # but add the subject and activity columns (562 and 563) since we need them later
  data2 <- data[, c(usedCols[, 1], 562, 563)]
  # we should now have only 68 cols (66 usedCols + subject label + activity label)
  # with the same number of rows: [1] 10299    68
  dim(data2)

  # 3Uses descriptive activity names to name the activities in the data set
  # read activity master data, giving some meaningful header "id" and "label"
  activityLabels <- read.table(paste(dataDir, "/", dataBaseDir, "/activity_labels.txt", sep = ""), col.names = c("id", "activity.label"))
  # check results
  activityLabels

  # set id column names for the merge below
  colnames(data2) <- t(usedCols[, 2])
  names(data2)[67] <- "subject.id"
  names(data2)[68] <- "activity.id"

  # the merge - using the labeled id columns
  data3 <- merge(data2, activityLabels, by.x = "activity.id", by.y = "id")

  # 4Appropriately labels the data set with descriptive variable names. 
  # we already set variable description in step 3 out of caution that the merge()
  # operation might change the column order and it would be difficult to set it again here

  # 5From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

  tidyData <- aggregate(data3[,2:66], by=list(data3$subject.id, data3$activity.label), FUN=mean)

  # header names are ok but for the first col, setting to "subject"
  names(tidyData)[1] <- "subject"
  names(tidyData)[2] <- "activity"

  RESULT <- "tidy.data"
  # check where we are
  getwd()
  write.table(tidyData, file=RESULT, row.names = TRUE)
  # check if it was written
  list.files()

  # verify the output is readable and check content visually
  View(read.table(RESULT, header = TRUE))
