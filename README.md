# Proyecto de Ingeniería de Datos: Análisis Histórico WW2

Este repositorio contiene la arquitectura de transformación de datos mediante **dbt (data build tool)** para el análisis histórico del conflicto de la Segunda Guerra Mundial. El proyecto implementa una arquitectura de datos moderna basada en el **modelo Medallón**, integrando datos provenientes de fuentes heterogéneas para alimentar un sistema de Inteligencia de Negocio avanzado.

![Arquitectura de Datos](https://www.databricks.com/wp-content/uploads/2021/06/Medallion-Architecture.png)

## Arquitectura del Proyecto

El sistema se estructura en tres capas lógicas implementadas sobre **Snowflake**, gestionadas íntegramente mediante **dbt**:

1.  **Capa Bronze (Raw):** Ingesta de datos crudos sin transformaciones, actuando como el repositorio de datos de origen.
2.  **Capa Silver (Staging & Intermediate):** Procesamiento, limpieza y estandarización. Se aplican técnicas de modelado para asegurar la calidad, manejo de nulos y estandarización de esquemas.
3.  **Capa Gold (Marts):** Modelado final siguiendo la metodología **Kimball (Star Schema)**. Los datos se presentan en tablas de hechos (`fct`) y dimensiones (`dim`) optimizadas para el consumo en herramientas de visualización.

## Stack Tecnológico

* **Almacenamiento y Cómputo:** Snowflake (Cloud Data Warehouse).
* **Orquestación y Transformación:** dbt Cloud.
* **Visualización:** Power BI (conectado mediante el modelo dimensional de la capa Gold).

## Aspectos Técnicos Relevantes

* **Modelado Dimensional:** Implementación de un modelo en estrella para maximizar el rendimiento analítico en herramientas de BI.
* **Calidad de Datos:** Integración de pruebas automatizadas (tests de unicidad, nulidad e integridad referencial) ejecutadas en cada ciclo de transformación para garantizar la fiabilidad del dato.
* **Gestión de Identidad:** Uso de claves subrogadas (Hashes MD5) para garantizar la trazabilidad y unicidad de los registros a través de los diferentes entornos (DEV, PRE, PRO).
* **Gobernanza:** Documentación automatizada y linaje de datos (`dbt docs`), incluyendo el mapeo de dependencias hacia los dashboards de consumo final (Exposures).

## Estructura del Repositorio

```text
├── models/
│   ├── staging/        # Modelos base y limpieza inicial
│   │    └──            # Carpetas para cada vista `stg` con su modelo y sql
│   ├── intermediate/   # Lógica de negocio y cruces complejos
│   │    └──            # Carpetas para cada tabla `int` con su modelo y sql
│   └── marts/          # Modelos finales (Hechos y Dimensiones)
│        └──            # Carpetas para cada tabla `dim` y `fct` con su modelo y sql
├── seeds/              # Archivos CSV para mapeo de datos maestros
└── dbt_project.yml     # Configuración del proyecto y entornos
