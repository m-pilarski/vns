#' FUNCTION_TITLE
#'
#' FUNCTION_DESCRIPTION
#'
#' @param .doc_vec DESCRIPTION.
#' @param .sentidict_tbl DESCRIPTION.
#' @param .brkiter_locale DESCRIPTION.
#' @param .by_sentence DESCRIPTION.
#'
#' @return RETURN_DESCRIPTION
#' @examples
#' # ADD_EXAMPLES_HERE
#' @export
calc_doc_tok_sentidict_tbl <- function(
  .doc_vec, .sentidict_tbl, .brkiter_locale="de_DE", .by_sentence=FALSE
){
  checkmate::assert(
    checkmate::check_character(
      .doc_vec, null.ok=FALSE, all.missing=TRUE
    ),
    checkmate::check_logical(
      .by_sentence, len=1, any.missing=FALSE, null.ok=FALSE
    )
  )
  .doc_vec |>
    tibble::as_tibble_col("doc_text_str") |>
    tibble::rowid_to_column(var="doc_id") |>
    (\(..tbl){
      if(.by_sentence){
        ..tbl <-
          ..tbl |>
          dplyr::mutate(
            doc_sen_str_lst = stringi::stri_split_boundaries(
              doc_text_str, type="sentence", locale=.brkiter_locale
            ),
            .keep="unused"
          ) |>
          tidyr::unnest_longer(
            doc_sen_str_lst, values_to="sen_str_raw", indices_to="sen_id"
          )
      }else{
        ..tbl <- ..tbl |> dplyr::mutate(
          sen_str_raw = doc_text_str, sen_id = NA_integer_, .keep="unused"
        )
      }
      return(..tbl)
    })() |>
    dplyr::mutate(
      doc_tok_str_lst = stringi::stri_split_boundaries(
        sen_str_raw, type="word", locale=.brkiter_locale
      ),
      .keep="unused"
    ) |>
    tidyr::unnest_longer(
      doc_tok_str_lst, values_to="tok_str_raw", indices_to="tok_id"
    ) |>
    dplyr::mutate(tok_str_prep = stringi::stri_trans_tolower(tok_str_raw)) |>
    dplyr::left_join(
      .sentidict_tbl, by=dplyr::join_by(tok_str_prep == tok_str),
      relationship="many-to-one", multiple="any"
    ) |>
    dplyr::mutate(
      tok_pol_lab = tidyr::replace_na(
        tok_pol_lab, factor("sen-neu", levels=levels(tok_pol_lab))
      ),
      tok_pol_num = tidyr::replace_na(tok_pol_num, 0)
    )
}
