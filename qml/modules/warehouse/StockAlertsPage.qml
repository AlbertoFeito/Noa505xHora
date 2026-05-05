import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Alertas de Stock"
        showBack: true
    }

    onVisibleChanged: {
        if (visible) {
            refreshAlerts()
        }
    }

    function refreshAlerts() {
        lowStockModel = ProductManager.getLowStockProducts()
    }

    property var lowStockModel: ProductManager.getLowStockProducts()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        CustomCard {
            Layout.fillWidth: true
            title: "Productos Bajo Stock Mínimo"
            subtitle: ProductManager.lowStockCount + " alertas"

            content: ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumHeight: 200

                // Estado vacío
                Rectangle {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 100
                    visible: lowStockModel.length === 0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacingSm

                        Label {
                            text: "✅"
                            font.pixelSize: 40
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Label {
                            text: "No hay productos bajo stock mínimo"
                            font.pixelSize: 14
                            color: Theme.textSecondary
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // Lista de productos
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: lowStockModel
                    clip: true
                    visible: lowStockModel.length > 0

                    delegate: ItemDelegate {
                        width: ListView.view.width
                        contentItem: RowLayout {
                            spacing: Theme.spacingSm

                            Rectangle {
                                width: 4
                                height: 40
                                radius: 2
                                color: Theme.error
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Label {
                                    text: modelData.name
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    color: Theme.textPrimary
                                }
                                Label {
                                    text: "Código: " + (modelData.code || "N/A")
                                    font.pixelSize: 11
                                    color: Theme.textSecondary
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 50
                                radius: Theme.radiusSm
                                color: "#FFEBEE"
                                border.color: Theme.error
                                border.width: 1

                                ColumnLayout {
                                    anchors.centerIn: parent

                                    RowLayout {
                                        Label {
                                            text: "Stock: "
                                            font.pixelSize: 10
                                            color: Theme.error
                                        }
                                        Label {
                                            text: modelData.stock + " / " + modelData.minStock + " mín"
                                            font.pixelSize: 14
                                            font.weight: Font.Bold
                                            color: Theme.error
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
