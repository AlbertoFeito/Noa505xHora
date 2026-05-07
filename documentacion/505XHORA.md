# Sistema de Gestion Desktop - 505 X HORA

Este proyecto consiste en el desarrollo de una aplicacion de escritorio disenada para automatizar y gestionar los procesos operativos de **505 X HORA**, una micro-empresa de servicios de venta de insumos, electrodomesticos, utiles del hogar y alimentos.

## Objetivos del Sistema

* **Gestion de Ingresos:** Optimizar la generacion de beneficios para los propietarios.
* **Control de Produccion:** Facilitar la distribucion de salarios basada en el aporte individual a la produccion y el comportamiento de las ventas.
* **Calidad de Servicio:** Garantizar el cumplimiento de las normas del flujo de ventas y la satisfaccion del cliente.

## Roles de Usuario y Funcionalidades

El sistema debe contemplar los siguientes perfiles basados en la estructura organizacional de la empresa:

### 1. Comercial (Oficina)
* **Recepcion de Clientes:** Emision de vales de venta y entrega.
* **Facturacion:** Generacion de facturas de compra.
* **Liquidacion:** Procesamiento inmediato de las liquidaciones de dinero entregadas por los mensajeros tras las ventas.
* **Gestion de Comisiones:** Conciliacion y fijacion de comisiones para gestores.

### 2. Encargado de Almacen (Ayudante)
* **Preparacion de Pedidos:** Revision de envolturas, embalajes y fechas de caducidad.
* **Control de Calidad:** Verificacion del funcionamiento de equipos antes de la entrega.
* **Inventario:** Realizacion del conteo fisico diario de productos al cierre de operaciones.

### 3. Mensajero / Ayudante
* **Gestion de Entregas:** Conciliacion de formas de pago, plazos y costos de mensajeria con el cliente.
* **Cobros:** Registro de cobros realizados en efectivo o transferencia.
* **Reporte de Incidentes:** Notificacion de sucesos con clientes durante el traslado.

### 4. Custodio
* **Resguardo de Recursos:** Recepcion de los recursos y el inventario fisico al finalizar el dia.

### 5. Administrador / Propietario
* **Control de Gastos:** Seguimiento de alquiler, tributos (ONAT), combustible, mantenimiento y salarios.
* **Configuracion de Horarios:** Gestion del horario de atencion (09:00 - 16:00) y de personal (08:30 - 17:00).
* **Gestion de Nomina:** Calculo de pagos quincenales y adicionales basados en ventas.

## Flujo de Venta Implementado

El sistema debe seguir estrictamente el flujo de trabajo definido:

1. **Recepcion:** Intercambio formal en oficina comercial para esclarecer detalles del producto.
2. **Facturacion:** Emision del documento legal de compra.
3. **Almacen:** Entrega de factura, revision fisica del producto y traslado al area de recepcion.
4. **Entrega/Traslado:** Comprobacion final, sugerencias de uso al cliente y cobro.
5. **Cierre:** Liquidacion comercial, conteo fisico en almacen y entrega al custodio.

## Requerimientos de Negocio

* **Disciplina de Venta:** El sistema debe registrar el cumplimiento de las normas de trato al cliente y vestuario.
* **Mantenimiento:** Programacion de alertas para el mantenimiento de medios de transporte los dias sabados.
* **Eficiencia:** Uso optimo de recursos para disminuir gastos asociados al proceso.

---

*Nota: Este sistema esta disenado para apoyar la transicion del modelo de negocio hacia una estructura legalizada y organizada.*

### Notas Adicionales

* **Interfaz de Usuario:** Dado que la empresa enfatiza "vender su imagen" y la "calidad del trabajo realizado", la aplicacion deberia tener una interfaz limpia y profesional que refleje estos valores.
* **Seguridad:** El sistema debe incluir un modulo de cuadre final del dia para asegurar que todos los recursos financieros y fisicos coincidan antes de ser entregados al custodio.
