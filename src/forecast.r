library(forecast)
library(Metrics)

# Load data
data <- read.csv("data.csv")

# Split data into training and testing sets
train <- window(data, end = c(2019, 12))
test <- window(data, start = c(2020, 1))

# Train ETS model
ets_model <- ets(train)

# Train ARIMA model
arima_model <- auto.arima(train)

# Make forecasts
ets_forecast <- forecast(ets_model, h = length(test))
arima_forecast <- forecast(arima_model, h = length(test))

# Evaluate forecasts using MASE
mase_ets <- MASE(ets_forecast$mean, test)
mase_arima <- MASE(arima_forecast$mean, test)

print(paste0("MASE for ETS model: ", mase_ets))
print(paste0("MASE for ARIMA model: ", mase_arima))
