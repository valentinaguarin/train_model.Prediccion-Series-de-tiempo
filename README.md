# train_model.Time-series
train_model es una función de R que nos permite entrenar, probar y comparar varios modelos de series temporales, usando una partición única (para dejar muestras fuera) o múltiples particiones (backtesting). Automatiza gran parte del proceso, permitiendo especificar parámetros de modelos, número de predicciones, etc. Es útil para explorar y seleccionar el mejor modelo, ahorrando tiempo y esfuerzo mientras se obtienen resultados comparativos sólidos.

## Modelos posibles:

- ets: modelo del paquete de forecast, el modelo ETS es un método de pronóstico univariado de series temporales; su uso se centra en los componentes de tendencia y estacionales.
-HoltWinters: modelo de suavizamiento exponencial del paquete de stats.
-nnetar: modelo del paquete de forecast (modelo de redes neuronales, se trata de un modelo no lineal autorregresivo).
-tslm: modelo de regresión del paquete de forecast.
