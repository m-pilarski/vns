#' Extract relevant text from HTML strings
#'
#' Uses Trafilatura in recall-oriented mode to extract plain text from
#' complete HTML documents.
#'
#' @param .html Character vector of HTML strings.
#' @return Character vector with extracted text, one entry per input string.
#' @examples
#' # extract_text_html("<html><body><main>Hello</main></body></html>")
#' @export
extract_text_html <- function(.html) {
  .extract_trafilatura(.html, "txt")
}
