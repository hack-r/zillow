
# Add Ground Truth from Train to Scores -----------------------------------


# Base Model Scores -------------------------------------------------------
# Monthly DRF's
pred10 <- fread("pred10.csv")
pred11 <- fread("pred11.csv")
pred12 <- fread("pred12.csv")

# LGB
lgb.pred <- readRDS("lgb_pred_score.RDS")

# Model Stack -------------------------------------------------------------
samp$`201610` <- pred10$predict * .5 + lgb.pred * .5
samp$`201710` <- pred10$predict * .5 + lgb.pred * .5
samp$`201611` <- pred11$predict * .5 + lgb.pred * .5
samp$`201711` <- pred11$predict * .5 + lgb.pred * .5
samp$`201612` <- pred12$predict * .5 + lgb.pred * .5
samp$`201712` <- pred12$predict * .5 + lgb.pred * .5

samp$`201610` <- pred10$predict * 0 + lgb.pred #* .5
samp$`201710` <- pred10$predict * 0 + lgb.pred #* .5
samp$`201611` <- pred11$predict * 0 + lgb.pred #* .5
samp$`201711` <- pred11$predict * 0 + lgb.pred #* .5
samp$`201612` <- pred12$predict * 0 + lgb.pred #* .5
samp$`201712` <- pred12$predict * 0 + lgb.pred #* .5

# Replace known parcel predictions with ground truth
samp$`201610`[samp$parcelid] <-
samp$`201710` <-
samp$`201611` <-
samp$`201711` <-
samp$`201612` <-
samp$`201712` <-

train_tmp <- train[!duplicated(train$parcelid),]
new       <- sqldf("select a.*, b.logerror from samp left join train_tmp b on a.parcelid = b.parcelid")

samp$`201610` <- ifelse(is.na(new$logerror), samp$`201610`, new$logerror)
samp$`201710` <- ifelse(is.na(new$logerror), samp$`201710`, new$logerror)
samp$`201611` <- ifelse(is.na(new$logerror), samp$`201611`, new$logerror)
samp$`201711` <- ifelse(is.na(new$logerror), samp$`201711`, new$logerror)
samp$`201612` <- ifelse(is.na(new$logerror), samp$`201612`, new$logerror)
samp$`201712` <- ifelse(is.na(new$logerror), samp$`201712`, new$logerror)


# Write Out Results -------------------------------------------------------
fwrite(samp, "submission.csv")
#zip("my_submission.zip", files=paste(getwd(), "submission.csv", sep="/"))

# Log Results -------------------------------------------------------------
# Python LGB:                  LB 0.0648528
# R LGB v2:                    LB 0.0650085
# R LGB v1:                    LB 0.0652332
# .5 monthly DRF, .5 R LGB v1: LB 0.0653991
# R LGB v3 (oct-dec only):     LB 0.0654371
# Monthly avg benchmark:       LB 0.0655826
# monthly DRF:                 LB 0.0663027
