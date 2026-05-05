#include "Sale.h"
#include <QDateTime>
#include <QDate>
#include <QDebug>

SaleManager::SaleManager(DatabaseManager *dbManager, QObject *parent)
    : QAbstractListModel(parent), m_dbManager(dbManager)
{
    loadSales();
}

int SaleManager::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_sales.count();
}

QVariant SaleManager::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_sales.count())
        return QVariant();

    const SaleData &sale = m_sales.at(index.row());
    switch (role) {
        case IdRole: return sale.id;
        case SaleNumberRole: return sale.saleNumber;
        case ClientNameRole: return sale.clientName;
        case ClientPhoneRole: return sale.clientPhone;
        case ClientAddressRole: return sale.clientAddress;
        case StatusRole: return sale.status;
        case PaymentTypeRole: return sale.paymentType;
        case SubtotalRole: return sale.subtotal;
        case DeliveryCostRole: return sale.deliveryCost;
        case CommissionRole: return sale.commission;
        case TotalRole: return sale.total;
        case AmountPaidRole: return sale.amountPaid;
        case NotesRole: return sale.notes;
        case CreatedByRole: return sale.createdBy;
        case MessengerIdRole: return sale.messengerId;
        case CreatedAtRole: return sale.createdAt;
    }
    return QVariant();
}

QHash<int, QByteArray> SaleManager::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[SaleNumberRole] = "saleNumber";
    roles[ClientNameRole] = "clientName";
    roles[ClientPhoneRole] = "clientPhone";
    roles[ClientAddressRole] = "clientAddress";
    roles[StatusRole] = "status";
    roles[PaymentTypeRole] = "paymentType";
    roles[SubtotalRole] = "subtotal";
    roles[DeliveryCostRole] = "deliveryCost";
    roles[CommissionRole] = "commission";
    roles[TotalRole] = "total";
    roles[AmountPaidRole] = "amountPaid";
    roles[NotesRole] = "notes";
    roles[CreatedByRole] = "createdBy";
    roles[MessengerIdRole] = "messengerId";
    roles[CreatedAtRole] = "createdAt";
    return roles;
}

double SaleManager::todaySalesTotal() const
{
    double total = 0;
    QDate today = QDate::currentDate();
    for (const SaleData &sale : m_sales) {
        QString createdAtStr = sale.createdAt;
        if (QDateTime::fromString(createdAtStr.replace(" ", "T"), Qt::ISODate).date() == today &&
            (sale.status == "liquidado" || sale.status == "entregado")) {
            total += sale.total;
        }
    }
    return total;
}

int SaleManager::todaySalesCount() const
{
    int count = 0;
    QDate today = QDate::currentDate();
    for (const SaleData &sale : m_sales) {
        QString createdAtStr = sale.createdAt;
        if (QDateTime::fromString(createdAtStr.replace(" ", "T"), Qt::ISODate).date() == today) {
            count++;
        }
    }
    return count;
}

double SaleManager::pendingAmount() const
{
    double total = 0;
    for (const SaleData &sale : m_sales) {
        if (sale.status != "liquidado" && sale.status != "cancelado") {
            total += (sale.total - sale.amountPaid);
        }
    }
    return total;
}

int SaleManager::createSale(const QString &clientName, const QString &clientPhone,
                             const QString &clientAddress, const QVariantList &items,
                             const QString &paymentType, double deliveryCost,
                             double commission, int createdBy, const QString &notes)
{
    QString saleNumber = generateSaleNumber();
    double subtotal = 0;

    // Calcular subtotal
    for (const QVariant &itemVar : items) {
        QVariantMap item = itemVar.toMap();
        subtotal += item["totalPrice"].toDouble();
    }

    double total = subtotal + deliveryCost;

    bool success = m_dbManager->executeTransaction([&]() -> bool {
        // Insertar venta
        QSqlQuery saleQuery = m_dbManager->executeQuery(
            "INSERT INTO sales (sale_number, client_name, client_phone, client_address, "
            "status, payment_type, subtotal, delivery_cost, commission, total, notes, created_by) "
            "VALUES (:sale_number, :client_name, :client_phone, :client_address, 'pendiente', "
            ":payment_type, :subtotal, :delivery_cost, :commission, :total, :notes, :created_by)",
            {
                {"sale_number", saleNumber},
                {"client_name", clientName},
                {"client_phone", clientPhone.isEmpty() ? QVariant(QVariant::String) : clientPhone},
                {"client_address", clientAddress.isEmpty() ? QVariant(QVariant::String) : clientAddress},
                {"payment_type", paymentType},
                {"subtotal", subtotal},
                {"delivery_cost", deliveryCost},
                {"commission", commission},
                {"total", total},
                {"notes", notes.isEmpty() ? QVariant(QVariant::String) : notes},
                {"created_by", createdBy > 0 ? createdBy : QVariant(QVariant::Int)}
            }
        );

        if (saleQuery.lastError().type() != QSqlError::NoError) {
            qWarning() << "Failed to create sale:" << saleQuery.lastError().text();
            qWarning() << "Last query:" << saleQuery.lastQuery();
            return false;
        }

        int saleId = saleQuery.lastInsertId().toInt();
        qDebug() << "Sale created with ID:" << saleId;

        // Insertar items
        for (const QVariant &itemVar : items) {
            QVariantMap item = itemVar.toMap();
            QSqlQuery itemQuery = m_dbManager->executeQuery(
                "INSERT INTO sale_items (sale_id, product_id, product_name, quantity, unit_price, total_price) "
                "VALUES (:sale_id, :product_id, :product_name, :quantity, :unit_price, :total_price)",
                {
                    {"sale_id", saleId},
                    {"product_id", item["productId"].toInt()},
                    {"product_name", item["productName"].toString()},
                    {"quantity", item["quantity"].toInt()},
                    {"unit_price", item["unitPrice"].toDouble()},
                    {"total_price", item["totalPrice"].toDouble()}
                }
            );

            if (itemQuery.lastError().type() != QSqlError::NoError) {
                qWarning() << "Failed to insert sale item:" << itemQuery.lastError().text();
                return false;
            }

            // Actualizar stock
            QSqlQuery stockQuery = m_dbManager->executeQuery(
                "UPDATE products SET stock = stock - :quantity WHERE id = :product_id",
                {
                    {"quantity", item["quantity"].toInt()},
                    {"product_id", item["productId"].toInt()}
                }
            );

            if (stockQuery.lastError().type() != QSqlError::NoError) {
                qWarning() << "Failed to update stock:" << stockQuery.lastError().text();
                return false;
            }
        }

        return true;
    });

    if (success) {
        refreshSales();
        // Obtener el ID de la venta creada
QSqlQuery idQuery = m_dbManager->executeQuery(
            "SELECT id FROM sales WHERE sale_number = :sale_number",
            QVariantMap{{"sale_number", saleNumber}}
        );
        if (idQuery.next()) {
            int newId = idQuery.value(0).toInt();
            qDebug() << "Returning sale ID:" << newId;
            return newId;
        }
    }

    qWarning() << "createSale failed, success:" << success;
    return -1;
}

bool SaleManager::updateSaleStatus(int saleId, const QString &status)
{
    QString sql = "UPDATE sales SET status = :status, updated_at = CURRENT_TIMESTAMP";
    if (status == "entregado") sql += ", delivered_at = CURRENT_TIMESTAMP";
    if (status == "liquidado") sql += ", liquidated_at = CURRENT_TIMESTAMP";
    sql += " WHERE id = :id";

    QSqlQuery query = m_dbManager->executeQuery(sql, QVariantMap{{"status", status}, {"id", saleId}});

    if (!query.lastError().text().isEmpty()) {
        qWarning() << "Failed to update sale status:" << query.lastError().text();
        return false;
    }

    refreshSales();
    return true;
}

QVariantMap SaleManager::getSale(int saleId) const
{
    for (const SaleData &sale : m_sales) {
        if (sale.id == saleId) {
            QVariantMap map;
            map["id"] = sale.id;
            map["saleNumber"] = sale.saleNumber;
            map["clientName"] = sale.clientName;
            map["clientPhone"] = sale.clientPhone;
            map["clientAddress"] = sale.clientAddress;
            map["status"] = sale.status;
            map["paymentType"] = sale.paymentType;
            map["subtotal"] = sale.subtotal;
            map["deliveryCost"] = sale.deliveryCost;
            map["commission"] = sale.commission;
            map["total"] = sale.total;
            map["amountPaid"] = sale.amountPaid;
            map["notes"] = sale.notes;
            map["createdAt"] = sale.createdAt;
            return map;
        }
    }
    return QVariantMap();
}

QVariantList SaleManager::getSaleItems(int saleId) const
{
    QVariantList list;
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT id, product_id, product_name, quantity, unit_price, total_price "
        "FROM sale_items WHERE sale_id = :sale_id",
        {{"sale_id", saleId}}
    );

    while (query.next()) {
        QVariantMap item;
        item["id"] = query.value("id").toInt();
        item["productId"] = query.value("product_id").toInt();
        item["productName"] = query.value("product_name").toString();
        item["quantity"] = query.value("quantity").toInt();
        item["unitPrice"] = query.value("unit_price").toDouble();
        item["totalPrice"] = query.value("total_price").toDouble();
        list.append(item);
    }
    return list;
}

QVariantList SaleManager::getSalesByStatus(const QString &status) const
{
    QVariantList list;
    for (const SaleData &sale : m_sales) {
        if (sale.status == status) {
            QVariantMap map;
            map["id"] = sale.id;
            map["saleNumber"] = sale.saleNumber;
            map["clientName"] = sale.clientName;
            map["status"] = sale.status;
            map["total"] = sale.total;
            map["createdAt"] = sale.createdAt;
            list.append(map);
        }
    }
    return list;
}

QVariantList SaleManager::getTodaySales() const
{
    QVariantList list;
    QDate today = QDate::currentDate();
    for (const SaleData &sale : m_sales) {
        QString createdAtStr = sale.createdAt;
        QDate saleDate = QDateTime::fromString(createdAtStr.replace(" ", "T"), Qt::ISODate).date();
        if (saleDate == today) {
            QVariantMap map;
            map["id"] = sale.id;
            map["saleNumber"] = sale.saleNumber;
            map["clientName"] = sale.clientName;
            map["status"] = sale.status;
            map["total"] = sale.total;
            map["amountPaid"] = sale.amountPaid;
            list.append(map);
        }
    }
    return list;
}

void SaleManager::refreshSales()
{
    beginResetModel();
    m_sales.clear();
    loadSales();
    endResetModel();
    emit todaySalesTotalChanged();
    emit todaySalesCountChanged();
    emit pendingAmountChanged();
    emit salesRefreshed();
}

int SaleManager::createInvoice(int saleId, const QString &clientName,
                                const QString &clientId, double total, int createdBy)
{
    QString invoiceNumber = "F" + QString::number(saleId).rightJustified(6, '0');

    QSqlQuery query = m_dbManager->executeQuery(
        "INSERT INTO invoices (invoice_number, sale_id, client_name, client_id, total, grand_total, created_by) "
        "VALUES (:invoice_number, :sale_id, :client_name, :client_id, :total, :grand_total, :created_by)",
        {
            {"invoice_number", invoiceNumber},
            {"sale_id", saleId},
            {"client_name", clientName},
            {"client_id", clientId.isEmpty() ? QVariant(QVariant::String) : clientId},
            {"total", total},
            {"grand_total", total},
            {"created_by", createdBy > 0 ? createdBy : QVariant(QVariant::Int)}
        }
    );

    if (!query.lastError().text().isEmpty()) {
        qWarning() << "Failed to create invoice:" << query.lastError().text();
        return -1;
    }

    // Actualizar estado de venta a facturado
    updateSaleStatus(saleId, "facturado");

    return query.lastInsertId().toInt();
}

bool SaleManager::markInvoicePrinted(int invoiceId)
{
    QSqlQuery query = m_dbManager->executeQuery(
        "UPDATE invoices SET printed = 1 WHERE id = :id",
        {{"id", invoiceId}}
    );
    return query.lastError().type() == QSqlError::NoError;
}

bool SaleManager::registerDelivery(int saleId, int messengerId, double deliveryCost)
{
    QSqlQuery query = m_dbManager->executeQuery(
        "INSERT INTO deliveries (sale_id, messenger_id, delivery_cost, departure_time) "
        "VALUES (:sale_id, :messenger_id, :delivery_cost, CURRENT_TIMESTAMP)",
        {
            {"sale_id", saleId},
            {"messenger_id", messengerId},
            {"delivery_cost", deliveryCost}
        }
    );

    if (!query.lastError().text().isEmpty()) {
        qWarning() << "Failed to register delivery:" << query.lastError().text();
        return false;
    }

    // Asignar mensajero a la venta y actualizar estado
    m_dbManager->executeQuery(
        "UPDATE sales SET messenger_id = :messenger_id, status = 'en_transito' WHERE id = :id",
        {{"messenger_id", messengerId}, {"id", saleId}}
    );

    refreshSales();
    return true;
}

bool SaleManager::updateDeliveryStatus(int saleId, const QString &status,
                                        double paymentCollected, const QString &incidentDesc)
{
    QSqlQuery query = m_dbManager->executeQuery(
        "UPDATE deliveries SET status = :status, payment_collected = :payment_collected, "
        "incident_description = :incident_description, arrival_time = CURRENT_TIMESTAMP "
        "WHERE sale_id = :sale_id",
        {
            {"status", status},
            {"payment_collected", paymentCollected},
            {"incident_description", incidentDesc.isEmpty() ? QVariant(QVariant::String) : incidentDesc},
            {"sale_id", saleId}
        }
    );

    if (!query.lastError().text().isEmpty()) {
        qWarning() << "Failed to update delivery:" << query.lastError().text();
        return false;
    }

    // Actualizar venta
    QString saleStatus = (status == "entregado") ? "entregado" : "incidente";
    updateSaleStatus(saleId, saleStatus);

    return true;
}

bool SaleManager::createLiquidation(int saleId, int messengerId, double amount,
                                     const QString &paymentType, double difference,
                                     const QString &differenceReason, int createdBy)
{
    QSqlQuery query = m_dbManager->executeQuery(
        "INSERT INTO liquidations (sale_id, messenger_id, amount, payment_type, "
        "difference, difference_reason, created_by) "
        "VALUES (:sale_id, :messenger_id, :amount, :payment_type, :difference, :difference_reason, :created_by)",
        {
            {"sale_id", saleId},
            {"messenger_id", messengerId},
            {"amount", amount},
            {"payment_type", paymentType},
            {"difference", difference},
            {"difference_reason", differenceReason.isEmpty() ? QVariant(QVariant::String) : differenceReason},
            {"created_by", createdBy > 0 ? createdBy : QVariant(QVariant::Int)}
        }
    );

    if (!query.lastError().text().isEmpty()) {
        qWarning() << "Failed to create liquidation:" << query.lastError().text();
        return false;
    }

    // Actualizar venta como liquidada y monto pagado
    m_dbManager->executeQuery(
        "UPDATE sales SET status = 'liquidado', amount_paid = :amount_paid WHERE id = :id",
        {{"amount_paid", amount}, {"id", saleId}}
    );

    refreshSales();
    return true;
}

bool SaleManager::performDailyReconciliation(const QDate &date, double expectedCash,
                                              double actualCash, double totalSales,
                                              double totalExpenses, const QString &reason,
                                              int closedBy)
{
    // Verificar si ya existe
    QSqlQuery check = m_dbManager->executeQuery(
        "SELECT id FROM daily_reconciliations WHERE reconciliation_date = :date",
        {{"date", date.toString(Qt::ISODate)}}
    );

    bool exists = check.next();
    bool balanced = qFuzzyCompare(expectedCash, actualCash);

    if (exists) {
        QSqlQuery query = m_dbManager->executeQuery(
            "UPDATE daily_reconciliations SET total_sales = :total_sales, total_expenses = :total_expenses, "
            "expected_cash = :expected_cash, actual_cash = :actual_cash, difference_reason = :difference_reason, "
            "is_balanced = :is_balanced, closed_by = :closed_by, closed_at = CURRENT_TIMESTAMP "
            "WHERE reconciliation_date = :date",
            {
                {"total_sales", totalSales},
                {"total_expenses", totalExpenses},
                {"expected_cash", expectedCash},
                {"actual_cash", actualCash},
                {"difference_reason", reason.isEmpty() ? QVariant(QVariant::String) : reason},
                {"is_balanced", balanced ? 1 : 0},
                {"closed_by", closedBy},
                {"date", date.toString(Qt::ISODate)}
            }
        );
        return query.lastError().type() == QSqlError::NoError;
    } else {
        QSqlQuery query = m_dbManager->executeQuery(
            "INSERT INTO daily_reconciliations (reconciliation_date, total_sales, total_expenses, "
            "expected_cash, actual_cash, difference_reason, is_balanced, closed_by, closed_at) "
            "VALUES (:date, :total_sales, :total_expenses, :expected_cash, :actual_cash, "
            ":difference_reason, :is_balanced, :closed_by, CURRENT_TIMESTAMP)",
            {
                {"date", date.toString(Qt::ISODate)},
                {"total_sales", totalSales},
                {"total_expenses", totalExpenses},
                {"expected_cash", expectedCash},
                {"actual_cash", actualCash},
                {"difference_reason", reason.isEmpty() ? QVariant(QVariant::String) : reason},
                {"is_balanced", balanced ? 1 : 0},
                {"closed_by", closedBy}
            }
        );
        return query.lastError().type() == QSqlError::NoError;
    }
}

QVariantMap SaleManager::getDailyReconciliation(const QDate &date) const
{
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT * FROM daily_reconciliations WHERE reconciliation_date = :date",
        {{"date", date.toString(Qt::ISODate)}}
    );

    if (query.next()) {
        QVariantMap map;
        map["id"] = query.value("id").toInt();
        map["totalSales"] = query.value("total_sales").toDouble();
        map["totalExpenses"] = query.value("total_expenses").toDouble();
        map["expectedCash"] = query.value("expected_cash").toDouble();
        map["actualCash"] = query.value("actual_cash").toDouble();
        map["difference"] = query.value("difference").toDouble();
        map["isBalanced"] = query.value("is_balanced").toBool();
        map["differenceReason"] = query.value("difference_reason").toString();
        return map;
    }
    return QVariantMap();
}

bool SaleManager::createCustodyRecord(const QDate &date, const QString &custodyType,
                                       double amount, int productCount,
                                       int deliveredBy, int receivedBy,
                                       const QString &notes)
{
    QSqlQuery query = m_dbManager->executeQuery(
        "INSERT INTO custody_records (record_date, custody_type, amount, product_count, "
        "delivered_by, received_by, notes) "
        "VALUES (:date, :custody_type, :amount, :product_count, :delivered_by, :received_by, :notes)",
        {
            {"date", date.toString(Qt::ISODate)},
            {"custody_type", custodyType},
            {"amount", amount},
            {"product_count", productCount},
            {"delivered_by", deliveredBy},
            {"received_by", receivedBy},
            {"notes", notes.isEmpty() ? QVariant(QVariant::String) : notes}
        }
    );

    if (!query.lastError().text().isEmpty()) {
        qWarning() << "Failed to create custody record:" << query.lastError().text();
        return false;
    }

    return true;
}

bool SaleManager::confirmCustody(int custodyId, const QString &pin)
{
    QSqlQuery query = m_dbManager->executeQuery(
        "UPDATE custody_records SET confirmed = 1, receipt_pin = :pin WHERE id = :id",
        {{"pin", pin}, {"id", custodyId}}
    );
    return query.lastError().type() == QSqlError::NoError;
}

void SaleManager::loadSales()
{
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT id, sale_number, client_name, client_phone, client_address, status, "
        "payment_type, subtotal, delivery_cost, commission, total, amount_paid, "
        "notes, created_by, messenger_id, created_at, delivered_at, liquidated_at "
        "FROM sales ORDER BY created_at DESC"
    );

    while (query.next()) {
        m_sales.append(saleFromQuery(query));
    }
}

SaleData SaleManager::saleFromQuery(const QSqlQuery &query) const
{
    SaleData sale;
    sale.id = query.value("id").toInt();
    sale.saleNumber = query.value("sale_number").toString();
    sale.clientName = query.value("client_name").toString();
    sale.clientPhone = query.value("client_phone").toString();
    sale.clientAddress = query.value("client_address").toString();
    sale.status = query.value("status").toString();
    sale.paymentType = query.value("payment_type").toString();
    sale.subtotal = query.value("subtotal").toDouble();
    sale.deliveryCost = query.value("delivery_cost").toDouble();
    sale.commission = query.value("commission").toDouble();
    sale.total = query.value("total").toDouble();
    sale.amountPaid = query.value("amount_paid").toDouble();
    sale.notes = query.value("notes").toString();
    sale.createdBy = query.value("created_by").toInt();
    sale.messengerId = query.value("messenger_id").toInt();
    sale.createdAt = query.value("created_at").toString();
    sale.deliveredAt = query.value("delivered_at").toString();
    sale.liquidatedAt = query.value("liquidated_at").toString();
    return sale;
}

QString SaleManager::generateSaleNumber() const
{
    QString prefix = "V" + QDate::currentDate().toString("yyyyMMdd");
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT COUNT(*) FROM sales WHERE sale_number LIKE :prefix",
        {{"prefix", prefix + "%"}}
    );
    int count = 0;
    if (query.next()) count = query.value(0).toInt();
    return prefix + QString::number(count + 1).rightJustified(3, '0');
}
