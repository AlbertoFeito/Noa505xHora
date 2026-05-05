import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Facturación"
        showBack: true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        CustomCard {
            Layout.fillWidth: true
            title: "Ventas Pendientes de Factura"

            Component.onCompleted: {
                console.log("InvoicePage loaded, pending sales:", SaleManager.getSalesByStatus("pendiente").length)
            }

            content: ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                model: SaleManager.getSalesByStatus("pendiente")
                clip: true

                emptyLabel: Label {
                    text: "No hay ventas pendientes"
                    font.pixelSize: 14
                    color: Theme.textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Layout.fillWidth: true
                }

                delegate: ItemDelegate {
                    width: ListView.view.width
                    contentItem: RowLayout {
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Label {
                                text: modelData.saleNumber + " - " + (modelData.clientName || "Sin nombre")
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: Theme.textPrimary
                            }
                            Label {
                                text: "Total: " + (modelData.total || 0).toFixed(2) + " CUP"
                                font.pixelSize: 12
                                color: Theme.textSecondary
                            }
                        }

                        CustomButton {
                            text: "Facturar"
                            type: 2

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("Facturar sale ID:", modelData.id)
                                    createInvoice(modelData.id)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function createInvoice(saleId) {
        console.log("createInvoice called with saleId:", saleId)

        var sale = SaleManager.getSale(saleId)
        console.log("Sale data:", sale)

        if (!sale || sale.id <= 0) {
            appWindow.showToast("Venta no encontrada", true)
            return
        }

        var invoiceId = SaleManager.createInvoice(
            saleId,
            sale.clientName || "",
            "",
            sale.total || 0,
            UserManager.currentUser.id || 0
        )

        console.log("Invoice created, invoiceId:", invoiceId)

        if (invoiceId > 0) {
            appWindow.showToast("Factura emitida correctamente")
            SaleManager.refreshSales()
        } else {
            appWindow.showToast("Error al emitir factura", true)
        }
    }
}
