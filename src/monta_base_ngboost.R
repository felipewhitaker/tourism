# Pacotes
library(tidyverse)
library(magrittr)
# Abrindo dados
df<-read.csv("data/dados_tratados.csv")
df %<>% select(-X)
df %<>% mutate(mes_ano = as.Date(mes_ano))
# Criando a variável dependente de interesse - log(yt/yt-12)
df %<>% mutate(valor_1 = (valor+1)) %>%
  group_by(pais) %>%
  mutate(l12 = lag(valor_1, 12)) %>% ungroup() %>%
  mutate(y = log(valor_1/l12)) %>% select(-valor_1, -l12)
# Jogando fora o começo e ano de 2023 - finais irregulares de série
df %<>% drop_na()
df %<>% filter(mes_ano < as.Date("2023-01-01"))
# Criando "lag_relevante"
df<-split.data.frame(df, df$pais)
for(i in seq_along(df)){
  df_aux<-df[[i]]
  for(j in 8:19){
    df_aux[[paste0("y_lag_", j)]]<-lag(df_aux$y, j)
  }
  df_aux %<>% pivot_longer(all_of(paste0("y_lag_", 8:19)), names_to = "lag_horizonte", values_to = "lag_y_relevante")
  df_aux$lag_horizonte<-str_remove_all(df_aux$lag_horizonte, "y_lag_")
  df[[i]]<-df_aux
}
df<-bind_rows(df)
df %<>% drop_na()
# Criando variáveis me janela rolante
df %<>% 
  group_by(pais, lag_horizonte) %>%
  mutate(min_5 = zoo::rollapplyr(lag_y_relevante, 5, min, fill = NA),
         max_5 = zoo::rollapplyr(lag_y_relevante, 5, max, fill = NA),
         mean_5 = zoo::rollapplyr(lag_y_relevante, 5, mean, fill = NA),
         median_5 = zoo::rollapplyr(lag_y_relevante, 5, median, fill = NA)) %>%
  ungroup() %>% drop_na()
# Juntando a prob de cada regime
df_prob<-read.csv("data/prob_regime_filtrada.csv")
df_prob %<>% mutate(mes_ano = as.Date(mes_ano))
df_prob %<>% select(mes_ano, pais, regime_prob)
df %<>% left_join(df_prob)

# Salvando
write.csv(df, "data/dados_ngboost.csv")
