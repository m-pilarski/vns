
#' FUNCTION_TITLE
#'
#' FUNCTION_DESCRIPTION
#'
#' @param .conda_envname DESCRIPTION.
#' @param .install_conda DESCRIPTION.
#' @param .create_condaenv DESCRIPTION.
#'
#' @return RETURN_DESCRIPTION
#' @examples
#' # ADD_EXAMPLES_HERE
#' @export
setup_vns_condaenv <- function(
  .conda_envname="vns_condaenv", .install_conda=NULL, .create_condaenv=NULL
){
  checkmate::assert(
    checkmate::check_character(
      .conda_envname, len=1, null.ok=FALSE, any.missing=FALSE
    ),
    checkmate::check_logical(
      .install_conda, len=1, null.ok=TRUE, any.missing=FALSE
    ),
    checkmate::check_logical(
      .create_condaenv, len=1, null.ok=TRUE, any.missing=FALSE
    )
  )
  if(is(try(reticulate::conda_version()), "try-error")){
    if(is.null(.install_conda)){
      if(interactive()){
        .install_miniconda <- identical(
          menu(
            title=crayon::italic("No conda installation found"),
            choices=c("run reticulate::install_miniconda()", "abort")
          ),
          1L
        )
      }else{
        .install_miniconda <- FALSE
      }
    }
    if(.install_miniconda){
      reticulate::install_miniconda()
    }else{
      rlang::abort(c(
        "Missing a conda installation.",
        i="Please rerun with .install_conda=TRUE or install conda manually"
      ))
    }
  }
  if(!.conda_envname %in% reticulate::conda_list()$name){
    if(is.null(.create_condaenv)){
      if(interactive()){
        .create_condaenv <- identical(
          menu(
            title=crayon::italic("The conda environment does not exist"),
            choices=c("run reticulate::conda_create(.conda_envname)", "abort")
          ),
          1L
        )
      }else{
        .create_condaenv <- FALSE
      }
    }
    if(.create_condaenv){
      reticulate::conda_create(envname=.conda_envname, python_version=NULL)
    }else{
      rlang::abort(c(
        "Missing the specified conda environment.",
        i=stringi::stri_c(
          "Please rerun with .create_condaenv=TRUE or create the conda ",
          "environment manually"
        )
      ))
    }
  }
  reticulate::conda_install(
    envname=.conda_envname, pip=TRUE, packages=c("germansentiment", "spacy")
  )
}


#' FUNCTION_TITLE
#'
#' FUNCTION_DESCRIPTION
#'
#' @param .conda_envname DESCRIPTION.
#'
#' @return RETURN_DESCRIPTION
#' @examples
#' # ADD_EXAMPLES_HERE
#' @export
use_vns_condaenv <- function(.conda_envname="vns_condaenv"){
  checkmate::assert_character(
    .conda_envname, len=1, any.missing=FALSE, null.ok=FALSE
  )
  reticulate::use_condaenv(condaenv=.conda_envname)
}
