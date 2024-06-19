
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![R-CMD-check](https://github.com/m-pilarski/derp/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/m-pilarski/derp/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

# vns: Verarbeitung Natürlicher Sprache

Welcome to the {vns} R package! “vns” stands for the German term
“Verarbeitung Natürlicher Sprache,” which translates to “Natural
Language Processing” in English. This package provides a comprehensive
suite of tools for quantitative text analysis, specifically tailored for
the German language.

## Installation

You can install the development version of vns from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("m-pilarski/vns")
```

## Example

``` r
library(vns)
```

### Setup Python Dependencies

`vns` has several Python dependencies that can be installed via
`setup_vns_condaenv`. If you prefer to use another Python version, you
can install the dependencies manually (listed in
`vns:::python_dependencies`).

``` r
# setup_vns_condaenv()
use_vns_condaenv()
```

### Example Data Sets

``` r
amazon_review_tbl <- load_amazon_review_tbl()

amazon_review_tbl
#> # A tibble: 210,000 × 4
#>   doc_id     doc_title                        doc_text             doc_label_num
#>   <chr>      <chr>                            <chr>                        <int>
#> 1 de_0784695 Leider nicht zu empfehlen        Leider, leider nach…             0
#> 2 de_0759207 Gummierung nach 6 Monaten kaputt zunächst macht der …             0
#> 3 de_0711785 Flohmarkt ware                   Siegel sowie Verpac…             0
#> 4 de_0964430 Katastrophe                      Habe dieses Produkt…             0
#> 5 de_0474538 Reißverschluss klemmt            Die Träger sind sch…             0
#> # ℹ 209,995 more rows
```

### Document Parsing

Sentence boundary detection, tokenization, and POS tagging via spaCy.

``` r
amazon_review_tbl |> 
  dplyr::slice_sample(n=1e3) |> 
  dplyr::pull(doc_text) |> 
  parse_doc_spacy()
#> # A tibble: 37,778 × 5
#>   doc_id sen_id tok_str tok_pos tok_tag
#>    <int>  <int> <chr>   <chr>   <chr>  
#> 1      0      1 Es      PRON    PPER   
#> 2      0      1 ist     AUX     VAFIN  
#> 3      0      1 NICHT   PART    PTKNEG 
#> 4      0      1 von     ADP     APPR   
#> 5      0      1 Samsung PROPN   NE     
#> # ℹ 37,773 more rows
```

``` r
# summary(amazon_review_tbl$doc_label_num)
# 
# amazon_review_tbl |> 
#   dplyr::mutate(
#     doc_label_class = factor(
#       dplyr::case_when(
#         doc_label_num < 2 ~ 1L, doc_label_num == 2 ~ 2L, doc_label_num > 2 ~ 3L,
#         .default=NA_integer_
#       ),
#       levels=1L:3L, labels=c("neg", "neu", "pos")
#     )
#   ) |> 
#   rsample::initial_split(strata=doc_label_class) |> 
#   (\(.splits){
#     cross_val_tbl <<- rsample::training(.splits)
#     final_val_tbl <<- rsample::testing(.splits)
#   })()
# 
# cross_val_splits <- rsample::vfold_cv(cross_val_tbl, strata=doc_label_class)
# 
# tune::
# 
# cross_val_splits$splits[[1]]$data
```
