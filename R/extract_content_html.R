.import_trafilatura <- function() {
  tryCatch(
    reticulate::import("trafilatura", delay_load = FALSE),
    error = \(..error) {
      rlang::abort(c(
        "The Python package `trafilatura` is required for HTML extraction.",
        i = "Install the vns Python dependencies with `setup_vns_condaenv()`.",
        x = ..error$message
      ))
    }
  )
}


.extract_trafilatura <- function(.html, .output_format) {
  checkmate::assert_character(
    .html,
    min.len = 1,
    any.missing = FALSE,
    null.ok = FALSE
  )

  .trafilatura <- .import_trafilatura()
  purrr::map_chr(.html, function(..html) {
    .content <- tryCatch(
      .trafilatura$extract(
        ..html,
        output_format = .output_format,
        favor_recall = TRUE,
        include_comments = FALSE,
        include_tables = TRUE,
        include_images = FALSE,
        include_links = FALSE,
        deduplicate = FALSE
      ),
      error = \(..error) {
        rlang::abort(c(
          "Trafilatura failed on input.",
          i = ..error$message
        ))
      }
    )

    if (is.null(.content)) "" else .content
  })
}


#' Extract relevant content from HTML strings
#'
#' Uses Trafilatura in recall-oriented mode to extract the main content from
#' complete HTML documents while retaining tables and document structure.
#'
#' @param .html Character vector of HTML strings.
#' @return Character vector with extracted HTML content, one entry per input
#'   string.
#' @examples
#' # extract_content_html("<html><body><main>Hello</main></body></html>")
#' @export
extract_content_html <- function(.html) {
  .extract_trafilatura(.html, "html")
}
