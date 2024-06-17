amazon_review_tbl <-
  fs::dir_ls(
    path=here::here("data-raw/input/mteb-amazon_reviews_multi/de/"),
    glob="*/*.jsonl"
  ) |>
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

fst::write_fst(
  x=amazon_review_tbl, path=here::here("inst/extdata/amazon_review_tbl.fst")
)
