# Load Required Libraries
library(ggplot2)
library(mgcv)
library(ranger)
library(caret)
library(gbm)
library(xgboost)
library(MASS) # Required for generalized additive models

# Read in the Data
train_dat <- read.csv("W23P1_train.csv", header = TRUE)

# Exploratory Data Analysis

# Density Plot of Pickup Locations
ggplot(train_dat, aes(x = pickup_longitude, y = pickup_latitude)) +
  geom_density_2d() +
  labs(x = "Longitude", y = "Latitude", title = "Density Plot of Pickup Locations")

# Create a new variable for the day of the week
train_dat$pickup_day <- weekdays(as.Date(train_dat$pickup_datetime))

# Calculate the average fare amount for each day of the week
avg_fare_by_day <- train_dat %>%
  group_by(pickup_day) %>%
  summarize(avg_fare = mean(fare_amount))

# Extract the hour of each pickup_datetime
train_dat$hour <- as.numeric(format(as.POSIXct(train_dat$pickup_datetime), '%H'))
hourly_fares <- aggregate(fare_amount ~ hour, data = train_dat, FUN = mean)

# Plot the hourly fares
plot(hourly_fares$hour, hourly_fares$fare_amount,
     type = "o",
     xlab = "Hour",
     ylab = "Average Fare Amount",
     main = "Hourly Average Trip Fares")

# Linear Regression Model for Passenger Count vs. Fare Amount
lm_model <- lm(fare_amount ~ passenger_count, data = train_dat)

# Linear Model
train_dat$day <- as.numeric(format(as.POSIXct(train_dat$pickup_datetime), '%d'))
test_dat <- read.csv("W23P1_test.csv", header = TRUE)
test_dat$day <- as.numeric(format(as.POSIXct(test_dat$pickup_datetime), '%d'))
model <- lm(fare_amount ~ pickup_longitude + pickup_latitude + dropoff_longitude + dropoff_latitude + day, data = train_dat)
predictions <- predict(model, newdata = test_dat)
outDat <- data.frame(uid = test_dat$uid, predicted_fare_amount = predictions)
write.csv(outDat, file = "W23P1_predictions.csv", row.names = FALSE)

# Generalized Additive Models
train_dat$distance <- sqrt((train_dat$pickup_longitude - train_dat$dropoff_longitude)^2 +
                           (train_dat$pickup_latitude - train_dat$dropoff_latitude)^2)
train_dat$time_of_day <- as.numeric(format(as.POSIXct(train_dat$pickup_datetime), '%H'))
test_dat$distance <- sqrt((test_dat$pickup_longitude - test_dat$dropoff_longitude)^2 + 
                          (test_dat$pickup_latitude - test_dat$dropoff_latitude)^2)
test_dat$time_of_day <- as.numeric(format(as.POSIXct(test_dat$pickup_datetime), '%H'))
gam_model <- gam(fare_amount ~ s(pickup_longitude, bs='cr') + s(pickup_latitude, bs='cr') + 
                 s(dropoff_longitude, bs='cr') + s(dropoff_latitude, bs='cr') + s(passenger_count, bs='cr') + 
                 s(distance, bs='cr') + s(time_of_day, bs='cr'), data = train_dat)
gam_pred <- predict(gam_model, newdata=test_dat)
outDat <- data.frame(uid = test_dat$uid, fare_amount = gam_pred)
write.csv(outDat, file = "W23P1_predictions_gam.csv", row.names = FALSE)

# Random Forests
model <- ranger(fare_amount ~ pickup_longitude + pickup_latitude + dropoff_longitude + 
                dropoff_latitude + passenger_count + distance + time_of_day, data = train_dat, num.trees = 1000, mtry = 3, importance = 'impurity')
predictions <- predict(model, data = test_dat)$predictions
outDat <- data.frame(uid = test_dat$uid, fare_amount = predictions)
write.csv(outDat, file = "W23P1_predictions_random_forests_mtry.csv", row.names = FALSE)

# Boosting Trees
boost_model <- gbm(fare_amount ~ pickup_longitude + pickup_latitude + dropoff_longitude +
                   dropoff_latitude + passenger_count + distance + time_of_day, data = train_dat, distribution = "gaussian", n.trees = 1000, interaction.depth = 3, cv.folds = 5)
cv.num <- gbm.perf(boost_model, method = "cv")
predictions <- predict(boost_model, newdata = test_dat, n.trees = cv.num)
outDat <- data.frame(uid = test_dat$uid, fare_amount = predictions)
write.csv(outDat, file = "W23P1_predictions_boosting_trees.csv", row.names = FALSE)
