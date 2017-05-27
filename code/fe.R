# FIPS --------------------------------------------------------------------
props$fips6037 <- ifelse(props$fips==6037,1,0)
props$fips6059 <- ifelse(props$fips==6059,1,0)
props$fips6111 <- ifelse(props$fips==6111,1,0)

props$fips <- NULL

# Property Land Use -------------------------------------------------------
props$flag_co_code_high <- ifelse(props$propertycountylandusecode %in% co_codes_high,1,0)
props$flag_co_code_low  <- ifelse(props$propertycountylandusecode %in% co_codes_low,1,0)

props$propertycountylandusecode <- NULL

# Create Training Data Set (subset of props) ------------------------------
# Join train to props
train <- as.data.table(sqldf("select a.*, b.* from train_raw a left join props b on a.parcelid = b.parcelid"))

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
saveRDS(train_dec, "train_dec.RDS")
