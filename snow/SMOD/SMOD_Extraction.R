# ==============================
# Snow Melt Timing (SMT) extraction
# ==============================

# Load required libraries
library(raster)
library(zoo)

# Set input and output directories
input_folder  <- "K:/1_Meteo_Datasets/AgERA5/SD/0100/"      # Original snow depth data
output_folder <- "K:/1_Meteo_Datasets/SMT_ForUse/AgERA5_SMT/"  # Output SMT folder

# Create output folder if it does not exist
if (!dir.exists(output_folder)) {
  dir.create(output_folder, recursive = TRUE)
}

# Get all tif files
snow_files <- dir(input_folder, pattern = "\\.tif$", full.names = TRUE)

# Filter files: only January–July of 1996
snow_files_filtered <- snow_files[
  grepl("1996(01|02|03|04|05|06|07)", basename(snow_files))
]

# Stack snow depth data
snow_stack <- stack(snow_files_filtered)

# ------------------------------
# Function to extract snow melt timing
# ------------------------------
get_smt <- function(snow) {
  
  # If all values are NA
  if (sum(is.na(snow)) == length(snow)) {
    smt <- NA
    
    # If snow exists for the entire period (never melts)
  } else if (sum(snow >= 1, na.rm = TRUE) == length(na.omit(snow))) {
    smt <- NA
    
  } else {
    # Convert snow depth to binary (no snow < 1, snow >= 1)
    snow_bin <- ifelse(snow < 1, 0, 1)
    
    # Identify 15 consecutive days with no snow
    no_snow_15 <- zoo::rollapply(
      snow_bin == 0,
      width = 15,
      FUN = sum,
      fill = NA,
      align = "left"
    )
    
    # First day of snow-free period
    melt_index <- which(no_snow_15 == 15)
    
    if (length(melt_index) > 0) {
      smt <- min(melt_index)
    } else {
      smt <- NA
    }
  }
  
  return(smt)
}

# ------------------------------
# Calculate Snow Melt Timing
# ------------------------------
smt_result <- calc(snow_stack, get_smt)

# Visualize result
plot(smt_result, main = "Snow Melt Timing (SMT)")

# Save result
output_file <- file.path(output_folder, "SMT1996.tif")
writeRaster(smt_result, output_file, format = "GTiff", overwrite = TRUE)

cat("Snow melt timing extraction completed and saved to:\n", output_file, "\n")
