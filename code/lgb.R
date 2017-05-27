
# Prepare Data for LGB ----------------------------------------------------
varnames <- setdiff(colnames(train), c("parcelid","date", "year",
                                       "logerror", "transactiondate"))
props_mat <- as.data.frame(props)
props_mat <- props_mat[,colnames(props_mat) %in% varnames]

props_mat_fac <- props_mat[,sapply(props_mat,class)%in%c("factor","character")]
props_mat     <- props_mat[,!sapply(props_mat,class)%in%c("factor","character")]

# Encode all factors/strings to numeric levels
for(n in 1:ncol(props_mat_fac)){
  tmp   <- data.table(V1=props_mat_fac[,n])
  class <- data.table(V1=unique(as.character(props_mat_fac[,n])), V2=seq(1,length(unique(as.character(props_mat_fac[,n])))))
  tmp   <- merge(tmp, class, by="V1", all.x=TRUE, sort=F)

  props_mat_fac[,n] <- as.numeric(tmp$V2)
}

props_mat <- cbind(props_mat, props_mat_fac)

# Join train to props_mat
props_mat$parcelid <- props$parcelid
train_mat          <- as.data.table(sqldf("select a.*, b.* from train_raw a left join props_mat b on a.parcelid = b.parcelid"))
props_mat$parcelid <- NULL

# Fix date
train_mat$date  <- ymd(train$transactiondate)
train_mat$month <- month(train_mat$date)

valid_mat <- train_mat[train_mat$month%in%c(10,11,12),]
# train_mat_nov <- train_mat[train_mat$month==11,]
# train_mat_dec <- train_mat[train_mat$month==12,]

train_mat$month    <- NULL
train_mat          <- train_mat[!train_mat$parcelid %in% valid_mat$parcelid,]
train_mat$parcelid <- NULL
train_mat$date     <- NULL
train_mat$transactiondate <- NULL
valid_mat$transactiondate <- NULL
#valid_mat$parcelid <- NULL
valid_mat$date     <- NULL

labels             <- train_mat$logerror#train$logerror[!train$parcelid %in% valid_mat$parcelid]
valid.labels       <- valid_mat$logerror
listing_id_test    <- props$parcelid
train_mat$logerror <- NULL
valid_mat$logerror <- NULL
pid                <- train_mat$parcelid
train_mat$parcelid <- NULL
vid                <- valid_mat$parcelid
valid_mat$parcelid <- NULL
valid_mat$parcelid <- NULL
valid_mat$month    <- NULL

saveRDS(labels, "labels.RDS")
saveRDS(valid.labels,"valid.labels.RDS")
saveRDS(pid, "pid.RDS")
saveRDS(vid, "vid.RDS")
saveRDS(train_mat, "train_mat.RDS")
saveRDS(valid_mat, "valid_mat.RDS")
saveRDS(props_mat, "props_mat.RDS")

t1_sparse <- Matrix(as.matrix(train_mat), sparse=TRUE) #[,colnames(train_mat)[sapply(train_mat,class)%in%c("nuermic","integer")]]
s1_sparse <- Matrix(as.matrix(props_mat), sparse=TRUE) #, with=FALSE
v1_sparse <- Matrix(as.matrix(valid_mat), sparse=TRUE)

cf   <- c("airconditioningtypeid",
          "architecturalstyletypeid",
          "buildingclasstypeid",
          "buildingqualitytypeid",
          "heatingorsystemtypeid",
          "propertylandusetypeid",
          "typeconstructiontypeid",
          "decktypeid",
          "pooltypeid10",
          "pooltypeid2",
          "pooltypeid7",
          "storytypeid",
          "fips6037",
          "fips6059",
          "fips6111")


dtrain <- lgb.Dataset(data = as.matrix(train_mat),
                      label = labels,
                      free_raw_data = FALSE,
                      #colnames = colnames(train_mat),
                      categorical_feature = which(colnames(train_mat) %in% cf))

lgb.Dataset.construct(dtrain)
saveRDS(dtrain, "dtrain.RDS")

dtest     <- lgb.Dataset(data                = as.matrix(valid_mat),
                         label               = valid.labels,#valid_mat[,"logerror"]
                         free_raw_data       = FALSE,
                         #colnames            = colnames(valid_mat),
                         categorical_feature = which(colnames(valid_mat) %in% cf))
lgb.Dataset.construct(dtest)

lgb.Dataset.save(dtrain, "dtrain.buffer")
lgb.Dataset.save(dtest, "dtest.buffer")

#--------------------Using validation set-------------------------
# valids is a list of lgb.Dataset, each of them is tagged with name
# valids allows us to monitor the evaluation result on all data in the list
valids <- list(train = dtrain, test = dtest)

# We can change evaluation metrics, or use multiple evaluation metrics
print("Train lightgbm using lgb.train with valids, watch logloss and error")
bst <- lgb.train(data = dtrain,
                 valids = valids,
                 eval = c("mean_absolute_error"), #, "binary_logloss",
                 nthread = 2,
                 num_leaves = 350,
                 learning_rate = 0.0021,
                 nrounds = 300,
                 boosting='gbdt',
                 objective = "regression_l2",
                 max_bin=9, #100
                 metric='l2',
                 sub_feature=.5,
                 bagging_fraction=1, #.85
                 bagging_freq=10,
                 min_data=500,
                 min_hessian=.05,
                 #max_depth = 20,
                 verbose = 1,
                 categorical_feature = cf
                 ) #0.0655485 Py 0.0648528


# Validation prediction / error
label.valid = getinfo(dtest, "label")
pred.valid <- predict(bst, as.matrix(valid_mat))
err        <- Metrics::mae(label.valid, pred.valid)
print(paste("test-error=", err)) # 0.0655485186283588

# OOS Scoring
t <- Sys.time()
score <- predict(bst, as.matrix(props_mat))
Sys.time()-t #8.639914 mins

# Save Predictions --------------------------------------------------------
saveRDS(pred.valid, "lgb_pred_valid.RDS")
saveRDS(score,      "lgb_pred_score.RDS")

#--------------------Save and load models-------------------------
# Save model to binary local file
lgb.save(bst, "lightgbm.model.v4")
