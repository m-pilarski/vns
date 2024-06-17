#' FUNCTION_TITLE
#'
#' FUNCTION_DESCRIPTION
#'
#' @return RETURN_DESCRIPTION
#' @format A data frame with 210000 rows and 4 variables:
#' \describe{
#'   \item{\code{doc_id}}{character. DESCRIPTION.}
#'   \item{\code{doc_title}}{character. DESCRIPTION.}
#'   \item{\code{doc_text}}{character. DESCRIPTION.}
#'   \item{\code{doc_label_num}}{integer. DESCRIPTION.}
#' }
#' @examples
#' # ADD_EXAMPLES_HERE
load_amazon_review_tbl <- function(){
  fst::read_fst(
    path=fs::path_package(package="derp", "extdata/amazon_review_tbl.fst")
  )
}
