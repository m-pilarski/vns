
<!-- README.md is generated from README.Rmd. Please edit that file -->

# vns

vns: Verarbeitung Natürlicher Sprache

Welcome to the vns R package! vns stands for “Verarbeitung Natürlicher
Sprache,” which translates to “Natural Language Processing” in English.
This package is a collection of quantitative text analysis tools
specifically designed with a focus on the German language. Installation

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
#>       doc_id                        doc_title
#> 1 de_0784695        Leider nicht zu empfehlen
#> 2 de_0759207 Gummierung nach 6 Monaten kaputt
#> 3 de_0711785                   Flohmarkt ware
#> 4 de_0964430                      Katastrophe
#> 5 de_0474538            Reißverschluss klemmt
#> 6 de_0178529                     Keine Option
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    doc_text
#> 1                                                                                                                                                                                                            Leider, leider nach einmal waschen ausgeblichen . Es sieht super hübsch aus , nur leider stinkt es ganz schrecklich und ein Waschgang in der Maschine ist notwendig ! Nach einem mal waschen sah es aus als wäre es 10 Jahre alt und hatte 1000 e von Waschgängen hinter sich :( echt schade !
#> 2 zunächst macht der Anker Halter einen soliden Eindruck. Die Magnethalterung ist auch brauchbar. Was gar nicht geht ist die Tatsache, dass die Halterung für runde Lüftungsdüsen, anders als vom Hersteller beschrieben, nicht geeignet ist! Ständig fällt das Smartphone runter. Durch das häufige Wiederanbringen ist nun auch die Gummierung kaputt, was zur Folge hat, dass die Lüftungsdüse schön zerkratzt wird! Also Schrott, der auch noch mein Auto beschädigt! Für mich ist das nicht brauchbar!
#> 3                                                                                                                                                                                                                                                                                                                                              Siegel sowie Verpackung war beschädigt und ware war gebraucht mit Verschleiß und Fingerabdrücke. Zurück geschickt und bessere qualitativere Artikel gekauft.
#> 4                                                                                                                                                                                                                                                                                                                                                                                                                            Habe dieses Produkt NIE erhalten und das Geld wurde nicht rückerstattet!!!!!!!
#> 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                        Die Träger sind schnell abgerissen
#> 6                                                                                                                                                                                                                                                                                                                                          Druckbild ist leider nicht akzeptabel. Die kompletten seiten werden grau eingefärbt. Verkäufer antwortet nicht auf Emails. Deshalb absolut nicht empfehlenswert.
#>   doc_label_num
#> 1             0
#> 2             0
#> 3             0
#> 4             0
#> 5             0
#> 6             0
```
