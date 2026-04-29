#ifndef INVENTORYSERVICE_H
#define INVENTORYSERVICE_H

#include <QObject>
#include <QDate>
#include <QVariantList>
#include <qqml.h>
#include "../database/DatabaseManager.h"

class InventoryService : public QObject {
    Q_OBJECT
    QML_ELEMENT

public:
    explicit InventoryService(DatabaseManager *dbManager, QObject *parent = nullptr);

    Q_INVOKABLE bool performDailyCount(const QDate &date, const QVariantList &counts, int countedBy);
    Q_INVOKABLE QVariantList getStockSummary() const;
    Q_INVOKABLE int getTotalStockValue() const;
    Q_INVOKABLE QVariantList getStockAlerts() const;

private:
    DatabaseManager *m_dbManager;
};

#endif // INVENTORYSERVICE_H
