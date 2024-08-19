#' FUNCTION_TITLE
#'
#' FUNCTION_DESCRIPTION
#'
#' @param .doc_str DESCRIPTION.
#' @param .by_sentence DESCRIPTION.
#' @param .brkiter_locale DESCRIPTION.
#' @return RETURN_DESCRIPTION
#' @examples
#' # ADD_EXAMPLES_HERE
#' @export
parse_doc_simple <- function(
  .doc_str, .by_sentence=TRUE, .brkiter_locale="de_DE"
){

  checkmate::assert(
    checkmate::check_character(.doc_str, null.ok=FALSE),
    checkmate::check_logical(.doc_str, len=1, any.missing=FALSE),
    checkmate::check_character(.brkiter_locale, len=1, any.missing=FALSE)
  )

  .doc_parse_tbl <-
    .doc_str |>
    tibble::as_tibble_col("doc_str") |>
    tibble::rowid_to_column(var="doc_id") |>
    (\(..tbl){
      if(.by_sentence){
        ..tbl <-
          ..tbl |>
          dplyr::mutate(
            doc_sen_str_lst = stringi::stri_split_boundaries(
              doc_str, type="sentence", locale=.brkiter_locale
            ),
            .keep="unused"
          ) |>
          tidyr::unnest_longer(
            doc_sen_str_lst, values_to="sen_str", indices_to="sen_id"
          )
      }else{
        ..tbl <- ..tbl |> dplyr::mutate(
          sen_str = doc_str, sen_id = NA_integer_, .keep="unused"
        )
      }
      return(..tbl)
    })() |>
    dplyr::mutate(
      sen_tok_str_lst = stringi::stri_split_boundaries(
        sen_str, type="word", locale=.brkiter_locale
      ),
      .keep="unused"
    ) |>
    tidyr::unnest_longer(
      sen_tok_str_lst, values_to="tok_str", indices_to="tok_id"
    )

  return(.doc_parse_tbl)

}

