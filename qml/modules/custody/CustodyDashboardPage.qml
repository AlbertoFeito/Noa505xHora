import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Módulo Custodio"
        showBack: true
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width

        ColumnLayout {
            width: parent.width
            anchors.margins: Theme.spacingMd
            spacing: Theme.spacingMd

            // Resumen del custodio
            CustomCard {
                Layout.fillWidth: true
                title: "Resumen de Custodia"
                subtitle: Qt.formatDate(new Date(), "dd/MM/yyyy")

                content: RowLayout {
                    spacing: Theme.spacingMd

                    // Custodias hoy
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
                                text: "Custodias Hoy"
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
                                text: "recibidas"
                                font.pixelSize: 11
                                color: "#2E7D32"
                                opacity: 0.8
                                Layout.alignment: Qt.AlignLeft
                            }
                        }
                    }

                    // Total en custodia
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
                                text: "En Custodia"
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
                                text: "CUP total"
                                font.pixelSize: 11
                                color: "#1565C0"
                                opacity: 0.8
                                Layout.alignment: Qt.AlignLeft
                            }
                        }
                    }

                    // Productos en custodia
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.minimumHeight: 80
                        radius: Theme.radiusMd
                        color: "#F3E5F5"
                        border.color: "#8E24AA"
                        border.width: 2

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingSm

                            Label {
                                text: "Productos"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: "#6A1B9A"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: "0"
                                font.pixelSize: 28
                                font.weight: Font.Bold
                                color: "#6A1B9A"
                                Layout.alignment: Qt.AlignLeft
                            }

                            Label {
                                text: "ítems"
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
                text: "Módulos del Custodio"
                font.pixelSize: 18
                font.weight: Font.Medium
                color: Theme.textPrimary
                Layout.leftMargin: Theme.spacingSm
            }

            // Grid de módulos del custodio
            GridLayout {
                columns: Math.min(2, Math.floor(parent.width / 250))
                columnSpacing: Theme.spacingMd
                rowSpacing: Theme.spacingMd

                // 1. Recibo de Custodia
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "1. Recibo Custodia"
                    subtitle: "Recibir custodia"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/custody/CustodyReceiptPage.qml")
                        }
                    }

                    content: RowLayout {
                        Label {
                            text: "📦"
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

                // 2. Historial de Custodia
                CustomCard {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    elevation: 1
                    title: "2. Historial"
                    subtitle: "Ver historial de custodia"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appWindow.navigateTo("modules/custody/CustodyHistoryPage.qml")
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