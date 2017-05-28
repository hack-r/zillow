
# Special Amenities -------------------------------------------------------
props$hashottuborspa <- ifelse(props$hashottuborspa=="true",1,0)

props$fireplacecnt         <- props$fireplacecnt - 1
props$fireplaceflag        <- ifelse(props$fireplaceflag=="true",1,0)
props$flag_no_fireplace    <- ifelse(props$fireplacecnt==0,1,0)
props$flag_1fireplace      <- ifelse(props$fireplacecnt==1,1,0)
props$flag_2fireplace      <- ifelse(props$fireplacecnt==2,2,0)
props$flag_3ormore_fireplace  <- ifelse(props$fireplacecnt>2,3,0)

props$flag_no_garage    <- ifelse(props$garagecarcnt==0,1,0)
props$flag_1car_garage  <- ifelse(props$garagecarcnt==1,1,0)
props$flag_2car_garage  <- ifelse(props$garagecarcnt==2,2,0)
props$flag_3ormore_garage  <- ifelse(props$garagecarcnt>2,3,0)

props$flag_pooltypeid2 <- ifelse(props$pooltypeid2==1,1,0) #Pool with Spa/Hot Tub
props$flag_pooltypeid7 <- ifelse(props$pooltypeid7==1,1,0) #Pool without hot tub

props$amenities_count <- 0
props$amenities_count <- props$hashottuborspa +
                         props$flag_1car_garage +
                         props$flag_2car_garage +
                         props$flag_3ormore_garage +
                         props$flag_pooltypeid2 +
                         props$flag_pooltypeid7 +
                         props$flag_1fireplace +
                         props$flag_2fireplace +
                         props$flag_3ormore_fireplace

# plot(density(props$yardbuildingsqft17),xlim=c(0,800)) # MAKES NO SENSE -- everyone has a patio and most are huge?
# plot(density(props$yardbuildingsqft26),xlim=c(0,500)) # MAKES NO SENSE
#props$flag_patio <- ifelse(props$yardbuildingsqft17) #Patio in  yard
#props$flag_shed <- ifelse(yardbuildingsqft26,,) # #Storage shed/building in yard
# pooltypeid10 conflicts with hashottuborspa; throw it out
# poolcnt is bad data

# FIPS --------------------------------------------------------------------
props$fips6037 <- ifelse(props$fips==6037,1,0)
props$fips6059 <- ifelse(props$fips==6059,1,0)
props$fips6111 <- ifelse(props$fips==6111,1,0)

props$fips <- NULL

# Property Land Use -------------------------------------------------------
props$flag_co_code_high <- ifelse(props$propertycountylandusecode %in% co_codes_high$propertycountylandusecode,1,0)
props$flag_co_code_low  <- ifelse(props$propertycountylandusecode %in% co_codes_low$propertycountylandusecode,1,0)

#props$propertycountylandusecode <- NULL

# Create Training Data Set (subset of props) ------------------------------
# Join train to props
train <- as.data.table(sqldf("select a.*, b.* from train_raw a left join props b on a.parcelid = b.parcelid"))
which(colnames(train)=="parcelid"); train$parcelid <- NULL;which(colnames(train)=="parcelid")

# Fix date
train$date  <- ymd(train$transactiondate)
train$month <- month(train$date)

# Reshape Y (train only) -- Method 1: Month level datasets / models
train_oct <- train[train$month==10,]
train_nov <- train[train$month==11,]
train_dec <- train[train$month==12,]

# Reshape Y (train only) -- Method 2:

saveRDS(train, "train.RDS")
saveRDS(train_oct, "train_oct.RDS")
saveRDS(train_nov, "train_nov.RDS")
saveRDS(train_dec, "train_dec.RDS")

fwrite(train, "train_r_export_for_python.csv")
fwrite(props, "props_r_export_for_python.csv") # really, you just need this one for python
