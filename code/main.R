
# Options and Libraries ---------------------------------------------------
options(scipen = 10)
setwd("..//data")
pacman::p_load(bit64, data.table, h2o, h2oEnsemble, lightgbm,
               lubridate, methods, Matrix, tidyverse, RRF, sqldf)
reload <- F # T to reload objects from .RDS

# Run Component Scripts ---------------------------------------------------
if(!reload){
# ETL
source("data.R")

# Feature Engineering
source("fe.R")

# EDA
source("eda.R")
} else{source("reload.R")}

# Model Training, Validation, Scoring
source("drf.R")
source("lgb.R")

# Final Ensemble
source("stack.R")