#include "ReportService.h"
#include <QSqlQuery>
#include <QDebug>

ReportService::ReportService(DatabaseManager *dbManager, QObject *parent)
    : QObject(parent), m_dbManager(dbManager)
{
}

QVariantMap ReportService::getSalesReport(const QDate &from, const QDate &to) const
{
    QVariantMap report;

    QSqlQuery totalQuery = m_dbManager->executeQuery(
        "SELECT COUNT(*) as count, COALESCE(SUM(total), 0) as total, "
        "COALESCE(SUM(delivery_cost), 0) as delivery, COALESCE(SUM(commission), 0) as commission "
        "FROM sales WHERE DATE(created_at) BETWEEN :from AND :to AND status = 'liquidado'",
        {
            {"from", from.toString(Qt::ISODate)},
            {"to", to.toString(Qt::ISODate)}
        }
    );

    if (totalQuery.next()) {
        report["saleCount"] = totalQuery.value("count").toInt();
        report["totalSales"] = totalQuery.value("total").toDouble();
        report["totalDelivery"] = totalQuery.value("delivery").toDouble();
        report["totalCommission"] = totalQuery.value("commission").toDouble();
    }

    QSqlQuery pendingQuery = m_dbManager->executeQuery(
        "SELECT COUNT(*) as count, COALESCE(SUM(total - amount_paid), 0) as pending "
        "FROM sales WHERE DATE(created_at) BETWEEN :from AND :to AND status != 'liquidado'",
        {
            {"from", from.toString(Qt::ISODate)},
            {"to", to.toString(Qt::ISODate)}
        }
    );

    if (pendingQuery.next()) {
        report["pendingCount"] = pendingQuery.value("count").toInt();
        report["pendingAmount"] = pendingQuery.value("pending").toDouble();
    }

    return report;
}

QVariantList ReportService::getSalesByDay(const QDate &from, const QDate &to) const
{
    QVariantList list;
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT DATE(created_at) as day, COUNT(*) as count, COALESCE(SUM(total), 0) as total "
        "FROM sales WHERE DATE(created_at) BETWEEN :from AND :to "
        "GROUP BY DATE(created_at) ORDER BY day",
        {
            {"from", from.toString(Qt::ISODate)},
            {"to", to.toString(Qt::ISODate)}
        }
    );

    while (query.next()) {
        QVariantMap map;
        map["date"] = query.value("day").toString();
        map["count"] = query.value("count").toInt();
        map["total"] = query.value("total").toDouble();
        list.append(map);
    }
    return list;
}

QVariantList ReportService::getTopProducts(const QDate &from, const QDate &to, int limit) const
{
    QVariantList list;
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT si.product_id, si.product_name, SUM(si.quantity) as qty, SUM(si.total_price) as revenue "
        "FROM sale_items si "
        "JOIN sales s ON si.sale_id = s.id "
        "WHERE DATE(s.created_at) BETWEEN :from AND :to "
        "GROUP BY si.product_id, si.product_name "
        "ORDER BY qty DESC LIMIT :limit",
        {
            {"from", from.toString(Qt::ISODate)},
            {"to", to.toString(Qt::ISODate)},
            {"limit", limit}
        }
    );

    while (query.next()) {
        QVariantMap map;
        map["productId"] = query.value("product_id").toInt();
        map["productName"] = query.value("product_name").toString();
        map["quantity"] = query.value("qty").toInt();
        map["revenue"] = query.value("revenue").toDouble();
        list.append(map);
    }
    return list;
}

QVariantMap ReportService::getFinancialReport(const QDate &from, const QDate &to) const
{
    QVariantMap report;

    // Ingresos
    QSqlQuery incomeQuery = m_dbManager->executeQuery(
        "SELECT COALESCE(SUM(total), 0) as income FROM sales "
        "WHERE DATE(created_at) BETWEEN :from AND :to AND status = 'liquidado'",
        {
            {"from", from.toString(Qt::ISODate)},
            {"to", to.toString(Qt::ISODate)}
        }
    );
    if (incomeQuery.next()) report["totalIncome"] = incomeQuery.value("income").toDouble();

    // Gastos
    QSqlQuery expenseQuery = m_dbManager->executeQuery(
        "SELECT COALESCE(SUM(amount), 0) as expenses FROM expenses "
        "WHERE expense_date BETWEEN :from AND :to",
        {
            {"from", from.toString(Qt::ISODate)},
            {"to", to.toString(Qt::ISODate)}
        }
    );
    if (expenseQuery.next()) report["totalExpenses"] = expenseQuery.value("expenses").toDouble();

    report["netResult"] = report["totalIncome"].toDouble() - report["totalExpenses"].toDouble();

    return report;
}

QVariantList ReportService::getExpensesReport(const QDate &from, const QDate &to) const
{
    QVariantList list;
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT category, COALESCE(SUM(amount), 0) as total "
        "FROM expenses WHERE expense_date BETWEEN :from AND :to "
        "GROUP BY category ORDER BY total DESC",
        {
            {"from", from.toString(Qt::ISODate)},
            {"to", to.toString(Qt::ISODate)}
        }
    );

    while (query.next()) {
        QVariantMap map;
        map["category"] = query.value("category").toString();
        map["amount"] = query.value("total").toDouble();
        list.append(map);
    }
    return list;
}

QVariantMap ReportService::getONATReport(int month, int year) const
{
    QVariantMap report;
    QDate from(year, month, 1);
    QDate to = from.addMonths(1).addDays(-1);

    // Ingresos declarables
    QSqlQuery incomeQuery = m_dbManager->executeQuery(
        "SELECT COALESCE(SUM(total), 0) as income FROM sales "
        "WHERE DATE(created_at) BETWEEN :from AND :to AND status = 'liquidado'",
        {
            {"from", from.toString(Qt::ISODate)},
            {"to", to.toString(Qt::ISODate)}
        }
    );
    if (incomeQuery.next()) report["declarableIncome"] = incomeQuery.value("income").toDouble();

    // Gastos deducibles
    QSqlQuery expenseQuery = m_dbManager->executeQuery(
        "SELECT category, COALESCE(SUM(amount), 0) as total "
        "FROM expenses WHERE expense_date BETWEEN :from AND :to "
        "GROUP BY category",
        {
            {"from", from.toString(Qt::ISODate)},
            {"to", to.toString(Qt::ISODate)}
        }
    );

    QVariantList deductibleExpenses;
    double totalDeductions = 0;
    while (expenseQuery.next()) {
        QVariantMap map;
        map["category"] = expenseQuery.value("category").toString();
        map["amount"] = expenseQuery.value("total").toDouble();
        totalDeductions += map["amount"].toDouble();
        deductibleExpenses.append(map);
    }

    report["deductions"] = deductibleExpenses;
    report["totalDeductions"] = totalDeductions;
    report["taxableBase"] = report["declarableIncome"].toDouble() - totalDeductions;
    report["month"] = month;
    report["year"] = year;

    return report;
}

QVariantList ReportService::getMessengerPerformance(const QDate &from, const QDate &to) const
{
    QVariantList list;
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT s.messenger_id, u.full_name, COUNT(*) as deliveries, "
        "COALESCE(SUM(s.delivery_cost), 0) as delivery_total, "
        "COALESCE(SUM(s.commission), 0) as commission_total "
        "FROM sales s "
        "JOIN users u ON s.messenger_id = u.id "
        "WHERE DATE(s.created_at) BETWEEN :from AND :to AND s.messenger_id IS NOT NULL "
        "GROUP BY s.messenger_id, u.full_name",
        {
            {"from", from.toString(Qt::ISODate)},
            {"to", to.toString(Qt::ISODate)}
        }
    );

    while (query.next()) {
        QVariantMap map;
        map["messengerId"] = query.value("messenger_id").toInt();
        map["messengerName"] = query.value("full_name").toString();
        map["deliveries"] = query.value("deliveries").toInt();
        map["deliveryTotal"] = query.value("delivery_total").toDouble();
        map["commissionTotal"] = query.value("commission_total").toDouble();
        list.append(map);
    }
    return list;
}

QVariantList ReportService::getSalesByCommercial(const QDate &from, const QDate &to) const
{
    QVariantList list;
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT s.created_by, u.full_name, COUNT(*) as sales_count, COALESCE(SUM(s.total), 0) as total "
        "FROM sales s "
        "JOIN users u ON s.created_by = u.id "
        "WHERE DATE(s.created_at) BETWEEN :from AND :to "
        "GROUP BY s.created_by, u.full_name",
        {
            {"from", from.toString(Qt::ISODate)},
            {"to", to.toString(Qt::ISODate)}
        }
    );

    while (query.next()) {
        QVariantMap map;
        map["userId"] = query.value("created_by").toInt();
        map["userName"] = query.value("full_name").toString();
        map["salesCount"] = query.value("sales_count").toInt();
        map["total"] = query.value("total").toDouble();
        list.append(map);
    }
    return list;
}

QVariantMap ReportService::getDashboardMetrics() const
{
    QVariantMap metrics;
    QDate today = QDate::currentDate();
    QDate startOfMonth(today.year(), today.month(), 1);

    // Ventas hoy
    QSqlQuery todaySales = m_dbManager->executeQuery(
        "SELECT COUNT(*) as count, COALESCE(SUM(total), 0) as total FROM sales WHERE DATE(created_at) = :today",
        {{"today", today.toString(Qt::ISODate)}}
    );
    if (todaySales.next()) {
        metrics["todaySalesCount"] = todaySales.value("count").toInt();
        metrics["todaySalesTotal"] = todaySales.value("total").toDouble();
    }

    // Ventas mes
    QSqlQuery monthSales = m_dbManager->executeQuery(
        "SELECT COALESCE(SUM(total), 0) as total FROM sales WHERE DATE(created_at) BETWEEN :from AND :to",
        {
            {"from", startOfMonth.toString(Qt::ISODate)},
            {"to", today.toString(Qt::ISODate)}
        }
    );
    if (monthSales.next()) metrics["monthSalesTotal"] = monthSales.value("total").toDouble();

    // Gastos hoy
    QSqlQuery todayExpenses = m_dbManager->executeQuery(
        "SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE expense_date = :today",
        {{"today", today.toString(Qt::ISODate)}}
    );
    if (todayExpenses.next()) metrics["todayExpenses"] = todayExpenses.value("total").toDouble();

    // Productos bajo stock
    QSqlQuery lowStock = m_dbManager->executeQuery(
        "SELECT COUNT(*) as count FROM products WHERE is_active = 1 AND stock <= min_stock"
    );
    if (lowStock.next()) metrics["lowStockCount"] = lowStock.value("count").toInt();

    // Total productos
    QSqlQuery totalProducts = m_dbManager->executeQuery(
        "SELECT COUNT(*) as count FROM products WHERE is_active = 1"
    );
    if (totalProducts.next()) metrics["totalProducts"] = totalProducts.value("count").toInt();

    // Valor inventario
    QSqlQuery stockValue = m_dbManager->executeQuery(
        "SELECT COALESCE(SUM(stock * sale_price), 0) as value FROM products WHERE is_active = 1"
    );
    if (stockValue.next()) metrics["stockValue"] = stockValue.value("value").toDouble();

    return metrics;
}
