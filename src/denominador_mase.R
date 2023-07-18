# Pacotes
library(tidyverse)
library(magrittr)

# Versão com todos os dados ----
# Abrindo dados
df<-readxl::read_excel("data/Tourism forecasting competition II dataset.xlsx",
                       sheet = "data for forecasting")
# Transformando datas
df$mes_ano<-as.Date(paste(str_sub(df$...1, 1, 4), str_sub(df$...1, -2, -1), "01", sep = "-"))
df %<>% select(-`...1`) # Removendo original
# Pivotando
df %<>% pivot_longer(all_of(setdiff(colnames(df), "mes_ano")), names_to = "pais", values_to = "valor")
# Criando lag12
df %<>% group_by(pais) %>% mutate(l_12 = lag(valor, 12)) %>%
  ungroup() %>% drop_na()
# Calculando abs(erro)
df %<>% mutate(abs_erro = abs(valor-l_12)) %>% select(-valor, -l_12)
# Finalizando calculando a média
df %<>% group_by(pais) %>% summarise(mae_s_naive_insample = mean(abs_erro)) %>%
  ungroup()
# Salvando
write.csv(df, "data/denominador_mase_completo.csv")

# Versão até 2019 (incluso) ----
# Abrindo dados
df<-readxl::read_excel("data/Tourism forecasting competition II dataset.xlsx",
                       sheet = "data for forecasting")
# Transformando datas
df$mes_ano<-as.Date(paste(str_sub(df$...1, 1, 4), str_sub(df$...1, -2, -1), "01", sep = "-"))
df %<>% select(-`...1`) # Removendo original
# Filtrando até o fim de 2019
df %<>% filter(mes_ano <= as.Date("2019-12-01"))
# Pivotando
df %<>% pivot_longer(all_of(setdiff(colnames(df), "mes_ano")), names_to = "pais", values_to = "valor")
# Criando lag12
df %<>% group_by(pais) %>% mutate(l_12 = lag(valor, 12)) %>%
  ungroup() %>% drop_na()
# Calculando abs(erro)
df %<>% mutate(abs_erro = abs(valor-l_12)) %>% select(-valor, -l_12)
# Finalizando calculando a média
df %<>% group_by(pais) %>% summarise(mae_s_naive_insample = mean(abs_erro)) %>%
  ungroup()
# Salvando
write.csv(df, "data/denominador_mase_pre_covid.csv")
