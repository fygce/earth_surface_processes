library(raster)
library(dplyr)
library(tidyr)

#------------------------------------
# 1. 定义每个窗口的路径
#------------------------------------
window_paths <- c(
  "K:/1_Meteo_Datasets/SMT_ForUse/AgERA5_SMT/5daywindow/01deg/",
  "K:/1_Meteo_Datasets/SMT_ForUse/AgERA5_SMT/10daywindow/01deg/",
  "K:/1_Meteo_Datasets/SMT_ForUse/AgERA5_SMT/15daywindow/01deg/",
  "K:/1_Meteo_Datasets/SMT_ForUse/AgERA5_SMT/20daywindow/01deg/",
  "K:/1_Meteo_Datasets/SMT_ForUse/AgERA5_SMT/25daywindow/01deg/",
  "K:/1_Meteo_Datasets/SMT_ForUse/AgERA5_SMT/30daywindow/01deg/",
  "K:/1_Meteo_Datasets/SMT_ForUse/AgERA5_SMT/35daywindow/01deg/"
)

windows <- c(5, 10, 15, 20, 25, 30, 35)
years <- 1982:2022

#------------------------------------
# 2. 统计有效像元函数
#------------------------------------
count_valid_pixels <- function(file_path) {
  r <- raster(file_path)
  sum(!is.na(values(r)))
}

#------------------------------------
# 3. 循环统计
#------------------------------------
results <- data.frame()

for (i in seq_along(windows)) {
  w <- windows[i]
  folder <- window_paths[i]
  
  for (yr in years) {
    fname <- file.path(folder, paste0("SMT", yr, ".tif"))
    if (!file.exists(fname)) {
      cat("未找到文件:", fname, "\n")
      next
    }
    
    valid_count <- count_valid_pixels(fname)
    results <- rbind(results,
                     data.frame(Year = yr,
                                Window = w,
                                ValidPixels = valid_count))
  }
}

#------------------------------------
# 4. 转换为宽表（年份为行，窗口为列）
#------------------------------------
results_wide <- results %>%
  pivot_wider(names_from = Window,
              values_from = ValidPixels,
              names_prefix = "Window_")

#------------------------------------
# 5. 转换为百分比
#------------------------------------
max_pixels <- 714797  # 基准像元数
cols <- grep("Window_", names(results_wide), value = TRUE)
results_wide[cols] <- results_wide[cols] / max_pixels * 100

#------------------------------------
# 6. 保存为 CSV
#------------------------------------
write.csv(results_wide,
          "K:/1_Meteo_Datasets/SMT_ForUse/AgERA5_SMT/sensitivity/SMOD_valid_pixel_percent.csv",
          row.names = FALSE)

cat("✔ 完成！百分比宽表已输出到 SMOD_valid_pixel_percent.csv\n")
