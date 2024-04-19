#' Generate a table of prompts
#' 
#' HPO phenotype annotations - code to generate prompts for input into chat GPT. 
#' @param effects Clinical characteristics to generate annotations for.
#' @param table_columns Define the columns of the output table.
#' @param batch_size The number of phenotypes per prompt.
#' @param hpo Get all phenotypes from the HPO.
#' @export 
prompt_gen_table <- function(effects = c("intellectual disability",
                                          "death",
                                          "impaired mobility",
                                          "physical malformations",
                                          "blindness",
                                          "sensory impairments",
                                          "immunodeficiency",
                                          "cancer",
                                          "reduced fertility"),
                              table_columns = c("phenotype",
                                                gsub(" ","_",effects), 
                                                "congenital_onset"),
                              responses=c("never", "rarely", "often", "always"),
                              hpo = HPOExplorer::get_hpo(),
                              batch_size = 2){ 
  library(HPOExplorer)
  library(data.table)
  # get phenotype names
  phenos <- data.frame(phenotype = hpo@elementMetadata[["name"]])
  n_terms <- nrow(phenos)
  batches <- split(seq_len(n_terms), 
                   ceiling(seq_along(seq_len(n_terms))/batch_size)) 
  # function to generate prompts
  prompt_gen <- function(x){ 
    terms <- paste(x,collapse="; ") 
    question <- paste("I need to annotate phenotypes as to whether they typically cause:", 
                      paste0(paste(effects, collapse = ", "),"?"), 
                      "Do they have congenital onset?",
                      "To answer, use a severity scale of:",paste0(paste(responses,collapse = ", "),"."),
                      "Do not consider indirect effects.",
                      "You must provide the output in python code as a data frame called df with columns:",
                      paste0(paste(table_columns, collapse = ", "),"."), 
                      "Also add a separate justification column for each outcome, e.g. death, death_justification.",
                      "These are the phenotypes:", 
                      paste(terms,".", sep=""), 
                      "Placeholders are not acceptable.")
    question <- gsub("\n", "", question)
    return(question)
  } 
  # get data frame of prompts
  prompts <- lapply(seq_len(length(batches)), function(i){
    batch_idx <- batches[[i]]
    data.table(
      batch=i,
      batch_idx=list(batch_idx),
      terms=list(phenos[batch_idx,]),
      prompt=gsub("\n", "",prompt_gen(x = phenos[batch_idx,]))
    )
  }) |>rbindlist() 
  return(prompts)
}
