setwd("~/Code/arena_python/calibration/")

library(ggplot2)
d <- read.csv("calibrate.csv")

slope	<- -97.05
bit_resolution <- 12
intercept <- 85.21

analog_calc <- function(x){
  x/(2^bit_resolution - 1)
}
calc <- function(x, y, z){
  z + y * analog_calc(x)
}


#transforming the analog read
d$analog_read_model <- analog_calc(d$analog_read)

# first plot --------------------------------------------------------------

#calculate what the box "feels" in terms of temperature
d$current_calc <- calc(d$analog_read, slope, intercept)

#guessing some values to try to match them to the collected temperature
fix_slope <- -76.5
fix_intercept <- 70

d$fix_calc <- calc(d$analog_read, fix_slope, fix_intercept)


ggplot(d, aes(x = analog_read_model, y = measured_temp)) +
  geom_point(color = "red") +
  geom_point(data = d, aes(x = analog_read_model, y = fix_calc), color = "blue") +
  ylim(0, 60)


# estimation --------------------------------------------------------------

#estimating new values with linear model
m1 <- lm(measured_temp ~ analog_read_model,
         data = d)  
summary(m1)

#getting estimates
fix_slope <- m1$coefficients[2]
fix_intercept <- m1$coefficients[1]


# reploting with new estimates --------------------------------------------

#reploting
d$fix_calc <- calc(d$analog_read, fix_slope, fix_intercept)

ggplot(d, aes(x = analog_read_model, y = measured_temp)) +
  geom_point(color = "red") +
  geom_point(data = d, aes(x = analog_read_model, y = fix_calc), color = "blue") +
  ylim(0, 60)


# new calibration ---------------------------------------------------------
# unused
# 
# new_data <- read.csv("flir calibration/relevant_columns.csv")
# new_data$read_temp <- NA
# temperatures <- c(16.1, 17.3, 18.6, 20.5, 21.8, 23,
#                   24.8, 26, 27.7, 29.2, 30.6, 31.6,
#                   32.8, 34.1, NA, 35.9, 37.2, 38.7, 39.9,
#                   41.2, 42.5, 44.2, 45.2, 46.5, 47.7,
#                   49.2, 50.6, 51.7, 53.2, 54.5, 56.1, 57.3)
# unique_temps <- unique(new_data$target_temp)
# 
# length(unique_temps) == length(temperatures)
# 
# for (i in 1:length(unique_temps)){
#   new_data[new_data$target_temp == unique_temps[i], ]$read_temp <- temperatures[i]
# }
# 
# 
# #transforming the analog read
# new_data$analog_read_model <- analog_calc(new_data$analog_read)
# 
# # new estimation ----------------------------------------------------------
# 
# #estimating new values with linear model
# m2 <- lm(read_temp ~ analog_read_model,
#          data = new_data)
# summary(m2)
# 
# library(brms)
# m3 <- brm(read_temp ~ analog_read_model,
#           data = new_data,
#           chains = 4,
#           cores = 4)
# 
# summary(m3)
# #getting estimates
# fix_slope <- summary(m3)$fixed[2]
# fix_intercept <- summary(m3)$fixed[1]
# 
# 
# # reploting with new estimates --------------------------------------------
# 
# #reploting
# new_data$fix_calc <- calc(new_data$analog_read, fix_slope, fix_intercept)
# 
# ggplot(new_data, aes(x = analog_read_model, y = read_temp)) +
#   geom_point(color = "red") +
#   geom_point(data = new_data, aes(x = analog_read_model, y = fix_calc), color = "blue")
# 
# # answer seems to be slope = -109.2922, and intercept = 96.0564
# 
# 
# # new calibration ---------------------------------------------------------
# 
# new_data <- read.csv("flir calibration/relevant_columns_second_pass.csv")
# new_data$read_temp <- NA
# temperatures <- c(12.8, 14, 15.5, 16.4, 17.6, 18.8,
#                   19.7, 21.1, 22.5, 23.7, 24.7, 25,
#                   26.9, 28, 29, 30, 30.9, 32.4, 33.1,
#                   34.2, 35.3, 36, 36.9, 37.9, 38.9,
#                   39.6, 40.9, 41.6, 42.5, 43.7, 44.4, 44.8)
# unique_temps <- unique(new_data$target_temp)
# 
# length(unique_temps) == length(temperatures)
# 
# for (i in 1:length(unique_temps)){
#   new_data[new_data$target_temp == unique_temps[i], ]$read_temp <- temperatures[i]
# }
# 
# 
# #transforming the analog read
# new_data$analog_read_model <- analog_calc(new_data$analog_read)
# 
# new_data <- new_data[new_data$target_temp > 16,]
# # new estimation ----------------------------------------------------------
# 
# #estimating new values with linear model
# m2 <- lm(read_temp ~ analog_read_model,
#          data = new_data)
# summary(m2)
# 
# 
# #getting estimates
# fix_slope <- m2$coefficients[2]
# fix_intercept <- m2$coefficients[1]
# 
# 
# # reploting with new estimates --------------------------------------------
# 
# #reploting
# new_data$fix_calc <- calc(new_data$analog_read, fix_slope, fix_intercept)
# 
# ggplot(new_data, aes(x = analog_read_model, y = read_temp)) +
#   geom_point(color = "red") +
#   geom_point(data = new_data, aes(x = analog_read_model, y = fix_calc), color = "blue")
# 
# # answer seems to be slope = -117.8487, and intercept = 101.64089