
# Add Ground Truth from Train to Scores -----------------------------------


# Base Model Scores -------------------------------------------------------
# Monthly DRF's
pred10 <- fread("pred10.csv")
pred11 <- fread("pred11.csv")
pred12 <- fread("pred12.csv")

# h2oens
ens10 <- readRDS("ens_score_oct.RDS")
ens11 <- readRDS("ens_score_nov.RDS")
ens12 <- readRDS("ens_score_dec.RDS")

# R LGB
lgb.pred <- readRDS("lgb_pred_score.RDS")

# Py LGB
lgb.py <- fread("lgb_starter.csv",header=T)

# Model Stack -------------------------------------------------------------
# samp$`201610` <- pred10$predict * .5 + lgb.pred * .5
# samp$`201710` <- pred10$predict * .5 + lgb.pred * .5
# samp$`201611` <- pred11$predict * .5 + lgb.pred * .5
# samp$`201711` <- pred11$predict * .5 + lgb.pred * .5
# samp$`201612` <- pred12$predict * .5 + lgb.pred * .5
# samp$`201712` <- pred12$predict * .5 + lgb.pred * .5
#
# samp$`201610` <- pred10$predict * 0 + lgb.pred #* .5
# samp$`201710` <- pred10$predict * 0 + lgb.pred #* .5
# samp$`201611` <- pred11$predict * 0 + lgb.pred #* .5
# samp$`201711` <- pred11$predict * 0 + lgb.pred #* .5
# samp$`201612` <- pred12$predict * 0 + lgb.pred #* .5
# samp$`201712` <- pred12$predict * 0 + lgb.pred #* .5

samp$`201610` <- ens10$predict * .02 + lgb.py$`201610` * .98
samp$`201710` <- ens10$predict * .02 + lgb.py$`201610` * .98
samp$`201611` <- ens11$predict * .02 + lgb.py$`201610` * .98
samp$`201711` <- ens11$predict * .02 + lgb.py$`201610` * .98
samp$`201612` <- ens12$predict * .02 + lgb.py$`201610` * .98
samp$`201712` <- ens12$predict * .02 + lgb.py$`201610` * .98


# Write Out Results -------------------------------------------------------
fwrite(samp, "submission.csv")
#zip("my_submission.zip", files=paste(getwd(), "submission.csv", sep="/"))

# Log Results -------------------------------------------------------------
# Python LGB:                  LB 0.0648528
# h2oens .02 Py LGB .98:       LB 0.0648664
# R LGB v4:                    LB 0.0649941
# R LGB v2:                    LB 0.0650085
# R LGB v1:                    LB 0.0652332
# R LGB v4 with g.t. replace:  LB 0.0653202
# .5 monthly DRF, .5 R LGB v1: LB 0.0653991
# R LGB v3 (oct-dec only):     LB 0.0654371
# Monthly avg benchmark:       LB 0.0655826
# monthly DRF:                 LB 0.0663027
