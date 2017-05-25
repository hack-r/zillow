# Train/Test split
# 
# You are provided with a full list of real estate properties in three counties (Los Angeles, Orange and Ventura, California) data in 2016.
# The train data has all the transactions before October 15, 2016, plus some of the transactions after October 15, 2016.
# The test data in the public leaderboard has the rest of the transactions between October 15 and December 31, 2016.
# The rest of the test data, which is used for calculating the private leaderboard, is all the properties in October 15, 2017, to December 15, 2017. This period is called the "sales tracking period", during which we will not be taking any submissions.
# You are asked to predict 6 time points for all properties: October 2016 (201610), November 2016 (201611), December 2016 (201612), October 2017 (201710), November 2017 (201711), and December 2017 (201712).
# Not all the properties are sold in each time period. If a property was not sold in a certain time period, that particular row will be ignored when calculating your score.
# If a property is sold multiple times within 31 days, we take the first reasonable value as the ground truth. By "reasonable", we mean if the data seems wrong, we will take the transaction that has a value that makes more sense.
# File descriptions
# 
# properties_2016.csv - all the properties with their home features for 2016. Note: Some 2017 new properties don't have any data yet except for their parcelid's. Those data points should be populated when properties_2017.csv is available.
# properties_2017.csv - all the properties with their home features for 2017 (will be available on 10/2/2017)
# train_2016.csv - the training set with transactions from 1/1/2016 to 12/31/2016
# train_2017.csv - the training set with transactions from 1/1/2017 to 9/15/2017 (will be available on 10/2/2017)
# sample_submission.csv - a sample submission file in the correct format
# Data fields
# 
# Please refer to zillow_data_dictonary.xlsx

# Load Raw Data -----------------------------------------------------------
props <- fread("properties_2016.csv")
samp  <- fread("sample_submission.csv", header=T)
train <- fread("train_2016.csv")
dict  <- fread("zillow_data_dictionary.csv")


# Transform ---------------------------------------------------------------
props
samp
train

# Fix date 
train$date  <- ymd(train$transactiondate)
train$month <- month(train$date)
train$year  <- year(train$date)

# Join train to props


month_avg <- aggregate(train$logerror, by=list(train$month, train$year), mean)
colnames(month_avg) <- c("month", "year", "y")

samp$`201610` <- rep(month_avg$y[month_avg$month==10],nrow(samp))
samp$`201611` <- rep(month_avg$y[month_avg$month==11],nrow(samp))
samp$`201612` <- rep(month_avg$y[month_avg$month==12],nrow(samp))
samp$`201710` <- rep(month_avg$y[month_avg$month==10],nrow(samp))
samp$`201711` <- rep(month_avg$y[month_avg$month==11],nrow(samp))
samp$`201712` <- rep(month_avg$y[month_avg$month==12],nrow(samp))

fwrite(samp, "avg_by_month.csv")
