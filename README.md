# Sistema 505 X HORA

Sistema de Gestión Desktop para la microempresa **505 X HORA**, desarrollado con **Qt6 QML** (frontend) y **C++** (backend).

## Características

- **Offline-first**: Base de datos SQLite local, funciona sin internet
- **Multi-rol**: 5 perfiles de usuario con permisos específicos
- **Flujo de venta completo**: Recepción → Facturación → Almacén → Entrega → Liquidación → Custodia
- **Cuadre final diario**: Control financiero automatizado
- **Reportes ONAT**: Pre-formateados para declaración tributaria
- **Interfaz profesional**: Material Design, responsive, dark/light mode ready

## Stack Tecnológico

| Capa | Tecnología |
|------|-----------|
| Frontend | Qt6 QML + Material Design |
| Backend | C++17 (Qt6) |
| Base de Datos | SQLite (QSql) |
| Build System | CMake 3.16+ |

## Arquitectura

```
505XHORA/
├── main.cpp                  # Punto de entrada, registro QML
├── CMakeLists.txt            # Configuración CMake
├── src/
│   ├── database/
│   │   └── DatabaseManager   # SQLite, transacciones, seed data
│   ├── models/
│   │   ├── UserManager       # Autenticación, roles, permisos
│   │   ├── ProductManager    # Catálogo de productos, stock
│   │   ├── SaleManager       # Ventas, facturas, liquidaciones
│   │   ├── InventoryManager  # Conteo físico, ajustes
│   │   ├── ExpenseManager    # Gastos operativos
│   │   └── PayrollManager    # Nómina quincenal
│   ├── services/
│   │   ├── InventoryService  # Operaciones de inventario
│   │   └── ReportService     # Dashboard, reportes ONAT
│   └── controllers/
│       └── AppController     # Coordinador principal, expone a QML
└── qml/
    ├── main.qml              # StackView, navegación, toast
    ├── Theme.qml             # Sistema de diseño corporativo
    ├── common/               # Componentes reutilizables
    ├── pages/                # Login, Dashboard, Perfil
    ├── modules/              # Módulos por rol
    │   ├── commercial/       # Ventas, facturas, liquidaciones
    │   ├── warehouse/        # Almacén, calidad, conteo
    │   ├── messenger/        # Entregas, cobros, incidentes
    │   ├── custody/          # Recibo custodia, historial
    │   └── admin/            # Dashboard, gastos, nómina, config
    └── dialogs/              # Cuadre final, confirmar, imprimir
```

## Compilación

### Requisitos

- Qt6.2+ (con módulos: Quick, QuickControls2, Sql)
- CMake 3.16+
- Compilador C++17 (GCC, Clang, MSVC)

### Pasos

```bash
# 1. Clonar o descargar el proyecto
cd 505XHORA

# 2. Crear directorio de build
mkdir build && cd build

# 3. Configurar con CMake
cmake .. -DCMAKE_PREFIX_PATH=/ruta/a/qt6

# 4. Compilar
cmake --build . --parallel

# 5. Ejecutar
./505XHORA
```

### Windows (MinGW)

```bash
cmake .. -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH=C:/Qt/6.x.x/mingw_64
cmake --build .
```

### macOS

```bash
cmake .. -DCMAKE_PREFIX_PATH=/usr/local/opt/qt@6
cmake --build .
```

## Usuarios de Prueba

| Usuario | Contraseña | Rol |
|-----------|-----------|-----|
| admin | admin505 | Administrador |
| comercial1 | comercial1 | Comercial |
| almacen1 | almacen1 | Almacén |
| mensajero1 | mensajero1 | Mensajero |
| custodio1 | custodio1 | Custodio |

## Flujo de Venta Implementado

1. **Comercial** crea Vale de Venta con datos del cliente y productos
2. **Comercial** emite Factura para el vale
3. **Almacén** recibe Vale de Entrega y prepara el pedido
4. **Almacén** realiza Control de Calidad (checklist)
5. **Mensajero** toma la entrega y registra estado "En Tránsito"
6. **Mensajero** entrega al cliente y registra cobro
7. **Comercial** liquida los fondos recibidos
8. **Almacén** realiza Conteo Físico al cierre
9. **Custodio** realiza Cuadre Final y recibe custodia

## Módulos por Rol

### Comercial
- Vale de Venta (recepción del cliente)
- Facturación (documento legal)
- Liquidación (fondos del mensajero)
- Comisiones (gestores)

### Almacén
- Vale de Entrega (preparación)
- Control de Calidad (checklist)
- Conteo Físico Diario
- Alertas de Stock

### Mensajero
- Estado de Entrega (en tránsito/entregado)
- Cobros (efectivo/transferencia)
- Reporte de Incidentes

### Custodio
- Recibo de Custodia (cuadre final)
- Historial de Custodia

### Administrador
- Dashboard (métricas del negocio)
- Gastos (alquiler, ONAT, combustible, etc.)
- Nómina Quincenal (salario + comisiones)
- Configuración (horarios, empresa)
- Reporte ONAT

## Estructura de Base de Datos

| Tabla | Propósito |
|-------|-----------|
| users | Usuarios y roles |
| products | Catálogo de productos |
| sales | Vales de venta |
| sale_items | Líneas de cada venta |
| invoices | Facturas emitidas |
| deliveries | Registro de entregas |
| liquidations | Liquidaciones de cobros |
| inventory_counts | Conteos físicos diarios |
| expenses | Gastos operativos |
| payroll | Nómina de empleados |
| custody_records | Entregas a custodio |
| daily_reconciliations | Cuadres finales |
| maintenance | Mantenimiento de transporte |
| config | Configuración del sistema |

## Configuración Horaria

- **Atención al Cliente**: 09:00 - 16:00
- **Jornada Laboral**: 08:30 - 17:00
- **Mantenimiento**: Sábados

## Seguridad

- Autenticación por usuario/contraseña
- RBAC (Role-Based Access Control) por módulos
- Cuadre final obligatorio antes de custodia
- Justificación obligatoria para diferencias de caja
- PIN de confirmación para custodia

## Próximos Pasos / Roadmap

1. **Fase 1** (Completado): Operación básica - ventas, facturas, liquidación, cuadre
2. **Fase 2** (Completado): Control - inventario, gastos, reportes ONAT, custodia
3. **Fase 3** (Parcial): Optimización - nómina automática, alertas mantenimiento, respaldo DB

## Licencia

Proyecto privado para 505 X HORA.

---

**Nota**: Este sistema está diseñado para apoyar la transición del modelo de negocio hacia una estructura legalizada (TCP, ONAT) en Cuba.
