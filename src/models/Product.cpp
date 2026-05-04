#include "Product.h"
#include <QDebug>

ProductManager::ProductManager(DatabaseManager *dbManager, QObject *parent)
    : QAbstractListModel(parent), m_dbManager(dbManager)
{
    loadProducts();
}

int ProductManager::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_products.count();
}

QVariant ProductManager::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_products.count())
        return QVariant();

    const ProductData &product = m_products.at(index.row());
    switch (role) {
        case IdRole: return product.id;
        case CodeRole: return product.code;
        case NameRole: return product.name;
        case CategoryRole: return product.category;
        case DescriptionRole: return product.description;
        case PurchasePriceRole: return product.purchasePrice;
        case SalePriceRole: return product.salePrice;
        case StockRole: return product.stock;
        case MinStockRole: return product.minStock;
        case UnitRole: return product.unit;
        case SupplierRole: return product.supplier;
        case LoteRole: return product.lote;
        case IsActiveRole: return product.isActive;
    }
    return QVariant();
}

QHash<int, QByteArray> ProductManager::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[CodeRole] = "code";
    roles[NameRole] = "name";
    roles[CategoryRole] = "category";
    roles[DescriptionRole] = "description";
    roles[PurchasePriceRole] = "purchasePrice";
    roles[SalePriceRole] = "salePrice";
    roles[StockRole] = "stock";
    roles[MinStockRole] = "minStock";
    roles[UnitRole] = "unit";
    roles[SupplierRole] = "supplier";
    roles[LoteRole] = "lote";
    roles[IsActiveRole] = "isActive";
    return roles;
}

int ProductManager::lowStockCount() const
{
    int count = 0;
    for (const ProductData &p : m_products) {
        if (p.stock <= p.minStock) count++;
    }
    return count;
}

bool ProductManager::addProduct(const QString &code, const QString &name, const QString &category,
                                 double salePrice, int stock, const QString &unit,
                                 const QString &description, int minStock, double purchasePrice, const QString &supplier,
                                 const QString &loteInput)
{
    // Si se proporciona lote, usarlo; si no, generar automáticamente
    QString lote = loteInput.isEmpty()
        ? "LOTE-" + QDateTime::currentDateTime().toString("yyyyMMdd-hhmmss") + "-" + supplier
        : loteInput;

    QSqlQuery query = m_dbManager->executeQuery(
        "INSERT INTO products (code, name, category, description, sale_price, purchase_price, supplier, lote, stock, min_stock, unit) "
        "VALUES (:code, :name, :category, :description, :sale_price, :purchase_price, :supplier, :lote, :stock, :min_stock, :unit)",
        {
            {"code", code},
            {"name", name},
            {"category", category},
            {"description", description.isEmpty() ? QString() : description},
            {"sale_price", salePrice},
            {"purchase_price", purchasePrice},
            {"supplier", supplier.isEmpty() ? QString() : supplier},
            {"lote", lote},
            {"stock", stock},
            {"min_stock", minStock},
            {"unit", unit}
        }
    );

    if (!query.lastError().text().isEmpty()) {
        qWarning() << "Failed to add product:" << query.lastError().text();
        return false;
    }

    refreshProducts();
    return true;
}

bool ProductManager::updateProduct(int id, const QVariantMap &fields)
{
    QStringList setParts;
    QVariantMap bindings = {{"id", id}};

    if (fields.contains("name")) { setParts << "name = :name"; bindings["name"] = fields["name"]; }
    if (fields.contains("code")) { setParts << "code = :code"; bindings["code"] = fields["code"]; }
    if (fields.contains("category")) { setParts << "category = :category"; bindings["category"] = fields["category"]; }
    if (fields.contains("salePrice")) { setParts << "sale_price = :sale_price"; bindings["sale_price"] = fields["salePrice"]; }
    if (fields.contains("purchasePrice")) { setParts << "purchase_price = :purchase_price"; bindings["purchase_price"] = fields["purchasePrice"]; }
    if (fields.contains("stock")) { setParts << "stock = :stock"; bindings["stock"] = fields["stock"]; }
    if (fields.contains("minStock")) { setParts << "min_stock = :min_stock"; bindings["min_stock"] = fields["minStock"]; }
    if (fields.contains("unit")) { setParts << "unit = :unit"; bindings["unit"] = fields["unit"]; }

    if (setParts.isEmpty()) return false;

    QString sql = "UPDATE products SET " + setParts.join(", ") + " WHERE id = :id";
    QSqlQuery query = m_dbManager->executeQuery(sql, bindings);

    if (!query.lastError().text().isEmpty()) {
        qWarning() << "Failed to update product:" << query.lastError().text();
        return false;
    }

    refreshProducts();
    return true;
}

bool ProductManager::deleteProduct(int id)
{
    return updateProduct(id, {{"isActive", false}});
}

QVariantMap ProductManager::getProduct(int id) const
{
    for (const ProductData &p : m_products) {
        if (p.id == id) {
            QVariantMap map;
            map["id"] = p.id;
            map["code"] = p.code;
            map["name"] = p.name;
            map["category"] = p.category;
            map["salePrice"] = p.salePrice;
            map["stock"] = p.stock;
            map["minStock"] = p.minStock;
            map["unit"] = p.unit;
            return map;
        }
    }
    return QVariantMap();
}

QVariantList ProductManager::getLowStockProducts() const
{
    QVariantList list;
    for (const ProductData &p : m_products) {
        if (p.stock <= p.minStock && p.isActive) {
            QVariantMap map;
            map["id"] = p.id;
            map["name"] = p.name;
            map["stock"] = p.stock;
            map["minStock"] = p.minStock;
            list.append(map);
        }
    }
    return list;
}

QVariantList ProductManager::getAllProductsList() const
{
    QVariantList list;
    for (const ProductData &p : m_products) {
        if (p.isActive) {
            QVariantMap map;
            map["id"] = p.id;
            map["code"] = p.code;
            map["name"] = p.name;
            map["stock"] = p.stock;
            map["minStock"] = p.minStock;
            map["category"] = p.category;
            map["salePrice"] = p.salePrice;
            map["purchasePrice"] = p.purchasePrice;
            map["supplier"] = p.supplier;
            map["lote"] = p.lote;
            map["unit"] = p.unit;
            list.append(map);
        }
    }
    return list;
}

QVariantList ProductManager::getCategories() const
{
    // Primero asegurar que SinCategoría existe
    QSqlQuery sinCatCheck = m_dbManager->executeQuery(
        "SELECT category FROM products WHERE category = 'SinCategoría'"
    );
    if (!sinCatCheck.next()) {
        // Crear SinCategoría si no existe
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

    // Consultar categorías directamente de la BD
    // Solo cuenta productos ACTIVOS (reales), no los dummy de categorías
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT category, COUNT(*) as count FROM products "
        "WHERE category != '' AND category IS NOT NULL AND is_active = 1 "
        "GROUP BY category ORDER BY category"
    );

    QVariantList list;

    // Agregar opción "Todas" al inicio
    QVariantMap allOption;
    allOption["category"] = "Todas";
    allOption["count"] = 0;
    list.append(allOption);

    // Obtener todas las categorías (incluyendo las que no tienen productos activos)
    QSqlQuery catQuery = m_dbManager->executeQuery(
        "SELECT DISTINCT category FROM products "
        "WHERE category != '' AND category IS NOT NULL "
        "ORDER BY category"
    );

    QSet<QString> existingCategories;
    while (catQuery.next()) {
        existingCategories.insert(catQuery.value("category").toString());
    }

    // Mapear counts a las categorías
    QMap<QString, int> counts;
    while (query.next()) {
        counts[query.value("category").toString()] = query.value("count").toInt();
    }

    // Agregar SinCategoría primero (si existe)
    if (existingCategories.contains("SinCategoría")) {
        QVariantMap map;
        map["category"] = "SinCategoría";
        map["count"] = counts.value("SinCategoría", 0);
        list.append(map);
    }

    // Agregar las demás categorías (excepto SinCategoría que ya está)
    for (const QString &cat : existingCategories) {
        if (cat != "SinCategoría") {
            QVariantMap map;
            map["category"] = cat;
            map["count"] = counts.value(cat, 0);
            list.append(map);
        }
    }

    return list;
}

void ProductManager::refreshProducts()
{
    beginResetModel();
    m_products.clear();
    loadProducts();
    endResetModel();
    emit productsRefreshed();
    emit lowStockCountChanged();
}

bool ProductManager::adjustStock(int productId, int newQuantity, const QString &reason)
{
    // Insertar en inventory_counts para trazabilidad
    QSqlQuery countQuery = m_dbManager->executeQuery(
        "INSERT INTO inventory_counts (product_id, expected_quantity, actual_quantity, notes) "
        "VALUES (:product_id, (SELECT stock FROM products WHERE id = :pid), :actual, :notes)",
        {
            {"product_id", productId},
            {"pid", productId},
            {"actual", newQuantity},
            {"notes", reason}
        }
    );

    if (countQuery.lastError().type() != QSqlError::NoError) {
        qWarning() << "Failed to log inventory adjustment:" << countQuery.lastError().text();
    }

    return updateProduct(productId, {{"stock", newQuantity}});
}

bool ProductManager::addStock(int productId, int quantityToAdd, const QString &invoiceNumber)
{
    // Sumar cantidad al stock actual
    // Primero obtener el stock actual
    QSqlQuery getQuery = m_dbManager->executeQuery(
        "SELECT stock FROM products WHERE id = :id",
        {{"id", productId}}
    );

    if (!getQuery.next()) {
        qWarning() << "Product not found:" << productId;
        return false;
    }

    int currentStock = getQuery.value("stock").toInt();
    int newStock = currentStock + quantityToAdd;

    // Actualizar el stock
    bool success = updateProduct(productId, {{"stock", newStock}});

    if (success) {
        // Registrar la entrada en inventory_counts para trazabilidad
        QSqlQuery insertQuery = m_dbManager->executeQuery(
            "INSERT INTO inventory_counts (product_id, expected_quantity, actual_quantity, notes, counted_by) "
            "VALUES (:product_id, :expected, :actual, :notes, 0)",
            {
                {"product_id", productId},
                {"expected", currentStock},
                {"actual", newStock},
                {"notes", "Entrada: Factura " + invoiceNumber}
            }
        );
        qDebug() << "Insert into inventory_counts result:" << insertQuery.lastError().text();
    }

    return success;
}

void ProductManager::loadProducts()
{
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT id, code, name, category, description, purchase_price, sale_price, "
        "stock, min_stock, unit, supplier, lote, is_active, created_at FROM products WHERE is_active = 1 ORDER BY name"
    );

    while (query.next()) {
        m_products.append(productFromQuery(query));
    }
}

ProductData ProductManager::productFromQuery(const QSqlQuery &query) const
{
    ProductData p;
    p.id = query.value("id").toInt();
    p.code = query.value("code").toString();
    p.name = query.value("name").toString();
    p.category = query.value("category").toString();
    p.description = query.value("description").toString();
    p.purchasePrice = query.value("purchase_price").toDouble();
    p.salePrice = query.value("sale_price").toDouble();
    p.stock = query.value("stock").toInt();
    p.minStock = query.value("min_stock").toInt();
    p.unit = query.value("unit").toString();
    p.supplier = query.value("supplier").toString();
    p.lote = query.value("lote").toString();
    p.isActive = query.value("is_active").toBool();
    p.createdAt = query.value("created_at").toString();
    return p;
}

QString ProductManager::generateProductCode() const
{
    // Generar código de producto automático: PROD-0001, PROD-0002, etc.
    QSqlQuery countQuery = m_dbManager->executeQuery("SELECT COUNT(*) FROM products WHERE is_active = 1");
    int nextNum = 1;
    if (countQuery.next()) {
        nextNum = countQuery.value(0).toInt() + 1;
    }
    return QString("PROD-%1").arg(nextNum, 4, 10, QChar('0'));
}
