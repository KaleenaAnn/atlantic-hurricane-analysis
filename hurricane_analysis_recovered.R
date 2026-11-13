# Atlantic hurricane regression analysis: recovered from original R command history
# Author: Kaleena Ann LaBerge
# Source: user's .Rhistory (November 2026)
# This file preserves the main analysis commands, organized for readability.
# It expects an existing prepared data frame called hurdat_1990_2025.
# The raw HURDAT2 parsing and cleaning script has not yet been recovered.
# Requires the prepared RData workspace file locally; do not upload private data.

if (!exists("hurdat_1990_2025")) {
  if (file.exists("hurdat_1990_2025.RData")) {
    load("hurdat_1990_2025.RData")
  } else {
    stop("Prepared data missing: load hurdat_1990_2025.RData first.")
  }
}
stopifnot(is.data.frame(hurdat_1990_2025))
stopifnot(all(c("StormID", "Year", "Wind", "Status") %in% names(hurdat_1990_2025)))

# ============================================
# WEEK 9: STATISTICAL ANALYSIS
# ============================================
# Check year range
range(hurdat_1990_2025$Year)
# Check missing values
sum(is.na(hurdat_1990_2025$Year))
sum(is.na(hurdat_1990_2025$Wind))
# Check for invalid wind values (-999)
sum(hurdat_1990_2025$Wind == -999, na.rm = TRUE)
# Generate descriptive statistics
summary(hurdat_1990_2025$Year)
summary(hurdat_1990_2025$Wind)
# Calculate standard deviation
sd(hurdat_1990_2025$Wind, na.rm = TRUE)
# ============================================
# STEP 5: SCATTERPLOT WITH REGRESSION LINE
# ============================================
# Create scatterplot
plot(hurdat_1990_2025$Year,
     hurdat_1990_2025$Wind,
     main = "Atlantic Tropical Cyclone Wind Speed, 1990–2025",
     xlab = "Year",
     ylab = "Maximum Sustained Wind Speed (knots)",
     pch = 16,
     col = rgb(0, 0, 1, 0.15))
# Fit simple linear regression
wind_model <- lm(Wind ~ Year,
                 data = hurdat_1990_2025)
# Add regression line
abline(wind_model, col = "red", lwd = 2)
summary(wind_model)
# ============================================
# STEP 7: REGRESSION DIAGNOSTICS
# ============================================
# Display four regression diagnostic plots
par(mfrow = c(2, 2))
plot(wind_model)
# Reset plotting window
par(mfrow = c(1, 1))
# ============================================
# STEP 8: STORM-LEVEL ANALYSIS
# ============================================
# Calculate the maximum wind speed for each storm
storm_data <- aggregate(
  Wind ~ StormID + Year,
  data = hurdat_1990_2025,
  FUN = max
)
# Check storm-level dataset
dim(storm_data)
head(storm_data)
# Fit storm-level linear regression
storm_model <- lm(Wind ~ Year, data = storm_data)
# Display regression results
summary(storm_model)
# Run Pearson correlation test
cor.test(storm_data$Year,
         storm_data$Wind,
         method = "pearson")
# ============================================
# STEP 9: STORM-LEVEL REGRESSION PLOT
# ============================================
plot(storm_data$Year,
     storm_data$Wind,
     main = "Maximum Wind Speed per Atlantic Storm, 1990–2025",
     xlab = "Year",
     ylab = "Storm Maximum Sustained Wind Speed (knots)",
     pch = 16,
     col = rgb(0, 0, 1, 0.35))
# Add storm-level regression line
abline(storm_model, col = "red", lwd = 2)
# ============================================
# STEP 10: STORM-LEVEL REGRESSION DIAGNOSTICS
# ============================================
# Display four diagnostic plots
par(mfrow = c(2, 2))
plot(storm_model)
# Reset plotting layout
par(mfrow = c(1, 1))
# ============================================
# STEP 11: SPEARMAN CORRELATION
# ============================================
# Test the monotonic relationship
cor.test(
  storm_data$Year,
  storm_data$Wind,
  method = "spearman",
  exact = FALSE
)
# ============================================
# STEP 12: YEAR-CLUSTERED REGRESSION
# ============================================
# Install packages if necessary
# If needed, run once: install.packages(c("sandwich", "lmtest"))
# Load packages
library(sandwich)
library(lmtest)
# Confirm the number of year clusters
length(unique(storm_data$Year))
# Calculate year-clustered standard errors
cluster_se <- vcovCL(
  storm_model,
  cluster = storm_data$Year,
  type = "HC1"
)
# Perform regression coefficient tests
# using clustered standard errors
coeftest(
  storm_model,
  vcov. = cluster_se,
  df = length(unique(storm_data$Year)) - 1
)
# Calculate 95% confidence intervals
# using year-clustered standard errors
coefci(
  storm_model,
  vcov. = cluster_se,
  df = length(unique(storm_data$Year)) - 1
)
# ============================================
# CHECK STORM STATUS SELECTION
# ============================================
# Display all storm status categories
table(hurdat_1990_2025$Status)
# Identify each storm's maximum wind speed
# using only tropical/subtropical observations
tropical_data <- subset(
  hurdat_1990_2025,
  Status %in% c("TD", "TS", "HU", "SD", "SS")
)
tropical_storm_data <- aggregate(
  Wind ~ StormID + Year,
  data = tropical_data,
  FUN = max
)
# Compare number of storms
nrow(storm_data)
nrow(tropical_storm_data)
# Compare storm maximum wind speeds
comparison <- merge(
  storm_data,
  tropical_storm_data,
  by = c("StormID", "Year"),
  suffixes = c("_Original", "_Tropical")
)
# Count storms whose maximum wind speeds differ
sum(comparison$Wind_Original != comparison$Wind_Tropical)
