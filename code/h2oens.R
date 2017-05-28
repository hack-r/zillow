# Libraries ---------------------------------------------------------------
library(h2oEnsemble)
library(SuperLearner)  # For metalearner such as "SL.glm"
library(cvAUC)  # Used to calculate test set AUC (requires version >=1.0.1 of cvAUC)

# Start H2O ---------------------------------------------------------------
system("java -Xmx20g -jar E://Jason//h2o//h2o.jar", wait = F)
h2o.init(nthread = -1)

# Data --------------------------------------------------------------------
train_oct$date            <- NULL
train_oct$month           <- NULL
train_oct$transactiondate <- NULL
train_oct$year            <- NULL
train_oct$parcelid        <- NULL
train_oct$parcelid        <- NULL

trainHex_oct <- as.h2o(train_oct)

train_nov$date            <- NULL
train_nov$month           <- NULL
train_nov$transactiondate <- NULL
train_nov$year            <- NULL
train_nov$parcelid        <- NULL
train_nov$parcelid        <- NULL

trainHex_nov <- as.h2o(train_nov)

train_dec$date            <- NULL
train_dec$month           <- NULL
train_dec$transactiondate <- NULL
train_dec$year            <- NULL
train_dec$parcelid        <- NULL
train_dec$parcelid        <- NULL

trainHex_dec <- as.h2o(train_dec)

traindf  <- as.data.frame(train)
trainHex <- as.h2o(traindf[,colnames(traindf)%in%colnames(train_nov)])
scoreHex <- as.h2o(props[,colnames(props)%in%colnames(train_nov)])

# Base and Metalearner Setup ----------------------------------------------
h2o.randomForest.1 <- function(..., ntrees = 200, nbins = 100, seed = 1, max_depth = 16) h2o.randomForest.wrapper(..., ntrees = ntrees, nbins = nbins, seed = seed, max_depth = max_depth)
h2o.deeplearning.1 <- function(..., hidden = c(500,500), activation = "Rectifier", seed = 1)  h2o.deeplearning.wrapper(..., hidden = hidden, activation = activation, seed = seed)
h2o.deeplearning.2 <- function(..., hidden = c(100,100,100), activation = "Tanh", seed = 1)  h2o.deeplearning.wrapper(..., hidden = hidden, activation = activation, seed = seed)
learner     <- c("h2o.randomForest.1", "h2o.deeplearning.1","h2o.deeplearning.2") #, "h2o.glm.wrapper"


# Oct Model ---------------------------------------------------------------
summary(trainHex[,"logerror"])

fit_y0 <- h2o.ensemble(x                = colnames(train_oct),#var_imp$variable[var_imp$percentage > 0.001],
                       y                = "logerror",
                       training_frame   = trainHex,
                       validation_frame = trainHex_oct,
                       metalearner      ="h2o.randomForest.wrapper",
                       learner          = learner)

valid_y0   <- predict(fit_y0, trainHex_oct)
score_y0     <- predict(fit_y0, scoreHex)

valid_y0 <- as.data.frame(valid_y0$pred)
score_y0   <- as.data.frame(score_y0$pred)

saveRDS(valid_y0, "ens_valid_oct_pred.RDS")
saveRDS(score_y0, "ens_score_oct.RDS")

# Nov Model ---------------------------------------------------------------
fit_y1 <- h2o.ensemble(x                = colnames(train_nov),#var_imp$variable[var_imp$percentage > 0.001],
                       y                = "logerror",
                       training_frame   = trainHex,
                       validation_frame = trainHex_nov,
                       metalearner      ="h2o.randomForest.wrapper",
                       learner          = learner)

valid_y1   <- predict(fit_y1, trainHex_nov)
score_y1   <- predict(fit_y1, scoreHex)

valid_y1 <- as.data.frame(valid_y1$pred)
score_y1 <- as.data.frame(score_y1$pred)

saveRDS(valid_y1, "ens_valid_nov_pred.RDS")
saveRDS(score_y1,   "ens_score_nov.RDS")


# Dec Model ---------------------------------------------------------------
fit_y2 <- h2o.ensemble(x                = colnames(train_dec),#var_imp$variable[var_imp$percentage > 0.001],
                       y                = "logerror",
                       training_frame   = trainHex,
                       validation_frame = trainHex_dec,
                       metalearner      ="h2o.randomForest.wrapper",
                       learner          = learner)

valid_y2   <- predict(fit_y2, trainHex_dec)
score_y2   <- predict(fit_y2, scoreHex)

valid_y2 <- as.data.frame(valid_y2$pred)
score_y2   <- as.data.frame(score_y2$pred)

saveRDS(valid_y2, "ens_valid_dec_pred.RDS")
saveRDS(score_y2,   "ens_score_dec.RDS")
