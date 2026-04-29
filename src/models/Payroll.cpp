#include "Payroll.h"
#include <QDebug>

PayrollManager::PayrollManager(DatabaseManager *dbManager, QObject *parent)
    : QAbstractListModel(parent), m_dbManager(dbManager)
{
    loadPayroll();
}

int PayrollManager::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_payroll.count();
}

QVariant PayrollManager::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_payroll.count())
        return QVariant();

    const PayrollData &p = m_payroll.at(index.row());
    switch (role) {
        case IdRole: return p.id;
        case EmployeeIdRole: return p.employeeId;
        case EmployeeNameRole: return p.employeeName;
        case PeriodStartRole: return p.periodStart;
        case PeriodEndRole: return p.periodEnd;
        case BaseSalaryRole: return p.baseSalary;
        case SalesCommissionRole: return p.salesCommission;
        case BonusesRole: return p.bonuses;
        case DeductionsRole: return p.deductions;
        case TotalPayRole: return p.totalPay;
        case PaymentDateRole: return p.paymentDate;
        case PaymentStatusRole: return p.paymentStatus;
    }
    return QVariant();
}

QHash<int, QByteArray> PayrollManager::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[EmployeeIdRole] = "employeeId";
    roles[EmployeeNameRole] = "employeeName";
    roles[PeriodStartRole] = "periodStart";
    roles[PeriodEndRole] = "periodEnd";
    roles[BaseSalaryRole] = "baseSalary";
    roles[SalesCommissionRole] = "salesCommission";
    roles[BonusesRole] = "bonuses";
    roles[DeductionsRole] = "deductions";
    roles[TotalPayRole] = "totalPay";
    roles[PaymentDateRole] = "paymentDate";
    roles[PaymentStatusRole] = "paymentStatus";
    return roles;
}

double PayrollManager::totalPayroll() const
{
    double total = 0;
    for (const PayrollData &p : m_payroll) {
        if (p.paymentStatus == "pendiente") total += p.totalPay;
    }
    return total;
}

bool PayrollManager::addPayroll(int employeeId, const QDate &periodStart, const QDate &periodEnd,
                                  double baseSalary, double commission, double bonuses,
                                  double deductions, int createdBy)
{
    double total = baseSalary + commission + bonuses - deductions;

    QSqlQuery query = m_dbManager->executeQuery(
        "INSERT INTO payroll (employee_id, period_start, period_end, base_salary, "
        "sales_commission, bonuses, deductions, total_pay, created_by) "
        "VALUES (:employee_id, :period_start, :period_end, :base_salary, "
        ":sales_commission, :bonuses, :deductions, :total_pay, :created_by)",
        {
            {"employee_id", employeeId},
            {"period_start", periodStart.toString(Qt::ISODate)},
            {"period_end", periodEnd.toString(Qt::ISODate)},
            {"base_salary", baseSalary},
            {"sales_commission", commission},
            {"bonuses", bonuses},
            {"deductions", deductions},
            {"total_pay", total},
            {"created_by", createdBy > 0 ? createdBy : QVariant(QVariant::Int)}
        }
    );

    if (!query.lastError().text().isEmpty()) {
        qWarning() << "Failed to add payroll:" << query.lastError().text();
        return false;
    }

    refreshPayroll();
    return true;
}

bool PayrollManager::markAsPaid(int payrollId, const QDate &paymentDate)
{
    QSqlQuery query = m_dbManager->executeQuery(
        "UPDATE payroll SET payment_status = 'pagado', payment_date = :payment_date WHERE id = :id",
        {{"payment_date", paymentDate.toString(Qt::ISODate)}, {"id", payrollId}}
    );

    if (!query.lastError().text().isEmpty()) {
        qWarning() << "Failed to mark payroll as paid:" << query.lastError().text();
        return false;
    }

    refreshPayroll();
    return true;
}

bool PayrollManager::deletePayroll(int id)
{
    QSqlQuery query = m_dbManager->executeQuery(
        "DELETE FROM payroll WHERE id = :id",
        {{"id", id}}
    );

    if (!query.lastError().text().isEmpty()) {
        qWarning() << "Failed to delete payroll:" << query.lastError().text();
        return false;
    }

    refreshPayroll();
    return true;
}

QVariantList PayrollManager::getPayrollByEmployee(int employeeId) const
{
    QVariantList list;
    for (const PayrollData &p : m_payroll) {
        if (p.employeeId == employeeId) {
            QVariantMap map;
            map["id"] = p.id;
            map["periodStart"] = p.periodStart;
            map["periodEnd"] = p.periodEnd;
            map["totalPay"] = p.totalPay;
            map["paymentStatus"] = p.paymentStatus;
            list.append(map);
        }
    }
    return list;
}

QVariantList PayrollManager::getPayrollByPeriod(const QDate &start, const QDate &end) const
{
    QVariantList list;
    for (const PayrollData &p : m_payroll) {
        if (p.periodStart >= start && p.periodEnd <= end) {
            QVariantMap map;
            map["id"] = p.id;
            map["employeeName"] = p.employeeName;
            map["totalPay"] = p.totalPay;
            map["paymentStatus"] = p.paymentStatus;
            list.append(map);
        }
    }
    return list;
}

void PayrollManager::refreshPayroll()
{
    beginResetModel();
    m_payroll.clear();
    loadPayroll();
    endResetModel();
    emit totalPayrollChanged();
    emit payrollRefreshed();
}

void PayrollManager::loadPayroll()
{
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT p.*, u.full_name as employee_name "
        "FROM payroll p "
        "LEFT JOIN users u ON p.employee_id = u.id "
        "ORDER BY p.period_start DESC"
    );

    while (query.next()) {
        m_payroll.append(payrollFromQuery(query));
    }
}

PayrollData PayrollManager::payrollFromQuery(const QSqlQuery &query) const
{
    PayrollData p;
    p.id = query.value("id").toInt();
    p.employeeId = query.value("employee_id").toInt();
    p.employeeName = query.value("employee_name").toString();
    p.periodStart = QDate::fromString(query.value("period_start").toString(), Qt::ISODate);
    p.periodEnd = QDate::fromString(query.value("period_end").toString(), Qt::ISODate);
    p.baseSalary = query.value("base_salary").toDouble();
    p.salesCommission = query.value("sales_commission").toDouble();
    p.bonuses = query.value("bonuses").toDouble();
    p.deductions = query.value("deductions").toDouble();
    p.totalPay = query.value("total_pay").toDouble();
    p.paymentDate = QDate::fromString(query.value("payment_date").toString(), Qt::ISODate);
    p.paymentStatus = query.value("payment_status").toString();
    p.createdBy = query.value("created_by").toInt();
    p.createdAt = query.value("created_at").toString();
    return p;
}
