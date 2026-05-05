import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Módulo Almacén"
        showBack: true
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width

        ColumnLayout {
            width: parent.width
            anchors.margins: Theme.spacingMd
            spacing: Theme.spacingMd

            // Resumen del almacén
            CustomCard {
                Layout.fillWidth: true
                title: "Resumen del Almacén"
                subtitle: Qt.formatDate(new Date(), "dd/MM/yyyy")

                content: RowLayout {
                    spacing: Theme.spacingMd

                    // Total Productos
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.minimumHeight: 80
                        radius: Theme.radiusMd
                        color: "#BBDEFB"
                        border.color: "#1565C0"
                        border.width: 2

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingSm

                            Label {
                                text: "Total Productos"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: "#0D47A1"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: ProductManager.rowCount()
                                font.pixelSize: 28
                                font.weight: Font.Bold
                                color: "#0D47A1"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: "ítems"
                                font.pixelSize: 11
                                color: "#0D47A1"
                                opacity: 0.8
                                Layout.alignment: Qt.AlignLeft
                            }
                        }
                    }

                    // Stock Bajo
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.minimumHeight: 80
                        radius: Theme.radiusMd
                        color: "#FFCDD2"
                        border.color: "#C62828"
                        border.width: 2

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingSm

                            Label {
                                text: "Stock Bajo"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: "#B71C1C"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: ProductManager.lowStockCount
                                font.pixelSize: 28
                                font.weight: Font.Bold
                                color: "#B71C1C"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: "alertas"
                                font.pixelSize: 11
                                color: "#B71C1C"
                                opacity: 0.8
                                Layout.alignment: Qt.AlignLeft
                            }
                        }
                    }

                    // Categorías (menos 1 porque incluye "Todas")
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.minimumHeight: 80
                        radius: Theme.radiusMd
                        color: "#E1BEE7"
                        border.color: "#7B1FA2"
                        border.width: 2

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingSm

                            Label {
                                text: "Categorías"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: "#6A1B9A"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: ProductManager.getCategories().length - 1
                                font.pixelSize: 28
                                font.weight: Font.Bold
                                color: "#6A1B9A"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: "tipos"
                                font.pixelSize: 11
                                color: "#6A1B9A"
                                opacity: 0.8
                                Layout.alignment: Qt.AlignLeft
                            }
                        }
                    }
                }
            }

            // Label módulos
            Label {
                text: "Módulos de Almacén"
                font.pixelSize: 18
                font.weight: Font.Medium
                color: Theme.textPrimary
                Layout.leftMargin: Theme.spacingSm
            }

            // Grid de módulos de almacén
            GridLayout {
                columns: Math.min(2, Math.floor(parent.width / 250))
                columnSpacing: Theme.spacingMd
                rowSpacing: Theme.spacingMd

                // 1. Entrada Productos
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "1. Entrada Productos"
                    subtitle: "Registrar productos recibidos"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/warehouse/ProductEntryPage.qml")
                        }
                    }

                    content: RowLayout {
                        Label {
                            text: "📥"
                            font.pixelSize: 32
                            color: Theme.success
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "→"
                            font.pixelSize: 20
                            color: Theme.accent
                        }
                    }
                }

                // 2. Alta Productos
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "2. Alta Productos"
                    subtitle: "Crear nuevos productos"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/warehouse/AltaProductPage.qml")
                        }
                    }

                    content: RowLayout {
                        Label {
                            text: "➕"
                            font.pixelSize: 32
                            color: Theme.primary
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "→"
                            font.pixelSize: 20
                            color: Theme.accent
                        }
                    }
                }

                // 3. Categorías
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "3. Categorías"
                    subtitle: "Gestionar categorías"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/warehouse/CategoriasPage.qml")
                        }
                    }

                    content: RowLayout {
                        Label {
                            text: "🏷️"
                            font.pixelSize: 32
                            color: Theme.info
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "→"
                            font.pixelSize: 20
                            color: Theme.accent
                        }
                    }
                }

                // 4. Productos
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "4. Productos"
                    subtitle: "Ver y editar productos"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/warehouse/ProductListPage.qml")
                        }
                    }

                    content: RowLayout {
                        Label {
                            text: "📋"
                            font.pixelSize: 32
                            color: Theme.primary
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "→"
                            font.pixelSize: 20
                            color: Theme.accent
                        }
                    }
                }

                // 5. Proveedores
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "5. Proveedores"
                    subtitle: "Gestionar proveedores"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/warehouse/ProveedoresPage.qml")
                        }
                    }

                    content: RowLayout {
                        Label {
                            text: "🏢"
                            font.pixelSize: 32
                            color: Theme.warning
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "→"
                            font.pixelSize: 20
                            color: Theme.accent
                        }
                    }
                }

                // 6. Control de Calidad
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "6. Control de Calidad"
                    subtitle: "Verificación de productos"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/warehouse/QualityCheckPage.qml")
                        }
                    }

                    content: RowLayout {
                        Label {
                            text: "✅"
                            font.pixelSize: 32
                            color: Theme.success
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "→"
                            font.pixelSize: 20
                            color: Theme.accent
                        }
                    }
                }

                // Conteo Diario
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "7. Conteo Diario"
                    subtitle: "Registro de inventario diario"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/warehouse/DailyCountPage.qml")
                        }
                    }

                    content: RowLayout {
                        Label {
                            text: "📊"
                            font.pixelSize: 32
                            color: Theme.warning
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "→"
                            font.pixelSize: 20
                            color: Theme.accent
                        }
                    }
                }

                // 8. Stock Bajo
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "8. Stock Bajo"
                    subtitle: "Productos por debajo del mínimo"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/warehouse/StockAlertsPage.qml")
                        }
                    }

                    content: RowLayout {
                        Label {
                            text: "⚠️"
                            font.pixelSize: 32
                            color: Theme.error
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "→"
                            font.pixelSize: 20
                            color: Theme.accent
                        }
                    }
                }

                // 9. Salida de Productos
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "9. Salida de Productos"
                    subtitle: "Registrar consumo/venta"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/warehouse/ProductExitPage.qml")
                        }
                    }

                    content: RowLayout {
                        Label {
                            text: "📤"
                            font.pixelSize: 32
                            color: Theme.error
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "→"
                            font.pixelSize: 20
                            color: Theme.accent
                        }
                    }
                }

                // 10. Vale de Entrega
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "10. Vale de Entrega"
                    subtitle: "Recibir y preparar pedidos"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/warehouse/DeliveryValePage.qml")
                        }
                    }

                    content: RowLayout {
                        Label {
                            text: "📦"
                            font.pixelSize: 32
                            color: Theme.accent
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "→"
                            font.pixelSize: 20
                            color: Theme.accent
                        }
                    }
                }

                // 11. Historial de Movimientos
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "11. Historial"
                    subtitle: "Ver todas las entradas y salidas"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/warehouse/InventoryHistoryPage.qml")
                        }
                    }

                    content: RowLayout {
                        Label {
                            text: "📋"
                            font.pixelSize: 32
                            color: Theme.info
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
    }
}