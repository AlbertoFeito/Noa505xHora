#ifndef ROLEENUMS_H
#define ROLEENUMS_H

#include <QObject>
#include <qqml.h>

class RoleEnums : public QObject {
    Q_OBJECT
    QML_ELEMENT
public:
    explicit RoleEnums(QObject *parent = nullptr) : QObject(parent) {}

    enum UserRole {
        Commercial = 1,
        Warehouse,
        Messenger,
        Custody,
        Administrator
    };
    Q_ENUM(UserRole)

    enum SaleStatus {
        Pending = 1,
        Invoiced,
        Prepared,
        InTransit,
        Delivered,
        Liquidated
    };
    Q_ENUM(SaleStatus)

    enum DeliveryStatus {
        InTrasit = 1,
        DeliveredOK,
        Incident
    };
    Q_ENUM(DeliveryStatus)

    enum PaymentType {
        Cash = 1,
        Transfer
    };
    Q_ENUM(PaymentType)

    static QString roleToString(UserRole role) {
        switch(role) {
            case Commercial: return QStringLiteral("comercial");
            case Warehouse: return QStringLiteral("almacen");
            case Messenger: return QStringLiteral("mensajero");
            case Custody: return QStringLiteral("custodio");
            case Administrator: return QStringLiteral("administrador");
        }
        return QStringLiteral("unknown");
    }

    static UserRole stringToRole(const QString &role) {
        if (role == QLatin1String("comercial")) return Commercial;
        if (role == QLatin1String("almacen")) return Warehouse;
        if (role == QLatin1String("mensajero")) return Messenger;
        if (role == QLatin1String("custodio")) return Custody;
        if (role == QLatin1String("administrador")) return Administrator;
        return Commercial;
    }
};

#endif // ROLEENUMS_H
