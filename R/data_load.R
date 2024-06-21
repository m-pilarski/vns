#' FUNCTION_TITLE
#'
#' FUNCTION_DESCRIPTION
#'
#' @format A tibble with 210000 rows and 4 columns:
#' \describe{
#'   \item{\code{doc_id}}{character. DESCRIPTION.}
#'   \item{\code{doc_title}}{character. DESCRIPTION.}
#'   \item{\code{doc_text}}{character. DESCRIPTION.}
#'   \item{\code{doc_label_num}}{integer. DESCRIPTION.}
#' }
#' @return RETURN_DESCRIPTION
#' @examples
#' amazon_review_tbl <- load_amazon_review_tbl()
#' @export
load_amazon_review_tbl <- function(){
  tibble::as_tibble(fst::read_fst(
    path=fs::path_package(package="vns", "extdata/amazon_review_tbl.fst")
  ))
}

#' FUNCTION_TITLE
#'
#' FUNCTION_DESCRIPTION
#'
#' @return RETURN_DESCRIPTION
#' @format A tibble with 1700 rows and 8 columns:
#' \describe{
#'   \item{\code{businessScenario}}{character. DESCRIPTION.}
#'   \item{\code{id}}{character. DESCRIPTION.}
#'   \item{\code{date}}{character. DESCRIPTION.}
#'   \item{\code{category}}{character. DESCRIPTION.}
#'   \item{\code{keyword}}{character. DESCRIPTION.}
#'   \item{\code{chunk_id}}{integer. DESCRIPTION.}
#'   \item{\code{chunk_str}}{character. DESCRIPTION.}
#'   \item{\code{chunk_cat}}{character. DESCRIPTION.}
#' }
#' @examples
#' # support_email_tbl <- load_support_email_tbl()
#' @export
load_support_email_tbl <- function(){
  tibble::as_tibble(fst::read_fst(
    path=fs::path_package(package="vns", "extdata/support_email_tbl.fst")
  ))
}
