#ifndef EXPENSE_H
#define EXPENSE_H

#include <QObject>
#include <QAbstractListModel>
#include <QVector>
#include <QDate>
#include <QVariantList>
#include <qqml.h>
#include "../database/DatabaseManager.h"

struct ExpenseData {
    int id = 0;
    QDate expenseDate;
    QString category;
    QString description;
    double amount = 0;
    QString paymentMethod;
    bool isRecurrent = false;
    QString recurrencePeriod;
    int createdBy = 0;
    QString createdAt;
};

class ExpenseManager : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(double todayExpenses READ todayExpenses NOTIFY todayExpensesChanged)
    Q_PROPERTY(double monthExpenses READ monthExpenses NOTIFY monthExpensesChanged)
    QML_ELEMENT

public:
    enum ExpenseRoles {
        IdRole = Qt::UserRole + 1,
        ExpenseDateRole,
        CategoryRole,
        DescriptionRole,
        AmountRole,
        PaymentMethodRole,
        IsRecurrentRole,
        RecurrencePeriodRole
    };

    explicit ExpenseManager(DatabaseManager *dbManager, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    double todayExpenses() const;
    double monthExpenses() const;

    Q_INVOKABLE bool addExpense(const QString &category, const QString &description,
                                 double amount, const QDate &date,
                                 const QString &paymentMethod = QStringLiteral("efectivo"),
                                 bool isRecurrent = false, int createdBy = 0);
    Q_INVOKABLE bool deleteExpense(int id);
    Q_INVOKABLE QVariantList getExpensesByDateRange(const QDate &from, const QDate &to) const;
    Q_INVOKABLE QVariantList getExpensesByCategory(const QString &category) const;
    Q_INVOKABLE double getCategoryTotal(const QString &category, const QDate &from, const QDate &to) const;
    Q_INVOKABLE QStringList expenseCategories() const;
    Q_INVOKABLE void refreshExpenses();

signals:
    void todayExpensesChanged();
    void monthExpensesChanged();
    void expensesRefreshed();

private:
    void loadExpenses();
    ExpenseData expenseFromQuery(const QSqlQuery &query) const;

    DatabaseManager *m_dbManager;
    QVector<ExpenseData> m_expenses;
};

#endif // EXPENSE_H
