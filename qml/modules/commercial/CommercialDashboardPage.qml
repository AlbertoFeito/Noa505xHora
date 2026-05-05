import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Módulo Comercial"
        showBack: true
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width

        ColumnLayout {
            width: parent.width
            anchors.margins: Theme.spacingMd
            spacing: Theme.spacingMd

            // Resumen del comercial
            CustomCard {
                Layout.fillWidth: true
                title: "Resumen Comercial"
                subtitle: Qt.formatDate(new Date(), "dd/MM/yyyy")

                content: RowLayout {
                    spacing: Theme.spacingMd

                    // Ventas de hoy
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.minimumHeight: 80
                        radius: Theme.radiusMd
                        color: "#E8F5E9"
                        border.color: "#43A047"
                        border.width: 2

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingSm

                            Label {
                                text: "Ventas Hoy"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: "#2E7D32"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: SaleManager.todaySalesCount
                                font.pixelSize: 28
                                font.weight: Font.Bold
                                color: "#2E7D32"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: "ventas"
                                font.pixelSize: 11
                                color: "#2E7D32"
                                opacity: 0.8
                                Layout.alignment: Qt.AlignLeft
                            }
                        }
                    }

                    // Total día
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.minimumHeight: 80
                        radius: Theme.radiusMd
                        color: "#E3F2FD"
                        border.color: "#1E88E5"
                        border.width: 2

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingSm

                            Label {
                                text: "Total Día"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: "#1565C0"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: SaleManager.todaySalesTotal.toFixed(2) + " CUP"
                                font.pixelSize: 20
                                font.weight: Font.Bold
                                color: "#1565C0"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: "ingresos"
                                font.pixelSize: 11
                                color: "#1565C0"
                                opacity: 0.8
                                Layout.alignment: Qt.AlignLeft
                            }
                        }
                    }

                    // Pendiente por cobrar
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.minimumHeight: 80
                        radius: Theme.radiusMd
                        color: "#FFF3E0"
                        border.color: "#FB8C00"
                        border.width: 2

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingSm

                            Label {
                                text: "Pendiente"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: "#E65100"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: SaleManager.pendingAmount.toFixed(2)
                                font.pixelSize: 28
                                font.weight: Font.Bold
                                color: "#E65100"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: "CUP por cobr",
                                font.pixelSize: 11
                                color: "#E65100"
                                opacity: 0.8
                                Layout.alignment: Qt.AlignLeft
                            }
                        }
                    }
                }
            }

            // Label módulos
            Label {
                text: "Módulos de Comercial"
                font.pixelSize: 18
                font.weight: Font.Medium
                color: Theme.textPrimary
                Layout.leftMargin: Theme.spacingSm
            }

            // Grid de módulos comerciales
            GridLayout {
                columns: Math.min(2, Math.floor(parent.width / 250))
                columnSpacing: Theme.spacingMd
                rowSpacing: Theme.spacingMd

                // 1. Nuevo Vale de Venta
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "1. Nuevo Vale"
                    subtitle: "Crear nueva venta"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/commercial/SaleValePage.qml")
                        }
                    }

                    content: RowLayout {
                        Label {
                            text: "💰"
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

                // 2. Facturación
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "2. Facturación"
                    subtitle: "Emitir facturas"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/commercial/InvoicePage.qml")
                        }
                    }

                    content: RowLayout {
                        Label {
                            text: "📄"
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

                // 3. Liquidación
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "3. Liquidación"
                    subtitle: "Liquidar cobros"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/commercial/LiquidationPage.qml")
                        }
                    }

                    content: RowLayout {
                        Label {
                            text: "💵"
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

                // 4. Comisiones
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "4. Comisiones"
                    subtitle: "Gestionar comisiones"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/commercial/CommissionPage.qml")
                        }
                    }

                    content: RowLayout {
                        Label {
                            text: "📊"
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

            // Estado de ventas hoy
            CustomCard {
                Layout.fillWidth: true
                title: "Estado de Ventas Hoy"

                content: ColumnLayout {
                    spacing: Theme.spacingSm

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "Pendientes:"
                            font.pixelSize: 13
                            color: Theme.textSecondary
                            Layout.fillWidth: true
                        }
                        Label {
                            text: SaleManager.getSalesByStatus("pendiente").length
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: Theme.warning
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "Facturados:"
                            font.pixelSize: 13
                            color: Theme.textSecondary
                            Layout.fillWidth: true
                        }
                        Label {
                            text: SaleManager.getSalesByStatus("facturado").length
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: Theme.info
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "Preparados:"
                            font.pixelSize: 13
                            color: Theme.textSecondary
                            Layout.fillWidth: true
                        }
                        Label {
                            text: SaleManager.getSalesByStatus("preparado").length
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: Theme.primary
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "Entregados:"
                            font.pixelSize: 13
                            color: Theme.textSecondary
                            Layout.fillWidth: true
                        }
                        Label {
                            text: SaleManager.getSalesByStatus("entregado").length
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: Theme.success
                        }
                    }
                }
            }
        }
    }
}