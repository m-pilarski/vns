#' Extract text from HTML strings with Readability
#'
#' Reads one or more HTML strings and extracts the main text using the bundled
#' Mozilla Readability library running inside the V8 JavaScript engine.
#'
#' @param .html Character vector of HTML strings.
#' @return Character vector with extracted text, one entry per input string.
#' @examples
#' # extract_text_html("<html><body>Hello</body></html>")
#' @export
extract_text_html <- function(.html){
  checkmate::assert_character(.html, min.len=1, any.missing=FALSE, null.ok=FALSE)

  .readability_dir <- fs::path_package("readability", package="vns")
  
  .read_js <- function(.filename){
    .path <- fs::path(.readability_dir, .filename)
    stringi::stri_c(readr::read_lines(.path), collapse="\n")
  }

  .ctx <- V8::v8()
  # Provide a minimal URL implementation if the engine lacks it; sufficient for
  # Readability's href resolution.
  # .ctx$eval(
  #   "if (typeof URL === 'undefined') { class URL { constructor(href, base){ this.href = base ? base + href : href; } } }"
  # )
  .ctx$eval(.read_js("JSDOMParser.js"))
  .ctx$eval(.read_js("Readability.js"))
  .ctx$eval(
    stringi::stri_c(
      "function parseWithReadability(html){",
      "  const parser = new JSDOMParser();",
      "  const doc = parser.parse(html, 'about:blank');",
      "  const article = new Readability(doc).parse();",
      "  return (article && article.textContent) ? article.textContent : '';",
      "}",
      sep="\n"
    )
  )

  .text <- purrr::map_chr(.html, function(.h){
    tryCatch(
      .ctx$call("parseWithReadability", .h),
      error=\(..e){
        rlang::abort(c(
          "Readability failed on input.",
          i=..e$message
        ))
      }
    )
  })

  return(.text)
}
