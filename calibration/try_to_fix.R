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
  geom_point(alpha = 0.1)


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
  read = new_data_long$val,
  measure = new_data_long$measure,
  tile = new_data_long$tile
)

write.csv(export_data, "calibrate/export_data.csv", row.names=FALSE, quote = F)


# answer seems to be slope = -62.09515, and intercept = 62.65304

result <- read.csv("sixth calibration/arena_data.csv")
result$fix_calc <- analog_calc(result$X3207.0)
ggplot(result, aes(x = X14.0, y = X14.0.3)) +
  geom_point() + 
  geom_smooth(method='lm', formula= y~x)+
  geom_abline(intercept = 0, slope = 1, color="red", linetype="dashed")



# values taken from the c++ program
a <- 0.0310214
b <- -0.00515655
c <- 2.61115e-05
shmodel <- function(a, b, c, R){
  return((1 / (a + b * log(R) + c * log(R)^3)))
}
new_data_long$resis <- 10000 / (2^bit_resolution / (new_data_long$val - 1.0))
resists <- seq(min(new_data_long$resis), max(new_data_long$resis), length.out = 100)
y <- shmodel(a, b, c, resists) - 273.15
y <- exp(resists) + 50

calc <- data.frame(x = y, y = resists)


library(ggplot2)

ggplot(calc, aes(x = x, y = y)) +
  geom_line() +
  geom_point(data = new_data_long, aes(x = measure, y = resis))

ggplot(data = new_data_long, aes(x = measure, y = resis)) +
  geom_point()

m3 <- lm(measure ~ analog_read_model, data = new_data_long)
summary(m3)

library(Hmisc)
precision <- 100
max <- 1
n_k <- 5
x_values <- seq(0, max, length.out = precision)
knots <- seq(0.05*max, 0.95*max, length.out = n_k)
xx <- rcspline.eval(x_values, knots = knots, inclx = T)
zero <- rep(1, precision)
xx <- cbind(zero,xx)
parametersL <- c(65.8341, -75.0247, 25.398, -7.38835, -138.323)
parametersM <- c(67.0292, -78.3638, 25.4279, 6.90711, -175.801)
parametersR <- c(67.4683, -77.527, 21.3805, 5.16503, -156.913)

yL <- xx%*%parametersL
yM <- xx%*%parametersM
yR <- xx%*%parametersR

calc <- data.frame(
  x = x_values,
  y = c(yL, yM, yR),
  tile = c(rep("L", precision), rep("M", precision), rep("R", precision))
)

ggplot(calc, aes(x = x, y = y)) +
  geom_point(data = new_data_long, aes(x = analog_read_model, y = measure)) +
  geom_line(color = "red")

ggplot(data = new_data_long, aes(x = analog_read_model, y = measure, color = tile)) +
  geom_point(alpha = 0.05) +
  geom_line(data = calc, aes(x = x, y = y, color = tile))




SS <- read.csv("calibrate/SS.csv")
SS$row <- seq(1:nrow(SS))
plot(SS[,2], SS[,1])



# second spline calibration ---------------------------------------------------------
l_data <- read.csv("third spline calibration/arena_data.csv")
m_data <- read.csv("second spline calibration/arena_data_M.csv")
r_data <- read.csv("second spline calibration/arena_data_R.csv")

new_data_long <- data.frame(
  val = c(l_data$L_val, m_data$M_val, r_data$R_val),
  target = c(l_data$L_target, m_data$M_target, r_data$R_target),
  measure = c(l_data$temp, m_data$temp, r_data$temp),
  tile = c(rep("L", nrow(l_data)), rep("M", nrow(m_data)), rep("R", nrow(r_data)))
)


new_data_long <- new_data_long[new_data_long$target > 14,]
#transforming the analog read
ggplot(new_data_long, aes(x = target, y = measure, color = tile)) +
  geom_point(alpha = 0.1) + 
  geom_smooth(method='lm', formula= y~x)+
  geom_abline(intercept = 0, slope = 1, color="red", linetype="dashed")

new_data_long <- na.omit(new_data_long)
export_data <- data.frame(
  read = new_data_long$val,
  measure = new_data_long$measure,
  tile = new_data_long$tile
)

write.csv(export_data, "calibrate/export_data.csv", row.names=FALSE, quote = F)

t <- read.csv("/media/mario/ECFC-DFF4/arena_data.csv")


ggplot(l_data, aes(x = L_target, y = temp)) +
  geom_point(alpha = 0.1) + 
  geom_smooth(method='lm', formula= y~x)+
  geom_abline(intercept = 0, slope = 1, color="red", linetype="dashed")



# second spline calibration ---------------------------------------------------------
l_data <- read.csv("third spline calibration/arena_data.csv")


new_data_long <- l_data[l_data$L_target > 14,]
#transforming the analog read
ggplot(new_data_long, aes(x = target, y = measure, color = tile)) +
  geom_point(alpha = 0.1) + 
  geom_smooth(method='lm', formula= y~x)+
  geom_abline(intercept = 0, slope = 1, color="red", linetype="dashed")

new_data_long <- na.omit(new_data_long)
export_data <- data.frame(
  read = new_data_long$L_val,
  measure = new_data_long$temp,
  tile = "L"
)

write.csv(export_data, "calibrate/export_data.csv", row.names=FALSE, quote = F)



ggplot(l_data, aes(x = L_target, y = temp)) +
  geom_point(alpha = 0.1) + 
  geom_smooth(method='lm', formula= y~x)+
  geom_abline(intercept = 0, slope = 1, color="red", linetype="dashed")



# final values -------------------------------------------------------------

l_data <- read.csv("third spline calibration/arena_data.csv")
m_data <- read.csv("second spline calibration/arena_data_M.csv")
r_data <- read.csv("second spline calibration/arena_data_R.csv")

new_data_long <- data.frame(
  val = c(l_data$L_val, m_data$M_val, r_data$R_val),
  target = c(l_data$L_target, m_data$M_target, r_data$R_target),
  measure = c(l_data$temp, m_data$temp, r_data$temp),
  tile = c(rep("L", nrow(l_data)), rep("M", nrow(m_data)), rep("R", nrow(r_data)))
)


new_data_long <- new_data_long[new_data_long$target > 14,]
#transforming the analog read
ggplot(new_data_long, aes(x = target, y = measure, color = tile)) +
  geom_point(alpha = 0.1) + 
  geom_smooth(method='lm', formula= y~x)+
  geom_abline(intercept = 0, slope = 1, color="red", linetype="dashed")

new_data_long$diff <- new_data_long$measure - new_data_long$target

ggplot(new_data_long, aes(x = target, y = diff, color = tile, group = tile)) +
stat_summary(fun = mean,
             geom = "pointrange",
             fun.max = function(x) mean(x) + sd(x),
             fun.min = function(x) mean(x) - sd(x))
  geom_point(alpha = 0.05, position = position_dodge(width = 0.5))

  

# flir 2 ------------------------------------------------------------------

data <- read.csv("flir calibration 2/arena_data (1).csv")
plot(data$L_target)
data$index <- NA
index <- 1

for(i in 1:(nrow(data)-1)){
  if(data$L_target[i] <= data$L_target[i+1]){
    data$index[i] <- index
  } else{
    index <- index + 1
    data$index[i] <- index
  }
}
plot(data$index)
summary(data$index)
data <- data[data$index > 6,]
plot(data$index)
plot(data$L_target)
data <- data[data$index != 9,]
data <- data[data$L_target > 16,]
unique(data$index)
l_data <- data[data$index == 7,]
m_data <- data[data$index == 8,]
r_data <- data[data$index == 10,]

new_data_long <- data.frame(
  val = c(l_data$L_val, m_data$M_val, r_data$R_val),
  target = c(l_data$L_target, m_data$M_target, r_data$R_target),
  measure = NA,
  tile = c(rep("L", nrow(l_data)), rep("M", nrow(m_data)), rep("R", nrow(r_data)))
)

mea <- read.csv("flir calibration 2/Temp heatbox 271021.csv")

for(i in 1:nrow(new_data_long)){
  new_data_long$measure[i] <- mea[mea$temp == new_data_long$target[i] &
                                    mea$tile == new_data_long$tile[i],]$measure
}


new_data_long <- na.omit(new_data_long)
export_data <- data.frame(
  read = new_data_long$val,
  measure = new_data_long$measure,
  tile = new_data_long$tile
)

write.csv(export_data, "calibrate/export_data.csv", row.names=FALSE, quote = F)

new_data_long$analog_val <- analog_calc(new_data_long$val)
lm_l <- lm(measure ~ analog_val, data = new_data_long[new_data_long$tile == "L",])
summary(lm_l)
lm_m <- lm(measure ~ analog_val, data = new_data_long[new_data_long$tile == "M",])
summary(lm_m)
lm_r <- lm(measure ~ analog_val, data = new_data_long[new_data_long$tile == "R",])
summary(lm_r)

ggplot(data = new_data_long, aes(x = analog_val, y = measure, color = tile)) +
  geom_point(alpha = 0.05)



library(Hmisc)
precision <- 100
max <- 1
n_k <- 5
x_values <- seq(0, max, length.out = precision)
knots <- seq(0.05*max, 0.95*max, length.out = n_k)
xx <- rcspline.eval(x_values, knots = knots, inclx = T)
zero <- rep(1, precision)
xx <- cbind(zero,xx)
parametersL <- c(92.6445, -103.802, 9.42424, -26.7882, -101.608)
parametersM <- c(93.9908, -108.338, 5.65328, 29.507, -348.009)
parametersR <- c(96.6713, -113.69, 4.13182, 44.786, -318.983)

yL <- xx%*%parametersL
yM <- xx%*%parametersM
yR <- xx%*%parametersR

calc <- data.frame(
  x = x_values,
  y = c(yL, yM, yR),
  tile = c(rep("L", precision), rep("M", precision), rep("R", precision))
)

ggplot(calc, aes(x = x, y = y)) +
  geom_point(data = new_data_long, aes(x = analog_val, y = measure)) +
  geom_line(color = "red")

ggplot(data = new_data_long, aes(x = analog_val, y = measure, color = tile)) +
  geom_point(alpha = 0.05) +
  geom_line(data = calc, aes(x = x, y = y, color = tile)) +
  xlim(0.35, 0.8) +
  ylim(15, 50)


# flir 3 ------------------------------------------------------------------


data <- read.csv("flir calibration 3/arena_data.csv")
plot(data$L_target)
data$index <- NA
index <- 1

for(i in 1:(nrow(data)-1)){
  if(data$L_target[i] <= data$L_target[i+1]){
    data$index[i] <- index
  } else{
    index <- index + 1
    data$index[i] <- index
  }
}
plot(data$index)
summary(data$index)
data <- data[data$index == 1 | data$index == 4 | data$index == 7,]
plot(data$index)
plot(data$L_target)
data <- data[data$L_target > 14,]
data <- data[data$L_target < 48,]
unique(data$index)
l_data <- data[data$index == 1,]
m_data <- data[data$index == 4,]
r_data <- data[data$index == 7,]

new_data_long <- data.frame(
  val = c(l_data$L_val, m_data$M_val, r_data$R_val),
  target = c(l_data$L_target, m_data$M_target, r_data$R_target),
  measure = NA,
  tile = c(rep("L", nrow(l_data)), rep("M", nrow(m_data)), rep("R", nrow(r_data)))
)

mea <- read.csv("flir calibration 3/Temp heatbox 281021.csv")

for(i in 1:nrow(new_data_long)){
  new_data_long$measure[i] <- mea[mea$temp == new_data_long$target[i] &
                                    mea$tile == new_data_long$tile[i],]$measure
}


new_data_long <- na.omit(new_data_long)
export_data <- data.frame(
  read = new_data_long$val,
  measure = new_data_long$measure,
  tile = new_data_long$tile
)

write.csv(export_data, "calibrate/export_data.csv", row.names=FALSE, quote = F)

new_data_long$analog_val <- analog_calc(new_data_long$val)
lm_l <- lm(measure ~ analog_val, data = new_data_long[new_data_long$tile == "L",])
summary(lm_l)
lm_m <- lm(measure ~ analog_val, data = new_data_long[new_data_long$tile == "M",])
summary(lm_m)
lm_r <- lm(measure ~ analog_val, data = new_data_long[new_data_long$tile == "R",])
summary(lm_r)

ggplot(data = new_data_long, aes(x = analog_val, y = measure, color = tile)) +
  geom_point(alpha = 0.05)



library(Hmisc)
precision <- 100
max <- 1
n_k <- 5
x_values <- seq(0, max, length.out = precision)
knots <- seq(0.05*max, 0.95*max, length.out = n_k)
xx <- rcspline.eval(x_values, knots = knots, inclx = T)
zero <- rep(1, precision)
xx <- cbind(zero,xx)
parametersL <- c(93.7487, -104.413, 6.54582, -33.6192, -100.089)
parametersM <- c(94.5345, -108.241, 3.45671, 28.6225, -305.973)
parametersR <- c(99.6374, -116.446, -4.51146, 61.102, -271.405)

yL <- xx%*%parametersL
yM <- xx%*%parametersM
yR <- xx%*%parametersR

calc <- data.frame(
  x = x_values,
  y = c(yL, yM, yR),
  tile = c(rep("L", precision), rep("M", precision), rep("R", precision))
)

ggplot(calc, aes(x = x, y = y)) +
  geom_point(data = new_data_long, aes(x = analog_val, y = measure)) +
  geom_line(color = "red")

ggplot(data = new_data_long, aes(x = analog_val, y = measure, color = tile)) +
  geom_point(alpha = 0.05) +
  geom_line(data = calc, aes(x = x, y = y, color = tile)) +
  xlim(0.35, 0.8) +
  ylim(15, 50)



# infrared thermo ---------------------------------------------------------



data <- read.csv("infrared thermo/arena_data.csv")
plot(data$L_target)
data$index <- NA
index <- 1

for(i in 1:(nrow(data)-1)){
  if(data$L_target[i] <= data$L_target[i+1]){
    data$index[i] <- index
  } else{
    index <- index + 1
    data$index[i] <- index
  }
}
plot(data$index)
summary(data$index)
indexed <- data
data <- indexed[indexed$index == 13 | indexed$index == 14,]
plot(data$index)
plot(data$L_target)
data <- data[data$L_target > 14,]
unique(data$index)
# l_data <- data[data$index == 1,]
# m_data <- data[data$index == 4,]
# r_data <- data[data$index == 7,]

new_data_long <- data.frame(
  val = c(data$L_val, data$M_val, data$R_val),
  target = c(data$L_target, data$M_target, data$R_target),
  measure = NA,
  tile = c(rep("L", nrow(data)), rep("M", nrow(data)), rep("R", nrow(data)))
)

mea <- read.csv("infrared thermo/Temp heatbox 011121.csv")

for(i in 1:nrow(new_data_long)){
  new_data_long$measure[i] <- mea[mea$temp == new_data_long$target[i] &
                                    mea$tile == new_data_long$tile[i],]$measure
}

new_data_long <- new_data_long[!(new_data_long$measure > 40 & new_data_long$analog_val > 0.485),]
new_data_long <- na.omit(new_data_long)
export_data <- data.frame(
  read = new_data_long$val,
  measure = new_data_long$measure,
  tile = new_data_long$tile
)

write.csv(export_data, "calibrate/export_data.csv", row.names=FALSE, quote = F)

new_data_long$analog_val <- analog_calc(new_data_long$val)
lm_l <- lm(measure ~ analog_val, data = new_data_long[new_data_long$tile == "L",])
summary(lm_l)
lm_m <- lm(measure ~ analog_val, data = new_data_long[new_data_long$tile == "M",])
summary(lm_m)
lm_r <- lm(measure ~ analog_val, data = new_data_long[new_data_long$tile == "R",])
summary(lm_r)

ggplot(data = new_data_long_t, aes(x = val, y = measure, color = tile)) +
  geom_point(alpha = 0.05)



library(Hmisc)
precision <- 100
max <- 1
n_k <- 5
x_values <- seq(0, max, length.out = precision)
knots <- seq(0.05*max, 0.95*max, length.out = n_k)
xx <- rcspline.eval(x_values, knots = knots, inclx = T)
zero <- rep(1, precision)
xx <- cbind(zero,xx)
parametersL <- c(79.4308, -89.4651, -0.187081, 1.64607, 3.95824)
parametersM <- c(80.9609, -92.0967, -0.222253, 1.49366, 1.76105)
parametersR <- c(80.5252, -91.2008, -0.372707, 2.21842, 3.83658)

yL <- xx%*%parametersL
yM <- xx%*%parametersM
yR <- xx%*%parametersR

calc <- data.frame(
  x = x_values,
  y = c(yL, yM, yR),
  tile = c(rep("L", precision), rep("M", precision), rep("R", precision))
)

ggplot(calc, aes(x = x, y = y)) +
  geom_point(data = new_data_long, aes(x = analog_val, y = measure)) +
  geom_line(color = "red")

ggplot(data = new_data_long, aes(x = analog_val, y = measure, color = tile)) +
  geom_point(alpha = 0.05) +
  geom_line(data = calc, aes(x = x, y = y, color = tile)) +
  xlim(0.35, 0.8) +
  ylim(15, 50)


# infrared thermo2 ---------------------------------------------------------



data <- read.csv("infrared thermo 2/arena_data.csv")
plot(data$L_target)
data$index <- NA
index <- 1

for(i in 1:(nrow(data)-1)){
  if(data$L_target[i] <= data$L_target[i+1]){
    data$index[i] <- index
  } else{
    index <- index + 1
    data$index[i] <- index
  }
}
plot(data$index)
summary(data$index)
indexed <- data
data <- indexed[indexed$index == 2,]
plot(data$index)
plot(data$L_target)
data <- data[data$L_target > 14,]
unique(data$index)
# l_data <- data[data$index == 1,]
# m_data <- data[data$index == 4,]
# r_data <- data[data$index == 7,]

new_data_long <- data.frame(
  val = c(data$L_val, data$M_val, data$R_val),
  target = c(data$L_target, data$M_target, data$R_target),
  measure = NA,
  tile = c(rep("L", nrow(data)), rep("M", nrow(data)), rep("R", nrow(data)))
)

mea <- read.csv("infrared thermo 2/Temp heatbox 031121.csv")

for(i in 1:nrow(new_data_long)){
  new_data_long$measure[i] <- mea[mea$temp == new_data_long$target[i] &
                                    mea$tile == new_data_long$tile[i],]$measure
}

#new_data_long <- new_data_long[!(new_data_long$measure > 40 & new_data_long$analog_val > 0.485),]
new_data_long <- new_data_long[2:nrow(new_data_long),]
new_data_long <- na.omit(new_data_long)
export_data <- data.frame(
  read = new_data_long$val,
  measure = new_data_long$measure,
  tile = new_data_long$tile
)

write.csv(export_data, "calibrate/export_data.csv", row.names=FALSE, quote = F)

new_data_long$analog_val <- analog_calc(new_data_long$val)
lm_l <- lm(measure ~ analog_val, data = new_data_long[new_data_long$tile == "L",])
summary(lm_l)
lm_m <- lm(measure ~ analog_val, data = new_data_long[new_data_long$tile == "M",])
summary(lm_m)
lm_r <- lm(measure ~ analog_val, data = new_data_long[new_data_long$tile == "R",])
summary(lm_r)

ggplot(data = new_data_long, aes(x = val, y = measure, color = tile)) +
  geom_point(alpha = 0.05)



library(Hmisc)
precision <- 100
max <- 1
n_k <- 5
x_values <- seq(0, max, length.out = precision)
knots <- seq(0.05*max, 0.95*max, length.out = n_k)
xx <- rcspline.eval(x_values, knots = knots, inclx = T)
zero <- rep(1, precision)
xx <- cbind(zero,xx)
# parametersL <- c(80.8773, -93.5178, 0.418203, 25.94, 23.1023)
# parametersM <- c(83.1577, -97.4657, -0.041277, 31.2212, 21.8266)
# parametersR <- c(83.628, -98.3216, 0.0269609, 29.0856, 26.5983)
parametersL <- c(86.4084, -107.371, -3.69321, 127.656, -393.183)
parametersM <- c(89.0889, -111.768, -7.23342, 144.546, -411.263)
parametersR <- c(90.8136, -116.597, -3.05034, 154.133, -501.815)

yL <- xx%*%parametersL
yM <- xx%*%parametersM
yR <- xx%*%parametersR

calc <- data.frame(
  x = x_values,
  y = c(yL, yM, yR),
  tile = c(rep("L", precision), rep("M", precision), rep("R", precision))
)

ggplot(calc, aes(x = x, y = y)) +
  geom_point(data = new_data_long, aes(x = analog_val, y = measure)) +
  geom_line(color = "red")

ggplot(data = new_data_long, aes(x = analog_val, y = measure, color = tile)) +
  geom_point(alpha = 0.05) +
  geom_line(data = calc, aes(x = x, y = y, color = tile)) +
  xlim(0.25, 0.8) +
  ylim(13, 53)


# infrared thermo3 ---------------------------------------------------------

data <- read.csv("infrared thermo 3/arena_data.csv")
plot(data$L_target)
data$index <- NA
index <- 1

for(i in 1:(nrow(data)-1)){
  if(data$L_target[i] <= data$L_target[i+1]){
    data$index[i] <- index
  } else{
    index <- index + 1
    data$index[i] <- index
  }
}
plot(data$index)
summary(data$index)
indexed <- data
data <- indexed[indexed$index == 3,]
plot(data$index)
plot(data$L_target)
data <- data[data$L_target > 14,]
unique(data$index)
# l_data <- data[data$index == 1,]
# m_data <- data[data$index == 4,]
# r_data <- data[data$index == 7,]

new_data_long <- data.frame(
  val = c(data$L_val, data$M_val, data$R_val),
  target = c(data$L_target, data$M_target, data$R_target),
  measure = NA,
  tile = c(rep("L", nrow(data)), rep("M", nrow(data)), rep("R", nrow(data)))
)

mea <- read.csv("infrared thermo 3/Temp heatbox 031121_2.csv")

for(i in 1:nrow(new_data_long)){
  new_data_long$measure[i] <- mea[mea$temp == new_data_long$target[i] &
                                    mea$tile == new_data_long$tile[i],]$measure
}

new_data_long <- na.omit(new_data_long)
export_data <- data.frame(
  read = new_data_long$val,
  measure = new_data_long$measure,
  tile = new_data_long$tile
)
write.csv(export_data, "calibrate/export_data2.csv", row.names=FALSE, quote = F)

previous <- read.csv("calibrate/export_data1.csv")
export_data <- rbind(export_data, previous)
#different name to append to the previoous one
write.csv(export_data, "calibrate/export_data.csv", row.names=FALSE, quote = F)

new_data_long$analog_val <- analog_calc(new_data_long$val)
lm_l <- lm(measure ~ analog_val, data = new_data_long[new_data_long$tile == "L",])
summary(lm_l)
lm_m <- lm(measure ~ analog_val, data = new_data_long[new_data_long$tile == "M",])
summary(lm_m)
lm_r <- lm(measure ~ analog_val, data = new_data_long[new_data_long$tile == "R",])
summary(lm_r)

ggplot(data = new_data_long, aes(x = val, y = measure, color = tile)) +
  geom_point(alpha = 0.05)



library(Hmisc)
precision <- 100
max <- 1
n_k <- 5
x_values <- seq(0, max, length.out = precision)
knots <- seq(0.05*max, 0.95*max, length.out = n_k)
xx <- rcspline.eval(x_values, knots = knots, inclx = T)
zero <- rep(1, precision)
xx <- cbind(zero,xx)
parametersL <- c(82.4619, -96.779, -4.99532, 44.9481, 2.93922)
parametersM <- c(84.0365, -99.5785, -3.0657, 42.1866, -7.10719)
parametersR <- c(84.2078, -100.44, -0.953949, 39.9038, 3.18809)

yL <- xx%*%parametersL
yM <- xx%*%parametersM
yR <- xx%*%parametersR

calc <- data.frame(
  x = x_values,
  y = c(yL, yM, yR),
  tile = c(rep("L", precision), rep("M", precision), rep("R", precision))
)

ggplot(calc, aes(x = x, y = y)) +
  geom_point(data = new_data_long, aes(x = analog_val, y = measure)) +
  geom_line(color = "red")

ggplot(data = new_data_long, aes(x = analog_val, y = measure, color = tile)) +
  geom_point(alpha = 0.05) +
  geom_line(data = calc, aes(x = x, y = y, color = tile)) +
  xlim(0.25, 0.8) +
  ylim(14, 55)


# lighting calibration ----------------------------------------------------


data <- read.csv("lighting calibration/arena_data.csv")
plot(data$L_target)
data$index <- NA
index <- 1

for(i in 1:(nrow(data)-1)){
  if(data$L_target[i] <= data$L_target[i+1]){
    data$index[i] <- index
  } else{
    index <- index + 1
    data$index[i] <- index
  }
}
plot(data$index)
summary(data$index)
indexed <- data
data <- indexed[indexed$index == 4,]
plot(data$index)
plot(data$L_target)
data <- data[data$L_target > 14,]
data <- data[2:nrow(data),]
unique(data$index)
# l_data <- data[data$index == 1,]
# m_data <- data[data$index == 4,]
# r_data <- data[data$index == 7,]

new_data_long <- data.frame(
  val = c(data$L_val, data$M_val, data$R_val),
  target = c(data$L_target, data$M_target, data$R_target),
  measure = NA,
  tile = c(rep("L", nrow(data)), rep("M", nrow(data)), rep("R", nrow(data)))
)

mea <- read.csv("lighting calibration/Temp heatbox 111121.csv")

for(i in 1:nrow(new_data_long)){
  new_data_long$measure[i] <- mea[mea$temp == new_data_long$target[i] &
                                    mea$tile == new_data_long$tile[i],]$measure
}

new_data_long <- na.omit(new_data_long)
export_data <- data.frame(
  read = new_data_long$val,
  measure = new_data_long$measure,
  tile = new_data_long$tile
)
write.csv(export_data, "calibrate/export_data.csv", row.names=FALSE, quote = F)

previous <- read.csv("calibrate/export_data1.csv")
export_data <- rbind(export_data, previous)
#different name to append to the previoous one
write.csv(export_data, "calibrate/export_data.csv", row.names=FALSE, quote = F)

new_data_long$analog_val <- analog_calc(new_data_long$val)
lm_l <- lm(measure ~ analog_val, data = new_data_long[new_data_long$tile == "L",])
summary(lm_l)
lm_m <- lm(measure ~ analog_val, data = new_data_long[new_data_long$tile == "M",])
summary(lm_m)
lm_r <- lm(measure ~ analog_val, data = new_data_long[new_data_long$tile == "R",])
summary(lm_r)

ggplot(data = new_data_long, aes(x = val, y = measure, color = tile)) +
  geom_point(alpha = 0.05)



library(Hmisc)
precision <- 100
max <- 1
n_k <- 5
x_values <- seq(0, max, length.out = precision)
knots <- seq(0.05*max, 0.95*max, length.out = n_k)
xx <- rcspline.eval(x_values, knots = knots, inclx = T)
zero <- rep(1, precision)
xx <- cbind(zero,xx)
parametersL <- c(90.5645, -110.825, -11.1511, 138.974, -380.393)
parametersM <- c(90.6486, -112.128, -10.443, 145.702, -432.13)
parametersR <- c(91.4241, -115.468, -2.89886, 145.405, -511.608)

yL <- xx%*%parametersL
yM <- xx%*%parametersM
yR <- xx%*%parametersR

calc <- data.frame(
  x = x_values,
  y = c(yL, yM, yR),
  tile = c(rep("L", precision), rep("M", precision), rep("R", precision))
)

ggplot(calc, aes(x = x, y = y)) +
  geom_point(data = new_data_long, aes(x = analog_val, y = measure)) +
  geom_line(color = "red")

ggplot(data = new_data_long, aes(x = analog_val, y = measure, color = tile)) +
  geom_point(alpha = 0.05) +
  geom_line(data = calc, aes(x = x, y = y, color = tile)) +
  xlim(0.25, 0.8) +
  ylim(14, 55)
