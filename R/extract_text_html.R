#' Extract text from HTML strings with Readability
#'
#' Normalizes HTML syntax without filtering content, passes the complete
#' document to Mozilla Readability, and returns the extracted article text.
#'
#' @param .html Character vector of HTML strings.
#' @return Character vector with extracted article text, one entry per input
#'   string.
#' @examples
#' # extract_text_html("<html><body><article>Hello</article></body></html>")
#' @export
extract_text_html <- function(.html) {
  .extract_readability(.html, "textContent")
}
