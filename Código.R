require(readxl)
require(magrittr)
require(dplyr)
require(tidyverse)
require(lmtest)
require(tseries)
require(forecast)
require(TSstudio)
require(janitor)
require(lubridate)
require(astsa)
require(lmtest)

rm(list=ls())
###########################-----------------juguetes----------------########################
data<-read_excel("Impo_mensual_cap_arancel_ago22.xlsx",skip=7,range = cell_rows(308:319),col_names = FALSE)

data %<>% clean_names()  #limpiar el nombre de las variables 

data %>%  head()

values<- data[c(3:18)]
values %<>% 
  select(x18,x17,x16,x15,x14,x13,x12,x11,x10,x9,x8,x7,x6,
         x5,x4,x3)
values<- as.vector(as.matrix(values))


#eliminar ls valores faltantes 
values %<>% na.omit() 
head(values)

#crear una secuencia de fechas, de acuerdo a los años de regristro
date<-seq(as.Date("2007/1/1"),as.Date("2022/8/1"),"months")

toys<-data.frame(values,date)

#¿ Convirtiendo a objeto ts, con los valores y las fechas de interes, con una frecuencia mensual
ts_toys <- ts(values, start =c(2007,01),
              end=c(2022,08), frequency = 12)

ts_info(ts_toys)
ts_toys %>% head()
ts_toys %>%  tail()

ts_toys_plot<-ts_plot(ts_toys,
                      title = " Serie de tiempo de importación de juguetes",
                      Xtitle = "Año",
                      Ytitle = "Número de juguetes ",
                      #slider = TRUE,
                      Xgrid = TRUE,
                      Ygrid = TRUE,
                      color = "blue"
)

ts_toys_plot 

des<-decompose(ts_toys)
plot(des)

### FUNCTION TRAIN_MODEL ###
### SE REALIZA CON 6 PREDICCIONES PARA EL TEST


methods <- list(hw = list(method = "HoltWinters",
                          method_arg = NULL,
                          notes = "HoltWinters Model"),
                autoarima_bic = list(method="auto.arima",
                                 method_arg = list(stepwise = FALSE,
                                                   approximation = FALSE,
                                                   ic = "bic"),
                                 notes= "Auto arima BIC"),
                ets1 = list(method = "ets",
                            method_arg = list(opt.crit = "mse"),
                            notes = "ETS model with opt.crit = mse"),
                tslm = list(method = "tslm",
                            method_arg = list(formula = input ~ trend+ season),
                            notes = "tslm model with trend and seasonal components"))



md <- suppressWarnings(train_model(input = ts_toys,
                                   methods = methods,
                                   train_method = list(partitions = 3, 
                                                       sample.out = 6, 
                                                       space = 5),
                                   horizon = 6,
                                   error = "MAPE"))

plot_model(md)
plot_error(md)


md$leaderboard

md$train$partition_1
md$train$partition_2
md$train$partition_3

md$error_summary$autoarima_bic

md$forecast$autoarima_bic$model

coeftest(md$forecast$autoarima_bic$model)

check<-checkresiduals(md$forecast$autoarima_bic$model)
check$p.value

qqnorm(md$forecast$autoarima_bic$model$residuals)
qqline(md$forecast$autoarima_bic$model$residuals)
shapiro.test(md$forecast$autoarima_bic$model$residuals)

md$forecast$autoarima_bic$forecast


plot_forecast(md$forecast$autoarima_bic$forecast)
#plot(md$forecast$autoarima_bic$forecast)

##### LOG
methods_1 <- list(autoarima_bic = list(method="auto.arima",
                                       method_arg = list(stepwise = FALSE,
                                                         approximation = FALSE,
                                                         ic = "bic"),
                                                         notes= "Auto arima BIC"))



md1 <- suppressWarnings(train_model(input = log(ts_toys),
                                   methods = methods_1,
                                   train_method = list(partitions = 3, 
                                                       sample.out = 6, 
                                                       space = 5),
                                   horizon = 6,
                                   error = "MAPE"))
md1

checkresiduals(md1$forecast$autoarima_bic$model)
qqnorm(md1$forecast$autoarima_bic$model$residuals)
qqline(md1$forecast$autoarima_bic$model$residuals)
shapiro.test(md1$forecast$autoarima_bic$model$residuals)

md1$forecast$autoarima_bic$forecast

plot(md1$forecast$autoarima_bic$forecast)



##########################################
md$error_summary$autoarima_bic
md$forecast$autoarima_base$model
md$forecast$hw$model
md$forecast$tslm$model

md$train$partition_1$autoarima_bic$forecast
md$train$partition_2$autoarima_bic$forecast
md$train$partition_3$autoarima_bic$forecast

md$train$partition_1
md$train$partition_2
md$train$partition_3

