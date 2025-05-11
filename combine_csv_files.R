# combine_csv_files.R
# merges a batch of csv files, putting the filename in a new column
# Requirement: All files must be within a single folder and the name must contain the pattern in the "finalText" variable
# adapted from http://serialmentor.com/blog/2016/6/13/reading-and-combining-many-tidy-data-files-in-R
# this version also adds a column for the row number (which will represent the timepoint in certain ImageJ results files)

# Setup -------
require(tidyverse)

# text to filter for in the end of the file name
finalText <- ".csv"

# ---- Prompt for a data folder ----
# no message will be displayed. Choose one of the files in the folder
selectedFile <- file.choose()
inputFolder <- dirname(selectedFile) # the input is the parent of the selected file

# Read all the files in the folder ------

outputFolder <- dirname(inputFolder) # parent of the input folder

# get file names
files <- dir(inputFolder, pattern = paste("*",finalText,sep=""))

# tibble is used because of the warning that data_frame is deprecated.
mergedDataWithNames <- tibble(datafile = files) %>% # tibble holding file names
  mutate(file_contents =
           map(datafile,          # read files into a new data column
               ~ read_csv(file.path(inputFolder, .),
                          locale = locale(encoding = "latin1"),
                          na = c("", "N/A"))))

# sort by filename and add a column for the row number (timepoint) 
mergedDataWithNames <- mergedDataWithNames %>% 
  arrange(datafile) %>%
  mutate("File Number" = row_number())

# unnest to make the list into a flat file again,
# but it now has 1 extra column to hold the data file name
mergedDataFlat <- unnest(mergedDataWithNames, cols = c(file_contents))


# Write an output file of all the merged data ----------

outputFile = paste(basename(inputFolder), " merged", finalText, sep = "")
write_csv(mergedDataFlat,file.path(outputFolder, outputFile))

