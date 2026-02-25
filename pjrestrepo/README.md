# Peer Assessment App — Propuesta de Aplicación

## Autor

[Tu Nombre]

## Proyecto

Mobile Development Project — Peer Assessment App

---

## 1. Descripción General

**Peer Assessment App** es una aplicación móvil desarrollada en Flutter que permite evaluar el desempeño y compromiso de estudiantes en actividades colaborativas dentro de cursos universitarios.

El sistema facilita la evaluación entre pares en trabajos grupales, proporcionando herramientas para gestionar cursos, grupos, actividades de evaluación y análisis de resultados. La aplicación promueve la responsabilidad individual, la transparencia en el trabajo colaborativo y el seguimiento del desempeño académico.

La solución contempla dos tipos de usuarios: profesores y estudiantes, con funcionalidades diferenciadas según su rol.

---

## 2. Referentes Analizados

### Google Classroom

* Gestión de cursos y estudiantes.
* Organización clara de actividades académicas.
* Flujo de interacción profesor–estudiante simple e intuitivo.

### Moodle

* Sistema estructurado de evaluaciones.
* Gestión avanzada de usuarios y roles.
* Seguimiento detallado del desempeño.

### Peergrade / Sistemas de Peer Assessment

* Evaluación entre pares estructurada.
* Retroalimentación entre estudiantes.
* Visualización de resultados y métricas.

Estos referentes evidencian la importancia de sistemas de evaluación colaborativa con retroalimentación estructurada y análisis de desempeño.

---

## 3. Arquitectura y Diseño de la Solución

### Arquitectura propuesta

La aplicación sigue principios de **Clean Architecture** para garantizar escalabilidad, mantenibilidad y separación de responsabilidades.

**Capas del sistema:**

* Presentation Layer: interfaz de usuario y manejo de interacción.
* Domain Layer: lógica de negocio y reglas del sistema.
* Data Layer: servicios externos, almacenamiento y persistencia.

### Gestión de estado

* GetX para manejo de estado, navegación e inyección de dependencias.

### Configuración del sistema

* Aplicación única con soporte de roles.
* Autenticación segura.
* Almacenamiento remoto de datos.
* Importación de grupos desde plataforma externa.

---

## 4. Funcionalidades Principales

### Profesor

* Crear y gestionar cursos.
* Invitar estudiantes mediante acceso privado o verificación.
* Importar grupos desde sistema externo.
* Crear actividades de evaluación.
* Definir visibilidad de resultados (públicos o privados).
* Visualizar métricas de desempeño.
* Consultar resultados detallados por estudiante y grupo.

### Estudiante

* Unirse a cursos.
* Visualizar grupo de trabajo.
* Evaluar a sus compañeros (sin autoevaluación).
* Consultar resultados de evaluaciones.
* Revisar historial de actividades.

---

## 5. Criterios de Evaluación

Cada estudiante es evaluado según los siguientes criterios:

* Puntualidad
* Contribuciones
* Compromiso
* Actitud

### Escala de evaluación

| Nivel | Descripción       |
| ----- | ----------------- |
| 2.0   | Needs Improvement |
| 3.0   | Adequate          |
| 4.0   | Good              |
| 5.0   | Excellent         |

No se permite autoevaluación.

---

## 6. Flujo Funcional del Sistema

### Flujo general del sistema

1. El profesor crea un curso.
2. El profesor invita estudiantes al curso.
3. El sistema importa los grupos desde la plataforma externa.
4. El profesor crea una actividad de evaluación.
5. El profesor define duración y visibilidad de la evaluación.
6. Los estudiantes acceden a la evaluación activa.
7. Cada estudiante evalúa a sus compañeros de grupo.
8. El sistema almacena y procesa las calificaciones.
9. El sistema calcula promedios por actividad, grupo y estudiante.
10. Los resultados se muestran según la configuración de visibilidad.
11. El profesor analiza métricas y desempeño.

---

### Flujo de evaluación entre pares (estudiante)


1. El estudiante inicia sesión.<img width="507" height="898" alt="image" src="https://github.com/user-attachments/assets/614a0076-63b2-44a8-938d-1cec0a16bf95" />

2. Selecciona curso activo.
3. Accede a evaluación disponible.
4. Selecciona miembro del grupo.
5. Evalúa criterios:

   * Puntualidad
   * Contribuciones
   * Compromiso
   * Actitud
6. Confirma evaluación.
7. Sistema registra resultados.

---

### Flujo de creación de evaluación (profesor)

1. Profesor inicia sesión.
2. Selecciona curso.
3. Crea nueva evaluación.
4. Define:

   * nombre
   * duración
   * visibilidad
   * criterios
5. Publica evaluación.
6. Sistema habilita evaluación para estudiantes.

---

### Flujo de visualización de resultados

1. Sistema procesa evaluaciones.
2. Calcula promedios.
3. Genera métricas:

   * promedio por actividad
   * promedio por grupo
   * promedio por estudiante
4. Muestra resultados según configuración:

   * solo profesor
   * profesor y estudiantes

---

## 7. Diseño UX/UI

El diseño de la aplicación prioriza:

* Usabilidad y claridad visual.
* Navegación intuitiva.
* Retroalimentación inmediata al usuario.
* Visualización clara de métricas.
* Interfaz adaptable según rol.
* Accesibilidad y consistencia visual.

El sistema incluye:

* Pantallas de autenticación.
* Dashboard de usuario.
* Flujo guiado de evaluación.
* Gestión de cursos.
* Panel de resultados y analítica.

---

## 8. Justificación de la Propuesta

La solución responde a la necesidad de evaluar el trabajo colaborativo de forma objetiva y estructurada dentro de entornos educativos.

Beneficios de la propuesta:

* Mejora la responsabilidad individual.
* Permite evaluación objetiva del trabajo en equipo.
* Facilita análisis del desempeño académico.
* Reduce sesgos en evaluaciones grupales.
* Proporciona retroalimentación cuantificable.

Los referentes analizados y prácticas educativas actuales evidencian la importancia de herramientas digitales para evaluación colaborativa.

---

## 9. Prototipo en Figma

Link del prototipo:
[Agregar enlace aquí]

El prototipo incluye:

* Flujo de autenticación.
* Dashboard de usuario.
* Evaluación entre pares.
* Gestión de cursos.
* Panel de resultados.

---

## 10. Tecnologías

* Flutter
* GetX
* Clean Architecture
* Servicios de autenticación y almacenamiento remoto

---

## 11. Conclusión

Peer Assessment App propone una solución tecnológica para mejorar los procesos de evaluación en trabajo colaborativo, permitiendo medición objetiva del desempeño y facilitando el seguimiento académico en entornos educativos.
