# AGENTS.md - 505 X HORA (Qt Desktop App)

**Stack**: Qt 6.9.3 + QML + C++ (CMake + MinGW)
**Project**: Sistema de gestión para micro-empresa de insumos/electrodomésticos

---

## Build & Run

```bash
# Build desde Qt505XHORA/
cd Qt505XHORA && mkdir -p build && cd build
cmake .. -G Ninja
cmake --build . --target appQt505XHORA

# Run (desde build/)
./appQt505XHORA.exe
```

## Tests

```bash
# Unit tests (CONSTANTS only - sin DB)
cmake --build . --target test_constants
./test_constants

# Integration tests (MANAGERS - requiere DB)
cmake --build . --target test_managers
./test_managers
```

---

## Architecture

```
Qt505XHORA/
├── main.cpp                    # Entry point, registra components
├── cpp/
│   ├── DatabaseManager         # SQLite wrapper
│   ├── AuthManager             # Autenticación
│   ├── ProductManager          # Catálogo productos
│   ├── SalesManager            # Ventas
│   ├── DeliveryManager         # Entregas/mensajeros
│   ├── FinanceManager          # Finanzas
│   └── AppConstantsQML         # Singleton para QML
├── components/                 # UI reutilizables (Theme, Button, Card, etc.)
└── pages/                      # Vistas (LoginPage, MenuPage)
```

**Entry point QML**: `Main.qml` (cargado desde `main.cpp`)

---

## IMPORTANTE: QtGraphicalEffects NO ESTÁ INSTALADO

**NUNCA usar:**
- `import QtGraphicalEffects 1.0`
- `DropShadow` (requiere GraphicalEffects)

**Usar en su lugar:**
- Bordes simples: `border.width: 1; border.color: Theme.divider`
- `radius` para tarjetas con ángulo redondeado

---

## QML Import Rules

Todas las páginas de negocio deben importar AMBOS módulos:

```qml
import QtQuick
import QtQuick.Controls
import Qt505XHORA 1.0    // Para AppConstants (métodos, paymentMethods, stockLowThreshold, etc.)
import Components 1.0   // Para Theme (colores, spacing, radius)
```

**Theme vs AppConstants:**
- **Theme**: Colores, spacing, radius, typography → `Theme.colorPrimaryBlue`, `Theme.radiusM`, `Theme.spacingL`
- **AppConstants**: Métodos helper, constantes de negocio → `AppConstants.paymentMethods`, `AppConstants.stockLowThreshold`, `AppConstants.canViewVentas()`

---

## Bugs Corregidos (2026-04-28)

| Bug | Archivo | Fix |
|-----|---------|-----|
| Columna incorrecta en INSERT | `DatabaseManager.cpp:362` | `base_salary` → `salary` |
| QtGraphicalEffects no disponible | `LoginPage.qml`, `Card.qml`, etc. | Eliminado import y DropShadow |
| Mezcla Theme/AppConstants | Todas las páginas | Unificado a Theme para estilos |
| Sintaxis inválida property var | `Main.qml:30-35,418-423` | `property var` → `property url` |
| Propiedades duplicadas | `Main.qml:418-423` | Eliminado bloque duplicado |

---

## Logging

El app loggea a `D:/2026/Noa/debug.txt` - útil para debugging.

---

## References

- `.atl/skill-registry.md` - Skills loaded por contexto
- `.atl/skills/qt-qml-components.md` - Errores QML y soluciones detalladas
- `.atl/skills/qt-qml-fundamentos.md` - Fundamentos QML: propiedades, señales, animaciones
- `.atl/skills/qt-qml-architecture.md` - Patrones: StackView, MVVM, singletons, navegación
- `.atl/skills/qt-cpp-qml-integration.md` - C++/QML: Q_PROPERTY, Q_INVOKABLE, registro