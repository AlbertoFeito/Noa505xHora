#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include "src/controllers/AppController.h"
#include "src/utils/RoleEnums.h"
#include "src/models/User.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    
    app.setOrganizationName("505XHORA");
    app.setApplicationName("Sistema 505 X HORA");
    app.setApplicationVersion("1.0.0");

    QQuickStyle::setStyle("Basic");      // <-- Recomendado para máxima

    // Registro de tipos para QML
    qRegisterMetaType<UserData>("UserData");
    qmlRegisterUncreatableType<RoleEnums>("com.xhora.enums", 1, 0, "RoleEnums", "Enum container");

    // Registro de Theme como singleton
    qmlRegisterSingletonType(QUrl("qrc:/qml/Theme.qml"), "com.xhora.theme", 1, 0, "Theme");

    // Inicializar controlador principal (maneja DB y lógica de negocio)
    AppController appController;
    if (!appController.initialize()) {
        qCritical() << "Failed to initialize application controller";
        return -1;
    }

    QQmlApplicationEngine engine;
    
    // Exponer controlador a QML como context property
    engine.rootContext()->setContextProperty("AppController", &appController);
    
    // Exponer sub-controladores
    engine.rootContext()->setContextProperty("UserManager", appController.userManager());
    engine.rootContext()->setContextProperty("ProductManager", appController.productManager());
    engine.rootContext()->setContextProperty("SaleManager", appController.saleManager());
    engine.rootContext()->setContextProperty("InventoryManager", appController.inventoryManager());
    engine.rootContext()->setContextProperty("ExpenseManager", appController.expenseManager());
    engine.rootContext()->setContextProperty("PayrollManager", appController.payrollManager());
    engine.rootContext()->setContextProperty("ReportManager", appController.reportManager());

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    
    engine.load(url);

    return app.exec();
}
