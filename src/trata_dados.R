# Pacotes
library(tidyverse)
library(magrittr)

# Abrindo base
df<-readxl::read_excel("data/Tourism forecasting competition II dataset.xlsx",
                       sheet = "data for forecasting")
# Transformando datas
df$mes_ano<-as.Date(paste(str_sub(df$...1, 1, 4), str_sub(df$...1, -2, -1), "01", sep = "-"))
df %<>% select(-`...1`) # Removendo original
# Pivotando
df %<>% pivot_longer(all_of(setdiff(colnames(df), "mes_ano")), names_to = "pais", values_to = "valor")
# Selecionando start_date por país
df<-split.data.frame(df, df$pais)
for(i in seq_along(df)){
  df[[i]] %<>% arrange(mes_ano)
  idx_comeca<-sort(which(!is.na(df[[i]]$valor)))[1]
  df[[i]]<-df[[i]][idx_comeca:nrow(df[[i]]),]
}
df<-bind_rows(df)
# Imputando dados faltantes exceto pelo ano de 2023
df<-split.data.frame(df, df$pais)
for(i in seq_along(df)){
  cond_teste<-df[[i]] %>% filter(mes_ano < as.Date("2023-01-01")) %>% pull(valor) %>% anyNA()
  if(cond_teste){
    posic<-df[[i]] %>% filter(mes_ano < as.Date("2023-01-01")) %>% pull(valor) %>% is.na()
    df[[i]][which(posic),"valor"]<-imputeTS::na_kalman(df[[i]])[which(posic), "valor"]
  }
}
df<-bind_rows(df)

# Salvando
write.csv(df, "data/dados_tratados.csv")
