#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QString>
#include <QVariant>
#include <QDateTime>
#include <QDebug>
#include <functional>

class DatabaseManager : public QObject {
    Q_OBJECT

public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    bool initialize();
    bool isOpen() const;
    QSqlQuery executeQuery(const QString &query, const QVariantMap &bindings = {});
    bool executeTransaction(const std::function<bool()> &operations);
    
    QSqlDatabase database() const { return m_db; }

private:
    bool createTables();
    bool seedInitialData();
    
    QSqlDatabase m_db;
    bool m_initialized = false;
};

#endif // DATABASEMANAGER_H
