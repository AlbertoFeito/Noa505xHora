#ifndef PRODUCT_H
#define PRODUCT_H

#include <QObject>
#include <QAbstractListModel>
#include <QVector>
#include <QSqlQuery>
#include <QVariantMap>
#include <QVariantList>
#include <qqml.h>
#include "../database/DatabaseManager.h"

struct ProductData {
    int id = 0;
    QString code;
    QString name;
    QString category;
    QString description;
    double purchasePrice = 0;
    double salePrice = 0;
    int stock = 0;
    int minStock = 0;
    QString unit;
    bool isActive = true;
    QString createdAt;
};

class ProductManager : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int lowStockCount READ lowStockCount NOTIFY lowStockCountChanged)
    QML_ELEMENT

public:
    enum ProductRoles {
        IdRole = Qt::UserRole + 1,
        CodeRole,
        NameRole,
        CategoryRole,
        DescriptionRole,
        PurchasePriceRole,
        SalePriceRole,
        StockRole,
        MinStockRole,
        UnitRole,
        IsActiveRole
    };

    explicit ProductManager(DatabaseManager *dbManager, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int lowStockCount() const;

    Q_INVOKABLE bool addProduct(const QString &code, const QString &name, const QString &category,
                                 double salePrice, int stock, const QString &unit = QStringLiteral("unidad"),
                                 const QString &description = QString(), int minStock = 0);
    Q_INVOKABLE bool updateProduct(int id, const QVariantMap &fields);
    Q_INVOKABLE bool deleteProduct(int id);
    Q_INVOKABLE QVariantMap getProduct(int id) const;
    Q_INVOKABLE QVariantList getLowStockProducts() const;
    Q_INVOKABLE QVariantList getCategories() const;
    Q_INVOKABLE void refreshProducts();
    Q_INVOKABLE bool adjustStock(int productId, int newQuantity, const QString &reason);
    Q_INVOKABLE bool addStock(int productId, int quantityToAdd, const QString &invoiceNumber);
    Q_INVOKABLE QVariantList getAllProductsList() const;

signals:
    void lowStockCountChanged();
    void productsRefreshed();

private:
    void loadProducts();
    ProductData productFromQuery(const QSqlQuery &query) const;

    DatabaseManager *m_dbManager;
    QVector<ProductData> m_products;
};

#endif // PRODUCT_H
