
<!-- README.md is generated from README.Rmd. Please edit that file -->

# vns: Verarbeitung Natürlicher Sprache

Welcome to the vns R package! vns stands for the German term
“Verarbeitung Natürlicher Sprache,” which translates to “Natural
Language Processing” in English. This package is a collection of
quantitative text analysis tools specifically designed with a focus on
the German language.

## Installation

You can install the development version of vns from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("m-pilarski/derp")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(vns)
```

### Example Data Sets

``` r
amazon_review_tbl <- load_amazon_review_tbl()

head(amazon_review_tbl)
#> # A tibble: 6 × 4
#>   doc_id     doc_title                        doc_text             doc_label_num
#>   <chr>      <chr>                            <chr>                        <int>
#> 1 de_0784695 Leider nicht zu empfehlen        Leider, leider nach…             0
#> 2 de_0759207 Gummierung nach 6 Monaten kaputt zunächst macht der …             0
#> 3 de_0711785 Flohmarkt ware                   Siegel sowie Verpac…             0
#> 4 de_0964430 Katastrophe                      Habe dieses Produkt…             0
#> 5 de_0474538 Reißverschluss klemmt            Die Träger sind sch…             0
#> # ℹ 1 more row
```
