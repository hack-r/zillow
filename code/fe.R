

# Analysis of Dupes -------------------------------------------------------
dupe

# Create Training Data Set (subset of props) ------------------------------
# Join train to props
train <- as.data.table(sqldf("select a.*, b.* from train a left join props b on a.parcelid = b.parcelid"))

# Repeated parcels in train
dupe <- train[duplicated(train$parcelid),]
dupe <- train[train$parcelid %in% dupe$parcelid,]

# Fix date
train$date  <- ymd(train$transactiondate)
train$month <- month(train$date)
train$year  <- year(train$date)

# Reshape Y (train only) -- Method 1: Month level datasets / models
train_oct <- train[train$month==10,]
train_nov <- train[train$month==11,]
train_dec <- train[train$month==12,]

# Reshape Y (train only) -- Method 2:

saveRDS(train, "train.RDS")
saveRDS(train_oct, "train_oct.RDS")
saveRDS(train_nov, "train_nov.RDS")
