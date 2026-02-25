


## Peer Assessment App – Evaluación Colaborativa

### Autor

Nombre: José Ferrer

Curso: Mobile Development

Proyecto: Peer Assessment App

Fecha: 2026

---

# 1. Problema Identificado

En los cursos universitarios donde se desarrollan actividades colaborativas, los docentes no tienen un mecanismo estructurado, transparente y cuantificable para evaluar el desempeño individual dentro de los equipos.

Actualmente:

* Los grupos se forman en Brightspace.
* No existe trazabilidad clara del desempeño individual.
* No hay métricas automáticas por estudiante, grupo o actividad.
* Las evaluaciones pueden ser subjetivas y poco estructuradas.

Esto genera:

* Injusticias en calificaciones.
* Baja responsabilidad individual.
* Falta de datos consolidados para toma de decisiones.

---

# 2. Referentes Analizados

### Brightspace (D2L)

* Gestión de grupos y categorías.
* No incluye evaluación estructurada entre pares con métricas avanzadas.

### Google Forms

* Permite evaluación entre pares.
* No genera métricas agregadas automáticas.
* No restringe autoevaluación automáticamente.

### Peergrade

* Sistema especializado en evaluación entre pares.
* Interfaz estructurada.
* Sin integración directa con Brightspace en contexto institucional.

---

# 3. Composición y Diseño de la Solución

## Arquitectura Propuesta

Se propone:

### Una sola aplicación Flutter con roles (Teacher / Student)

Justificación:

* Reduce duplicidad de código.
* Facilita mantenimiento.
* Centraliza autenticación.
* Mejor experiencia UX coherente.

---

## Arquitectura Técnica

Se implementará **Clean Architecture**:

### Presentation Layer

* GetX Controllers
* UI Screens
* Widgets

### Domain Layer

* Entities
* UseCases
* Repository Interfaces

### Data Layer

* Repository Implementations
* Remote Data Source (Roble)
* Local cache (si aplica)

---

## Gestión Técnica

* State Management: GetX
* Navigation: GetX routes
* Dependency Injection: GetX Bindings
* Auth & Storage: Roble
* Permisos: Location + Background

---

# 4. Flujo Funcional Detallado

## Teacher Flow

1. Login
2. Crear curso
3. Invitar estudiantes (token privado / código verificación)
4. Importar grupos desde Brightspace
5. Crear evaluación:

   * Nombre
   * Ventana de tiempo
   * Categoría
   * Visibilidad (Public / Private)
6. Activar evaluación
7. Visualizar métricas:

   * Promedio actividad
   * Promedio grupo
   * Promedio estudiante
   * Detalle por criterio

---

## Student Flow

1. Login
2. Unirse a curso
3. Ver evaluaciones activas
4. Evaluar compañeros (sin autoevaluación)
5. Enviar evaluación
6. Ver resultados (si son públicos)

---

# 5. Modelo de Evaluación

Cada evaluación incluye:

* Nombre
* Duración
* Visibilidad (Pública / Privada)
* Categoría de grupo

### Criterios evaluados:

* Punctuality
* Contributions
* Commitment
* Attitude

Escala:
2.0 – Needs Improvement
3.0 – Adequate
4.0 – Good
5.0 – Excellent

No se permite autoevaluación.

---

# 6. Acceso a Resultados

### Teacher puede ver:

* Promedio por actividad
* Promedio por grupo
* Promedio por estudiante
* Detalle por criterio

### Student puede ver:

* Resultados si la evaluación es pública

---

# 7. Prototipo Figma

Enlace al prototipo:
[(Figma)](https://www.figma.com/make/0uZ0VbrH1lQeuG6b2yE7T9/Peer-Assessment-App-UX-Flow?t=OlXwS1pFtGwFbZoW-1)

Incluye:

* Login
* Dashboard Teacher
* Dashboard Student
* Crear evaluación
* Evaluar compañeros
* Vista de métricas
* Resultados públicos

---

# 8. Justificación del Modelo

La solución:

* Aumenta responsabilidad individual.
* Genera métricas objetivas.
* Permite análisis longitudinal.
* Mejora justicia en calificación.
* Se integra con Brightspace sin reemplazarlo.

---

# 9. Tecnologías

* Flutter
* GetX
* Roble
* Clean Architecture
* Brightspace API (importación grupos)

---

# 10. Posibles Extensiones Futuras

* Detección de sesgo en evaluación
* Algoritmo de ponderación por confiabilidad
* Reportes descargables PDF
* Dashboard avanzado con gráficas
* Integración directa LMS

---


