import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Vale de Entrega"
        showBack: true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        CustomCard {
            Layout.fillWidth: true
            title: "Ventas Facturadas - Preparar"

            content: ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: SaleManager.getSalesByStatus("facturado")
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
                                    text: "Total: " + modelData.total.toFixed(2) + " CUP"
                                    font.pixelSize: 12
                                    color: Theme.textSecondary
                                }
                            }
                            CustomButton {
                                text: "Preparar"
                                type: 2
                                onClicked: prepareOrder(modelData.id)
                            }
                        }

                        // Items de la venta
                        ListView {
                            Layout.fillWidth: true
                            Layout.preferredHeight: count * 32
                            model: SaleManager.getSaleItems(modelData.id)
                            interactive: false

                            delegate: Label {
                                width: ListView.view.width
                                text: "  • " + modelData.productName + " (x" + modelData.quantity + ")"
                                font.pixelSize: 12
                                color: Theme.textSecondary
                            }
                        }
                    }
                }
            }
        }
    }

    function prepareOrder(saleId) {
        if (SaleManager.updateSaleStatus(saleId, "preparado")) {
            appWindow.showToast("Orden preparada para entrega")
        }
    }
}
