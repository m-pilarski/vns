#' FUNCTION_TITLE
#'
#' FUNCTION_DESCRIPTION
#'
#' @param .model_name Name des vortrainierten Modells auf dem Hugging Face Hub.
#' @param .clean_text Textbereinigung vor der Klassifikation erzwingen oder
#'   abschalten. `NULL` waehlt sie automatisch: nur fuer
#'   `"oliverguhr/german-sentiment-bert"`, dessen Trainingsdaten so
#'   vorverarbeitet wurden. Andere Modelle erwarten den Rohtext.
#'
#' @return RETURN_DESCRIPTION
#' @examples
#' # ADD_EXAMPLES_HERE
#' @export
load_germansentiment_model <- function(
  .model_name="oliverguhr/german-sentiment-bert", .clean_text=NULL
){
  checkmate::assert_character(
    .model_name, len=1, any.missing=FALSE, null.ok=FALSE
  )
  checkmate::assert_logical(
    .clean_text, len=1, any.missing=FALSE, null.ok=TRUE
  )
  .lib_os <- reticulate::import("os")
  .lib_os$environ["TOKENIZERS_PARALLELISM"] <- "false"
  # Eigenes Modul statt der Bibliothek germansentiment: deren
  # predict_sentiment() nutzt tokenizer.batch_encode_plus(), das in
  # transformers 5 entfernt wurde. Die Ergebnisse sind identisch.
  .lib_vns_sentiment <- reticulate::import_from_path(
    "vns_sentiment", path=system.file("python", package="vns")
  )
  .germansentiment_model <- .lib_vns_sentiment$SentimentModel(
    model_name=.model_name, clean_text=.clean_text
  )
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
      "vns_sentiment.SentimentModel"
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
