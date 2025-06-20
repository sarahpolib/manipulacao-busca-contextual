# Extração de Anotações por Palavras e Tópicos

Este repositório contém um script em R para manipulação e busca contextual de anotações em arquivos derivados do ELAN (.txt), com foco em identificar e extrair trechos relacionados a tópicos específicos (e.g., TRABALHO, LAZER, BAIRRO) e a palavras-chave (e.g.,  rico, pobre), a partir de entrevistas transcritas. O objetivo é facilitar a análise qualitativa de trechos específicos de entrevistas sociolinguísticas.

## Estrutura de Arquivos

- `amostra2.txt` — base de dados tabular extraída do ELAN com colunas: trilha (V1), tempo inicial (V2), tempo final (V3), anotação (V4), nome do arquivo (V5)
- `anotacoes_BAIRRO.txt`, `anotacoes_LAZER.txt`, `anotacoes_trabalho.txt` — saídas com trechos anotados por tópico
- `trechos_POBRE.txt`, `trechos_RICO.txt` — saídas com trechos contendo palavras-chave
- `.RData`, `.Rhistory` — arquivos de sessão
- `extracao-anotacoes-por-palavraschave.R` — script principal do projeto

## Requisitos

- R (versão 4.x)
- Pacote tidyverse

## Como Usar

### 1. Pré-processamento dos dados

Antes de rodar o script, exporte seus arquivos .eaf no formato .txt delimitado por tabulação com as seguintes colunas:

| V1 (trilha) | V2 (início) | V3 (fim) | V4 (anotação) | V5 (nome do arquivo) |

### 2. Executar o script

Abra o script `extracao-anotacoes-por-palavraschave.R` no R e execute as seções a seguir:

#### Etapas principais:

- Limpeza de dados: remoção de pontuação, padronização de maiúsculas/minúsculas
- Filtragem cronológica: ordenação das anotações de cada arquivo (coluna V5) por tempo (coluna V2) e trilhas de interesse (coluna V1; ex: ROTEIRO, S1, D1)
- Padronização de nome dos tópicos de interesse, como INFÂNCIA, TRABALHO e LAZER (dados de ROTEIRO na coluna V4)
- Extração de tópicos:
- TRABALHO, LAZER, BAIRRO: identificação dos trechos com base em seus intervalos temporais
- Busca por palavras-chave:
 - rico, pobre: extrai até 15 linhas de contexto por ocorrência

## Saídas Geradas

O script exporta automaticamente os seguintes arquivos .txt a partir do input `amostra2.txt’ :

- `anotacoes_TRABALHO.txt`
- `anotacoes_LAZER.txt`
- `anotacoes_BAIRRO.txt`
- `trechos_RICO.txt`
- `trechos_POBRE.txt`

## Observações

- Os trechos são extraídos com base nos intervalos de tempo definidos pelas trilhas ROTEIRO
- A busca por palavras-chave considera apenas trilhas diferentes de ROTEIRO (ex.: falas dos participantes)
- O script é adaptável para outros tópicos e palavras, basta ajustar os filtros e padrões de busca

## Autoria

Script desenvolvido por Sarah Poli e Maylle Freitas em 02/06/2025 para análise qualitativa de anotações em trilhas no ELAN (exportadas em .txt) com foco em classe social, trabalho, lazer e espaço urbano em entrevistas

## Licença

Este projeto está sob a licença MIT. Sinta-se à vontade para reutilizar, adaptar e compartilhar.


