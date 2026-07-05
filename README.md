# Título
## Impacto de los servicios prehospitalarios en la mortalidad y letalidad en accidentes de tránsito en Chile

Repositorio de organización, documentación y gestión del proyecto de investigación, creado en el marco de la actividad práctica de ciencia abierta del curso **Diseño y Gestión de Proyecto de Investigación** (Departamento de Salud Pública).

---

## Descripción del problema

Los siniestros de tránsito son una de las principales causas de mortalidad evitable en Chile y afectan de manera desproporcionada a personas en edad productiva. Chile cuenta con una red formal de atención prehospitalaria (APH) —central de llamados, regulación/triage, SAMU, SAPU/SUR y unidades de emergencia hospitalaria—, pero persiste una brecha crítica: **no se ha estimado con precisión el impacto real de estos servicios sobre los desenlaces clínicos** (sobrevida, mortalidad y letalidad) de las personas lesionadas, ni se han analizado de forma sistemática las **desigualdades territoriales** en tiempos de respuesta, cobertura, equipamiento y personal especializado.

El proyecto aborda esta brecha mediante un análisis cuantitativo con enfoque territorial, apoyado en el concepto de la "hora dorada", que vincula la oportunidad y calidad de la atención prehospitalaria con la sobrevida en trauma grave.

## Pregunta de investigación

¿Existen diferencias territoriales significativas en los tiempos de respuesta, cobertura y recursos de los servicios prehospitalarios, y cómo se relacionan estas diferencias con los desenlaces clínicos de mortalidad y letalidad de las personas accidentadas de tránsito en Chile?

## Objetivos

**General.** Analizar la asociación entre la oportunidad y la calidad de la atención prehospitalaria y los desenlaces clínicos (mortalidad y letalidad) en personas lesionadas en accidentes de tránsito en Chile, considerando las diferencias territoriales en la organización y el desempeño de estos servicios.

**Específicos.**
1. Describir las características de la atención prehospitalaria recibida por las víctimas de accidentes de tránsito en distintas regiones (tiempo de respuesta, tipo de personal, equipamiento y protocolos).
2. Estimar la asociación entre los tiempos de respuesta prehospitalaria y la mortalidad, diferenciando por localización geográfica y tipo de zona (urbana/rural).
3. Evaluar la relación entre los componentes de calidad del sistema prehospitalario (recursos humanos, procedimientos clínicos y capacidades operativas) y la letalidad de las lesiones.

**Hipótesis.** La variabilidad en los componentes del sistema de atención prehospitalaria (tiempo de respuesta, tipo de unidad enviada, categorización del trauma e intervenciones en terreno) se asocia de manera significativa con diferencias en los desenlaces clínicos, particularmente la sobrevida hospitalaria.

## Estado actual del proyecto

**Protocolo finalizado; en fase inicial de obtención y preparación de datos.**
El marco conceptual, el estado del arte, el problema, la pregunta, los objetivos y la hipótesis están definidos (ver protocolo en `docs/`). Actualmente se trabaja en la consolidación de la base a nivel de persona (siniestros 2014–2024) y en el diseño del plan de análisis. Aún no se han producido resultados ni manuscritos.

## Estructura del repositorio

```
.
├── README.md                     # Este archivo: presenta el proyecto y el repositorio
├── LICENSE                       # Licencia de uso del código y la documentación
├── .gitignore                    # Archivos y datos excluidos del control de versiones
├── docs/                         # Documentación del proyecto y de los datos
│   ├── plan_manejo_datos.pdf     # Plan de manejo y documentación de datos
│   └── diccionario_datos.xlsx    # Diccionario de datos de la base a nivel de persona
├── code/                         # Scripts de limpieza, procesamiento y análisis
│   ├── README.md                 # Descripción del flujo de scripts y su orden de ejecución
│   └── 01_preparacion_datos.R    # Ejemplo de script de preparación (plantilla reproducible)
├── outputs/                      # Resultados generados por el código (tablas, figuras, modelos)
└── manuscripts/                  # Borradores, protocolo y versiones del manuscrito
```


## Datos

- **Fuente principal:** base de datos de siniestros de tránsito registrada por Carabineros de Chile y procesada por la Comisión Nacional de Seguridad de Tránsito (CONASET), a nivel de persona, período 2014–2024 (`Personas 2014-2024.xlsx`).
- **Unidad de análisis:** la persona involucrada en un siniestro de tránsito.
- Las bases de datos con información individual **no se incluyen** en este repositorio. La documentación de su estructura está en `docs/diccionario_datos.xlsx` y su gestión en `docs/plan_manejo_datos.pdf`.


