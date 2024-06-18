support_email_tbl <-
  xml2::read_xml(
    here::here(
      "data-raw/input/omq_public_email_data/omq_public_interactions.xml"
    )
  ) |>
  xml2::xml_find_all("//interactions/interaction") |>
  xml2::as_list() |>
  purrr::map_dfr(\(.node){
    .meta_tbl <-
      .node |>
      purrr::pluck("metadata") |>
      (\(..x){..x[lengths(..x) > 0]})() |>
      purrr::map(unlist) |>
      tibble::as_tibble_row()
    .chunk_tbl <-
      .node |>
      purrr::pluck("text") |>
      purrr::map_dfr(\(..x){
        tibble::tibble(
          chunk_str=as.character(..x[[1]]), chunk_cat=attr(..x, "goldCategory")
        )
      }) |>
      dplyr::filter(
        stringi::stri_detect_charclass(chunk_str, "[^[:cntrl:]]")
      ) |>
      tibble::rowid_to_column("chunk_id")
    dplyr::bind_cols(.meta_tbl, .chunk_tbl)
  })

fst::write_fst(
  x=support_email_tbl, path=here::here("inst/extdata/support_email_tbl.fst")
)
