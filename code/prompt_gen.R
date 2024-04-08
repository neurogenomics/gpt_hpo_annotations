## HPO phenotype annotations - code to generate prompts for input into chat GPT ##
library(HPOExplorer)
library(data.table)

# get all phenotypes from the HPO 
all_res <- get_hpo()


# get phenotype names
phenos <- data.frame(phenotype = all_res@elementMetadata[["name"]])

# 2 phenotypes per prompt
batch_size = 2

n_terms <- nrow(phenos)
batches <- split(seq_len(n_terms), 
                 ceiling(seq_along(seq_len(n_terms))/batch_size))


# prep prompt 
effects <- "intellectual disability, death, impaired mobility, 
physical malformations, blindness, sensory impairments, 
immunodeficiency, cancer, reduced fertility?"

# define the columns of the output table 
table_columns <- "phenotype, intellectual_disability, death, impaired_mobility, 
physical_malformations, blindness, sensory_impairments, immunodeficiency, cancer, 
reduced_fertility, congenital_onset."

# function to generate prompts
prompt_gen <- function(x){ 
  
  terms <- paste(
    x,
    collapse="; "
  ) 
  
  question <- paste("I need to annotate phenotypes as to whether they typically cause:", 
                   effects, 
                   "Do they have congenital onset?",
                   "To answer, use a severity scale of: never, rarely, often, always. Do not consider indirect effects.",
                   "You must provide the output in python code as a data frame called df with columns:",
                   table_columns, 
                   "Also add a separate justification column for each outcome, e.g. death, death_justification.",
                   "These are the phenotypes:", 
                   paste(terms,".", sep=""), 
                   "Placeholders are not acceptable.")
  question <- gsub("\n", "", question)
  
  return(question)
}

res <- lapply(seq_len(length(batches)), function(i){
  batch_idx <- batches[[i]]
  question <- prompt_gen(x = phenos[batch_idx,])
})

# get data frame of prompts
res2 <- unlist(res)
prompts <- data.table(prompt = res2)
prompts$prompt <- gsub("\n", "", prompts$prompt)

