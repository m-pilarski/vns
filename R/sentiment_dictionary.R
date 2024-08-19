#' FUNCTION_TITLE
#'
#' FUNCTION_DESCRIPTION
#'
#' @param .doc_str DESCRIPTION.
#' @param .sentidict_tbl DESCRIPTION.
#' @param .parse_doc_fn DESCRIPTION.
#'
#' @return RETURN_DESCRIPTION
#' @examples
#' # ADD_EXAMPLES_HERE
#' @export
calc_tok_sentidict_tbl <- function(
  .doc_str, .sentidict_tbl=sentidict_sws_tbl, .parse_doc_fn=parse_doc_simple
){
  checkmate::assert(
    checkmate::check_character(
      .doc_str, null.ok=FALSE, all.missing=TRUE
    ),
    checkmate::check_logical(
      .by_sentence, len=1, any.missing=FALSE, null.ok=FALSE
    )
  )
  .doc_str |>
    .parse_doc_fn() |>
    dplyr::mutate(tok_match_str = stringi::stri_trans_tolower(tok_str)) |>
    dplyr::left_join(
      .sentidict_tbl, by=dplyr::join_by(tok_match_str == tok_str),
      relationship="many-to-one", multiple="any"
    ) |>
    dplyr::mutate(
      tok_pol_lab = forcats::fct_na_value_to_level(
        f=tok_pol_lab, level="sen-miss"
      ),
      tok_pol_num = tidyr::replace_na(tok_pol_num, 0)
    )
}

#' FUNCTION_TITLE
#'
#' FUNCTION_DESCRIPTION
#'
#' @param .doc_str DESCRIPTION.
#' @param .tok_valid_regex DESCRIPTION.
#' @param .parse_doc_fn DESCRIPTION.
#' @param .calc_tok_sentidict_tbl_fn DESCRIPTION.
#'
#' @return RETURN_DESCRIPTION
#' @examples
#' # ADD_EXAMPLES_HERE
#' @export
calc_doc_sentidict_tbl <- function(
  .doc_str, .tok_valid_regex="[[:alnum:]]", .parse_doc_fn=parse_doc_simple,
  .calc_tok_sentidict_tbl_fn=calc_tok_sentidict_tbl
){
  # TODO: argument checks
  # checkmate::assert(
  #   checkmate::check_data_frame(
  #     .tok_sentidict_tbl, col.names=c("tok_str", "")
  #   )
  # )
  .doc_str |>
    .parse_doc_fn() |>
    .calc_tok_sentidict_tbl_fn() |>
    dplyr::filter(
      stringi::stri_detect_regex(str=tok_str, pattern=.tok_valid_regex)
    ) |>
    dplyr::summarize(
      doc_pol_num = mean(tok_pol_num),
      doc_count_word = n(),
      .by=doc_id
    )
}
