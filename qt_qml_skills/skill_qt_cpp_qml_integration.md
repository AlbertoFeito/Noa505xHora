# Skill: qt-cpp-qml-integration

## description
Integración completa entre C++ y QML: Q_PROPERTY, Q_INVOKABLE, signals/slots, context properties, singletones y tipos personalizados.

## context
- **Macros clave**: Q_OBJECT, Q_PROPERTY, Q_INVOKABLE, Q_SIGNAL, Q_SLOT, Q_ENUM
- **Registro de tipos**: qmlRegisterType, qmlRegisterSingletonType, qmlRegisterUncreatableType
- **Contexto QML**: QQmlContext, setContextProperty
- **Engine**: QQmlApplicationEngine, QQmlEngine

## patterns

### Exponer C++ a QML con Q_PROPERTY
```cpp
// Backend.h
#include <QObject>
#include <qqml.h>

class Backend : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString userName READ userName WRITE setUserName NOTIFY userNameChanged)
    Q_PROPERTY(int userAge READ userAge WRITE setUserAge NOTIFY userAgeChanged)
    QML_ELEMENT

public:
    explicit Backend(QObject *parent = nullptr);

    QString userName() const { return m_userName; }
    void setUserName(const QString &name) {
        if (m_userName != name) {
            m_userName = name;
            emit userNameChanged();
        }
    }

    int userAge() const { return m_userAge; }
    void setUserAge(int age) {
        if (m_userAge != age) {
            m_userAge = age;
            emit userAgeChanged();
        }
    }

    Q_INVOKABLE void saveUserData();
    Q_INVOKABLE QString generateReport() const;

signals:
    void userNameChanged();
    void userAgeChanged();
    void dataSaved(bool success);

private:
    QString m_userName;
    int m_userAge = 0;
};
```

### Registro de tipos en main.cpp
```cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "Backend.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    // Método 1: Registro como tipo QML (Qt 5.15+)
    qmlRegisterType<Backend>("com.myapp.backend", 1, 0, "Backend");

    // Método 2: Singleton
    qmlRegisterSingletonType<Backend>("com.myapp.backend", 1, 0, "Backend",
        [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject* {
            Q_UNUSED(engine)
            Q_UNUSED(scriptEngine)
            return new Backend();
        });

    // Método 3: Context property (instancia única global)
    Backend backend;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("backend", &backend);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
```

### Uso en QML
```qml
import QtQuick
import QtQuick.Controls
import com.myapp.backend 1.0

ApplicationWindow {
    visible: true

    // Usando como tipo registrado
    Backend {
        id: myBackend
        userName: "John Doe"
        userAge: 30
        onDataSaved: function(success) {
            statusLabel.text = success ? "Saved!" : "Error!"
        }
    }

    // O usando context property
    Label {
        id: statusLabel
        text: backend.userName  // Acceso directo a context property
    }

    Button {
        text: "Save"
        onClicked: {
            myBackend.saveUserData()
            // o: backend.saveUserData()
        }
    }
}
```

### Enum en C++ accesible desde QML
```cpp
class Status : public QObject {
    Q_OBJECT
public:
    enum Value {
        Idle,
        Loading,
        Success,
        Error
    };
    Q_ENUM(Value)
};

// Registro
qmlRegisterUncreatableType<Status>("com.myapp.enums", 1, 0, "Status", "Enum only");
```

```qml
import com.myapp.enums 1.0

Item {
    property int currentStatus: Status.Idle

    onCurrentStatusChanged: {
        switch(currentStatus) {
            case Status.Loading: console.log("Loading..."); break;
            case Status.Success: console.log("Done!"); break;
            case Status.Error: console.log("Error!"); break;
        }
    }
}
```

### Listas desde C++ a QML
```cpp
class StringListModel : public QAbstractListModel {
    Q_OBJECT
public:
    Q_INVOKABLE QStringList getItems() const { return m_items; }
    Q_INVOKABLE void setItems(const QStringList &items) {
        beginResetModel();
        m_items = items;
        endResetModel();
    }

private:
    QStringList m_items;
};
```

## best_practices
- Usar `QML_ELEMENT` y `qmlRegisterType` en Qt 6 para registro automático
- Preferir `Q_PROPERTY` con `NOTIFY` para bindings bidireccionales
- Usar `Q_INVOKABLE` para métodos que retornan valores; `Q_SLOT` para void
- Implementar `operator==` en tipos personalizados para optimizar bindings
- Usar `QVariantList` y `QVariantMap` para pasar datos estructurados simples
- Registrar enums con `Q_ENUM` para acceso tipado desde QML
- Usar `QQmlEngine::setObjectOwnership` para controlar ciclo de vida

## common_mistakes
- Olvidar `Q_OBJECT` macro (signals/slots no funcionan)
- No emitir señal `NOTIFY` al cambiar propiedad (bindings no se actualizan)
- Usar `Q_SLOT` para métodos que retornan valores útiles
- Pasar objetos QML a C++ sin manejar ownership
- Usar tipos no registrados como parámetros de Q_INVOKABLE
- No usar `const` correctamente en getters

---

## Tu Proyecto: 505XHORA

Tu proyecto usa **todos** estos patrones. Acá tenés los ejemplos específicos:

### Tu struct UserData (Q_GADGET - registro de tipos personalizado)
```cpp
// src/models/User.h - Tu proyecto
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
```

### Tu UserManager (QAbstractListModel + Q_INVOKABLE)
```cpp
// src/models/User.h - Tu proyecto
class UserManager : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(UserData currentUser READ currentUser NOTIFY currentUserChanged)
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY isLoggedInChanged)
    QML_ELEMENT

public:
    // Métodos Q_INVOKABLE accesibles desde QML
    Q_INVOKABLE bool login(const QString &username, const QString &password);
    Q_INVOKABLE void logout();
    Q_INVOKABLE bool addUser(const QString &username, const QString &password, 
                             const QString &fullName, const QString &role, 
                             const QString &phone = QString());
    Q_INVOKABLE bool updateUser(int id, const QVariantMap &fields);
    Q_INVOKABLE QVariantMap getUser(int id) const;
    Q_INVOKABLE QStringList availableRoles() const {
        return QStringList() << "comercial" << "almacen" << "mensajero" << "custodio" << "administrador";
    }
    Q_INVOKABLE bool hasPermission(const QString &permission) const;
    // ...
};
```

### Tu registro en main.cpp
```cpp
// main.cpp - Tu proyecto
int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    
    // Registrar tipo personalizado para signals/slots
    qRegisterMetaType<UserData>("UserData");
    
    // Registrar enum como tipo no-creable
    qmlRegisterUncreatableType<RoleEnums>("com.xhora.enums", 1, 0, "RoleEnums", "Enum container");
    
    // Tu AppController con todos los managers
    AppController appController;
    appController.initialize();
    
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("UserManager", appController.userManager());
    // ... todos los managers
    
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    return app.exec();
}
```

### Tu acceso desde QML
```qml
// Tu proyecto: qml/pages/LoginPage.qml
import QtQuick
import QtQuick.Controls

Button {
    text: "Iniciar Sesión"
    onClicked: {
        // Llamada directa al manager
        UserManager.login(usernameField.text, passwordField.text)
    }
}

Connections {
    target: UserManager
    onLoginSuccess: {
        // NavigationBar.currentIndex = 0
        console.log("Login exitoso:", UserManager.currentUser.fullName)
    }
    onLoginFailed: function(error) {
        console.log("Error:", error)
    }
}
```

### Tu Pattern: QAbstractListModel con roles
```cpp
// Tu proyecto: src/models/User.cpp
int UserManager::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent)
    return m_users.count();
}

QVariant UserManager::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_users.count())
        return QVariant();
    
    const UserData &user = m_users[index.row()];
    switch (role) {
        case IdRole: return user.id;
        case UsernameRole: return user.username;
        case FullNameRole: return user.fullName;
        case RoleRole: return user.role;
        case PhoneRole: return user.phone;
        case EmailRole: return user.email;
        case IsActiveRole: return user.isActive;
        default: return QVariant();
    }
}

QHash<int, QByteArray> UserManager::roleNames() const {
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
```

## references
- [Qt C++ Integration](https://doc.qt.io/qt-6/qtqml-cppintegration-topic.html)
- [QML Element](https://doc.qt.io/qt-6/qqmlengine.html#QML_ELEMENT)
- [Property Binding](https://doc.qt.io/qt-6/qtqml-syntax-propertybinding.html)

---

## Lecciones del Proyecto 505XHORA

### Theme como Singleton con QRC
```qml
// Theme.qml - agregar pragma Singleton
import QtQuick

pragma Singleton

QtObject {
    property color primary: "#37474F"
    property color accent: "#009688"
    // ... más propiedades
}
```

```cpp
// main.cpp - registrar el singleton
qmlRegisterSingletonType(QUrl("qrc:/qml/Theme.qml"), "com.xhora.theme", 1, 0, "Theme");
```

### Context Properties Pattern (Tu Proyecto)
```cpp
// main.cpp - exposing managers como context properties
AppController appController;
appController.initialize();

QQmlApplicationEngine engine;
engine.rootContext()->setContextProperty("UserManager", appController.userManager());
engine.rootContext()->setContextProperty("ProductManager", appController.productManager());
engine.rootContext()->setContextProperty("SaleManager", appController.saleManager());
// ... todos los managers
```

### Problemas Comunes y Soluciones
- **QString::replace no es const**: siempre crear copia local antes de usar replace
  ```cpp
  // ERROR: sale.createdAt.replace(" ", "T") // const QString no permite
  QString createdAtStr = sale.createdAt;
  QDate date = QDateTime::fromString(createdAtStr.replace(" ", "T"), Qt::ISODate).date();
  ```
- **Includes con CMake**: agregar `include_directories(${CMAKE_SOURCE_DIR})` en CMakeLists.txt
- **QRC prefix correcto**: si main.cpp usa `qrc:/qml/main.qml`, el qresource debe tener prefix `/qml`
