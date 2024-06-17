library(dplyr)
library(reticulate)

`%<-%` <- zeallot::`%<-%`
`%||%` <- rlang::`%||%`

# amazon_review_tbl <- fst::read_fst(here::here("data/amazon_review_tbl.fst"))


load_germansentiment_model <- function(){
  .lib_germansentiment <- reticulate::import("germansentiment")
  .germansentiment_model <- .lib_germansentiment$SentimentModel()
  return(.germansentiment_model)
}


# lib_builtin <- reticulate::import_builtins()

calc_sentiment <- function(
  .doc_str, .germansentiment_model=load_germansentiment_model()
){
  checkmate::assert_character(.doc_str, len=1, any.missing=FALSE)
  .doc_str |>
    as.list() |>
    .germansentiment_model$predict_sentiment(output_probabilities=TRUE) |>
    purrr::transpose() |>
    purrr::map(\(..doc_pred){
      ..doc_pred |>
        purrr::chuck(2) |>
        (\(...doc_pred_prob){
          ...doc_pred_prob |>
            purrr::chuck(
              which.max(purrr::map_dbl(...doc_pred_prob, 2))
            ) |>
            rlang::set_names(c("doc_class_lab", "doc_class_prob"))
        })()
    }) |>
    dplyr::bind_rows()
}

# checkmate::assert_character()

# calc_sentiment_memo <- memoise::memoize(calc_sentiment)

# calc_doc_sentiment_tbl <- function(.doc_vec, ..., .cache_dir=NULL){
#   purrr::map_dfr(.doc_vec, \(..doc){
#     c(doc_str=..doc, calc_sentiment_memo(..doc))
#   })
# }
