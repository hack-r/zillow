
cat("check fe.R for any features used here which are not present in objects")


# Understanding Log Error -------------------------------------------------
# logerror = log(Zestimate) - log(SalePrice)
Zestimate  <- 100000
SalesPrice <- 150000
le = log(Zestimate) - log(SalesPrice)
le

round(exp(le)*SalesPrice) == Zestimate

# Analysis of Dupes -------------------------------------------------------
# Create object to hold data on parcels which have more than one date in train
dupe <- train[duplicated(train$parcelid),]
dupe <- train[train$parcelid %in% dupe$parcelid,]

dupe$parcelid <- as.factor(dupe$parcelid)
dupe$month    <- as.factor(dupe$month)
saveRDS(dupe, "dupe.RDS")

# Sample Size by Month
table(dupe$month) # Nov prohibitively small; Oct and Dec are questionably small
dupe       <- dupe[!dupe$month==11,]
dupe$month <- droplevels(dupe$month)

# Bar Chart of logerror by Month
ggplot(dupe, aes(month, logerror)) +
  geom_col()

# Bar Chart of abs(logerror) by Month
ggplot(dupe, aes(month, abs(logerror))) +
  geom_col()

# Bar Chart of Error by Month
ggplot(dupe, aes(month, exp(logerror))) +
  geom_col()

# Mean logerror
mean(dupe$logerror)

# Linear Effect of Month, Parcle ID Fixed Effects Model
mod <- glm(logerror ~ month + parcelid, data = dupe)
summary(mod)

# Property Land Use -------------------------------------------------------
aggregate(train$logerror, by=list(train$propertycountylandusecode),mean)

co_codes <- sqldf("select avg(logerror) as logerror, count(1) as count from train group by propertycountylandusecode order by count desc")

co_codes      <- co_codes[co_codes$count > 50,]
co_codes_high <- co_codes[co_codes$logerror > .01,]
co_codes_low  <- co_codes[co_codes$logerror < -.01,]
