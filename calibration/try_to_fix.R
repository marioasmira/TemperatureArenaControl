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


# new calibration ---------------------------------------------------------
new_data <- read.csv("second calibration/relevant_columns.csv")
new_data$read_temp <- NA
temperatures <- read.csv("second calibration/measured.csv")
unique_temps <- unique(new_data$L_target)
unique_temps <- unique_temps[unique_temps != 19.82]
new_data_long <- data.frame(
  value = c(new_data$L_value, new_data$M_value, new_data$R_value),
  target_temp = c(new_data$L_target, new_data$M_target, new_data$R_target),
  tile = c(rep("L", nrow(new_data)), rep("M", nrow(new_data)), rep("R", nrow(new_data)))
)

temperatures_long <- data.frame(
  measure = c(temperatures$L, temperatures$M, temperatures$R),
  target_temp = c(rep(temperatures$temperature, 3)),
  tile = c(rep("L", nrow(temperatures)), rep("M", nrow(temperatures)), rep("R", nrow(temperatures)))
)

new_data_long$measured <- NA
tiles = c("L", "M", "R")

for(temp in 1:length(unique_temps)){
  for(tile in 1:length(tiles)){
    new_data_long[new_data_long$target_temp == unique_temps[temp] & new_data_long$tile == tiles[tile],]$measured <- 
      temperatures_long[temperatures_long$target_temp == unique_temps[temp] & temperatures_long$tile == tiles[tile],]$measure
  }
}

new_data_long <- new_data_long[new_data_long$value != 0,]
#transforming the analog read
new_data_long$analog_read_model <- analog_calc(new_data_long$value)

# new estimation ----------------------------------------------------------

#estimating new values with linear model
m2 <- lm(measured ~ analog_read_model,
         data = new_data_long)
summary(m2)


#getting estimates
fix_slope <- m2$coefficients[2]
fix_intercept <- m2$coefficients[1]


# reploting with new estimates --------------------------------------------

#reploting
new_data_long$fix_calc <- calc(new_data_long$value, fix_slope, fix_intercept)

ggplot(new_data_long, aes(x = analog_read_model, y = measured)) +
  geom_point(color = "red") +
  geom_point(data = new_data_long, aes(x = analog_read_model, y = fix_calc), color = "blue")

# answer seems to be slope = -78.062830, and intercept = 69.309268

# another calibration ---------------------------------------------------------
new_data <- read.csv("third calibration/relevant_columns.csv")
new_data$read_temp <- NA
temperatures <- read.csv("third calibration/measured.csv")
unique_temps <- unique(new_data$L_target)
unique_temps <- unique_temps[unique_temps != 19.82]
tiles = c("L", "M", "R")

new_data_long <- data.frame(
  value = rep(c(new_data$L_value, new_data$M_value, new_data$R_value), 2),
  target_temp = rep(c(new_data$L_target, new_data$M_target, new_data$R_target),2),
  tile = rep(c(rep("L", nrow(new_data)), rep("M", nrow(new_data)), rep("R", nrow(new_data))),2),
  measure = c(rep("1", 3*nrow(new_data)), rep("2", 3*nrow(new_data)))
)

temperatures_long <- data.frame(
  measure = c(temperatures$L, temperatures$M, temperatures$R),
  target_temp = c(rep(temperatures$temperature, 3)),
  tile = c(rep("L", nrow(temperatures)), rep("M", nrow(temperatures)), rep("R", nrow(temperatures))),
  measure.1 = rep(c("1","2"), 1.5*nrow(temperatures))
)

new_data_long$measured <- NA
nmeasures <- c("1", "2")
for(m in 1:2){
  for(temp in 1:length(unique_temps)){
    for(tile in 1:length(tiles)){
      new_data_long[
        new_data_long$target_temp == unique_temps[temp] &
          new_data_long$tile == tiles[tile] &
          new_data_long$measure == nmeasures[m]
        ,]$measured <- 
        temperatures_long[
          temperatures_long$target_temp == unique_temps[temp] &
            temperatures_long$tile == tiles[tile] &
            temperatures_long$measure.1 == nmeasures[m]
          ,]$measure
    }
  }
}


new_data_long <- new_data_long[new_data_long$value != 0,]
#transforming the analog read
new_data_long$analog_read_model <- analog_calc(new_data_long$value)

# new estimation ----------------------------------------------------------

#estimating new values with linear model
m2 <- lm(measured ~ analog_read_model,
         data = new_data_long)
summary(m2)


#getting estimates
fix_slope <- m2$coefficients[2]
fix_intercept <- m2$coefficients[1]


# reploting with new estimates --------------------------------------------

#reploting
new_data_long$fix_calc <- calc(new_data_long$value, fix_slope, fix_intercept)

ggplot(new_data_long, aes(x = analog_read_model, y = measured)) +
  geom_point(color = "red") +
  geom_point(data = new_data_long, aes(x = analog_read_model, y = fix_calc), color = "blue")

# answer seems to be slope = -76.354282, and intercept = 70.037168


# yet another calibration ---------------------------------------------------------
l_data <- read.csv("fourth calibration/arena_data_L.csv")
m_data <- read.csv("fourth calibration/arena_data_M.csv")
r_data <- read.csv("fourth calibration/arena_data_R.csv")
l_data <- l_data[(nrow(l_data)-nrow(m_data)):nrow(l_data),]

new_data_long <- data.frame(
  val = c(l_data$L_val, m_data$M_val, r_data$R_val),
  target = c(l_data$L_target, m_data$M_target, r_data$R_target),
  measure = c(l_data$temp, m_data$temp, r_data$temp),
  tile = c(rep("L", nrow(l_data)), rep("M", nrow(m_data)), rep("R", nrow(r_data)))
)


new_data_long <- new_data_long[new_data_long$target > 14,]
#transforming the analog read
new_data_long$analog_read_model <- analog_calc(new_data_long$val)

# new estimation ----------------------------------------------------------

#estimating new values with linear model
m2 <- lm(measure ~ analog_read_model,
         data = new_data_long)
summary(m2)


#getting estimates
fix_slope <- m2$coefficients[2]
fix_intercept <- m2$coefficients[1]


# reploting with new estimates --------------------------------------------

#reploting
new_data_long$fix_calc <- calc(new_data_long$val, fix_slope, fix_intercept)

ggplot(new_data_long, aes(x = analog_read_model, y = measure)) +
  geom_point(color = "red") +
  geom_point(data = new_data_long, aes(x = analog_read_model, y = fix_calc), color = "blue")



ggplot(new_data_long, aes(x = analog_read_model, y = measure, color = tile)) +
  geom_point()


# answer seems to be slope = -82.920729, and intercept = 75.982780

result <- read.csv("fourth calibration/arena_data.csv")
result$fix_calc <- analog_calc(result$X3066.0)
ggplot(result, aes(x = X14.0.2, y = X15.21)) +
  geom_point()



# calibrating calibrator --------------------------------------------------

d <- read.csv("fifth calibration/water readings.csv")

# values taken from the c++ program
a <- 0.00122683
b <- 0.000218001
c <- 1.56148e-07
shmodel <- function(a, b, c, R){
  return((1 / (a + b * log(R) + c * log(R)^3)))
}

resists <- seq(3568, 21000, length.out = 100)
y <- shmodel(a, b, c, resists) - 273.15

calc <- data.frame(x = y, y = resists)


library(ggplot2)

ggplot(calc, aes(x = x, y = y)) +
  geom_line() +
  geom_point(data = d, aes(x = temp, y = resistance))


# yet yet another calibration ---------------------------------------------------------
l_data <- read.csv("fifth calibration/arena_data_L.csv")
m_data <- read.csv("fifth calibration/arena_data_M.csv")
r_data <- read.csv("fifth calibration/arena_data_R.csv")
l_data <- l_data[(nrow(l_data)-nrow(m_data)):nrow(l_data),]

new_data_long <- data.frame(
  val = c(l_data$L_val, m_data$M_val, r_data$R_val),
  target = c(l_data$L_target, m_data$M_target, r_data$R_target),
  measure = c(l_data$temp, m_data$temp, r_data$temp),
  tile = c(rep("L", nrow(l_data)), rep("M", nrow(m_data)), rep("R", nrow(r_data)))
)


new_data_long <- new_data_long[new_data_long$target > 14,]
#transforming the analog read
new_data_long$analog_read_model <- analog_calc(new_data_long$val)

# new estimation ----------------------------------------------------------

#estimating new values with linear model
m2 <- lm(measure ~ analog_read_model,
         data = new_data_long)
summary(m2)


#getting estimates
(fix_slope <- m2$coefficients[2])
(fix_intercept <- m2$coefficients[1])


# reploting with new estimates --------------------------------------------

#reploting
new_data_long$fix_calc <- calc(new_data_long$val, fix_slope, fix_intercept)

ggplot(new_data_long, aes(x = analog_read_model, y = measure)) +
  geom_point(color = "red") +
  geom_point(data = new_data_long, aes(x = analog_read_model, y = fix_calc), color = "blue")



ggplot(new_data_long, aes(x = analog_read_model, y = measure, color = tile)) +
  geom_point()


# answer seems to be slope = -52.43235, and intercept = 55.13457

result <- read.csv("fifth calibration/arena_data.csv")
result <- read.csv("/media/mario/4714-E6D1/arena_data_L.csv")
result$fix_calc <- analog_calc(result$X3216.0)
ggplot(result, aes(x = X14.0, y = X14.98)) +
  geom_point()

ggplot(result, aes(x = X3216.0, y = X14.98)) +
  geom_point()



# last calibration ---------------------------------------------------------
l_data <- read.csv("sixth calibration/arena_data_L.csv")
m_data <- read.csv("sixth calibration/arena_data_M.csv")
r_data <- read.csv("sixth calibration/arena_data_R.csv")
l_data <- l_data[(nrow(l_data)-nrow(m_data)):nrow(l_data),]

new_data_long <- data.frame(
  val = c(l_data$L_val, m_data$M_val, r_data$R_val),
  target = c(l_data$L_target, m_data$M_target, r_data$R_target),
  measure = c(l_data$temp, m_data$temp, r_data$temp),
  tile = c(rep("L", nrow(l_data)), rep("M", nrow(m_data)), rep("R", nrow(r_data)))
)


new_data_long <- new_data_long[new_data_long$target > 14,]
#transforming the analog read
new_data_long$analog_read_model <- analog_calc(new_data_long$val)

# new estimation ----------------------------------------------------------

#estimating new values with linear model
m2 <- lm(measure ~ analog_read_model,
         data = new_data_long)
summary(m2)


#getting estimates
(fix_slope <- m2$coefficients[2])
(fix_intercept <- m2$coefficients[1])


# reploting with new estimates --------------------------------------------

#reploting
new_data_long$fix_calc <- calc(new_data_long$val, fix_slope, fix_intercept)

ggplot(new_data_long, aes(x = analog_read_model, y = measure)) +
  geom_point(color = "red") +
  geom_point(data = new_data_long, aes(x = analog_read_model, y = fix_calc), color = "blue")


export_data <- data.frame(
  read = new_data_long$analog_read_model,
  measure = new_data_long$measure
)

write.csv(export_data, "export_data.csv", row.names=FALSE)


# answer seems to be slope = -62.09515, and intercept = 62.65304

result <- read.csv("sixth calibration/arena_data.csv")
result$fix_calc <- analog_calc(result$X3207.0)
ggplot(result, aes(x = X14.0, y = X14.0.3)) +
  geom_point() + 
  geom_smooth(method='lm', formula= y~x)+
  geom_abline(intercept = 0, slope = 1, color="red", linetype="dashed")

