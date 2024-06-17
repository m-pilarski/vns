`%||%` <- rlang::`%||%`
`%0%` <- vctrs::`%0%`

xml2::read_xml(
  here::here(
    "data_raw/input/omq_public_email_data/omq_public_categories.xml"
  )
)

support_email_tbl <- 
  xml2::read_xml(
    here::here(
      "data_raw/input/omq_public_email_data/omq_public_interactions.xml"
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
        tibble::as_tibble_row(
          c(chunk_str=as.character(..x[[1]]), chunk_cat=attr(..x, "goldCategory"))
        )
      }) |> 
      dplyr::filter(
        stringi::stri_detect_charclass(chunk_str, "[^[:cntrl:]]")
      ) |> 
      tibble::rowid_to_column("chunk_id")
    dplyr::bind_cols(.meta_tbl, .chunk_tbl)
  })
  
support_email_tbl |> xml2::as_list() |> purrr::pluck(2)
  

  purrr::map_dfr(function(.path){
    .path |> 
      file() |> 
      jsonlite::stream_in() |> 
      dplyr::mutate(
        doc_id = id, doc_title_text = text, doc_label_num = as.integer(label),
        .keep="none"
      ) |> 
      tidyr::separate_wider_delim(
        doc_title_text, names=c("doc_title", "doc_text"), delim="\n\n", 
        too_many="merge"
      ) |> 
      tibble::as_tibble()
  })
  
fst::write_fst(amazon_review_tbl, here::here("data/amazon_review_tbl.fst"))
