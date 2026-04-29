#ifndef SALE_H
#define SALE_H

#include <QObject>
#include <QAbstractListModel>
#include <QVector>
#include <QSqlQuery>
#include <QDate>
#include <QVariantMap>
#include <QVariantList>
#include <qqml.h>
#include "../database/DatabaseManager.h"

struct SaleItemData {
    int id = 0;
    int productId = 0;
    QString productName;
    int quantity = 1;
    double unitPrice = 0;
    double totalPrice = 0;
};

struct SaleData {
    int id = 0;
    QString saleNumber;
    QString clientName;
    QString clientPhone;
    QString clientAddress;
    QString status;
    QString paymentType;
    double subtotal = 0;
    double deliveryCost = 0;
    double commission = 0;
    double total = 0;
    double amountPaid = 0;
    QString notes;
    int createdBy = 0;
    int messengerId = 0;
    QString createdAt;
    QString deliveredAt;
    QString liquidatedAt;
    QVector<SaleItemData> items;
};

class SaleManager : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(double todaySalesTotal READ todaySalesTotal NOTIFY todaySalesTotalChanged)
    Q_PROPERTY(int todaySalesCount READ todaySalesCount NOTIFY todaySalesCountChanged)
    Q_PROPERTY(double pendingAmount READ pendingAmount NOTIFY pendingAmountChanged)
    QML_ELEMENT

public:
    enum SaleRoles {
        IdRole = Qt::UserRole + 1,
        SaleNumberRole,
        ClientNameRole,
        ClientPhoneRole,
        ClientAddressRole,
        StatusRole,
        PaymentTypeRole,
        SubtotalRole,
        DeliveryCostRole,
        CommissionRole,
        TotalRole,
        AmountPaidRole,
        NotesRole,
        CreatedByRole,
        MessengerIdRole,
        CreatedAtRole
    };

    explicit SaleManager(DatabaseManager *dbManager, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    double todaySalesTotal() const;
    int todaySalesCount() const;
    double pendingAmount() const;

    // CRUD Ventas
    Q_INVOKABLE int createSale(const QString &clientName, const QString &clientPhone,
                                const QString &clientAddress, const QVariantList &items,
                                const QString &paymentType = QStringLiteral("efectivo"),
                                double deliveryCost = 0, double commission = 0,
                                int createdBy = 0, const QString &notes = QString());
    Q_INVOKABLE bool updateSaleStatus(int saleId, const QString &status);
    Q_INVOKABLE QVariantMap getSale(int saleId) const;
    Q_INVOKABLE QVariantList getSaleItems(int saleId) const;
    Q_INVOKABLE QVariantList getSalesByStatus(const QString &status) const;
    Q_INVOKABLE QVariantList getTodaySales() const;
    Q_INVOKABLE void refreshSales();

    // Facturación
    Q_INVOKABLE int createInvoice(int saleId, const QString &clientName,
                                   const QString &clientId, double total,
                                   int createdBy);
    Q_INVOKABLE bool markInvoicePrinted(int invoiceId);

    // Entregas
    Q_INVOKABLE bool registerDelivery(int saleId, int messengerId, double deliveryCost);
    Q_INVOKABLE bool updateDeliveryStatus(int saleId, const QString &status,
                                            double paymentCollected = 0,
                                            const QString &incidentDesc = QString());

    // Liquidación
    Q_INVOKABLE bool createLiquidation(int saleId, int messengerId, double amount,
                                         const QString &paymentType, double difference = 0,
                                         const QString &differenceReason = QString(),
                                         int createdBy = 0);

    // Cuadre
    Q_INVOKABLE bool performDailyReconciliation(const QDate &date, double expectedCash,
                                                 double actualCash, double totalSales,
                                                 double totalExpenses, const QString &reason,
                                                 int closedBy);
    Q_INVOKABLE QVariantMap getDailyReconciliation(const QDate &date) const;

    // Custodia
    Q_INVOKABLE bool createCustodyRecord(const QDate &date, const QString &custodyType,
                                         double amount, int productCount,
                                         int deliveredBy, int receivedBy,
                                         const QString &notes);
    Q_INVOKABLE bool confirmCustody(int custodyId, const QString &pin);

signals:
    void todaySalesTotalChanged();
    void todaySalesCountChanged();
    void pendingAmountChanged();
    void salesRefreshed();

private:
    void loadSales();
    SaleData saleFromQuery(const QSqlQuery &query) const;
    QString generateSaleNumber() const;

    DatabaseManager *m_dbManager;
    QVector<SaleData> m_sales;
};

#endif // SALE_H
