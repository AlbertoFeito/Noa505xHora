import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Módulo Mensajero"
        showBack: true
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width

        ColumnLayout {
            width: parent.width
            anchors.margins: Theme.spacingMd
            spacing: Theme.spacingMd

            // Resumen del mensajería
            CustomCard {
                Layout.fillWidth: true
                title: "Resumen del Mensajero"
                subtitle: Qt.formatDate(new Date(), "dd/MM/yyyy")

                content: RowLayout {
                    spacing: Theme.spacingMd

                    // Entregas pendientes
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
                                text: "Pendientes"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: "#E65100"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: SaleManager.getSalesByStatus("preparado").length
                                font.pixelSize: 28
                                font.weight: Font.Bold
                                color: "#E65100"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: "entregas"
                                font.pixelSize: 11
                                color: "#E65100"
                                opacity: 0.8
                                Layout.alignment: Qt.AlignLeft
                            }
                        }
                    }

                    // En tránsito
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
                                text: "En Tránsito"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: "#2E7D32"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: "0"
                                font.pixelSize: 28
                                font.weight: Font.Bold
                                color: "#2E7D32"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: "en camino"
                                font.pixelSize: 11
                                color: "#2E7D32"
                                opacity: 0.8
                                Layout.alignment: Qt.AlignLeft
                            }
                        }
                    }

                    // Cobros
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
                                text: "Cobros"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: "#1565C0"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: "0.00"
                                font.pixelSize: 28
                                font.weight: Font.Bold
                                color: "#1565C0"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: "CUP hoy"
                                font.pixelSize: 11
                                color: "#1565C0"
                                opacity: 0.8
                                Layout.alignment: Qt.AlignLeft
                            }
                        }
                    }
                }
            }

            // Label módulos
            Label {
                text: "Módulos del Mensajero"
                font.pixelSize: 18
                font.weight: Font.Medium
                color: Theme.textPrimary
                Layout.leftMargin: Theme.spacingSm
            }

            // Grid de módulos del mensajero
            GridLayout {
                columns: Math.min(2, Math.floor(parent.width / 250))
                columnSpacing: Theme.spacingMd
                rowSpacing: Theme.spacingMd

                // 1. Estado de Entregas
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "1. Estado Entregas"
                    subtitle: "Seguimiento de entregas"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/messenger/DeliveryStatusPage.qml")
                        }
                    }

                    content: RowLayout {
                        Label {
                            text: "🚚"
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

                // 2. Cobros
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "2. Cobros"
                    subtitle: "Registrar cobros"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/messenger/CollectionPage.qml")
                        }
                    }

                    content: RowLayout {
                        Label {
                            text: "💵"
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

                // 3. Incidentes
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "3. Incidentes"
                    subtitle: "Reportar incidentes"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/messenger/IncidentReportPage.qml")
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
            }
        }
    }
}