#ifndef USER_H
#define USER_H

#include <QObject>
#include <QAbstractListModel>
#include <QVector>
#include <QSqlQuery>
#include <QSqlError>
#include <QVariantMap>
#include <QVariantList>
#include <qqml.h>
#include "../database/DatabaseManager.h"

struct UserData {
    Q_GADGET
    Q_PROPERTY(int id MEMBER id)
    Q_PROPERTY(QString username MEMBER username)
    Q_PROPERTY(QString fullName MEMBER fullName)
    Q_PROPERTY(QString role MEMBER role)
    Q_PROPERTY(QString phone MEMBER phone)
    Q_PROPERTY(QString email MEMBER email)
    Q_PROPERTY(bool isActive MEMBER isActive)
    Q_PROPERTY(QString createdAt MEMBER createdAt)

public:
    int id = 0;
    QString username;
    QString fullName;
    QString role;
    QString phone;
    QString email;
    bool isActive = true;
    QString createdAt;
};
Q_DECLARE_METATYPE(UserData)

class UserManager : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(UserData currentUser READ currentUser NOTIFY currentUserChanged)
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY isLoggedInChanged)
    QML_ELEMENT

public:
    enum UserRoles {
        IdRole = Qt::UserRole + 1,
        UsernameRole,
        FullNameRole,
        RoleRole,
        PhoneRole,
        EmailRole,
        IsActiveRole
    };

    explicit UserManager(DatabaseManager *dbManager, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    bool isLoggedIn() const { return m_currentUser.id > 0; }
    UserData currentUser() const { return m_currentUser; }
    QString currentUserRole() const { return m_currentUser.role; }

    Q_INVOKABLE bool login(const QString &username, const QString &password);
    Q_INVOKABLE void logout();
    Q_INVOKABLE bool addUser(const QString &username, const QString &password, 
                             const QString &fullName, const QString &role, 
                             const QString &phone = QString());
    Q_INVOKABLE bool updateUser(int id, const QVariantMap &fields);
    Q_INVOKABLE bool deactivateUser(int id);
    Q_INVOKABLE QVariantMap getUser(int id) const;
    Q_INVOKABLE QVariantList getUsersByRole(const QString &role) const;
    Q_INVOKABLE QVariantList getAllUsers() const;
    Q_INVOKABLE void refreshUsers();

    Q_INVOKABLE QStringList availableRoles() const {
        return QStringList() << "comercial" << "almacen" << "mensajero" << "custodio" << "administrador";
    }

    Q_INVOKABLE bool hasPermission(const QString &permission) const;

signals:
    void currentUserChanged();
    void isLoggedInChanged();
    void loginSuccess();
    void loginFailed(const QString &error);
    void usersRefreshed();

private:
    void loadUsers();
    UserData userFromQuery(const QSqlQuery &query) const;

    DatabaseManager *m_dbManager;
    QVector<UserData> m_users;
    UserData m_currentUser;
};

#endif // USER_H
