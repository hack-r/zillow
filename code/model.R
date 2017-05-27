# Start H2O ---------------------------------------------------------------
system("java -Xmx20g -jar E://Jason//h2o//h2o.jar", wait = F)
h2o.init(nthread = -1)

# Load Data ---------------------------------------------------------------
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



# Oct Model -------------------------------------------------------------------
grid_y10 <- h2o.grid("randomForest",
                     x                        = colnames(trainHex_oct),
                     #x                        = y0_vi$variable[y0_vi$percentage > 0],
                     y                        = "logerror",
                     training_frame           = trainHex,
                     validation_frame         = trainHex_oct,
                     model_id                 = "drf_grid.hex",
                     ntrees                   = 300,
                     #max_depth                = 9,
                     nbins                    = 10,
                     nbins_top_level          = 100,
                     #sample_rate              = .95,
                     stopping_rounds          = 10,
                     stopping_metric          = "MSE",
                     stopping_tolerance       = .001,
                     #mtries                   = 8,
                     nfolds                   = 3,
                     seed                     = 2016,
                     col_sample_rate_per_tree = 1,
                     min_rows                 = 2,
                     hyper_params             = list(
                       max_depth=c(1,3,9,12))
)

summary(grid_y10)
y10_drf <- h2o.getModel("Grid_DRF_file1474cee66f8NA_8_model_R_1495752426426_12_model_3")
summary(y10_drf) # finishedsquarefeet15
h2o.mse(y10_drf)
sqrt(h2o.mse(y10_drf)) #

y10_vi <- as.data.frame(h2o.varimp(y10_drf)); head(y10_vi)
y10_vi; saveRDS(y10_vi, "y10_vi.RDS")
plot(y10_vi$percentage)

# Nov Model ---------------------------------------------------------------
grid_y11 <- h2o.grid("randomForest",
                     x                        = colnames(trainHex_nov),
                     #x                        = y0_vi$variable[y0_vi$percentage > 0],
                     y                        = "logerror",
                     training_frame           = trainHex,
                     validation_frame         = trainHex_nov,
                     model_id                 = "drf_grid.hex",
                     ntrees                   = 300,
                     #max_depth                = 9,
                     nbins                    = 10,
                     nbins_top_level          = 100,
                     #sample_rate              = .95,
                     stopping_rounds          = 10,
                     stopping_metric          = "MSE",
                     stopping_tolerance       = .001,
                     #mtries                   = 8,
                     nfolds                   = 3,
                     seed                     = 2016,
                     col_sample_rate_per_tree = 1,
                     min_rows                 = 2,
                     hyper_params             = list(
                       max_depth=c(1,3,9))
)

summary(grid_y11)
y11_drf <- h2o.getModel("Grid_DRF_file1474cee66f8NA_8_model_R_1495752426426_13_model_2")
summary(y11_drf) #
h2o.mse(y11_drf)
sqrt(h2o.mse(y11_drf)) #

y11_vi <- as.data.frame(h2o.varimp(y11_drf)); head(y11_vi)
y11_vi; saveRDS(y11_vi, "y11_vi.RDS")
plot(y11_vi$percentage)

# dec Model ---------------------------------------------------------------
grid_y12 <- h2o.grid("randomForest",
                     x                        = colnames(trainHex_dec),
                     #x                        = y0_vi$variable[y0_vi$percentage > 0],
                     y                        = "logerror",
                     training_frame           = trainHex,
                     validation_frame         = trainHex_dec,
                     model_id                 = "drf_grid.hex",
                     ntrees                   = 300,
                     #max_depth                = 9,
                     nbins                    = 10,
                     nbins_top_level          = 100,
                     #sample_rate              = .95,
                     stopping_rounds          = 10,
                     stopping_metric          = "MSE",
                     stopping_tolerance       = .001,
                     #mtries                   = 8,
                     nfolds                   = 3,
                     seed                     = 2016,
                     col_sample_rate_per_tree = 1,
                     min_rows                 = 2,
                     hyper_params             = list(
                       max_depth=c(1,3,9))
)

summary(grid_y12)
y12_drf <- h2o.getModel("Grid_DRF_file1474cee66f8NA_8_model_R_1495752426426_14_model_2")
summary(y12_drf) #
h2o.mse(y12_drf)
sqrt(h2o.mse(y12_drf)) #

y12_vi <- as.data.frame(h2o.varimp(y12_drf)); head(y12_vi)
y12_vi; saveRDS(y12_vi, "y12_vi.RDS")
plot(y12_vi$percentage)

# Predict -----------------------------------------------------------------
pred10 <- h2o.predict(y10_drf, scoreHex)
pred11 <- h2o.predict(y11_drf, scoreHex)
pred12 <- h2o.predict(y12_drf, scoreHex)

pred10 <- as.data.table(pred10)
pred11 <- as.data.table(pred11)
pred12 <- as.data.table(pred12)

fwrite(pred10, "pred10.csv")
fwrite(pred11, "pred11.csv")
fwrite(pred12, "pred12.csv")

samp$`201610` <- pred10$predict
samp$`201710` <- pred10$predict
samp$`201611` <- pred11$predict
samp$`201711` <- pred11$predict
samp$`201612` <- pred12$predict
samp$`201712` <- pred12$predict

fwrite(samp, "monthly_drf.csv")
