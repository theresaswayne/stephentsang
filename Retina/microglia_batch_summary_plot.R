# microglia_batch_summary_plot.R

# applies filters, calculates mean and sd, and plots shape parameters for a merged dataset

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


# ---- Calculate average values for all objects within the filters ----

results <- df %>% group_by(Label) %>%
  summarise(Count = n(),
            MeanArea = mean(Area),
            sdArea = sd(Area),
            MeanSolidity = mean(Solidity),
            sdSolidity = sd(Solidity),
            MeanAspectRatio = mean(AR),
            sdAspectRatio = sd(AR),
            MeanCircularity = mean(`Circ.`),
            sdCircularity = sd(`Circ.`))


# ---- Write the output table ----

resultFile = paste(sans_ext(basename(selectedFile)), "_summary.csv", sep = "")
write_csv(results,file.path(parentFolder, resultFile))

# ---- Plot ---- 
p_solid <- ggplot(df,
                 aes(x=substring(Label,1,4),
                     y=Solidity)) + 
  geom_boxplot() + xlab("Sample")
ggsave(file.path(parentFolder, "solidity.pdf"))


p_circ <- ggplot(df,
                  aes(x=substring(Label,1,4),
                      y=`Circ.`)) + 
  geom_boxplot() + 
  xlab("Sample") +
  ylab("Circularity")

ggsave(file.path(parentFolder, "circularity.pdf"))

p_AR <- ggplot(df,
                 aes(x=substring(Label,1,4),
                     y=AR)) + 
  geom_boxplot() + 
  xlab("Sample") +
  ylab("Aspect Ratio")

ggsave(file.path(parentFolder, "aspectratio.pdf"))


p_AR_ylim <- ggplot(df,
               aes(x=substring(Label,1,4),
                   y=AR)) + 
  geom_boxplot() + 
  xlab("Sample") +
  ylab("Aspect Ratio (y axis cropped to 4)") +
  ylim(1,4)

ggsave(file.path(parentFolder, "aspectratio_ylimited.pdf"))







