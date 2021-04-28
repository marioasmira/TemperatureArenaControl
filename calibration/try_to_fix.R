setwd("~/Code/arena_python/")

library(ggplot2)
d <- read.csv("calibrate.csv")

slope	<- -97.05
bit_resolution <- 12
intercept <- 85.21

calc <- function(x, y, z){
  z + ((y * x)/(2^bit_resolution - 1))
}


#transforming the analog read
d$analog_read_model <- d$analog_read / (2^bit_resolution - 1)

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
