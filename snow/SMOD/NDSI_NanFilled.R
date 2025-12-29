library(raster)
snow_data_path <- dir('J:/2_SnowData/2_AVHRR_NDSI/1983/',full.names = TRUE)
exam <- raster(snow_data_path[1])
exam_data <- getValues(exam) 
for (i in 1:length(snow_data_path)){
  if ( i %% 100  == 0){
    print(i)
  }
  
  if (i == 1){
    snow_1 <- raster("J:/2_SnowData/2_AVHRR_NDSI/1983/19821231na_filled.tif")
  }else{
    snow_1 <- raster(output_path)
  }
  
  snow_2 <- raster(snow_data_path[i])
  
  data_1 <- getValues(snow_1)
  data_2 <- getValues(snow_2)
  
  data_1[data_1 > 100] <- NA
  data_2[data_2 > 100] <- NA
  
  data_2[is.na(data_2)] <- data_1[is.na(data_2)]
  
  
  output <- setValues(exam,data_2)
  output_path <- paste('J:/2_SnowData/2_AVHRR_NDSI/na_fill_NDSI/', substr(snow_data_path[i],33,40),'na_filled.tif',sep='')
  writeRaster(output,output_path, format = 'GTiff')
  
}
