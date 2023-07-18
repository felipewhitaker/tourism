# Pacotes
library(tidyverse)
library(magrittr)
library(forecast)

# Load data
data<-read.csv("data/dados_tratados.csv")
data %<>% select(-X)
data %<>% mutate(mes_ano = as.Date(mes_ano))
data<-split.data.frame(data, data$pais)
# Loop pré-COVID
# Rodando em loop
lista_pre<-list()
for(i in seq_along(data)){
  df<-data[[i]]
  df %<>% filter(mes_ano <= as.Date("2019-12-01"))
  ts_completa<-ts(data = df$valor, end = c(2019, 12), frequency = 12)
  # Split data into training and testing sets
  train<-window(ts_completa, end = c(2018, 12))
  test<-window(ts_completa, start = c(2019, 1))
  # Train ETS model
  ets_model<-ets(train)
  # Train ARIMA model
  arima_model<-auto.arima(train)
  # Make forecasts
  ets_forecast<-forecast(ets_model, h = length(test))
  arima_forecast<-forecast(arima_model, h = length(test))
  # Salvando
  lista_pre[[i]]<-tibble("pais" = unique(df$pais), "mes_ano" = tail(df$mes_ano, 12),
                         "prev_ets" = ets_forecast$mean, "prev_arima" = arima_forecast$mean,
                         "ocorrido" = tail(df$valor, 12))
  print(i)
}

lista_pre<-bind_rows(lista_pre)

# Salvando
write.csv(lista_pre, "data/previsoes_pre_covid_benchmarks.csv")

# Loop Completo
# Rodando em loop
data<-read.csv("data/dados_tratados.csv")
data %<>% select(-X)
data %<>% mutate(mes_ano = as.Date(mes_ano))
data<-split.data.frame(data, data$pais)
lista<-list()
for(i in seq_along(data)){
  df<-data[[i]]
  df %<>% filter(mes_ano < as.Date("2023-01-01"))
  ts_completa<-ts(data = df$valor, end = c(2022, 12), frequency = 12)
  # Split data into training and testing sets
  train<-window(ts_completa, end = c(2021, 12))
  test<-window(ts_completa, start = c(2022, 1))
  # Train ETS model
  ets_model<-ets(log(train))
  # Train ARIMA model
  arima_model<-auto.arima(log(train))
  # Make forecasts
  ets_forecast<-forecast(ets_model, h = length(test))
  arima_forecast<-forecast(arima_model, h = length(test))
  # Salvando
  lista[[i]]<-tibble("pais" = unique(df$pais), "mes_ano" = tail(df$mes_ano, 12),
                     "prev_ets" = exp(ets_forecast$mean), "prev_arima" = exp(arima_forecast$mean),
                     "ocorrido" = tail(df$valor, 12))
  print(i)
}

lista<-bind_rows(lista)

# Salvando
write.csv(lista, "data/logexp_previsoes_completa_benchmarks.csv")
