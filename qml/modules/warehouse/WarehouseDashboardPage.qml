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

            // Grid de módulos de almacén
            GridLayout {
                columns: Math.min(2, Math.floor(parent.width / 250))
                columnSpacing: Theme.spacingMd
                rowSpacing: Theme.spacingMd

                // Vale de Entrega
                CustomCard {
                    Layout.fillWidth: true

                    content: MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/warehouse/DeliveryValePage.qml")
                        }

                        ColumnLayout {
                            spacing: Theme.spacingSm

                            Label {
                                text: "📦"
                                font.pixelSize: 32
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Vale de Entrega"
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                color: Theme.textPrimary
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Recibir y preparar pedidos"
                                font.pixelSize: 12
                                color: Theme.textSecondary
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }

                // Entrada Productos
                CustomCard {
                    Layout.fillWidth: true

                    content: MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/warehouse/ProductEntryPage.qml")
                        }

                        ColumnLayout {
                            spacing: Theme.spacingSm

                            Label {
                                text: "📥"
                                font.pixelSize: 32
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Entrada Productos"
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                color: Theme.textPrimary
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Registrar productos recibidos"
                                font.pixelSize: 12
                                color: Theme.textSecondary
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }

                // Alta Productos
                CustomCard {
                    Layout.fillWidth: true

                    content: MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/warehouse/AltaProductPage.qml")
                        }

                        ColumnLayout {
                            spacing: Theme.spacingSm

                            Label {
                                text: "➕"
                                font.pixelSize: 32
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Alta Productos"
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                color: Theme.textPrimary
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Crear nuevos productos"
                                font.pixelSize: 12
                                color: Theme.textSecondary
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }

                // Categorías
                CustomCard {
                    Layout.fillWidth: true

                    content: MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/warehouse/CategoriasPage.qml")
                        }

                        ColumnLayout {
                            spacing: Theme.spacingSm

                            Label {
                                text: "🏷️"
                                font.pixelSize: 32
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Categorías"
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                color: Theme.textPrimary
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Gestionar categorías"
                                font.pixelSize: 12
                                color: Theme.textSecondary
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }

                // Control de Calidad
                CustomCard {
                    Layout.fillWidth: true

                    content: MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/warehouse/QualityCheckPage.qml")
                        }

                        ColumnLayout {
                            spacing: Theme.spacingSm

                            Label {
                                text: "✅"
                                font.pixelSize: 32
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Control de Calidad"
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                color: Theme.textPrimary
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Verificación de productos"
                                font.pixelSize: 12
                                color: Theme.textSecondary
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }

                // Conteo Diario
                CustomCard {
                    Layout.fillWidth: true

                    content: MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/warehouse/DailyCountPage.qml")
                        }

                        ColumnLayout {
                            spacing: Theme.spacingSm

                            Label {
                                text: "📊"
                                font.pixelSize: 32
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Conteo Diario"
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                color: Theme.textPrimary
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Registro de inventario diario"
                                font.pixelSize: 12
                                color: Theme.textSecondary
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }

                // Stock Bajo
                CustomCard {
                    Layout.fillWidth: true

                    content: MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/warehouse/StockAlertsPage.qml")
                        }

                        ColumnLayout {
                            spacing: Theme.spacingSm

                            Label {
                                text: "⚠️"
                                font.pixelSize: 32
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Stock Bajo"
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                color: Theme.textPrimary
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Productos por debajo del mínimo"
                                font.pixelSize: 12
                                color: Theme.textSecondary
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
    }
}