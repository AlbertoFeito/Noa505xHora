# Skill Registry - Proyecto 505XHORA

## Project Context
- **Tipo**: Qt/QML Desktop App (C++ backend + QML frontend)
- **Qt Version**: 6.9.3 (MinGW 64-bit)
- **Framework**: Qt Quick + Qt SQL + CMake
- **Arquitectura**: Context Properties con AppController como coordinator

## PC Configuration (Guerra)

| Componente | Ruta |
|------------|------|
| Qt Core | `C:\Qt6\6.9.3\mingw_64` |
| Compiler | `C:\Qt6\Tools\mingw1310_64` |
| CMake | `C:\Qt6\Tools\CMake_64` |
| Qt IFW | `C:\Qt6\Tools\QtIFW\4.4.1` |
| **WebAssembly** | `C:\Qt6\6.9.3\wasm_singlethread` |
| **Emsdk** | `D:\instaladores\emsdk` |
| **Android SDK** | `D:\instaladores\android\androidqt6.9` |
| **Android NDK** | `D:\instaladores\android\androidqt6.9\ndk\27.2.12479018` |
| **Android Platforms** | `android-31, 34, 35, 36` |

## Build Commands
```batch
:: Debug
cmake -B build -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH=C:/Qt6/6.9.3/mingw_64
cmake --build build --parallel

:: Release
cmake -B build -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH=C:/Qt6/6.9.3/mingw_64 -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
```

## Project Structure
```
505XHORA/
├── main.cpp                    # Entry point, registra Theme singleton, expone managers
├── CMakeLists.txt              # CMake config con include_directories
├── src/
│   ├── controllers/            # AppController (coordinador)
│   ├── database/               # DatabaseManager
│   ├── models/                 # User, Product, Sale, Inventory (QAbstractListModel)
│   ├── services/              # InventoryService, ReportService
│   └── utils/                  # Constants, RoleEnums
└── qml/                       # UI layer
    ├── Theme.qml              # Singleton para theming
    ├── common/                # CustomTextField, CustomButton, CustomCard, NavigationBar
    ├── pages/                 # LoginPage, DashboardPage, ProfilePage
    ├── modules/               # admin, commercial, warehouse, messenger, custody
    └── dialogs/               # ConfirmDialog, CuadreFinalDialog
```

## Key Learnings

### CMake
- Agregar `include_directories(${CMAKE_SOURCE_DIR})` para permitir `#include "src/..."`

### C++/QML Integration
- Theme como singleton: `pragma Singleton` en QML + `qmlRegisterSingletonType` en main.cpp
- Managers como context properties: `engine.rootContext()->setContextProperty("UserManager", ...)`

### QML Patterns
- CustomTextField: label flotante estilo Material con toggle password
- Theme singleton accesible desde cualquier QML sin imports

### Deployment
- windeployqt para Windows: copia todos los Qt DLLs, plugins, QML, translations
- Deploy en build/deploy (~104 MB, 1345 archivos)

## Common Issues Fixed
1. QString::replace no es const - crear copia local
2. QRC prefix debe coincidir con la URL en main.cpp (ej. `/qml`)
3. Theme no se cargaba - usar singleton registration
4. CustomTextField warnings - importar Material y configurar estilo