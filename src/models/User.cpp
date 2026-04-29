#include "User.h"
#include <QDebug>

UserManager::UserManager(DatabaseManager *dbManager, QObject *parent)
    : QAbstractListModel(parent), m_dbManager(dbManager)
{
    loadUsers();
}

int UserManager::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_users.count();
}

QVariant UserManager::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_users.count())
        return QVariant();

    const UserData &user = m_users.at(index.row());
    switch (role) {
        case IdRole: return user.id;
        case UsernameRole: return user.username;
        case FullNameRole: return user.fullName;
        case RoleRole: return user.role;
        case PhoneRole: return user.phone;
        case EmailRole: return user.email;
        case IsActiveRole: return user.isActive;
    }
    return QVariant();
}

QHash<int, QByteArray> UserManager::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[UsernameRole] = "username";
    roles[FullNameRole] = "fullName";
    roles[RoleRole] = "role";
    roles[PhoneRole] = "phone";
    roles[EmailRole] = "email";
    roles[IsActiveRole] = "isActive";
    return roles;
}

bool UserManager::login(const QString &username, const QString &password)
{
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT * FROM users WHERE username = :username AND password_hash = :password AND is_active = 1",
        {{"username", username}, {"password", password}}
    );

    if (query.next()) {
        m_currentUser = userFromQuery(query);
        emit currentUserChanged();
        emit isLoggedInChanged();
        emit loginSuccess();
        return true;
    }

    emit loginFailed("Usuario o contraseña incorrectos");
    return false;
}

void UserManager::logout()
{
    m_currentUser = UserData();
    emit currentUserChanged();
    emit isLoggedInChanged();
}

bool UserManager::addUser(const QString &username, const QString &password,
                           const QString &fullName, const QString &role,
                           const QString &phone)
{
    QSqlQuery query = m_dbManager->executeQuery(
        "INSERT INTO users (username, password_hash, full_name, role, phone) "
        "VALUES (:username, :password, :full_name, :role, :phone)",
        {
            {"username", username},
            {"password", password},
            {"full_name", fullName},
            {"role", role},
            {"phone", phone.isEmpty() ? QVariant(QVariant::String) : phone}
        }
    );

    if (!query.lastError().text().isEmpty()) {
        qWarning() << "Failed to add user:" << query.lastError().text();
        return false;
    }

    refreshUsers();
    return true;
}

bool UserManager::updateUser(int id, const QVariantMap &fields)
{
    QStringList setParts;
    QVariantMap bindings = {{"id", id}};

    if (fields.contains("fullName")) {
        setParts << "full_name = :full_name";
        bindings["full_name"] = fields["fullName"];
    }
    if (fields.contains("phone")) {
        setParts << "phone = :phone";
        bindings["phone"] = fields["phone"];
    }
    if (fields.contains("role")) {
        setParts << "role = :role";
        bindings["role"] = fields["role"];
    }
    if (fields.contains("isActive")) {
        setParts << "is_active = :is_active";
        bindings["is_active"] = fields["isActive"].toBool() ? 1 : 0;
    }

    if (setParts.isEmpty()) return false;

    QString sql = "UPDATE users SET " + setParts.join(", ") + ", updated_at = CURRENT_TIMESTAMP WHERE id = :id";
    QSqlQuery query = m_dbManager->executeQuery(sql, bindings);

    if (!query.lastError().text().isEmpty()) {
        qWarning() << "Failed to update user:" << query.lastError().text();
        return false;
    }

    refreshUsers();
    return true;
}

bool UserManager::deactivateUser(int id)
{
    return updateUser(id, {{"isActive", false}});
}

bool UserManager::deleteUser(int id)
{
    QString sql = "DELETE FROM users WHERE id = ?";
    QSqlQuery query = m_dbManager->executeQuery(sql, {{"id", id}});

    if (!query.isValid()) {
        qWarning() << "Failed to delete user:" << query.lastError();
        return false;
    }

    refreshUsers();
    return true;
}

QVariantMap UserManager::getUser(int id) const
{
    for (const UserData &user : m_users) {
        if (user.id == id) {
            QVariantMap map;
            map["id"] = user.id;
            map["username"] = user.username;
            map["fullName"] = user.fullName;
            map["role"] = user.role;
            map["phone"] = user.phone;
            map["email"] = user.email;
            map["isActive"] = user.isActive;
            return map;
        }
    }
    return QVariantMap();
}

QVariantList UserManager::getUsersByRole(const QString &role) const
{
    QVariantList list;
    for (const UserData &user : m_users) {
        if (user.role == role && user.isActive) {
            QVariantMap map;
            map["id"] = user.id;
            map["username"] = user.username;
            map["fullName"] = user.fullName;
            map["role"] = user.role;
            list.append(map);
        }
    }
    return list;
}

QVariantList UserManager::getAllUsers() const
{
    QVariantList list;
    for (const UserData &user : m_users) {
        QVariantMap map;
        map["id"] = user.id;
        map["username"] = user.username;
        map["fullName"] = user.fullName;
        map["role"] = user.role;
        map["phone"] = user.phone;
        map["email"] = user.email;
        map["isActive"] = user.isActive;
        list.append(map);
    }
    return list;
}

void UserManager::refreshUsers()
{
    beginResetModel();
    m_users.clear();
    loadUsers();
    endResetModel();
    emit usersRefreshed();
}

bool UserManager::hasPermission(const QString &permission) const
{
    if (!isLoggedIn()) return false;

    // Mapeo simple de permisos por rol
    static QMap<QString, QStringList> rolePermissions = {
        {"administrador", QStringList() << "all"},
        {"comercial", QStringList() << "sales" << "invoices" << "liquidations" << "daily_close"},
        {"almacen", QStringList() << "inventory" << "quality_check" << "daily_count" << "prepare_orders"},
        {"mensajero", QStringList() << "deliveries" << "collections" << "incidents"},
        {"custodio", QStringList() << "custody" << "receipt"}
    };

    QStringList permissions = rolePermissions.value(m_currentUser.role);
    return permissions.contains("all") || permissions.contains(permission);
}

void UserManager::loadUsers()
{
    QSqlQuery query = m_dbManager->executeQuery(
        "SELECT id, username, full_name, role, phone, email, is_active, created_at FROM users WHERE is_active = 1 ORDER BY full_name"
    );

    while (query.next()) {
        m_users.append(userFromQuery(query));
    }
}

UserData UserManager::userFromQuery(const QSqlQuery &query) const
{
    UserData user;
    user.id = query.value("id").toInt();
    user.username = query.value("username").toString();
    user.fullName = query.value("full_name").toString();
    user.role = query.value("role").toString();
    user.phone = query.value("phone").toString();
    user.email = query.value("email").toString();
    user.isActive = query.value("is_active").toBool();
    user.createdAt = query.value("created_at").toString();
    return user;
}
