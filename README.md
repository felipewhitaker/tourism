# Tourism Forecasting Competition

This project was developed for the **Tourism Forecasting Competition amid COVID-19 Round II: Recovery of the Chinese Outbound Travel Market from the Pandemic**. 

> The aim of this tourism forecasting competition is three-fold:
> 
> - To further advance the methodology of tourism forecasting in a crisis, particularly for demand recovery, and contribute to the development of this field of research;
> - To inform the tourism industry and destination management and marketing organisations of the good forecasting practice and the predicted recovery of the Chinese outbound market;
> - To promote the Curated Collection on Tourism Demand Forecasting of Annals of Tourism Research as a leading and main outlet for state-of-the-art tourism forecasting research.

## Other works

## Executing this project

Most of this project was developed in R, thanks to the amazing time series packages available.

The work flow was as follows:

- Run `src/trata_dados.R` to prepare data (remove NaN and input data using Kalman Filter)
- Run `src/benchmark_forecast.R` to generate benchmark forecasts (ETS and ARIMA)
- Run `denominador_mase.R` to calculate MASE for benchmark forecasts