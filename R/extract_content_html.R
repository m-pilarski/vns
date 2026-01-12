#' Extract Readability content from HTML strings
#'
#' Reads one or more HTML strings and extracts the Readability-processed HTML
#' (article content) using the bundled Mozilla Readability library running
#' inside the V8 JavaScript engine.
#'
#' @param .html Character vector of HTML strings.
#' @return Character vector with extracted HTML content, one entry per input
#'   string.
#' @examples
#' # extract_content_html("<html><body>Hello</body></html>")
#' @export
extract_content_html <- function(.html) {
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
  .ctx$eval(
    stringi::stri_c(
      "function parseWithReadability(html){",
      "  const parser = new JSDOMParser();",
      "  const doc = parser.parse(html, 'about:blank');",
      "  const article = new Readability(doc).parse();",
      "  return (article && article.content) ? article.content : '';",
      "}",
      sep="\n"
    )
  )

  .content <- purrr::map_chr(.html, function(..html) {
    tryCatch(
      expr = {
        sink(file = nullfile())
        ..content <- .ctx$call("parseWithReadability", ..html)
        sink(file = NULL)
      },
      error = \(..e) {
        rlang::abort(c(
          "Readability failed on input.",
          i = ..e$message
        ))
      }
    )
    return(..content)
  })

  return(.content)
}
