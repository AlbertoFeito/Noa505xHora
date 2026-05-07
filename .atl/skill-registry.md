# Skill Registry - Proyecto 505XHORA

**Delegator use only.** Any agent that launches sub-agents reads this registry to resolve compact rules, then injects them directly into sub-agent prompts. Sub-agents do NOT read this registry or individual SKILL.md files.

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

## Build Commands

```batch
:: Debug
cmake -B build -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH=C:/Qt6/6.9.3/mingw_64
cmake --build build --parallel

:: Release
cmake -B build -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH=C:/Qt6/6.9.3/mingw_64 -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
```

## User Skills

| Trigger | Skill | Path |
|---------|-------|------|
| Cuando se trabaja con QML | qt-qml-fundamentos | C:\Users\guerra\.config\opencode\skills\qt-qml-fundamentos\SKILL.md |
| Cuando se diseña arquitectura QML | qt-qml-architecture | C:\Users\guerra\.config\opencode\skills\qt-qml-architecture\SKILL.md |
| Cuando se desarrolla lógica C++ para QML | qt-cpp-qml-integration | C:\Users\guerra\.config\opencode\skills\qt-cpp-qml-integration\SKILL.md |
|Cuando secribe código TypeScript| typescript | C:\Users\guerra\.config\opencode\skills\typescript\SKILL.md |
|Cuando se usa React 19 | react-19 | C:\Users\guerra\.config\opencode\skills\react-19\SKILL.md |
|Cuando se crea componente Angular | angular-core | C:\Users\guerra\.config\opencode\skills\angular\core\SKILL.md |
|Cuando se escribe Tests Python | pytest | C:\Users\guerra\.config\opencode\skills\pytest\SKILL.md |
|Cuando se escribe Tests Go | go-testing | C:\Users\guerra\.config\opencode\skills\go-testing\SKILL.md |
|Cuando se escribe PR o usa gh CLI | github-pr | C:\Users\guerra\.config\opencode\skills\github-pr\SKILL.md |
|Cuando se escribe documentación | cognitive-doc-design | C:\Users\guerra\.config\opencode\skills\cognitive-doc-design\SKILL.md |
| Cuando se crea Jira epic | jira-epic | C:\Users\guerra\.config\opencode\skills\jira-epic\SKILL.md |
| Cuando se crea Jira task | jira-task | C:\Users\guerra\.config\opencode\skills\jira-task\SKILL.md |

### Project Qt Skills (qt_qml_skills/)

| Trigger | Skill | Path |
|---------|-------|------|
| Estilos y theming en QML | qt-qml-styling-theming | qt_qml_skills/skill_qt_qml_styling_theming.md |
| Modelos de datos QML | qt-qml-models-data | qt_qml_skills/skill_qt_qml_models_data.md |
| Networking REST en QML | qt-qml-networking-rest | qt_qml_skills/skill_qt_qml_networking_rest.md |
| Performance QML | qt-qml-performance | qt_qml_skills/skill_qt_qml_performance.md |
| Deployment QML | qt-qml-deployment | qt_qml_skills/skill_qt_qml_deployment.md |
| Testing y debugging QML | qt-qml-testing-debugging | qt_qml_skills/skill_qt_qml_testing_debugging.md |

## Compact Rules

Pre-digested rules per skill. Delegators copy matching blocks into sub-agent prompts as `## Project Standards (auto-resolved)`.

### qt-qml-fundamentos
- Usar tipos explícitos: `property int`, `property string`, `property bool`, `property url`
- NO usar `property var` para tipos simples — usar solo para datos dinámicos
- Signals requieren `signal nombre()` en QML, conectar con `onSignalName: handler`
- Estados: `State { name: "loaded"; PropertyChanges { target: obj; visible: true } }`
- Animaciones: `NumberAnimation`, `PropertyAnimation`, easing curves

### qt-qml-architecture
- StackView para navegación con `push()`, `pop()`, `replace()`
- Singletons: `pragma Singleton` + `qmlRegisterSingletonType` en main.cpp
- Context Properties: `engine.rootContext()->setContextProperty("Name", obj)`
- NavigationBar: StackView principal con índice para acceso directo

### qt-cpp-qml-integration
- Q_PROPERTY con NOTIFY: `Q_PROPERTY(Type name READ name WRITE setName NOTIFY nameChanged)`
- Q_INVOKABLE para m��todos llamables desde QML
- Señales: `emit signalName(args)` en C++, `onSignalName: handler` en QML
- Registro: `qmlRegisterType<MyClass>()` o `qmlRegisterSingletonInstance()`
- Models: heredar de QAbstractListModel, implementar `roleNames()` y `data()`

### typescript
- Tipos explícitos siempre, evitar `any`
- Interfaces > Types para estructuras
- Generics para código reutilizable
- `export type` para tipos compartidos

### react-19
- No useMemo/useCallback — React Compiler maneja memoización
- `use()` para promesas/context
- Server Components por defecto, agregar 'use client' solo si hay interactividad

### angular-core
- Componentes standalone por defecto
- Signals para estado reactivo: `signal()`, `computed()`, `effect()`
- `inject()` para DI (no constructor)
- `@for`, `@if` en lugar de `*ngFor`, `*ngIf`

### pytest
- fixtures: `@pytest.fixture` con setup/teardown
- parametrize: `@pytest.mark.parametrize`
- assert con mensajes: `assert result == expected, "msg"`

### go-testing
- `t.Helper()` para mensajes claros
- Tabla-driven tests con estructuras
- golden files para outputs grandes

### github-pr
- Conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`
- PR title = commit subject
- Body con bullet points explicando el "qué" y "por qué"

### cognitive-doc-design
- Progressive disclosure: lo importante primero
- Chunking: seccionar contenido largo
- Tables para comparaciones
- Signposting: headers claros que guían

### qt-qml-styling-theming
- Qt Quick Controls 2 para Material/Universal/Fusion
- Theme: `Material.theme: Material.Dark`, `Material.accent: Material.Purple`
- Custom controls: heredar de `Control`, sobreescribir `background`
- Dark mode: `Material.background: "#121212"`
- NO usar QtGraphicalEffects (no disponible en este entorno)

### qt-qml-models-data
- ListModel: `ListElement { name: "Apple"; cost: 2.45 }` para datos simples
- QAbstractListModel (C++): heredar, implementar `roleNames()` y `data()`
- ListView delegate: `index`, `model`, `modelData` disponibles
- Sorting/filtering: QSortFilterProxyModel en C++ o JS en QML

### qt-qml-networking-rest
- XMLHttpRequest nativo en QML: `new XMLHttpRequest()`
- Estados: `readyState` (0-4), `status` (200=OK)
- QNetworkAccessManager en C++ para requests complejos
- WebSocket: `WebSocket` QML o `QWebSocket` C++
- JSON: `JSON.parse()`, `JSON.stringify()` o QJsonDocument

### qt-qml-performance
- Loader para lazy loading de páginaspesadas
- StackView: navegación sin cargar todo
- ListView: `cacheBuffer`, `maximumFlickVelocity`
- Evita bindings en loops: cachear valores

### qt-qml-deployment
- Windows: `windeployqt.exe --release --qmldir .\qml .\release\app.exe`
- Build: `cmake --build build/Desktop_Qt_6_9_3_MinGW_64_bit-Release --parallel`
- Deploy: `C:\Qt6\6.9.3\mingw_64\bin\windeployqt.exe --release --qmldir D:\2026\505XHORA\qml D:\2026\505XHORA\deploy\505XHORA.exe`
- Ejecutar: `Start-Process -FilePath "D:\2026\505XHORA\deploy\505XHORA.exe"`
- Android SDK: `D:\instaladores\android\androidqt6.9`
- emsdk: `D:\instaladores\emsdk`
- WebAssembly: `C:\Qt6\6.9.3\wasm_singlethread`

### qt-qml-testing-debugging
- Qt Test: `import QtTest`, `TestCase {}`
- Squish para automated GUI tests
- GammaRay para introspección
- QML Profiler en Qt Creator

## Project Conventions

| File | Path | Notes |
|------|------|-------|
| AGENTS.md | documentacion/AGENTS.md | Build/test commands, arquitectura, QML rules |
| skill-registry.md | .atl/skill-registry.md | Este archivo |
| README.md | README.md | Stack y estructura general |

## SDD Context

**Persistence**: engram (Engram available)
**Strict TDD Mode**: disabled (no test runner)

### Testing Capabilities
| Layer | Status |
|-------|--------|
| Unit | ❌ Not found |
| Integration | ❌ Not found |
| E2E | ❌ Not found |

### Next Steps
- Listo para `/sdd-explore <topic>` o iniciar cambios
- Para testing, agregar Qt Test o Google Test framework

## References

- `.atl/skills/qt-qml-fundamentos.md` - Fundamentos QML
- `.atl/skills/qt-qml-architecture.md` - Patrones arquitectura
- `.atl/skills/qt-cpp-qml-integration.md` - C++/QML integración