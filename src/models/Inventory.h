#ifndef INVENTORY_H
#define INVENTORY_H

#include <QObject>
#include <QAbstractListModel>
#include <QVector>
#include <QDate>
#include <QVariantList>
#include <qqml.h>
#include "../database/DatabaseManager.h"

struct InventoryCountData {
    int id = 0;
    QDate countDate;
    int productId = 0;
    QString productName;
    int expectedQuantity = 0;
    int actualQuantity = 0;
    int difference = 0;
    QString notes;
    int countedBy = 0;
    QString countedByName;
    QString createdAt;
};

class InventoryManager : public QAbstractListModel {
    Q_OBJECT
    QML_ELEMENT

public:
    enum InventoryRoles {
        IdRole = Qt::UserRole + 1,
        CountDateRole,
        ProductIdRole,
        ProductNameRole,
        ExpectedQuantityRole,
        ActualQuantityRole,
        DifferenceRole,
        NotesRole,
        CountedByRole,
        CountedByNameRole
    };

    explicit InventoryManager(DatabaseManager *dbManager, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE bool addInventoryCount(int productId, int actualQuantity, const QString &notes, int countedBy);
    Q_INVOKABLE bool updateInventoryCount(int countId, int actualQuantity, const QString &notes);
    Q_INVOKABLE QVariantList getCountsByDate(const QDate &date) const;
    Q_INVOKABLE QVariantList getDiscrepancies(const QDate &date) const;
    Q_INVOKABLE void refreshCounts();
    Q_INVOKABLE int getTotalProducts() const;
    Q_INVOKABLE int getCountedProducts(const QDate &date) const;

signals:
    void countsRefreshed();

private:
    void loadCounts();
    InventoryCountData countFromQuery(const QSqlQuery &query) const;

    DatabaseManager *m_dbManager;
    QVector<InventoryCountData> m_counts;
};

#endif // INVENTORY_H
