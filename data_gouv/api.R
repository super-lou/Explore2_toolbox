
library(dplyr)

dotenv::load_dot_env()

path = "/home/louis/Documents/bouleau/INRAE/project/Explore2_project/Explore2_toolbox/figures/incertitude"

Sys.setenv("DATAVERSE_KEY" = Sys.getenv("API_TOKEN"))
Sys.setenv("DATAVERSE_SERVER" = Sys.getenv("BASE_URL"))



metadata_blocks <- dataverse::get_metadata_blocks()
print(metadata_blocks)

dataverse::create_dataset("Explore2", )


