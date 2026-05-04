#include "src/controllers/AppController.h"
#include <QDebug>
#include <QSqlQuery>
#include <QStringList>

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

    // SIEMPRE asegurar que SinCategoría existe
    QSqlQuery sinCatQuery = m_dbManager->executeQuery(
        "SELECT category FROM products WHERE category = 'SinCategoría'"
    );
    if (!sinCatQuery.next()) {
        m_dbManager->executeQuery(
            "INSERT INTO products (code, name, category, description, sale_price, stock, min_stock, unit, is_active) "
            "VALUES (:code, :name, :category, :description, 0, 0, 0, 'unidad', 0)",
            {
                {"code", "CAT-SINCAT"},
                {"name", "CATEGORIA:SinCategoría"},
                {"category", "SinCategoría"},
                {"description", "Categoría por defecto para productos sin categoría"}
            }
        );
    }

    // Creamos un producto "dummy" como categoría
    // Lo mantenemos inactivo (is_active = 0) para que persista la categoría
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

    // El producto queda inactivo pero existe, así que la categoría persiste
    return insertQuery.lastError().type() == QSqlError::NoError;
}

bool AppController::deleteCategory(const QString &categoryName)
{
    // Verificar si hay productos con esta categoría
    QSqlQuery checkQuery = m_dbManager->executeQuery(
        "SELECT COUNT(*) as count FROM products WHERE LOWER(category) = LOWER(:category) AND is_active = 1",
        {{"category", categoryName}}
    );

    if (checkQuery.next() && checkQuery.value("count").toInt() > 0) {
        // Hay productos activos con esta categoría, no se puede eliminar
        return false;
    }

    // Eliminar productos inactivos de esta categoría (categorías "dummy")
    QSqlQuery deleteQuery = m_dbManager->executeQuery(
        "DELETE FROM products WHERE LOWER(category) = LOWER(:category) AND is_active = 0",
        {{"category", categoryName}}
    );

    return deleteQuery.lastError().type() == QSqlError::NoError;
}

QVariantList AppController::getSuppliersList() const
{
    QVariantList list;
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT id, code, name, contact_person, phone, email, address FROM suppliers WHERE is_active = 1 ORDER BY name"
    );

    while (query.next()) {
        QVariantMap map;
        map["id"] = query.value("id").toInt();
        map["code"] = query.value("code").toString();
        map["name"] = query.value("name").toString();
        map["contact_person"] = query.value("contact_person").toString();
        map["phone"] = query.value("phone").toString();
        map["email"] = query.value("email").toString();
        map["address"] = query.value("address").toString();
        list.append(map);
    }
    return list;
}

bool AppController::addSupplier(const QString &name, const QString &contact, const QString &phone, const QString &email, const QString &address)
{
    // Generar código de proveedor
    QString initials;
    QStringList words = name.toUpper().split(" ", Qt::SkipEmptyParts);
    for (int i = 0; i < qMin(3, words.length()); i++) {
        if (words[i].length() > 0) {
            initials += words[i].left(1);
        }
    }

    QSqlQuery countQuery = m_dbManager->executeQuery(
        "SELECT COUNT(*) FROM suppliers WHERE code LIKE :pattern",
        {{"pattern", "PRO-" + initials + "%"}}
    );

    int nextNum = 1;
    if (countQuery.next()) {
        nextNum = countQuery.value(0).toInt() + 1;
    }

    QString code = "PRO-" + initials + "-" + QString("%1").arg(nextNum, 3, 10, QChar('0'));

    QSqlQuery insertQuery = m_dbManager->executeQuery(
        "INSERT INTO suppliers (code, name, contact_person, phone, email, address) "
        "VALUES (:code, :name, :contact, :phone, :email, :address)",
        {
            {"code", code},
            {"name", name},
            {"contact", contact.isEmpty() ? QString() : contact},
            {"phone", phone.isEmpty() ? QString() : phone},
            {"email", email.isEmpty() ? QString() : email},
            {"address", address.isEmpty() ? QString() : address}
        }
    );

    return insertQuery.lastError().type() == QSqlError::NoError;
}

bool AppController::deleteSupplier(int id)
{
    QSqlQuery deleteQuery = m_dbManager->executeQuery(
        "DELETE FROM suppliers WHERE id = :id",
        {{"id", id}}
    );
    return deleteQuery.lastError().type() == QSqlError::NoError;
}

bool AppController::updateSupplier(int id, const QString &name, const QString &contact, const QString &phone, const QString &email, const QString &address)
{
    QSqlQuery updateQuery = m_dbManager->executeQuery(
        "UPDATE suppliers SET name = :name, contact_person = :contact, phone = :phone, email = :email, address = :address WHERE id = :id",
        {
            {"id", id},
            {"name", name},
            {"contact", contact.isEmpty() ? QString() : contact},
            {"phone", phone.isEmpty() ? QString() : phone},
            {"email", email.isEmpty() ? QString() : email},
            {"address", address.isEmpty() ? QString() : address}
        }
    );
    return updateQuery.lastError().type() == QSqlError::NoError;
}

QString AppController::generateProductCode()
{
    // Generar código de producto automático: PROD-0001, PROD-0002, etc.
    QSqlQuery countQuery = m_dbManager->executeQuery("SELECT COUNT(*) FROM products WHERE is_active = 1");
    int nextNum = 1;
    if (countQuery.next()) {
        nextNum = countQuery.value(0).toInt() + 1;
    }
    return QString("PROD-%1").arg(nextNum, 4, 10, QChar('0'));
}
