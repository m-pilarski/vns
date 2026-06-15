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

  .with_restored_sink <- function(.expr) {
    .sink_count <- sink.number()
    on.exit({
      while (sink.number() > .sink_count) {
        sink(NULL)
      }
    }, add = TRUE)
    force(.expr)
  }

  .readability_input_html <- function(..html) {
    ..doc <- xml2::read_html(..html)
    xml2::xml_remove(xml2::xml_find_all(
      ..doc,
      paste(
        ".//script[not(@type='application/ld+json')]",
        ".//style",
        ".//noscript",
        ".//nav",
        ".//header",
        ".//footer",
        ".//*[contains(concat(' ', normalize-space(@class), ' '), ' teaser ')]",
        ".//*[contains(concat(' ', normalize-space(@class), ' '), ' share ')]",
        sep = "|"
      )
    ))

    .candidates <- xml2::xml_find_all(..doc, ".//article|.//main")
    .node <- if (length(.candidates) > 0) {
      .candidates[[which.max(nchar(xml2::xml_text(.candidates)))]]
    } else {
      xml2::xml_find_first(..doc, ".//body")
    }

    .title <- xml2::xml_text(xml2::xml_find_first(..doc, ".//title"))
    paste0(
      "<!doctype html><html><head><title>",
      htmltools::htmlEscape(.title),
      "</title></head><body>",
      as.character(.node),
      "</body></html>"
    )
  }

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
      "  if (doc && !doc.documentElement) {",
      "    for (const child of doc.childNodes || []) {",
      "      if (child.localName === 'html') {",
      "        doc.documentElement = child;",
      "        break;",
      "      }",
      "    }",
      "    if (!doc.documentElement && doc.firstChild) doc.documentElement = doc.firstChild;",
      "  }",
      "  const article = new Readability(doc, {charThreshold: 250, keepClasses: false}).parse();",
      "  return (article && article.content) ? article.content : '';",
      "}",
      sep="\n"
    )
  )

  .content <- purrr::map_chr(.html, function(..html) {
    tryCatch(
      expr = {
        ..readability_html <- .readability_input_html(..html)
        ..content <- .with_restored_sink({
          sink(file = nullfile())
          .ctx$call("parseWithReadability", ..readability_html)
        })
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
