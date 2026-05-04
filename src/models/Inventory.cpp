#include "Inventory.h"
#include <QDebug>

InventoryManager::InventoryManager(DatabaseManager *dbManager, QObject *parent)
    : QAbstractListModel(parent), m_dbManager(dbManager)
{
    loadCounts();
}

int InventoryManager::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_counts.count();
}

QVariant InventoryManager::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_counts.count())
        return QVariant();

    const InventoryCountData &count = m_counts.at(index.row());
    switch (role) {
        case IdRole: return count.id;
        case CountDateRole: return count.countDate;
        case ProductIdRole: return count.productId;
        case ProductNameRole: return count.productName;
        case ExpectedQuantityRole: return count.expectedQuantity;
        case ActualQuantityRole: return count.actualQuantity;
        case DifferenceRole: return count.difference;
        case NotesRole: return count.notes;
        case CountedByRole: return count.countedBy;
        case CountedByNameRole: return count.countedByName;
    }
    return QVariant();
}

QHash<int, QByteArray> InventoryManager::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[CountDateRole] = "countDate";
    roles[ProductIdRole] = "productId";
    roles[ProductNameRole] = "productName";
    roles[ExpectedQuantityRole] = "expectedQuantity";
    roles[ActualQuantityRole] = "actualQuantity";
    roles[DifferenceRole] = "difference";
    roles[NotesRole] = "notes";
    roles[CountedByRole] = "countedBy";
    roles[CountedByNameRole] = "countedByName";
    return roles;
}

bool InventoryManager::addInventoryCount(int productId, int actualQuantity, const QString &notes, int countedBy)
{
    QSqlQuery query = m_dbManager->executeQuery(
        "INSERT INTO inventory_counts (product_id, expected_quantity, actual_quantity, notes, counted_by) "
        "VALUES (:product_id, (SELECT stock FROM products WHERE id = :pid), :actual_quantity, :notes, :counted_by)",
        {
            {"product_id", productId},
            {"pid", productId},
            {"actual_quantity", actualQuantity},
            {"notes", notes.isEmpty() ? QVariant(QVariant::String) : notes},
            {"counted_by", countedBy > 0 ? countedBy : QVariant(QVariant::Int)}
        }
    );

    if (!query.lastError().text().isEmpty()) {
        qWarning() << "Failed to add inventory count:" << query.lastError().text();
        return false;
    }

    // Actualizar stock real si hay diferencia
    QSqlQuery stockQuery = m_dbManager->executeQuery(
        "UPDATE products SET stock = :actual WHERE id = :id",
        {{"actual", actualQuantity}, {"id", productId}}
    );

    refreshCounts();
    return true;
}

bool InventoryManager::updateInventoryCount(int countId, int actualQuantity, const QString &notes)
{
    QSqlQuery query = m_dbManager->executeQuery(
        "UPDATE inventory_counts SET actual_quantity = :actual, notes = :notes WHERE id = :id",
        {
            {"actual", actualQuantity},
            {"notes", notes.isEmpty() ? QVariant(QVariant::String) : notes},
            {"id", countId}
        }
    );

    if (!query.lastError().text().isEmpty()) {
        qWarning() << "Failed to update inventory count:" << query.lastError().text();
        return false;
    }

    refreshCounts();
    return true;
}

QVariantList InventoryManager::getCountsByDate(const QDate &date) const
{
    QVariantList list;
    for (const InventoryCountData &count : m_counts) {
        if (count.countDate == date) {
            QVariantMap map;
            map["id"] = count.id;
            map["productName"] = count.productName;
            map["expectedQuantity"] = count.expectedQuantity;
            map["actualQuantity"] = count.actualQuantity;
            map["difference"] = count.difference;
            list.append(map);
        }
    }
    return list;
}

QVariantList InventoryManager::getRecentEntries(int limit) const
{
    QVariantList list;

    qDebug() << "getRecentEntries called with limit:" << limit;

    // Query directo usando QSqlQuery directo (sin el DatabaseManager wrapper)
    QString sql = "SELECT id, product_id, expected_quantity, actual_quantity, notes, created_at "
                "FROM inventory_counts "
                "WHERE notes LIKE 'Entrada:%' "
                "ORDER BY created_at DESC LIMIT " + QString::number(limit);

    // Usar database directamente
    QSqlDatabase db = QSqlDatabase::database();
    QSqlQuery query(db);

    if (!query.exec(sql)) {
        qWarning() << "Query failed:" << query.lastError().text();
        return list;
    }

    // Si el query no devuelve error pero no hay resultados, está bien (puede que no haya entradas)
    // Recorrer los resultados
    while (query.next()) {
        int productId = query.value("product_id").toInt();

        // Obtener nombre del producto
        QSqlQuery prodQuery(db);
        prodQuery.prepare("SELECT name, code FROM products WHERE id = :id");
        prodQuery.bindValue(":id", productId);
        prodQuery.exec();

        QString productName = "Producto";
        QString productCode = "N/A";
        if (prodQuery.next()) {
            productName = prodQuery.value("name").toString();
            productCode = prodQuery.value("code").toString();
        }

        QVariantMap map;
        map["id"] = query.value("id").toInt();
        map["productId"] = productId;
        map["productName"] = productName;
        map["productCode"] = productCode;
        map["previousStock"] = query.value("expected_quantity").toInt();
        map["newStock"] = query.value("actual_quantity").toInt();
        map["addedQuantity"] = query.value("actual_quantity").toInt() - query.value("expected_quantity").toInt();
        map["notes"] = query.value("notes").toString();
        map["date"] = query.value("created_at").toString();
        list.append(map);
    }

    qDebug() << "Returning" << list.size() << "entries";
    return list;
}

QVariantList InventoryManager::getRecentExits(int limit) const
{
    QVariantList list;

    QString sql = "SELECT id, product_id, expected_quantity, actual_quantity, notes, created_at "
                "FROM inventory_counts "
                "WHERE notes LIKE 'Salida:%' "
                "ORDER BY created_at DESC LIMIT " + QString::number(limit);

    QSqlDatabase db = QSqlDatabase::database();
    QSqlQuery query(db);

    if (!query.exec(sql)) {
        qWarning() << "getRecentExits query failed:" << query.lastError().text();
        return list;
    }

    while (query.next()) {
        int productId = query.value("product_id").toInt();

        QSqlQuery prodQuery(db);
        prodQuery.prepare("SELECT name, code FROM products WHERE id = :id");
        prodQuery.bindValue(":id", productId);
        prodQuery.exec();

        QString productName = "Producto";
        QString productCode = "N/A";
        if (prodQuery.next()) {
            productName = prodQuery.value("name").toString();
            productCode = prodQuery.value("code").toString();
        }

        int quantity = query.value("expected_quantity").toInt() - query.value("actual_quantity").toInt();

        QVariantMap map;
        map["id"] = query.value("id").toInt();
        map["productId"] = productId;
        map["productName"] = productName;
        map["productCode"] = productCode;
        map["quantity"] = quantity;
        map["reason"] = query.value("notes").toString().replace("Salida: ", "");
        map["date"] = query.value("created_at").toString();
        list.append(map);
    }

    return list;
}

QVariantList InventoryManager::getDiscrepancies(const QDate &date) const
{
    QVariantList list;
    for (const InventoryCountData &count : m_counts) {
        if (count.countDate == date && count.difference != 0) {
            QVariantMap map;
            map["id"] = count.id;
            map["productName"] = count.productName;
            map["expected"] = count.expectedQuantity;
            map["actual"] = count.actualQuantity;
            map["difference"] = count.difference;
            list.append(map);
        }
    }
    return list;
}

void InventoryManager::refreshCounts()
{
    beginResetModel();
    m_counts.clear();
    loadCounts();
    endResetModel();
    emit countsRefreshed();
}

int InventoryManager::getTotalProducts() const
{
    QSqlQuery query = m_dbManager->executeQuery("SELECT COUNT(*) FROM products WHERE is_active = 1");
    if (query.next()) return query.value(0).toInt();
    return 0;
}

int InventoryManager::getCountedProducts(const QDate &date) const
{
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT COUNT(DISTINCT product_id) FROM inventory_counts WHERE count_date = :date",
        {{"date", date.toString(Qt::ISODate)}}
    );
    if (query.next()) return query.value(0).toInt();
    return 0;
}

void InventoryManager::loadCounts()
{
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT ic.id, ic.count_date, ic.product_id, p.name as product_name, "
        "ic.expected_quantity, ic.actual_quantity, ic.difference, ic.notes, "
        "ic.counted_by, u.full_name as counted_by_name "
        "FROM inventory_counts ic "
        "LEFT JOIN products p ON ic.product_id = p.id "
        "LEFT JOIN users u ON ic.counted_by = u.id "
        "ORDER BY ic.count_date DESC, ic.created_at DESC"
    );

    while (query.next()) {
        m_counts.append(countFromQuery(query));
    }
}

InventoryCountData InventoryManager::countFromQuery(const QSqlQuery &query) const
{
    InventoryCountData count;
    count.id = query.value("id").toInt();
    count.countDate = QDate::fromString(query.value("count_date").toString(), Qt::ISODate);
    count.productId = query.value("product_id").toInt();
    count.productName = query.value("product_name").toString();
    count.expectedQuantity = query.value("expected_quantity").toInt();
    count.actualQuantity = query.value("actual_quantity").toInt();
    count.difference = query.value("difference").toInt();
    count.notes = query.value("notes").toString();
    count.countedBy = query.value("counted_by").toInt();
    count.countedByName = query.value("counted_by_name").toString();
    return count;
}
