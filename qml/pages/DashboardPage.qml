import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"
import "../modules/commercial"
import "../modules/warehouse"
import "../modules/messenger"
import "../modules/custody"
import "../modules/admin"
import ".."

Page {
    id: dashboardPage
    background: Rectangle { color: Theme.background }

    property string currentRole: UserManager.currentUser.role || ""
    property var user: UserManager.currentUser

    header: NavigationBar {
        pageTitle: "505 X HORA - " + (user.fullName || user.username || "Dashboard")
        actions: [
            {
                text: "Perfil",
                action: function() { appWindow.navigateTo("pages/ProfilePage.qml") }
            },
            {
                text: "Salir",
                action: function() { UserManager.logout() }
            }
        ]
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        ScrollBar.vertical.policy: ScrollBar.AlwaysOn

        ColumnLayout {
            width: parent.width
            anchors.margins: Theme.spacingMd
            spacing: Theme.spacingMd

            // Resumen del día (solo admin y comercial)
            CustomCard {
                Layout.fillWidth: true
                visible: currentRole === "administrador" || currentRole === "comercial"
                title: "Resumen del Día"
                subtitle: Qt.formatDate(new Date(), "dd/MM/yyyy")

                content: GridLayout {
                    columns: Math.min(4, Math.floor(parent.width / 200))
                    columnSpacing: Theme.spacingMd
                    rowSpacing: Theme.spacingMd

                    Repeater {
                        model: [
                            { label: "Ventas Hoy", value: SaleManager.todaySalesCount, unit: "ventas", color: "#009688", bg: "#B2DFDB" },
                            { label: "Total Ventas", value: SaleManager.todaySalesTotal.toFixed(2), unit: "CUP", color: "#2E7D32", bg: "#C8E6C9" },
                            { label: "Gastos Hoy", value: ExpenseManager.todayExpenses.toFixed(2), unit: "CUP", color: "#C62828", bg: "#FFCDD2" },
                            { label: "Productos", value: ProductManager.rowCount(), unit: "ítems", color: "#1565C0", bg: "#BBDEFB" }
                        ]

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.minimumHeight: 80
                            radius: Theme.radiusMd
                            color: modelData.bg
                            border.color: modelData.color
                            border.width: 2

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.spacingSm

                                Label {
                                    text: modelData.label
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: modelData.color
                                    Layout.alignment: Qt.AlignLeft
                                }

                                Label {
                                    text: modelData.value
                                    font.pixelSize: 26
                                    font.weight: Font.Bold
                                    color: modelData.color
                                    Layout.alignment: Qt.AlignLeft
                                }

                                Label {
                                    text: modelData.unit
                                    font.pixelSize: 11
                                    color: modelData.color
                                    opacity: 0.8
                                    Layout.alignment: Qt.AlignLeft
                                }
                            }
                        }
                    }
                }
            }

            // Módulos por rol
            Label {
                text: "Módulos de Trabajo"
                font.pixelSize: 18
                font.weight: Font.Medium
                color: Theme.textPrimary
                Layout.leftMargin: Theme.spacingSm
            }

            GridLayout {
                Layout.fillWidth: true
                columns: Math.min(3, Math.floor(parent.width / 300))
                columnSpacing: Theme.spacingMd
                rowSpacing: Theme.spacingMd

                Repeater {
                    model: getModulesForRole(currentRole)

                    delegate: CustomCard {
                        Layout.fillWidth: true
                        Layout.minimumHeight: 120
                        elevation: 1
                        title: modelData.title
                        subtitle: modelData.description

                        MouseArea {
                            anchors.fill: parent
                            onClicked: appWindow.navigateTo(modelData.page)
                        }

                        content: RowLayout {
                            Label {
                                text: modelData.icon
                                font.pixelSize: 32
                                color: modelData.color
                            }
                            Item { Layout.fillWidth: true }
                            Label {
                                text: "→"
                                font.pixelSize: 20
                                color: Theme.accent
                            }
                        }
                    }
                }
            }

            // Alertas de stock (solo almacén y admin)
            CustomCard {
                Layout.fillWidth: true
                visible: (currentRole === "administrador" || currentRole === "almacen") && ProductManager.lowStockCount > 0
                title: "Alertas de Stock Bajo"
                subtitle: ProductManager.lowStockCount + " productos requieren atención"

                content: ListView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(200, count * 56)
                    model: ProductManager.getLowStockProducts()
                    delegate: ItemDelegate {
                        width: ListView.view.width
                        contentItem: RowLayout {
                            Label {
                                text: modelData.name
                                font.pixelSize: 14
                                color: Theme.textPrimary
                                Layout.fillWidth: true
                            }
                            Label {
                                text: modelData.stock + " / " + modelData.minStock + " min"
                                font.pixelSize: 13
                                color: Theme.error
                                font.weight: Font.Medium
                            }
                        }
                    }
                }
            }

            // Mantenimiento programado (sábado)
            CustomCard {
                Layout.fillWidth: true
                visible: currentRole === "administrador" || currentRole === "mensajero"
                title: "Mantenimiento de Transporte"
                subtitle: new Date().getDay() === 6 ? "Programado para hoy" : "Próximo: sábado"

                content: Label {
                    text: "Revise el estado de los medios de transporte. El mantenimiento programado es los días sábados."
                    font.pixelSize: 13
                    color: Theme.textSecondary
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }
    }

    function getModulesForRole(role) {
        var modules = []

        // Administrador ve TODOS los dashboards
        // Otros roles ven solo su dashboard

        if (role === "administrador") {
            // Dashboard Admin
            modules.push({
                title: "Admin",
                description: "Gastos, Nómina, Config, Usuarios",
                page: "modules/admin/DashboardAdminPage.qml",
                icon: "📈",
                color: Theme.primary
            })
            // Comercial
            modules.push({
                title: "Comercial",
                description: "Ventas, Facturación, Liquidación",
                page: "modules/commercial/CommercialDashboardPage.qml",
                icon: "💰",
                color: Theme.success
            })
            // Almacén
            modules.push({
                title: "Almacén",
                description: "Productos, Entradas, Stock",
                page: "modules/warehouse/WarehouseDashboardPage.qml",
                icon: "🏭",
                color: Theme.warning
            })
            // Mensajero
            modules.push({
                title: "Mensajero",
                description: "Entregas, Cobros, Incidentes",
                page: "modules/messenger/MessengerDashboardPage.qml",
                icon: "🚚",
                color: Theme.info
            })
            // Custodio
            modules.push({
                title: "Custodio",
                description: "Custodia, Historial",
                page: "modules/custody/CustodyDashboardPage.qml",
                icon: "🔐",
                color: Theme.accent
            })
        }

        // Roles específicos ven su dashboard
        if (role === "comercial") {
            modules.push({
                title: "Dashboard",
                description: "Resumen comercial",
                page: "modules/commercial/CommercialDashboardPage.qml",
                icon: "📊",
                color: Theme.primary
            })
        }

        if (role === "almacen") {
            modules.push({
                title: "Dashboard",
                description: "Resumen de almacén",
                page: "modules/warehouse/WarehouseDashboardPage.qml",
                icon: "📊",
                color: Theme.primary
            })
        }

        if (role === "mensajero") {
            modules.push({
                title: "Dashboard",
                description: "Resumen del mensajero",
                page: "modules/messenger/MessengerDashboardPage.qml",
                icon: "📊",
                color: Theme.primary
            })
        }

        if (role === "custodio") {
            modules.push({
                title: "Dashboard",
                description: "Resumen de custodia",
                page: "modules/custody/CustodyDashboardPage.qml",
                icon: "📊",
                color: Theme.primary
            })
        }

        return modules
    }
}
