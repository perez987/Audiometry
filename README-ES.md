# Audiometry

![Platform](https://img.shields.io/badge/macOS-13+-orange.svg)
![Swift](https://img.shields.io/badge/Swift-5-color=9494ff.svg)
![Xcode](https://img.shields.io/badge/Xcode-15.2+-lavender.svg)

<a href="README.md">
    <img src="https://img.shields.io/badge/English-README-blue" alt=“English README”>
</a><br><br>

## Aplicación para macOS 13+

<img src="Images/Main-window-dual.png" width="640px">

Si bien esta aplicación es válida para el uso diario, es más un ejercicio para aprender SwiftUI y el almacenamiento persistente de datos. Considéralo una forma de practicar SwiftUI con una aplicación funcional que puedes modificar a tu gusto.

## Resumen

- Proyecto Xcode 15.2
- Aplicación compatible con macOS 13+
- Características:
	- Entrada de datos de pacientes y de pruebas audiométricas
	- Cálculos de evaluación de pérdida auditiva
	- Incluye índices SAL y ELI con visualización de resultados
	- Sistema de almacenamiento dual: CoreData y SwiftUI (alternar entre ellos)
	- Sistema de idiomas con inglés y español
	- Botones para navegar entre los pacientes guardados
	- Botón de búsqueda
	- Imprimir informe del paciente actual
	- Datos de muestra para tener a los pacientes ya en la primera ejecución.

## Implementación de almacenamiento dual

La aplicación admite dos mecanismos de almacenamiento diferentes entre los que se puede alternar:

1. Almacenamiento CoreData: Framework tradicional de Apple con base de datos SQLite
2. Almacenamiento SwiftUI: Enfoque nativo de SwiftUI con archivos JSON

Un control segmentado en la parte superior de la ventana permite alternar entre los modos de almacenamiento. Cada sistema de almacenamiento mantiene sus propios datos.

La implementación de Almacenamiento SwiftUI junto con Almacenamiento CoreData permite a los usuarios comparar ambos enfoques en paralelo. Se puede alternar entre ambos métodos de almacenamiento para conocerlos y evaluar cuál se adapta mejor a las necesidades.

## Almacenamiento SwiftUI

La aplicación de la rama `swiftui` implementa únicamente el sistema de almacenamiento SwiftUI.

## Datos guardados

Los datos del paciente se guardan en diferentes archivos según el modo de almacenamiento:

**Almacenamiento CoreData**

`/Users/<nombre_usuario>/Library/Containers/perez987.Audiometry/Data/Library/Application Support/Audiometry/DataModel.sqlite`

**Almacenamiento SwiftUI**

`/Users/<nombre_usuario>/Library/Containers/perez987.Audiometry/Data/Library/Application Support/Audiometry/patients.json`

Puede trasladar sus datos guardados copiando esos archivos (base de datos SQLite y archivo JSON) a otro equipo y ejecutando la aplicación Audiometry.

## Información ampliada sobre las funciones

### 🌐 Idiomas disponibles

- **Interfaz bilingüe**: Cambia entre inglés y español
- **Clasificaciones localizadas**: Clasificaciones de pérdida auditiva en ambos idiomas
- **Traducción completa de la interfaz**: Todos los elementos de la interfaz son compatibles con ambos idiomas.

### 💾 Gestión de datos de pacientes

- **Integración de datos centrales**: Almacenamiento persistente de historiales de pacientes
- **Botón Guardar**: Los datos del paciente se guardan. Al guardarlos, los pacientes se ordenan por nombre.
- **Navegación de pacientes**: Explora los pacientes guardados con los botones Anterior/Siguiente.
- **Creación de nuevos pacientes**: Crea fácilmente nuevos pacientes.

### 🔍 Búsqueda y navegación

- **Búsqueda de pacientes**: Busca pacientes por nombre con una interfaz de búsqueda dedicada.
- **Contador de pacientes**: Muestra la posición actual en la lista de pacientes (p. ej., "1 / 3").
- **Acceso rápido**: Barra de navegación con todas las funciones esenciales.

### 🏥 Experiencia de usuario

- **Flujo de trabajo optimizado**: Todas las funciones de gestión de pacientes en la barra de navegación superior
- **Funcionalidad preservada**: Se conservan todos los cálculos de audiometría originales
- **Diseño para macOS**: Interfaz nativa de macOS que sigue las directrices de diseño de Apple.
