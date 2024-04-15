## Harnessing AI to annotate the severity of all phenotypic abnormalities within the Human phenotype Ontology

The [Human phenotype Ontology (HPO)](https://hpo.jax.org/app/) has played a crucial role in defining, diagnosing, prognosing, and treating human diseases by providing a standardised database for phenotypic abnormalities. However, there is currently no information pertaining to the severity of each phenotype, making systematic analyses and prioritisation of results difficult. With 18,082 abnormalities now corresponding to over 10,000 rare diseases, manual curation of such phenotypic annotations by experts would be labor-intensive and time-consuming. Leveraging advances in artificial intelligence, we employed the OpenAI GPT-4 model with Python to systematically annotate the severity of ~ 17,000 phenotypic abnormalities in the HPO.  We also developed a severity scoring system that incorporates both the nature of the phenotype outcome and the frequency of its occurrence. These severity metrics will enable efforts to systematically prioritise which human phenotypes are most detrimental to human well being, and best targets for therapeutic intervention. 