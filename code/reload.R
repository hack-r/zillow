props <- readRDS("props.RDS")
train <- readRDS("train.RDS")
samp  <- readRDS("samp.RDS")
dict  <- fread("zillow_data_dictionary.csv")
dupe  <- readRDS("dupe.RDS")

train_oct <- readRDS("train_oct.RDS")
train_nov <- readRDS("train_nov.RDS")
train_dec <- readRDS("train_dec.RDS")

train_raw <- fread("train_2016.csv") #readRDS("train_raw.RDS")
props_raw <- readRDS("props_raw.RDS")

props_mat <- readRDS("props_mat.RDS")
valid_mat <- readRDS("valid_mat.RDS")
train_mat <- readRDS("train_mat.RDS")

vid <- readRDS("vid.RDS")
pid <- readRDS("vid.RDS")

labels       <- readRDS("labels.RDS")
valid.labels <- readRDS("valid.labels.RDS")
