import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Estado de Entregas"
        showBack: true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        CustomCard {
            Layout.fillWidth: true
            title: "Entregas Asignadas"

            content: ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: SaleManager.getSalesByStatus("preparado")
                clip: true

                delegate: ItemDelegate {
                    width: ListView.view.width
                    contentItem: ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSm

                        RowLayout {
                            Layout.fillWidth: true
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Label {
                                    text: modelData.saleNumber + " - " + modelData.clientName
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    color: Theme.textPrimary
                                }
                                Label {
                                    text: modelData.clientAddress || "Entrega en local"
                                    font.pixelSize: 12
                                    color: Theme.textSecondary
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                            CustomButton {
                                text: "Iniciar"
                                type: 2
                                onClicked: startDelivery(modelData.id)
                            }
                        }
                    }
                }
            }
        }

        CustomCard {
            Layout.fillWidth: true
            title: "En Tránsito"

            content: ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                model: SaleManager.getSalesByStatus("en_transito")
                clip: true

                delegate: ItemDelegate {
                    width: ListView.view.width
                    contentItem: RowLayout {
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Label {
                                text: modelData.saleNumber
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: Theme.textPrimary
                            }
                            Label {
                                text: modelData.clientName
                                font.pixelSize: 12
                                color: Theme.textSecondary
                            }
                        }
                        CustomButton {
                            text: "Entregar"
                            type: 1
                            onClicked: completeDelivery(modelData.id)
                        }
                    }
                }
            }
        }
    }

    function startDelivery(saleId) {
        if (SaleManager.registerDelivery(saleId, UserManager.currentUser.id, 0)) {
            appWindow.showToast("Entrega iniciada")
            SaleManager.refreshSales()
        }
    }

    function completeDelivery(saleId) {
        if (SaleManager.updateDeliveryStatus(saleId, "entregado", 0, "")) {
            appWindow.showToast("Entrega completada")
            SaleManager.refreshSales()
        }
    }
}
