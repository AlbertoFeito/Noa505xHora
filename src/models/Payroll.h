#ifndef PAYROLL_H
#define PAYROLL_H

#include <QObject>
#include <QAbstractListModel>
#include <QVector>
#include <QDate>
#include <QVariantList>
#include <qqml.h>
#include "../database/DatabaseManager.h"

struct PayrollData {
    int id = 0;
    int employeeId = 0;
    QString employeeName;
    QDate periodStart;
    QDate periodEnd;
    double baseSalary = 0;
    double salesCommission = 0;
    double bonuses = 0;
    double deductions = 0;
    double totalPay = 0;
    QDate paymentDate;
    QString paymentStatus;
    int createdBy = 0;
    QString createdAt;
};

class PayrollManager : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(double totalPayroll READ totalPayroll NOTIFY totalPayrollChanged)
    QML_ELEMENT

public:
    enum PayrollRoles {
        IdRole = Qt::UserRole + 1,
        EmployeeIdRole,
        EmployeeNameRole,
        PeriodStartRole,
        PeriodEndRole,
        BaseSalaryRole,
        SalesCommissionRole,
        BonusesRole,
        DeductionsRole,
        TotalPayRole,
        PaymentDateRole,
        PaymentStatusRole
    };

    explicit PayrollManager(DatabaseManager *dbManager, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    double totalPayroll() const;

    Q_INVOKABLE bool addPayroll(int employeeId, const QDate &periodStart, const QDate &periodEnd,
                                 double baseSalary, double commission, double bonuses,
                                 double deductions, int createdBy);
    Q_INVOKABLE bool markAsPaid(int payrollId, const QDate &paymentDate);
    Q_INVOKABLE bool deletePayroll(int id);
    Q_INVOKABLE QVariantList getPayrollByEmployee(int employeeId) const;
    Q_INVOKABLE QVariantList getPayrollByPeriod(const QDate &start, const QDate &end) const;
    Q_INVOKABLE void refreshPayroll();

signals:
    void totalPayrollChanged();
    void payrollRefreshed();

private:
    void loadPayroll();
    PayrollData payrollFromQuery(const QSqlQuery &query) const;

    DatabaseManager *m_dbManager;
    QVector<PayrollData> m_payroll;
};

#endif // PAYROLL_H
