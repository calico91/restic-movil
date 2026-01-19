---
applyTo: '**'
---
# Entorno
Flutter: 3.38.6 (Channel Stable)
Dart: >=3.0.0 <4.0.0
Manejo de Estado: GetX (usando GetX Pattern)
Formularios: reactive_forms

# Dependencias a Implementar (Usar últimas versiones estables)
dependencies:
  # Core
  get:                      # Gestor de estado y rutas
  dio:                      # Cliente HTTP poderoso
  flutter_secure_storage:   # Almacenamiento seguro (Tokens)
  
  # Utilidades
  logger:                   # Logs limpios y formateados
  intl:                     # Formato de fechas y números
  flutter_dotenv:           # Variables de entorno (.env)
  
  # UI/UX
  google_fonts:             # Tipografías (opcional pero recomendado)
  cached_network_image:     # Carga eficiente de imágenes (opcional)

dev_dependencies:
  flutter_lints:            # Reglas de linting oficiales
  flutter_test:
    sdk: flutter
  build_runner:             # Para generación de código (si se requiere)

# Estructura de Directorios (Clean Architecture + GetX Pattern)
lib/
├── app/
│   ├── bindings/            # Bindings Globales (ej. InitialBinding)
│   ├── data/
│   │   ├── models/          # Modelos de datos (fromJson/toJson)
│   │   ├── providers/       # API Clients (Dio setup, Interceptors)
│   │   ├── repositories/    # Contratos e Implementaciones de Repositorios
│   │   └── services/        # Servicios persistentes (AuthService, StorageService)
│   ├── modules/             # Pantallas (Features)
│   │   ├── auth/            # Módulo de Autenticación
│   │   │   ├── bindings/    # Inyección de dependencias del módulo
│   │   │   ├── controllers/ # Lógica de negocio de la vista
│   │   │   └── views/       # Widgets de pantalla principal 
│   │   └── home/
│   └── routes/
│       ├── app_pages.dart   # Mapa de rutas (GetPage)
│       └── app_routes.dart  # Constantes de rutas (Strings)
├── core/
│   ├── config/              # Configuración de entorno (Environment)
│   ├── theme/               # Estilos, Colores, AppTheme
│   ├── utils/               # Validadores, Helpers, Extensiones
│   └── values/              # Assets paths, Strings constantes
└── main.dart

# Consumo de servicios en controller (GetX Pattern)
Evitar variables booleanas de loading (ej. isLoading). Usar el siguiente patrón para llamadas asíncronas con feedback visual:

  Get.showOverlay(
        loadingWidget: LoadingCharging(),
        asyncFunction: () async {
          // Lógica asíncrona aquí
        },
      );

# UI/UX Rules
1. **Scaffold**: Todas las pantallas deben usar `CustomScaffold`. Este widget implementa automáticamente:
   - El `CustomAppBar` transparente.
   - El fondo con gradiente (Rojo a Azul).
   - El contenedor blanco principal con bordes redondeados.
   - Soporte para Drawer, BottomNavigationBar y botón de "Atrás".
   - Se debe importar desde `package:restic_movil/core/utils/widgets/custom_scaffold.dart`.
2. **Estructura de la Vista**: Mantener el método `build` limpio, pasando el contenido principal al parámetro `body` del `CustomScaffold`.
3. **Secciones Expandibles**: Para mostrar información detallada que puede ocupar mucho espacio (ej. listas, grids), usar el widget `ExpandableSection`. 
   - Se debe importar desde `package:restic_movil/core/utils/widgets/expandable_section.dart`.

# Reglas de Desarrollo
1. **Nombramiento**: Usa `snake_case` para archivos y carpetas, `CamelCase` para clases.
2. **Inyección de Dependencias**: Usa `Get.lazyPut` en los `Bindings` para optimizar memoria.
3. **Manejo de Errores**: Implementa bloques `try-catch` en los `Repositories` y devuelve errores procesados o excepciones personalizadas.
4. **Imports**: Prefiere imports absolutos `package:restic_movil/...` sobre relativos `../../`.
5. **Assets**: Coloca imágenes en `assets/images` e iconos en `assets/icons`.
6. **Decalaracion de Variables**: Usa `final` y `const` siempre que sea posible para inmutabilidad y declara el tipo de la variable.
7. **EndPoints**: Mantener centralizados los path de los servicios en `lib/app/data/http/url_paths.dart`.

# Configuración Adicional
- Crear archivo `.env` en la raíz para URLs y Keys.
- Configurar `analysis_options.yaml` para ser estricto con los lints.