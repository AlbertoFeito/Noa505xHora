# Skill: qt-qml-architecture-patterns

## description
Patrones de arquitectura para aplicaciones QML: MVVM, Flux, Redux, inyección de dependencias, navegación y gestión de estado global.

## context
- **Patrones**: MVVM, MVC, Flux, Redux, Clean Architecture
- **Librerías**: QuickFlux, qredux, QtMvvm
- **Conceptos**: Store, Actions, Reducers, ViewModels

## patterns

### MVVM en QML
```qml
// ViewModel en C++
class LoginViewModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(bool canLogin READ canLogin NOTIFY canLoginChanged)

public:
    Q_INVOKABLE void login();

signals:
    void loginSuccess();
    void loginFailed(const QString &error);

private:
    bool canLogin() const { return !m_username.isEmpty() && !m_password.isEmpty() && !m_isLoading; }

    QString m_username;
    QString m_password;
    bool m_isLoading = false;
    QString m_errorMessage;
};
```

```qml
// LoginView.qml (View)
import QtQuick
import QtQuick.Controls

Page {
    property LoginViewModel viewModel

    Column {
        anchors.centerIn: parent
        spacing: 16
        width: 300

        TextField {
            placeholderText: "Username"
            text: viewModel.username
            onTextChanged: viewModel.username = text
        }

        TextField {
            placeholderText: "Password"
            echoMode: TextInput.Password
            text: viewModel.password
            onTextChanged: viewModel.password = text
        }

        Button {
            text: "Login"
            enabled: viewModel.canLogin
            onClicked: viewModel.login()
        }

        Label {
            text: viewModel.errorMessage
            color: "red"
            visible: viewModel.errorMessage !== ""
        }

        BusyIndicator {
            running: viewModel.isLoading
        }
    }
}
```

### Flux/Redux con QuickFlux
```qml
// AppDispatcher.qml (Singleton)
pragma Singleton
import QuickFlux 1.1

Dispatcher {
    // Central dispatcher for all actions
}
```

```qml
// AppStore.qml (Singleton)
pragma Singleton
import QtQuick
import QuickFlux 1.1

Store {
    property var todos: []
    property string filter: "all"

    Filter {
        type: ActionTypes.addTodo
        onDispatched: {
            todos.push({ id: Date.now(), text: message.text, completed: false })
            todosChanged()
        }
    }

    Filter {
        type: ActionTypes.toggleTodo
        onDispatched: {
            var todo = todos.find(function(t) { return t.id === message.id })
            if (todo) {
                todo.completed = !todo.completed
                todosChanged()
            }
        }
    }

    Filter {
        type: ActionTypes.setFilter
        onDispatched: {
            filter = message.filter
        }
    }
}
```

```qml
// TodoList.qml
import QtQuick
import QtQuick.Controls

ListView {
    model: AppStore.todos.filter(function(todo) {
        if (AppStore.filter === "active") return !todo.completed
        if (AppStore.filter === "completed") return todo.completed
        return true
    })

    delegate: CheckDelegate {
        text: modelData.text
        checked: modelData.completed
        onClicked: AppDispatcher.dispatch(ActionTypes.toggleTodo, { id: modelData.id })
    }
}
```

### Navegación con StackView
```qml
// NavigationManager.qml (Singleton)
pragma Singleton
import QtQuick

QtObject {
    property var stackView: null

    function navigateTo(page, properties) {
        if (stackView) {
            stackView.push(Qt.resolvedUrl(page), properties || {})
        }
    }

    function goBack() {
        if (stackView && stackView.depth > 1) {
            stackView.pop()
        }
    }

    function replace(page, properties) {
        if (stackView) {
            stackView.replace(Qt.resolvedUrl(page), properties || {})
        }
    }

    function clearAndNavigateTo(page, properties) {
        if (stackView) {
            stackView.clear()
            stackView.push(Qt.resolvedUrl(page), properties || {})
        }
    }
}
```

```qml
// main.qml
import QtQuick
import QtQuick.Controls

ApplicationWindow {
    visible: true

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "HomePage.qml"

        Component.onCompleted: NavigationManager.stackView = stackView
    }
}
```

## best_practices
- Separar View (QML), ViewModel (C++/QML) y Model (C++)
- Usar singletons para servicios globales (navegación, API, tema)
- Implementar inyección de dependencias via properties
- Usar `Connections` para escuchar señales de ViewModels
- Evitar lógica de negocio en archivos QML
- Usar `Loader` para cargar páginas bajo demanda
- Implementar patrones de navegación consistentes
- Documentar el flujo de datos en arquitecturas Flux/Redux

## common_mistakes
- Mezclar lógica de UI con lógica de negocio
- No usar ViewModels (código spaghetti)
- Acoplamiento fuerte entre vistas
- No manejar el estado de navegación (back button)
- Usar globals sin control
- No implementar cleanup al destruir páginas

---

## Arquitectura de Tu Proyecto: 505XHORA

Tu proyecto usa un patrón de **Managers como Context Properties** que es único y efectivo para aplicaciones Qt/QML pequeñas a medianas.

### Estructura en main.cpp (Tu proyecto)
```cpp
// main.cpp - Tu proyecto: D:\2026\505XHORA\main.cpp
int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    // 1. Inicializar AppController (coordinador central)
    AppController appController;
    if (!appController.initialize()) {
        qCritical() << "Failed to initialize application controller";
        return -1;
    }

    QQmlApplicationEngine engine;
    
    // 2. Exponer TODOS los managers como context properties
    // Esto permite acceso directo desde QML: AppController, UserManager, etc.
    engine.rootContext()->setContextProperty("AppController", &appController);
    engine.rootContext()->setContextProperty("UserManager", appController.userManager());
    engine.rootContext()->setContextProperty("ProductManager", appController.productManager());
    engine.rootContext()->setContextProperty("SaleManager", appController.saleManager());
    engine.rootContext()->setContextProperty("InventoryManager", appController.inventoryManager());
    engine.rootContext()->setContextProperty("ExpenseManager", appController.expenseManager());
    engine.rootContext()->setContextProperty("PayrollManager", appController.payrollManager());
    engine.rootContext()->setContextProperty("ReportManager", appController.reportManager());

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    return app.exec();
}
```

### Acceso desde QML (Tu proyecto)
```qml
// qml/pages/LoginPage.qml - Tu proyecto
import QtQuick
import QtQuick.Controls

Column {
    TextField {
        text: UserManager.currentUser.username
    }
    
    Button {
        onClicked: {
            // Login desde QML -> C++ Manager
            UserManager.login(usernameField.text, passwordField.text)
        }
    }
}

Connections {
    target: UserManager
    onLoginSuccess: {
        // Navegar al dashboard
        stackView.push("qrc:/qml/pages/DashboardPage.qml")
    }
}
```

### AppController como Coordinator (Tu proyecto)
```cpp
// src/controllers/AppController.h - Tu proyecto
class AppController : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isInitialized READ isInitialized NOTIFY isInitializedChanged)
    QML_ELEMENT

public:
    // Getters para todos los managers
    UserManager* userManager() const { return m_userManager; }
    ProductManager* productManager() const { return m_productManager; }
    SaleManager* saleManager() const { return m_saleManager; }
    InventoryManager* inventoryManager() const { return m_inventoryManager; }
    ExpenseManager* expenseManager() const { return m_expenseManager; }
    PayrollManager* payrollManager() const { return m_payrollManager; }
    ReportService* reportManager() const { return m_reportService; }

private:
    DatabaseManager *m_dbManager;
    UserManager *m_userManager;
    ProductManager *m_productManager;
    SaleManager *m_saleManager;
    InventoryManager *m_inventoryManager;
    ExpenseManager *m_expenseManager;
    PayrollManager *m_payrollManager;
    InventoryService *m_inventoryService;
    ReportService *m_reportService;
};
```

### Ventajas de tu arquitectura
- **Acceso directo** desde QML sin imports complejos
- **Separación clara**: cada Manager maneja un dominio (User, Sale, Inventory, etc.)
- **C++ como lógica de negocio**: toda la manipulación de datos en C++
- **QML para UI**: solo presentación y bindings

### Cuándo usar esta arquitectura vs MVVM puro
| Este patrón (Tu proyecto) | MVVM puro |
|---------------------------|-----------|
| Apps medianas/pequeñas | Apps grandes y complejas |
|-equipo reducido | Equipo grande con múltiples devs |
| Acceso directo a managers | ViewModels inyectados |
| Menos indirección | Más flexibilidad para testing |

## references
- [QuickFlux](https://github.com/benlau/quickflux)
- [QtMvvm](https://github.com/Skycoder42/QtMvvm)
- [MVVM Pattern](https://doc.qt.io/qt-6/qtquick-modelviewsdata-modelview.html)
