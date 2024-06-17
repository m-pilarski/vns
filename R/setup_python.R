install_pydeps <- function(
  .conda_envname="derp_env", .install_conda=NULL, .create_condaenv=NULL
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
        .install_miniconda <- identical(
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
      reticulate::conda_create(envname=.conda_envname)
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
    envname=.conda_envname, pip=TRUE, packages="germansentiment"
  )
}
