#ifndef CONSTANTS_H
#define CONSTANTS_H

#include <QString>

namespace Constants {
    // Database
    inline const char* DB_NAME = "505xhora.db";
    inline const char* DB_TYPE = "QSQLITE";
    
    // Horarios
    inline const char* HORARIO_ATENCION_INICIO = "09:00";
    inline const char* HORARIO_ATENCION_FIN = "16:00";
    inline const char* HORARIO_PERSONAL_ENTRADA = "08:30";
    inline const char* HORARIO_PERSONAL_SALIDA = "17:00";
    
    // Mantenimiento
    inline const int DIA_MANTENIMIENTO = 6; // Sábado (Qt::Saturday = 6)
    
    // Roles
    inline const char* ROLE_COMMERCIAL = "comercial";
    inline const char* ROLE_WAREHOUSE = "almacen";
    inline const char* ROLE_MESSENGER = "mensajero";
    inline const char* ROLE_CUSTODY = "custodio";
    inline const char* ROLE_ADMIN = "administrador";
    
    // Categorías de gasto
    inline const char* EXPENSE_RENT = "alquiler";
    inline const char* EXPENSE_ONAT = "onat";
    inline const char* EXPENSE_TRANSPORT = "transportista";
    inline const char* EXPENSE_SALARY = "salario";
    inline const char* EXPENSE_FUEL = "combustible";
    inline const char* EXPENSE_MAINTENANCE = "mantenimiento";
    
    // Estados de venta
    inline const char* SALE_STATUS_PENDING = "pendiente";
    inline const char* SALE_STATUS_INVOICED = "facturado";
    inline const char* SALE_STATUS_PREPARED = "preparado";
    inline const char* SALE_STATUS_IN_TRANSIT = "en_transito";
    inline const char* SALE_STATUS_DELIVERED = "entregado";
    inline const char* SALE_STATUS_LIQUIDATED = "liquidado";
    
    // Estados de entrega
    inline const char* DELIVERY_STATUS_TRANSIT = "en_traslado";
    inline const char* DELIVERY_STATUS_DELIVERED = "entregado";
    inline const char* DELIVERY_STATUS_INCIDENT = "incidente";
    
    // Formas de pago
    inline const char* PAYMENT_CASH = "efectivo";
    inline const char* PAYMENT_TRANSFER = "transferencia";
}

#endif // CONSTANTS_H
