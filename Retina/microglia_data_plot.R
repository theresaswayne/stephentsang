# microglia_data_plot.R

# applies filters, plots shape parameters for a single dataset
# e.g. AR vs solidity

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

# ---- plot solidity vs AR ----

AR_Sol <- ggplot(df, aes(x=Solidity, y=AR)) + 
  geom_point(alpha = 0.15)
AR_Sol

# ---- plot circ vs AR ----

AR_Circ <- ggplot(df, aes(x=`Circ.`, y=AR)) + 
  geom_point(alpha = 0.15)
AR_Circ

# ---- plot solidity vs circ ----

Sol_Circ <- ggplot(df, aes(x=`Circ.`, y=Solidity)) + 
  geom_point(alpha = 0.15)
Sol_Circ


# Change the point size, and shape
#ggplot(mtcars, aes(x=wt, y=mpg)) +
#  geom_point(size=2, shape=23)

