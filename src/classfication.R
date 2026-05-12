# ==============================================================================
# Title:        LULC Classification & Cross-Validation (See5.0)
# Project:      Grand River Grasslands (GRG) Restoration Study
# Author:       Lasya Venigalla
# Date:         Originally documented 2018
# Environment:  R Statistical Computing (C50, sf, foreign)
# ==============================================================================

# --- 1. ENVIRONMENT & LIBRARY SETUP ---
# Set memory limit for large geospatial datasets
memory.limit(size = 2010241024 * 1024)

# Load required packages
library("C50")      # Decision Tree algorithm
library("sf")       # For reading File Geodatabases (.gdb)
library("foreign")  # For .dbf export
library("plyr")     # Data manipulation
library("devtools")

# --- 2. SEGMENT-BASED CLASSIFICATION & CROSS-VALIDATION ---

# Set workspace for Segment data
setwd("L:\\Project\\SegClassifyData")

# Import Segment Training Data from GDB
dbftrain <- sf::st_read(dsn = "SegClassifyData.gdb", layer = "trainStat_08")

# Pre-processing: Convert Variety of Aspect to Factor
dbftrain[,'VARIETY_Aspect'] <- factor(dbftrain[,'VARIETY_Aspect'])

# Randomize Data and Set Seed for Reproducibility
set.seed(2411)
g <- runif(nrow(dbftrain))
dbftrainr <- dbftrain[order(g),]

# Define Training Subsets (Columns 1-109: Features | Column 110: Target)
trainX <- dbftrainr[1:1241, 1:109]
trainy <- dbftrainr[1:1241, 110]

# --- 3. K-FOLD CROSS VALIDATION (10-FOLD) ---
folds <- split(dbftrainr, cut(sample(1:nrow(dbftrainr)), 10))
errs.c50 <- rep(NA, length(folds))

# Formula for all multispectral, topographic, and solar attributes
form <- "Name ~ MIN_leafoff_b1 + MAX_leafoff_b1 + RANGE_leafoff_b1 + MEAN_leafoff_b1 + STD_leafoff_b1 + 
         SUM_leafoff_b1 + VARIETY_leafoff_b1 + MAJORITY_leafoff_b1 + MINORITY_leafoff_b1 + 
         MEDIAN_leafoff_b1 + MIN_leafoff_b2 + MAX_leafoff_b2 + RANGE_leafoff_b2 + MEAN_leafoff_b2 + 
         STD_leafoff_b2 + SUM_leafoff_b2 + VARIETY_leafoff_b2 + MAJORITY_leafoff_b2 + 
         MINORITY_leafoff_b2 + MEDIAN_leafoff_b2 + MIN_Solrad + MAX_Solrad + MEAN_Slope + VARIETY_Aspect"

for (i in 1:length(folds)) {
  test <- ldply(folds[i], data.frame)
  train <- ldply(folds[-i], data.frame)
  
  # Train model with 30 boosting trials
  tmp.model <- C5.0(as.formula(form), train, trials = 30)
  tmp.predict <- predict(tmp.model, newdata=test)
  
  # Calculate Accuracy
  conf.mat <- table(test$Name, tmp.predict)
  errs.c50[i] <- 1 - sum(diag(conf.mat))/sum(conf.mat)
}

print(sprintf("Average Error (k-fold): %.3f percent", 100*mean(errs.c50)))

# --- 4. PIXEL-BASED CLASSIFICATION BASELINE ---

# Set workspace for Pixel data
setwd("L:\\Project\\PixClassifyData")

# Import Pixel Training Data
dbf_pix_train <- sf::st_read(dsn = "PixClassifyData.gdb", layer = "trainStat1243")

# Randomize Pixel Data
set.seed(2411)
g_pix <- runif(nrow(dbf_pix_train))
dbftrainr_pix <- dbf_pix_train[order(g_pix),]

# Train Columns (Spectral Bands 1-12)
trainX_pix <- dbftrainr_pix[1:1243, 2:14]
trainy_pix <- dbftrainr_pix[1:1243, 1]

# Define Pixel-based Classifier
model_pix <- C50::C5.0(trainX_pix, trainy_pix, trials = 30)

# --- 5. FINAL CLASSIFICATION & EXPORT ---

# Import Segment Testing Data (812,965 segments)
dbftest_seg <- sf::st_read(dsn = "SegClassifyData.gdb", layer = "testStat")
dbftest_seg[,'VARIETY_Aspect'] <- factor(dbftest_seg[,'VARIETY_Aspect'])

testx_seg <- dbftest_seg[1:812965, 1:109]

# Predict Class for all Segments
final_model <- C50::C5.0(trainX, trainy, trials = 30)
predictions <- predict(final_model, testx_seg, type="class")

# Merge predictions and export to DBF for ArcGIS joining
final_output <- cbind(testx_seg, predictions)
write.dbf(final_output, "L:\\Project\\Results\\ImageSegmentation\\ClassifySeg_Final.dbf")

print("Classification Workflow Complete.")
