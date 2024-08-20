#' FUNCTION_TITLE
#'
#' FUNCTION_DESCRIPTION
#'
#' @return RETURN_DESCRIPTION
#' @examples
#' # ADD_EXAMPLES_HERE
#' @export
load_germansentiment_model <- function(){
  reticulate::import("os")$environ["TOKENIZERS_PARALLELISM"] <- FALSE
  .lib_germansentiment <- reticulate::import("germansentiment", delay_load=TRUE)
  .germansentiment_model <- .lib_germansentiment$SentimentModel()
  return(.germansentiment_model)
}

#' FUNCTION_TITLE
#'
#' FUNCTION_DESCRIPTION
#'
#' @param .doc_str DESCRIPTION.
#' @param .germansentiment_model DESCRIPTION.
#'
#' @return RETURN_DESCRIPTION
#' @examples
#' # ADD_EXAMPLES_HERE
#' @export
calc_doc_germansentiment_tbl <- function(
  .doc_str, .germansentiment_model=load_germansentiment_model()
){
  checkmate::assert_character(.doc_str, len=1, any.missing=FALSE)
  .germansentiment_model |>
    reticulate::import_builtins(delay_load=TRUE)$type() |>
    stringi::stri_detect_fixed(
      "germansentiment.sentimentmodel.SentimentModel"
    ) |>
    stopifnot()
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
