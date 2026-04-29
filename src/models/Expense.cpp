#include "Expense.h"
#include <QDebug>

ExpenseManager::ExpenseManager(DatabaseManager *dbManager, QObject *parent)
    : QAbstractListModel(parent), m_dbManager(dbManager)
{
    loadExpenses();
}

int ExpenseManager::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_expenses.count();
}

QVariant ExpenseManager::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_expenses.count())
        return QVariant();

    const ExpenseData &expense = m_expenses.at(index.row());
    switch (role) {
        case IdRole: return expense.id;
        case ExpenseDateRole: return expense.expenseDate;
        case CategoryRole: return expense.category;
        case DescriptionRole: return expense.description;
        case AmountRole: return expense.amount;
        case PaymentMethodRole: return expense.paymentMethod;
        case IsRecurrentRole: return expense.isRecurrent;
        case RecurrencePeriodRole: return expense.recurrencePeriod;
    }
    return QVariant();
}

QHash<int, QByteArray> ExpenseManager::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[ExpenseDateRole] = "expenseDate";
    roles[CategoryRole] = "category";
    roles[DescriptionRole] = "description";
    roles[AmountRole] = "amount";
    roles[PaymentMethodRole] = "paymentMethod";
    roles[IsRecurrentRole] = "isRecurrent";
    roles[RecurrencePeriodRole] = "recurrencePeriod";
    return roles;
}

double ExpenseManager::todayExpenses() const
{
    double total = 0;
    QDate today = QDate::currentDate();
    for (const ExpenseData &e : m_expenses) {
        if (e.expenseDate == today) total += e.amount;
    }
    return total;
}

double ExpenseManager::monthExpenses() const
{
    double total = 0;
    QDate today = QDate::currentDate();
    for (const ExpenseData &e : m_expenses) {
        if (e.expenseDate.year() == today.year() && e.expenseDate.month() == today.month()) {
            total += e.amount;
        }
    }
    return total;
}

bool ExpenseManager::addExpense(const QString &category, const QString &description,
                                 double amount, const QDate &date,
                                 const QString &paymentMethod, bool isRecurrent, int createdBy)
{
    QSqlQuery query = m_dbManager->executeQuery(
        "INSERT INTO expenses (category, description, amount, expense_date, payment_method, "
        "is_recurrent, recurrence_period, created_by) "
        "VALUES (:category, :description, :amount, :expense_date, :payment_method, "
        ":is_recurrent, :recurrence_period, :created_by)",
        {
            {"category", category},
            {"description", description.isEmpty() ? QVariant(QVariant::String) : description},
            {"amount", amount},
            {"expense_date", date.toString(Qt::ISODate)},
            {"payment_method", paymentMethod},
            {"is_recurrent", isRecurrent ? 1 : 0},
            {"recurrence_period", isRecurrent ? QStringLiteral("mensual") : QVariant(QVariant::String)},
            {"created_by", createdBy > 0 ? createdBy : QVariant(QVariant::Int)}
        }
    );

    if (!query.lastError().text().isEmpty()) {
        qWarning() << "Failed to add expense:" << query.lastError().text();
        return false;
    }

    refreshExpenses();
    return true;
}

bool ExpenseManager::deleteExpense(int id)
{
    QSqlQuery query = m_dbManager->executeQuery(
        "DELETE FROM expenses WHERE id = :id",
        {{"id", id}}
    );

    if (!query.lastError().text().isEmpty()) {
        qWarning() << "Failed to delete expense:" << query.lastError().text();
        return false;
    }

    refreshExpenses();
    return true;
}

QVariantList ExpenseManager::getExpensesByDateRange(const QDate &from, const QDate &to) const
{
    QVariantList list;
    for (const ExpenseData &e : m_expenses) {
        if (e.expenseDate >= from && e.expenseDate <= to) {
            QVariantMap map;
            map["id"] = e.id;
            map["date"] = e.expenseDate;
            map["category"] = e.category;
            map["description"] = e.description;
            map["amount"] = e.amount;
            list.append(map);
        }
    }
    return list;
}

QVariantList ExpenseManager::getExpensesByCategory(const QString &category) const
{
    QVariantList list;
    for (const ExpenseData &e : m_expenses) {
        if (e.category == category) {
            QVariantMap map;
            map["id"] = e.id;
            map["date"] = e.expenseDate;
            map["amount"] = e.amount;
            map["description"] = e.description;
            list.append(map);
        }
    }
    return list;
}

double ExpenseManager::getCategoryTotal(const QString &category, const QDate &from, const QDate &to) const
{
    double total = 0;
    for (const ExpenseData &e : m_expenses) {
        if (e.category == category && e.expenseDate >= from && e.expenseDate <= to) {
            total += e.amount;
        }
    }
    return total;
}

QStringList ExpenseManager::expenseCategories() const
{
    return QStringList() << "alquiler" << "onat" << "transportista" << "salario"
                         << "combustible" << "mantenimiento" << "otro";
}

void ExpenseManager::refreshExpenses()
{
    beginResetModel();
    m_expenses.clear();
    loadExpenses();
    endResetModel();
    emit todayExpensesChanged();
    emit monthExpensesChanged();
    emit expensesRefreshed();
}

void ExpenseManager::loadExpenses()
{
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT id, expense_date, category, description, amount, payment_method, "
        "is_recurrent, recurrence_period, created_at "
        "FROM expenses ORDER BY expense_date DESC"
    );

    while (query.next()) {
        m_expenses.append(expenseFromQuery(query));
    }
}

ExpenseData ExpenseManager::expenseFromQuery(const QSqlQuery &query) const
{
    ExpenseData e;
    e.id = query.value("id").toInt();
    e.expenseDate = QDate::fromString(query.value("expense_date").toString(), Qt::ISODate);
    e.category = query.value("category").toString();
    e.description = query.value("description").toString();
    e.amount = query.value("amount").toDouble();
    e.paymentMethod = query.value("payment_method").toString();
    e.isRecurrent = query.value("is_recurrent").toBool();
    e.recurrencePeriod = query.value("recurrence_period").toString();
    e.createdAt = query.value("created_at").toString();
    return e;
}
