
#' FUNCTION_TITLE
#'
#' FUNCTION_DESCRIPTION
#'
#' @param .model_name DESCRIPTION.
#'
#' @return RETURN_DESCRIPTION
#' @examples
#' # ADD_EXAMPLES_HERE
#' @export
load_spacy_model <- function(.model_name){
  .pylib_spacy <- reticulate::import("spacy", delay_load=TRUE)
  .spacy_model <- .pylib_spacy$load(
    name="de_core_news_lg",
    # disable=list(
    #   "tok2vec",
    #   "tagger",
    #   "parser",
    #   "ner",
    #   "attribute_ruler",
    #   "lemmatizer"
    # )
  )
  # system2(reticulate::py_exe(), args=c("-m", "spacy", "download", .model_name))
}


#' FUNCTION_TITLE
#'
#' FUNCTION_DESCRIPTION
#'
#' @param .doc_str DESCRIPTION.
#' @param .spacy_model DESCRIPTION.
#' @param .n_process DESCRIPTION.
#' @param .batch_size DESCRIPTION.
#'
#' @return RETURN_DESCRIPTION
#' @examples
#' # ADD_EXAMPLES_HERE
#' @export
parse_doc_spacy <- function(
  .doc_str, .spacy_model=load_spacy_model("de_core_news_lg"),
  .n_process=1L, .batch_size=50L
){

  .pylib_spacy <- reticulate::import("spacy", delay_load=TRUE)
  .pyfuns <- reticulate::import_builtins()

  .doc_parse_tbl <-
    .doc_str |>
    .spacy_model$pipe(n_process=.n_process, batch_size=.batch_size) |>
    .pyfuns$enumerate() |>
    reticulate::iterate(\(.enum_doc){
      reticulate::iterate(.enum_doc[[2]], \(..tok){
        .pyfuns$dict(
          doc_id = .enum_doc[[1]],
          tok_str = ..tok$text,
          tok_pos = ..tok$pos_,
          tok_tag = ..tok$tag_,
          tok_sen_start = ..tok$is_sent_start
        )
      })
    }) |>
    dplyr::bind_rows() |>
    dplyr::mutate(
      sen_id = cumsum(tok_sen_start),
      .by=doc_id, .after=doc_id, .keep="unused"
    )

  return(.doc_parse_tbl)

}
