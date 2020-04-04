calculate_distance <- function(customer_latitude, customer_longitude, data_recintos) {
  
  distance <- c()
  
  for (i in 1:nrow(data_recintos)){
    
    distance_temp <- distGeo( c(customer_longitude, customer_latitude), c(data_recintos[i,"longitud"], 
                                                                          data_recintos[i,"latitud"]) )
    
    distance <- c (distance, distance_temp/1000)
    
  }
  
  
  data_2 <- cbind(data_recintos, distance)
  
  
  return (data_2)
}