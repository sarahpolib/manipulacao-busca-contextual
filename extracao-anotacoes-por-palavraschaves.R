#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
#%%%%%%%%%%%%%%%%%%%%%%% Manipulação e busca contextual %%%%%%%%%%%%%%%%%%%%%#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 30/05/2025 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% V3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# data nova
###### Passos pré manipulação:
    #1º: Exportar vários arquivos .eaf para o formato de texto delimitado por tabulador com as colunas:#nome da trilha, #tempo inicial, #final, #anotação, #nome do arquivo
    #2º: verificar estrutura da planilha --> V1: nome da trilha, V4: anotações, V5: nome do arquivo

###### script vai pesquisar e exportar como txt os trechos de ROTEIRO (trabalho, infancia e lazer), além de pesquisar por contexto as palavras "rico" "pobre" para comentários sobre classe 

#

#CARREGAR PACOTES####
library(tidyverse)

#INICIAR AREA DE TRABALHO####
rm(list = ls())
setwd("C:/Users/sarah/Downloads/analiseSclasse/analise-qualitativa/amostra2")

#CARREGAR ARQUIVO####
arquivo<-"amostra2"
arquivo2<-paste(arquivo, ".txt", sep="")
dados <- read.delim(arquivo2, header=FALSE, quote = "", fileEncoding = "UTF-8")

#CHECAGEM DOS DADOS####
head(dados)
str(dados)
#View(dados)
length(dados[,1])
dados_originais <- dados
unique(dados$V5)

#MANIPULAÇÃO DOS DADOS:####
##Retirar caracteres, colOcoar anotações em caixa baixa e nome de trilhas em caixa alta####
dados$V4 <- gsub("\\(|\\)|\\{|\\}|\\'|\\[|\\]|\\!|\\.|\\/|\\?|\"", "", dados$V4, ignore.case=T)
dados$V4 <- sub("\\s+$", "", dados$V4) #remove espaços do final de cada string
dados$V4 <- tolower(dados$V4)
dados$V1 <- toupper(dados$V1)
str(dados)

##Anotações em ordem cronológica e selecionar trilhas de interesse ####
unique(dados$V1)
dados2 <- dados %>% 
  filter(V1 %in% c("ROTEIRO", "S", "D1")) %>% 
  arrange(V5, V2) %>% #ordem cronológica a partir de tempo incial
  droplevels()
#View(dados2)


##checagem da trilha ROTEIRO####
dados.ROTEIRO  <- dados2 %>% 
  filter(V1 == "ROTEIRO", ignore.case = TRUE)
unique(dados.ROTEIRO$V4)

#Arrumar inconsistências
dados3 <- dados2 %>%
  mutate(
    V4 = if_else(
      V1 == "ROTEIRO",
      case_when(
      str_detect(V4, regex("trab", ignore_case = TRUE)) ~ "TRABALHO",
      str_detect(V4, regex("inf", ignore_case = TRUE)) ~ "INFÂNCIA",
      str_detect(V4, regex("quest", ignore_case = TRUE)) ~ "QUESTIONÁRIO DE IDENTIDADE",
      str_detect(V4, regex("produ", ignore_case = TRUE)) ~ "PRODUÇÃO PERCEPÇÃO AVALIAÇÃO LINGUÍSTICA",
      str_detect(V4, regex("fam", ignore_case = TRUE)) ~ "FAMÍLIA",
      TRUE ~ toupper(V4)
    ),
    V4
  )
  )

##checagem da trilha ROTEIRO####
dados.ROTEIRO2  <- dados3 %>% 
  filter(V1 == "ROTEIRO", ignore.case = TRUE)
unique(dados.ROTEIRO2$V4)



#BUSCA POR TÓPICO: TRABALHO ####
dados.TRABALHO <- dados.ROTEIRO2 %>% 
  filter(V4 == "TRABALHO") %>% 
  droplevels() %>% 
  print()



## Filtrar apenas as anotações que estão dentro dos intervalos de tempo de TRABALHO em cada arquivo
arquivos <- unique(dados$V5)


# Inicializa um data frame acumulador
anotacoes_TRABALHO <- data.frame()

# Loop por arquivo
for (arquivo in arquivos) { 
  dados_arquivo <- dados3 %>% 
    filter(V5 == arquivo) #cria um subconjunto de dados que contém as linhas de cada arquivo
  
  # Filtra intervalos "TRABALHO", selecionando apenas o incio e o fim dos trechos sobre trabalho
  intervalos_trabalho <- dados.TRABALHO %>%
    filter(grepl("TRABALHO", V4), V5 == arquivo) %>%
    select(inicio = V2, fim = V3)
  
  # Se houver algum intervalo de TRABALHO
  if (nrow(intervalos_trabalho) > 0) {
    anotacoes_dentro <- dados_arquivo %>% 
      filter(
        sapply(1:n(), function(i) {
        any(intervalos_trabalho$inicio <= V2[i] & intervalos_trabalho$fim >= V3[i])
      }) # Para cada anotação, verifica se ela está dentro de algum intervalo de TRABALHO

    )
    
    # Acumula
    anotacoes_TRABALHO <- bind_rows(anotacoes_TRABALHO, anotacoes_dentro %>% select(V1, V4,V5))
  }
}

# Exporta tudo para um único arquivo
write_csv(anotacoes_TRABALHO, "anotacoes_trabalho.txt")


#BUSCA POR TÓPICO: LAZER####

#BUSCA POR TÓPICO: LAZER####

#BUSCA POR TÓPICO







#Retirar dados contextuais e roteiro, deixando apenas trilhas D1 e S####
dados2 <- dados %>% 
  filter(!V1 %in% c("Dados Contextuais", "Roteiro", "ROTEIRO", "S1")) %>% 
  arrange(V5, V2) %>% #ordem cronológica a partir de tempo incial
  droplevels()

#checagem
str(dados2)
View(dados2)
unique(dados2$V1)
dados2$V2
head(dados2)
names(dados2)

#colocar V1 em V4 separando por "|" ####
#Passo descartado pra consegur filtrar por V1
#dados2$V4 <- paste(dados2$V1, dados2$V4, sep = " | ")
#head(dados2)
#str(dados2)
#dados2$V4

#Selecionar apenas as colunas de interesse: falante, anotação e arquivo ####
dados3 <- dados2 %>% 
  select(V1, V4, V5)
head(dados3)


#BUSCAR CONTEXTOS ##############################################################

## Lista de palavras e seus nomes de arquivo #### 
palavras <- list(
  RICO = "\\brico\\b",
  POBRE = "\\bpobre\\b",
  BAIRRO = "\\bbairro\\b",
  LAZER = "\\blazer\\b",
  TRABALHO_SERVICO = "trabalh|serviço",
  MEGASENA = "\\bmega[\\s\\-]?sena\\b"
)

## Faz a busca para cada palavra ####
for (nome_palavra in names(palavras)) {
  
  padrao <- palavras[[nome_palavra]]
  blocos_geral <- list()
  
  # Percorre os arquivos do corpus
  arquivos <- unique(dados3$V5)
  for (arquivo in arquivos) {
    
    print(paste("Processando:", arquivo)) 
    
    # Subconjunto com falas D1 apenas para busca
    df_arquivo_D1 <- subset(dados3, V5 == arquivo & V1 == "D1")
    
    # Subconjunto completo para extrair trechos
    df_arquivo_tudo <- subset(dados3, V5 == arquivo)
    
    # Encontra posições relativas (em df_arquivo_D1) da palavra
    posicoes_relativas <- grep(padrao, df_arquivo_D1$V4, ignore.case = TRUE)
    if (length(posicoes_relativas) == 0) next
    
    # Converte posições para índices reais no dados3
    posicoes_absolutas <- as.numeric(rownames(df_arquivo_D1)[posicoes_relativas])
    
    for (linha_dados3 in posicoes_absolutas) {
      
      print(paste("Extraindo trecho a partir da linha (dados3):", linha_dados3))
      
      # Localiza a linha correspondente no df_arquivo_tudo
      linha_inicio <- which(rownames(df_arquivo_tudo) == linha_dados3)
      
      if (length(linha_inicio) == 0) next  # segurança
      
      # Agora inclui também a coluna V1 no trecho
      trecho <- df_arquivo_tudo[
        linha_inicio:min(nrow(df_arquivo_tudo), linha_inicio + 15),
        c("V1", "V4", "V5")
      ]
      
      # Remove tags HTML
      trecho$V4 <- gsub("<[^>]+>", "", trecho$V4)
      
      # Formata linha como: V1 \t V4 \t V5
      bloco_texto <- apply(trecho, 1, function(linha) paste(linha, collapse = "\t"))
      bloco_completo <- c(
        paste0("### Arquivo: ", arquivo),
        "--- Trecho ---",
        bloco_texto,
        ""
      )
      blocos_geral[[length(blocos_geral) + 1]] <- bloco_completo
    }
  }
  
  # Escreve arquivo de saída
  if (length(blocos_geral) > 0) {
    saida_final <- unlist(blocos_geral)
    nome_arquivo_saida <- paste0("trechos_", nome_palavra, ".txt")
    writeLines(saida_final, nome_arquivo_saida)
  }
}

