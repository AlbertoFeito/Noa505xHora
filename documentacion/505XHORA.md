Este es el contenido para un archivo **`README.md`** o de documentación técnica diseñado para ser utilizado en **OpenCode**. El documento estructura el sistema de escritorio para la micro-empresa **505 X HORA** basándose en los roles, flujos de trabajo y objetivos definidos en las fuentes.

---

```markdown
# Sistema de Gestión Desktop - 505 X HORA

Este proyecto consiste en el desarrollo de una aplicación de escritorio diseñada para automatizar y gestionar los procesos operativos de **505 X HORA**, una micro-empresa de servicios de venta de insumos, electrodomésticos, útiles del hogar y alimentos.

## ?? Objetivos del Sistema
*   **Gestión de Ingresos:** Optimizar la generación de beneficios para los propietarios.
*   **Control de Producción:** Facilitar la distribución de salarios basada en el aporte individual a la producción y el comportamiento de las ventas.
*   **Calidad de Servicio:** Garantizar el cumplimiento de las normas del flujo de ventas y la satisfacción del cliente.

## ?? Roles de Usuario y Funcionalidades

El sistema debe contemplar los siguientes perfiles basados en la estructura organizacional de la empresa:

### 1. Comercial (Oficina)
*   **Recepción de Clientes:** Emisión de vales de venta y entrega.
*   **Facturación:** Generación de facturas de compra.
*   **Liquidación:** Procesamiento inmediato de las liquidaciones de dinero entregadas por los mensajeros tras las ventas.
*   **Gestión de Comisiones:** Conciliación y fijación de comisiones para gestores.

### 2. Encargado de Almacén (Ayudante)
*   **Preparación de Pedidos:** Revisión de envolturas, embalajes y fechas de caducidad.
*   **Control de Calidad:** Verificación del funcionamiento de equipos antes de la entrega.
*   **Inventario:** Realización del conteo físico diario de productos al cierre de operaciones.

### 3. Mensajero / Ayudante
*   **Gestión de Entregas:** Conciliación de formas de pago, plazos y costos de mensajería con el cliente.
*   **Cobros:** Registro de cobros realizados en efectivo o transferencia.
*   **Reporte de Incidentes:** Notificación de sucesos con clientes durante el traslado.

### 4. Custodio
*   **Resguardo de Recursos:** Recepción de los recursos y el inventario físico al finalizar el día.

### 5. Administrador / Propietario
*   **Control de Gastos:** Seguimiento de alquiler, tributos (ONAT), combustible, mantenimiento y salarios.
*   **Configuración de Horarios:** Gestión del horario de atención (09:00 - 16:00) y de personal (08:30 - 17:00).
*   **Gestión de Nómina:** Cálculo de pagos quincenales y adicionales basados en ventas.

## ?? Flujo de Venta Implementado
El sistema debe seguir estrictamente el flujo de trabajo definido:
1.  **Recepción:** Intercambio formal en oficina comercial para esclarecer detalles del producto.
2.  **Facturación:** Emisión del documento legal de compra.
3.  **Almacén:** Entrega de factura, revisión física del producto y traslado al área de recepción.
4.  **Entrega/Traslado:** Comprobación final, sugerencias de uso al cliente y cobro.
5.  **Cierre:** Liquidación comercial, conteo físico en almacén y entrega al custodio.

## ?? Requerimientos de Negocio
*   **Disciplina de Venta:** El sistema debe registrar el cumplimiento de las normas de trato al cliente y vestuario.
*   **Mantenimiento:** Programación de alertas para el mantenimiento de medios de transporte los días sábados.
*   **Eficiencia:** Uso óptimo de recursos para disminuir gastos asociados al proceso.

---
*Nota: Este sistema está diseñado para apoyar la transición del modelo de negocio hacia una estructura legalizada y organizada.*
```

### Notas Adicionales
*   **Interfaz de Usuario:** Dado que la empresa enfatiza "vender su imagen" y la "calidad del trabajo realizado", la aplicación debería tener una interfaz limpia y profesional que refleje estos valores.
*   **Seguridad:** El sistema debe incluir un módulo de cuadre final del día para asegurar que todos los recursos financieros y físicos coincidan antes de ser entregados al custodio.