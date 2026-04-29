#ifndef REPORTSERVICE_H
#define REPORTSERVICE_H

#include <QObject>
#include <QDate>
#include <QVariantMap>
#include <QVariantList>
#include <qqml.h>
#include "../database/DatabaseManager.h"

class ReportService : public QObject {
    Q_OBJECT
    QML_ELEMENT

public:
    explicit ReportService(DatabaseManager *dbManager, QObject *parent = nullptr);

    // Reportes de ventas
    Q_INVOKABLE QVariantMap getSalesReport(const QDate &from, const QDate &to) const;
    Q_INVOKABLE QVariantList getSalesByDay(const QDate &from, const QDate &to) const;
    Q_INVOKABLE QVariantList getTopProducts(const QDate &from, const QDate &to, int limit = 10) const;

    // Reportes financieros
    Q_INVOKABLE QVariantMap getFinancialReport(const QDate &from, const QDate &to) const;
    Q_INVOKABLE QVariantList getExpensesReport(const QDate &from, const QDate &to) const;

    // Reporte ONAT
    Q_INVOKABLE QVariantMap getONATReport(int month, int year) const;

    // Reporte de desempeño
    Q_INVOKABLE QVariantList getMessengerPerformance(const QDate &from, const QDate &to) const;
    Q_INVOKABLE QVariantList getSalesByCommercial(const QDate &from, const QDate &to) const;

    // Dashboard admin
    Q_INVOKABLE QVariantMap getDashboardMetrics() const;

private:
    DatabaseManager *m_dbManager;
};

#endif // REPORTSERVICE_H
