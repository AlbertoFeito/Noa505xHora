#include "InventoryService.h"
#include <QSqlQuery>
#include <QDebug>

InventoryService::InventoryService(DatabaseManager *dbManager, QObject *parent)
    : QObject(parent), m_dbManager(dbManager)
{
}

bool InventoryService::performDailyCount(const QDate &date, const QVariantList &counts, int countedBy)
{
    return m_dbManager->executeTransaction([&]() -> bool {
        for (const QVariant &var : counts) {
            QVariantMap count = var.toMap();
            QSqlQuery query = m_dbManager->executeQuery(
                "INSERT INTO inventory_counts (count_date, product_id, expected_quantity, actual_quantity, counted_by) "
                "VALUES (:date, :product_id, (SELECT stock FROM products WHERE id = :pid), :actual, :counted_by)",
                {
                    {"date", date.toString(Qt::ISODate)},
                    {"product_id", count["productId"].toInt()},
                    {"pid", count["productId"].toInt()},
                    {"actual", count["actualQuantity"].toInt()},
                    {"counted_by", countedBy}
                }
            );

            if (!query.lastError().text().isEmpty()) {
                qWarning() << "Failed to insert count:" << query.lastError().text();
                return false;
            }

            // Actualizar stock real
            QSqlQuery stockQuery = m_dbManager->executeQuery(
                "UPDATE products SET stock = :actual WHERE id = :id",
                {
                    {"actual", count["actualQuantity"].toInt()},
                    {"id", count["productId"].toInt()}
                }
            );

            if (stockQuery.lastError().type() != QSqlError::NoError) {
                qWarning() << "Failed to update stock:" << stockQuery.lastError().text();
                return false;
            }
        }
        return true;
    });
}

QVariantList InventoryService::getStockSummary() const
{
    QVariantList list;
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT category, COUNT(*) as count, SUM(stock * sale_price) as value "
        "FROM products WHERE is_active = 1 GROUP BY category"
    );

    while (query.next()) {
        QVariantMap map;
        map["category"] = query.value("category").toString();
        map["productCount"] = query.value("count").toInt();
        map["stockValue"] = query.value("value").toDouble();
        list.append(map);
    }
    return list;
}

int InventoryService::getTotalStockValue() const
{
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT COALESCE(SUM(stock * sale_price), 0) as total FROM products WHERE is_active = 1"
    );
    if (query.next()) return query.value("total").toInt();
    return 0;
}

QVariantList InventoryService::getStockAlerts() const
{
    QVariantList list;
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT id, name, stock, min_stock FROM products WHERE is_active = 1 AND stock <= min_stock ORDER BY name"
    );

    while (query.next()) {
        QVariantMap map;
        map["id"] = query.value("id").toInt();
        map["name"] = query.value("name").toString();
        map["stock"] = query.value("stock").toInt();
        map["minStock"] = query.value("min_stock").toInt();
        list.append(map);
    }
    return list;
}
