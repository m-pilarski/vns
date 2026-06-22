.extract_readability <- function(.html, .field) {
  checkmate::assert_character(.html, min.len = 1, any.missing = FALSE, null.ok = FALSE)

  .ctx <- V8::v8()
  .ctx$eval(
    readr::read_file(
      fs::path_package("readability", "JSDOMParser.js", package = "vns")
    )
  )
  .ctx$eval(
    readr::read_file(
      fs::path_package("readability", "Readability.js", package = "vns")
    )
  )
  .ctx$eval("console.log = function() {};")
  .ctx$eval(
    stringi::stri_c(
      "function extractReadability(html, field){",
      "  const parser = new JSDOMParser();",
      "  const doc = parser.parse(html, 'about:blank');",
      "  const article = new Readability(doc).parse();",
      "  return article && typeof article[field] === 'string' ? article[field] : '';",
      "}",
      sep = "\n"
    )
  )

  purrr::map_chr(.html, function(..html) {
    tryCatch(
      .ctx$call("extractReadability", ..html, .field),
      error = \(..e) {
        rlang::abort(c(
          "Readability failed on input.",
          i = ..e$message
        ))
      }
    )
  })
}


#' Extract Readability content from HTML strings
#'
#' Passes each HTML string directly to Mozilla Readability and returns the
#' extracted article HTML.
#'
#' @param .html Character vector of HTML strings.
#' @return Character vector with extracted article HTML, one entry per input
#'   string.
#' @examples
#' # extract_content_html("<html><body><article>Hello</article></body></html>")
#' @export
extract_content_html <- function(.html) {
  .extract_readability(.html, "content")
}
