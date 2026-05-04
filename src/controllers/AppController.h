#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <QObject>
#include <QDate>
#include <QVariantMap>
#include <qqml.h>
#include "src/database/DatabaseManager.h"
#include "src/models/User.h"
#include "src/models/Product.h"
#include "src/models/Sale.h"
#include "src/models/Inventory.h"
#include "src/models/Expense.h"
#include "src/models/Payroll.h"
#include "src/services/InventoryService.h"
#include "src/services/ReportService.h"

class AppController : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isInitialized READ isInitialized NOTIFY isInitializedChanged)
    Q_PROPERTY(QString currentDate READ currentDate CONSTANT)
    QML_ELEMENT

public:
    explicit AppController(QObject *parent = nullptr);
    ~AppController();

    bool isInitialized() const { return m_initialized; }
    QString currentDate() const { return QDate::currentDate().toString(Qt::ISODate); }

    bool initialize();

    UserManager* userManager() const { return m_userManager; }
    ProductManager* productManager() const { return m_productManager; }
    SaleManager* saleManager() const { return m_saleManager; }
    InventoryManager* inventoryManager() const { return m_inventoryManager; }
    ExpenseManager* expenseManager() const { return m_expenseManager; }
    PayrollManager* payrollManager() const { return m_payrollManager; }
    ReportService* reportManager() const { return m_reportService; }

    Q_INVOKABLE QVariantMap getConfig() const;
    Q_INVOKABLE bool updateConfig(const QString &key, const QString &value);
    Q_INVOKABLE bool addCategory(const QString &categoryName);
    Q_INVOKABLE bool deleteCategory(const QString &categoryName);

    // Proveedores
    Q_INVOKABLE QVariantList getSuppliersList() const;
    Q_INVOKABLE bool addSupplier(const QString &name, const QString &contact, const QString &phone, const QString &email, const QString &address);
    Q_INVOKABLE bool deleteSupplier(int id);
    Q_INVOKABLE bool updateSupplier(int id, const QString &name, const QString &contact, const QString &phone, const QString &email, const QString &address);
    Q_INVOKABLE QString generateProductCode();

signals:
    void isInitializedChanged();

private:
    DatabaseManager *m_dbManager;
    UserManager *m_userManager;
    ProductManager *m_productManager;
    SaleManager *m_saleManager;
    InventoryManager *m_inventoryManager;
    ExpenseManager *m_expenseManager;
    PayrollManager *m_payrollManager;
    InventoryService *m_inventoryService;
    ReportService *m_reportService;
    bool m_initialized = false;
};

#endif // APPCONTROLLER_H
