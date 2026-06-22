.readability_void_elements <- c(
  "area", "base", "br", "col", "command", "embed", "hr", "img", "input",
  "link", "meta", "param", "source", "wbr"
)


.escape_readability_attribute <- function(.value) {
  stringi::stri_replace_all_fixed(
    .value,
    c("&", "\"", "<", ">"),
    c("&amp;", "&quot;", "&lt;", "&gt;"),
    vectorize_all = FALSE
  )
}


.serialize_readability_node <- function(.node) {
  .type <- xml2::xml_type(.node)
  if (.type != "element") {
    return(as.character(.node))
  }

  .name <- xml2::xml_name(.node)
  .attributes <- xml2::xml_attrs(.node)
  .attribute_text <- if (length(.attributes) > 0) {
    stringi::stri_c(
      " ",
      names(.attributes),
      "=\"",
      .escape_readability_attribute(unname(.attributes)),
      "\"",
      collapse = ""
    )
  } else {
    ""
  }

  if (.name %in% .readability_void_elements) {
    return(stringi::stri_c("<", .name, .attribute_text, "/>"))
  }

  .content <- purrr::map_chr(
    xml2::xml_contents(.node),
    .serialize_readability_node
  )
  stringi::stri_c(
    "<",
    .name,
    .attribute_text,
    ">",
    stringi::stri_c(.content, collapse = ""),
    "</",
    .name,
    ">"
  )
}


.normalize_readability_html <- function(.html) {
  .document <- xml2::read_html(.html)
  .serialize_readability_node(xml2::xml_root(.document))
}


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
      .ctx$call(
        "extractReadability",
        .normalize_readability_html(..html),
        .field
      ),
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
#' Normalizes HTML syntax without filtering content, passes the complete
#' document to Mozilla Readability, and returns the extracted article HTML.
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
