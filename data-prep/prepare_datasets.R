library(dplyr)
library(stringr)

data_folder <- './Dados'
MIN_NUM_DISCURSOS = 10
anos <-c(2016:2018)

output_path_discursos_sep = paste(data_folder,'discursos_sep.csv',sep='/')
output_path_discursos_concat = paste(data_folder,'discursos_concat.csv',sep='/')

discursos_sep = data.frame()

for(ano in anos) {
  input_path <- paste(data_folder,paste0('parsed_discurso_', ano, '_dit.csv'),sep='/')  
  discursos_sep <- read.csv2(input_path) %>%
    mutate(deputado = trimws(gsub("\\(.*", "", deputado))) %>%
    na.omit() %>%
    rbind(discursos_sep,.)
}

discursos_sep_clean <- discursos_sep %>%
  rowwise() %>%
  mutate(discurso = sub(".*?-", "", Discurso)) %>%
  ungroup() %>%
  select(-Discurso)

write.csv2(discursos_sep_clean,output_path_discursos_sep, row.names=F)

discursos_deputados_qtd <- discursos_sep_clean %>%
  group_by(deputado) %>%
  arrange(timestamp) %>%
  summarise(num_discursos = n(),
            partido = last(partido),
            uf = last(uf))

selected_deputados <- discursos_deputados_qtd %>%
  filter(num_discursos >= MIN_NUM_DISCURSOS)

discursos_deputados_selecionados_concat <- discursos_sep_clean %>%
  select(-timestamp, -partido, -uf) %>%
  merge(selected_deputados) %>%
  group_by(deputado, partido, uf) %>%
  summarise(discurso_total = paste(discurso, collapse=' '))

write.csv2(discursos_deputados_selecionados_concat,output_path_discursos_concat, row.names=F)
