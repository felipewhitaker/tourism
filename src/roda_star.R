# Pacotes
library(tidyverse)
library(magrittr)
library(forecast)
library(tsDyn)

data<-read.csv("data/dados_tratados.csv")
data %<>% select(-X)
data %<>% mutate(mes_ano = as.Date(mes_ano))
data<-split.data.frame(data, data$pais)
lista<-list()
for(i in seq_along(data)){
  df<-data[[i]]
  df$valor<-(df$valor+1)
  df$l12<-lag(df$valor, 12)
  df$y_tratado<-log(df$valor/df$l12)
  df %<>% drop_na()
  mod<-star(df$y_tratado, noRegimes = 2, m = 2)
  regime_prob<-try(sigmoid(mod$model.specific$thVar))
  if(class(regime_prob) == "try-error"){
    regime_prob<-rep(1, (nrow(df)-2))
  }
  lista[[i]]<-tibble("pais" = unique(df$pais),
                     "mes_ano" = tail(df$mes_ano, length(regime_prob)),
                     "regime_prob" = regime_prob)
  print(i)
}

lista<-bind_rows(lista)

# Salvando
write.csv(lista, "data/prob_regime_filtrada.csv")
