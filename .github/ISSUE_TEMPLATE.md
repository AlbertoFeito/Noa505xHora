# Issues del Proyecto 505XHORA

## Cómo crear un issue
```bash
gh issue create --title "[Módulo] Nombre" --body "contenido" --repo AlbertoFeito/Noa505xHora
```

---

## Lista de Issues a Crear

### Fase 1 - Básico para operar

**1. [Módulo] Entrada de Productos al Almacén**
```
## Descripción
Registrar productos que llegan al almacén (aumentar stock)

## Estado
🔴 Por hacer

## Actividades
- Buscar producto por código/nombre
- Ingresar cantidad recibida
- Registrar número de factura del proveedor
- Guardar → aumenta stock

## Prioridad
Alta
```

**2. [Módulo] Preparación de Pedidos**
```
## Descripción
Lista de ventas facturadas para preparar y separar productos

## Estado
⚠️ Parcial - Ya existe UI pero falta lógica

## Actividades
- Ver lista de ventas con estado "facturado"
- Ver productos de cada venta
- Marcar como "preparado"
- Generar Vale de Entrega
```

**3. [Módulo] Control de Calidad**
```
## Descripción
Checklist de verificación antes de entregar al mensajero

## Estado
⚠️ Solo UI - No guarda datos

## Actividades
- Checklist: envoltura, funcionamiento, caducidad, cantidad, etiquetado
- Marcar como aprobado
- Registrar quién validó
```

**4. [Módulo] Cuadre Final del Día**
```
## Descripción
Verificar que todo cuadre: dinero + inventario al cerrar

## Estado
🔴 Por hacer

## Actividades
- Mostrar ventas del día
- Mostrar cobros registrados
- Mostrar inventario físico vs sistema
- Generar reporte de custodia
```

### Fase 2 - Pendientes

**5. [Módulo] Vale de Entrega** - Generar documento para mensajero
**6. [Módulo] Catálogo de Productos** - Ver/Editar productos
**7. [Módulo] Estado de Entregas** - Seguimiento de pedidos
**8. [Módulo] Registro de Cobros** - Cash/transfer
**9. [Módulo] Incidentes** - Reportar problemas
**10. [Módulo] Dashboard Financiero** - Resumen ingresos/gastos

---

## Estado Actual del Proyecto (ya implementado)

✅ **Gestión de Usuarios** - CRUD completo
✅ **Comercial** - Vale de venta, Facturación, Liquidación
✅ **Almacén** - Alertas de stock
✅ **Finanzas** - Gastos, Nómina
⚠️ **Varios** - Parcialmente implementados