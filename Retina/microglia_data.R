# microglia_data.R

# applies filters, calculates count and shape parameters for a single dataset
# plots AR vs solidity

# ---- Setup ----

require(tidyverse) # for data processing
require(stringr) # for string harvesting
require(ggplot2) # for plotting
require(xfun) # for filename manipulation


# ---- Get the data ----

selectedFile <- file.choose() # no message will be displayed. Choose the file to analyze
parentFolder <- dirname(selectedFile) # parent of the selected file
dfOrig <- read_csv(selectedFile)

# ---- Filter the data ----

# Apply additional filters as needed

maxArea = 600 # in microns2
df <- dfOrig %>% filter(Area <= maxArea)

# ---- Create an output table ----

# it's just one row actually

fileName <- df$Label[1]
results <- data.frame("Filename" = fileName)

# ---- Calculate average values for all objects within the filters ----

results$Count <- nrow(df)
results$MeanArea <- mean(df$Area)
results$sdArea <- sd(df$Area)
results$MeanSolidity <- mean(df$Solidity)
results$sdSolidity <- sd(df$Solidity)
results$MeanAspectRatio <- mean(df$AR)
results$sdAspectRatio <- sd(df$AR)
results$MeanCircularity <- mean(df$`Circ.`)
results$sdCircularity <- sd(df$`Circ.`)

# ---- Write the output table ----

resultFile = paste(sans_ext(basename(selectedFile)), "_summary.csv", sep = "")
write_csv(results,file.path(parentFolder, resultFile))

