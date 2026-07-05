library(tidyverse)
library(janitor)
library(gtsummary)
library(gt)
library(broom)
library(flextable)
library(officer)

attach(BaseACCdist)

base_comparacion <- BaseACCdist |> 
  filter(tipo_caso %in% c("Fatal", "Grave")) |> 
  mutate(
    tipo_caso = factor(tipo_caso, levels = c("Grave", "Fatal")),
    fatal_binario = if_else(tipo_caso == "Fatal", 1, 0),
    tramo_distancia = case_when(
      distancia_km < 2 ~ "<2 km",
      distancia_km >= 2 & distancia_km < 5 ~ "2 a 4,9 km",
      distancia_km >= 5 & distancia_km < 10 ~ "5 a 9,9 km",
      distancia_km >= 10 ~ "≥10 km",
      TRUE ~ NA_character_
    ),
    tramo_distancia = factor(
      tramo_distancia,
      levels = c("<2 km", "2 a 4,9 km", "5 a 9,9 km", "≥10 km")
    )
  )

tabla_1 <- base_comparacion |> 
  select(tipo_caso, distancia_km) |> 
  tbl_summary(
    by = tipo_caso,
    statistic = list(
      distancia_km ~ "{median} ({p25} - {p75})"
    ),
    digits = list(
      distancia_km ~ 2
    ),
    label = list(
      distancia_km ~ "Distancia al SAMU más cercano (km)"
    )
  ) |> 
  add_p(
    test = list(distancia_km ~ "wilcox.test")
  ) |> 
  modify_header(
    label ~ "**Variable**",
    stat_1 ~ "**Graves**",
    stat_2 ~ "**Fatales**",
    p.value ~ "**Valor p**"
  ) |> 
  modify_caption(
    "**Tabla 1. Distancia al centro SAMU más cercano según tipo de accidente**"
  ) |> 
  bold_labels()

tabla_modelo1 <- glm(
  fatal_binario ~ distancia_km,
  data = base_comparacion,
  family = binomial()
) |> 
  tbl_regression(
    exponentiate = TRUE,
    label = list(
      distancia_km ~ "Distancia al SAMU más cercano, por cada 1 km"
    )
  ) |> 
  modify_header(
    label ~ "**Variable**",
    estimate ~ "**OR**",
    ci ~ "**IC 95%**",
    p.value ~ "**Valor p**"
  ) |> 
  modify_caption(
    "**Tabla 2. Asociación entre distancia al SAMU más cercano y fatalidad del accidente**"
  ) |> 
  bold_labels()

tabla_modelo2 <- glm(
  fatal_binario ~ distancia_km + factor(ano),
  data = base_comparacion,
  family = binomial()
) |> 
  tbl_regression(
    exponentiate = TRUE,
    label = list(
      distancia_km ~ "Distancia al SAMU más cercano, por cada 1 km"
    )
  ) |> 
  modify_header(
    label ~ "**Variable**",
    estimate ~ "**OR ajustado**",
    ci ~ "**IC 95%**",
    p.value ~ "**Valor p**"
  ) |> 
  modify_caption(
    "**Tabla 3. Asociación ajustada entre distancia al SAMU más cercano y fatalidad del accidente**"
  ) |> 
  bold_labels()

tabla_tramos <- base_comparacion |> 
  select(tipo_caso, tramo_distancia) |> 
  tbl_cross(
    row = tramo_distancia,
    col = tipo_caso,
    percent = "row"
  ) |> 
  add_p(
    test = "chisq.test"
  ) |> 
  modify_header(
    label ~ "**Tramo de distancia al SAMU**",
    stat_1 ~ "**Graves**",
    stat_2 ~ "**Fatales**",
    p.value ~ "**Valor p**"
  ) |> 
  modify_caption(
    "**Tabla 4. Distribución de accidentes graves y fatales según tramo de distancia al SAMU más cercano**"
  ) |> 
  bold_labels()

tabla_modelo_tramos <- glm(
  fatal_binario ~ tramo_distancia + factor(ano),
  data = base_comparacion,
  family = binomial()
) |> 
  tbl_regression(
    exponentiate = TRUE,
    label = list(
      tramo_distancia ~ "Tramo de distancia al SAMU más cercano"
    )
  ) |> 
  modify_header(
    label ~ "**Variable**",
    estimate ~ "**OR ajustado**",
    ci ~ "**IC 95%**",
    p.value ~ "**Valor p**"
  ) |> 
  modify_caption(
    "**Tabla 5. Asociación entre tramos de distancia al SAMU y fatalidad del accidente**"
  ) |> 
  bold_labels()

tabla_1
tabla_modelo1
tabla_modelo2
tabla_tramos
tabla_modelo_tramos

#gráficos
ggplot(base_comparacion, aes(x = tipo_caso, y = distancia_km)) +
  geom_boxplot() +
  labs(
    x = "Tipo de accidente",
    y = "Distancia al SAMU más cercano (km)",
    title = "Distancia al SAMU más cercano según tipo de accidente"
  ) +
  theme_minimal()

#2
ggplot(base_comparacion, aes(x = distancia_km, fill = tipo_caso)) +
  geom_density(alpha = 0.4) +
  labs(
    x = "Distancia al SAMU más cercano (km)",
    y = "Densidad",
    fill = "Tipo de accidente",
    title = "Distribución de distancia al SAMU según tipo de accidente"
  ) +
  theme_minimal()

#wilconson unilateral

dist_fatal <- base_comparacion |> 
  filter(tipo_caso == "Fatal") |> 
  pull(distancia_km)

dist_grave <- base_comparacion |> 
  filter(tipo_caso == "Grave") |> 
  pull(distancia_km)

wilcox_unilateral <- wilcox.test(
  dist_fatal,
  dist_grave,
  alternative = "greater"
)

wilcox_unilateral

tabla_wilcox <- tibble(
  prueba = "Wilcoxon unilateral",
  hipotesis = "Distancia fatal > distancia grave",
  valor_p = wilcox_unilateral$p.value
) |> 
  gt() |> 
  tab_header(
    title = md("**Prueba de comparación de distancia al SAMU**"),
    subtitle = "Hipótesis: los accidentes fatales ocurren más lejos que los graves"
  ) |> 
  cols_label(
    prueba = "Prueba estadística",
    hipotesis = "Hipótesis evaluada",
    valor_p = "Valor p"
  ) |> 
  fmt_number(
    columns = valor_p,
    decimals = 4
  )

tabla_wilcox

#otros graficos
library(patchwork)
library(moments)

ggplot(base_comparacion, aes(x = distancia_km)) +
  geom_histogram(bins = 50, color = "white") +
  facet_wrap(~ tipo_caso, scales = "free_y") +
  labs(
    title = "Distribución de la distancia al SAMU según tipo de accidente",
    subtitle = "Comparación entre accidentes graves y fatales",
    x = "Distancia al SAMU más cercano (km)",
    y = "Frecuencia"
  ) +
  theme_minimal()

#boxplot
ggplot(base_comparacion, aes(x = tipo_caso, y = distancia_km)) +
  geom_boxplot() +
  labs(
    title = "Distancia al SAMU más cercano según tipo de accidente",
    subtitle = "Presencia de valores extremos y asimetría",
    x = "Tipo de accidente",
    y = "Distancia al SAMU más cercano (km)"
  ) +
  theme_minimal()

#qq plot
ggplot(base_comparacion, aes(sample = distancia_km)) +
  stat_qq() +
  stat_qq_line() +
  labs(
    title = "Q-Q plot de la distancia al SAMU más cercano",
    subtitle = "Evaluación visual de normalidad",
    x = "Cuantiles teóricos",
    y = "Cuantiles observados"
  ) +
  theme_minimal()

ggplot(base_comparacion, aes(sample = distancia_km)) +
  stat_qq() +
  stat_qq_line() +
  facet_wrap(~ tipo_caso) +
  labs(
    title = "Q-Q plot de distancia al SAMU según tipo de accidente",
    subtitle = "Evaluación de normalidad por grupo",
    x = "Cuantiles teóricos",
    y = "Cuantiles observados"
  ) +
  theme_minimal()

#asimetría numerica
base_comparacion |> 
  summarise(
    n = n(),
    media = mean(distancia_km, na.rm = TRUE),
    mediana = median(distancia_km, na.rm = TRUE),
    desviacion_estandar = sd(distancia_km, na.rm = TRUE),
    asimetria = skewness(distancia_km, na.rm = TRUE)
  )

library(scales)
limite_p95 <- quantile(base_comparacion$distancia_km, 0.95, na.rm = TRUE)

ggplot(base_comparacion, aes(x = tipo_caso, y = distancia_km, fill = tipo_caso)) +
  geom_boxplot(
    width = 0.55,
    alpha = 0.75,
    outlier.shape = NA
  ) +
  geom_jitter(
    width = 0.12,
    alpha = 0.08,
    size = 0.7
  ) +
  coord_cartesian(
    ylim = c(0, limite_p95)
  ) +
  labs(
    title = "Distancia al SAMU más cercano según tipo de accidente",
    subtitle = "Eje Y limitado al percentil 95 para mejorar la visualización",
    x = "",
    y = "Distancia al SAMU más cercano (km)",
    fill = "Tipo de accidente"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 12),
    axis.text.x = element_text(face = "bold", size = 13),
    axis.text.y = element_text(size = 11),
    axis.title.y = element_text(face = "bold", size = 12)
  )


#prueba box plot con log
ggplot(base_comparacion, aes(x = tipo_caso, y = distancia_km, fill = tipo_caso)) +
  geom_boxplot(
    width = 0.55,
    alpha = 0.75,
    outlier.alpha = 0.25
  ) +
  scale_y_log10(
    breaks = c(0.5, 1, 2, 5, 10, 20, 50),
    labels = c("0,5", "1", "2", "5", "10", "20", "50")
  ) +
  labs(
    title = "Distancia al SAMU más cercano según tipo de accidente",
    subtitle = "Escala logarítmica para representar mejor la distribución asimétrica",
    x = "",
    y = "Distancia al SAMU más cercano (km, escala log10)",
    fill = "Tipo de accidente"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 12),
    axis.text.x = element_text(face = "bold", size = 13),
    axis.text.y = element_text(size = 11),
    axis.title.y = element_text(face = "bold", size = 12)
  )

library(officer)
base_comparacion <- BaseACCdist |> 
  filter(tipo_caso %in% c("Fatal", "Grave")) |> 
  mutate(
    tipo_caso = factor(tipo_caso, levels = c("Grave", "Fatal")),
    ano = factor(ano),
    tramo_distancia = case_when(
      distancia_km < 2 ~ "<2 km",
      distancia_km >= 2 & distancia_km < 5 ~ "2 a 4,9 km",
      distancia_km >= 5 & distancia_km < 10 ~ "5 a 9,9 km",
      distancia_km >= 10 ~ "≥10 km",
      TRUE ~ NA_character_
    ),
    tramo_distancia = factor(
      tramo_distancia,
      levels = c("<2 km", "2 a 4,9 km", "5 a 9,9 km", "≥10 km")
    )
  )
tabla_descriptiva_base <- base_comparacion |> 
  select(
    tipo_caso,
    ano,
    distancia_km,
    tramo_distancia,
    samu_mas_cercano,
    samu_comuna,
    fatales,
    graves
  ) |> 
  tbl_summary(
    by = tipo_caso,
    statistic = list(
      all_continuous() ~ "{median} ({p25} - {p75})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    digits = list(
      all_continuous() ~ 2,
      all_categorical() ~ c(0, 1)
    ),
    label = list(
      ano ~ "Año del accidente",
      distancia_km ~ "Distancia al SAMU más cercano (km)",
      tramo_distancia ~ "Tramo de distancia al SAMU",
      samu_mas_cercano ~ "Centro SAMU más cercano",
      samu_comuna ~ "Comuna del centro SAMU más cercano",
      fatales ~ "Número de fallecidos registrados",
      graves ~ "Número de lesionados graves registrados"
    ),
    missing = "no"
  ) |> 
  add_overall(
    last = FALSE,
    col_label = "**Total**"
  ) |> 
  add_p(
    test = list(
      distancia_km ~ "wilcox.test",
      all_categorical() ~ "chisq.test"
    )
  ) |> 
  modify_header(
    label ~ "**Variable**",
    stat_0 ~ "**Total**",
    stat_1 ~ "**Graves**",
    stat_2 ~ "**Fatales**",
    p.value ~ "**Valor p**"
  ) |> 
  modify_caption(
    "**Tabla 1. Caracterización de accidentes graves y fatales incluidos en el análisis**"
  ) |> 
  bold_labels()

tabla_descriptiva_base

#segunda opcion
tabla_descriptiva_presentacion <- base_comparacion |> 
  select(
    tipo_caso,
    ano,
    distancia_km,
    tramo_distancia
  ) |> 
  tbl_summary(
    by = tipo_caso,
    statistic = list(
      distancia_km ~ "{median} ({p25} - {p75})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    digits = list(
      distancia_km ~ 2,
      all_categorical() ~ c(0, 1)
    ),
    label = list(
      ano ~ "Año del accidente",
      distancia_km ~ "Distancia al SAMU más cercano (km)",
      tramo_distancia ~ "Tramo de distancia al SAMU"
    ),
    missing = "no"
  ) |> 
  add_overall(
    last = FALSE,
    col_label = "**Total**"
  ) |> 
  add_p(
    test = list(
      distancia_km ~ "wilcox.test",
      all_categorical() ~ "chisq.test"
    )
  ) |> 
  modify_header(
    label ~ "**Variable**",
    stat_0 ~ "**Total**",
    stat_1 ~ "**Graves**",
    stat_2 ~ "**Fatales**",
    p.value ~ "**Valor p**"
  ) |> 
  modify_caption(
    "**Tabla 1. Descripción de la base de análisis según tipo de accidente**"
  ) |> 
  bold_labels()

tabla_descriptiva_presentacion

#segunda tabla
tabla_tramos_descriptiva <- base_comparacion |> 
  count(tipo_caso, tramo_distancia) |> 
  group_by(tipo_caso) |> 
  mutate(
    porcentaje = 100 * n / sum(n),
    resultado = paste0(n, " (", round(porcentaje, 1), "%)")
  ) |> 
  select(tramo_distancia, tipo_caso, resultado) |> 
  pivot_wider(
    names_from = tipo_caso,
    values_from = resultado
  ) |> 
  gt() |> 
  tab_header(
    title = md("**Distribución de accidentes según distancia al SAMU más cercano**"),
    subtitle = "Frecuencia y porcentaje dentro de cada tipo de accidente"
  ) |> 
  cols_label(
    tramo_distancia = "Tramo de distancia",
    Grave = "Graves",
    Fatal = "Fatales"
  ) |> 
  tab_source_note(
    source_note = "Porcentajes calculados dentro de cada grupo de accidente."
  )

tabla_tramos_descriptiva

#tabla compacta
tabla_resumen_manual <- base_comparacion |> 
  group_by(tipo_caso) |> 
  summarise(
    n = n(),
    distancia_media_km = mean(distancia_km, na.rm = TRUE),
    distancia_de_km = sd(distancia_km, na.rm = TRUE),
    distancia_mediana_km = median(distancia_km, na.rm = TRUE),
    distancia_p25_km = quantile(distancia_km, 0.25, na.rm = TRUE),
    distancia_p75_km = quantile(distancia_km, 0.75, na.rm = TRUE),
    distancia_min_km = min(distancia_km, na.rm = TRUE),
    distancia_max_km = max(distancia_km, na.rm = TRUE)
  ) |> 
  mutate(
    distancia_media_de = paste0(
      round(distancia_media_km, 2), " ± ", round(distancia_de_km, 2)
    ),
    distancia_mediana_riq = paste0(
      round(distancia_mediana_km, 2), " (",
      round(distancia_p25_km, 2), " - ",
      round(distancia_p75_km, 2), ")"
    ),
    rango = paste0(
      round(distancia_min_km, 2), " - ",
      round(distancia_max_km, 2)
    )
  ) |> 
  select(
    tipo_caso,
    n,
    distancia_media_de,
    distancia_mediana_riq,
    rango
  )

tabla_resumen_manual_gt <- tabla_resumen_manual |> 
  gt() |> 
  tab_header(
    title = md("**Descripción de la distancia al SAMU más cercano**"),
    subtitle = "Accidentes graves y fatales en la Región Metropolitana"
  ) |> 
  cols_label(
    tipo_caso = "Tipo de accidente",
    n = "N",
    distancia_media_de = "Media ± DE (km)",
    distancia_mediana_riq = "Mediana (P25 - P75) km",
    rango = "Rango km"
  ) |> 
  tab_source_note(
    source_note = "DE: desviación estándar. Distancia calculada en línea recta/geodésica."
  )

tabla_resumen_manual_gt
