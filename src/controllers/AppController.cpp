#include "src/controllers/AppController.h"
#include <QDebug>
#include <QSqlQuery>

AppController::AppController(QObject *parent)
    : QObject(parent),
      m_dbManager(new DatabaseManager(this)),
      m_userManager(nullptr),
      m_productManager(nullptr),
      m_saleManager(nullptr),
      m_inventoryManager(nullptr),
      m_expenseManager(nullptr),
      m_payrollManager(nullptr),
      m_inventoryService(nullptr),
      m_reportService(nullptr)
{
}

AppController::~AppController()
{
    delete m_userManager;
    delete m_productManager;
    delete m_saleManager;
    delete m_inventoryManager;
    delete m_expenseManager;
    delete m_payrollManager;
    delete m_inventoryService;
    delete m_reportService;
}

bool AppController::initialize()
{
    if (!m_dbManager->initialize()) {
        qCritical() << "Failed to initialize database";
        return false;
    }

    m_userManager = new UserManager(m_dbManager, this);
    m_productManager = new ProductManager(m_dbManager, this);
    m_saleManager = new SaleManager(m_dbManager, this);
    m_inventoryManager = new InventoryManager(m_dbManager, this);
    m_expenseManager = new ExpenseManager(m_dbManager, this);
    m_payrollManager = new PayrollManager(m_dbManager, this);
    m_inventoryService = new InventoryService(m_dbManager, this);
    m_reportService = new ReportService(m_dbManager, this);

    m_initialized = true;
    emit isInitializedChanged();
    return true;
}

QVariantMap AppController::getConfig() const
{
    QVariantMap config;
    QSqlQuery query = m_dbManager->executeQuery("SELECT key, value FROM config");
    while (query.next()) {
        config[query.value("key").toString()] = query.value("value").toString();
    }
    return config;
}

bool AppController::updateConfig(const QString &key, const QString &value)
{
    QSqlQuery query = m_dbManager->executeQuery(
        "INSERT INTO config (key, value) VALUES (:key, :value) "
        "ON CONFLICT(key) DO UPDATE SET value = :value, updated_at = CURRENT_TIMESTAMP",
        {{"key", key}, {"value", value}}
    );
    return query.lastError().type() == QSqlError::NoError;
}

bool AppController::addCategory(const QString &categoryName)
{
    // Las categorías se almacenan junto con los productos
    // Verificamos si ya existe para no duplicar
    QSqlQuery checkQuery = m_dbManager->executeQuery(
        "SELECT DISTINCT category FROM products WHERE LOWER(category) = LOWER(:category)",
        {{"category", categoryName}}
    );

    if (checkQuery.next()) {
        // Ya existe la categoría
        return false;
    }

    // Creamos un producto "dummy" temporal para crear la categoría
    // Luego lo eliminamos pero la categoría queda en la lista de categorías
    QSqlQuery insertQuery = m_dbManager->executeQuery(
        "INSERT INTO products (code, name, category, description, sale_price, stock, min_stock, unit, is_active) "
        "VALUES (:code, :name, :category, :description, 0, 0, 0, 'unidad', 0)",
        {
            {"code", "CAT-" + QString::number(QDateTime::currentSecsSinceEpoch())},
            {"name", "CATEGORIA:" + categoryName},
            {"category", categoryName},
            {"description", "Categoría temporal"}
        }
    );

    // Eliminar el producto temporal, pero la categoría queda
    if (insertQuery.lastError().type() == QSqlError::NoError) {
        int lastId = insertQuery.lastInsertId().toInt();
        m_dbManager->executeQuery("DELETE FROM products WHERE id = :id", {{"id", lastId}});
        return true;
    }

    return false;
}
