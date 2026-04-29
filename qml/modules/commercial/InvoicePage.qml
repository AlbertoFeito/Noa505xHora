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

            content: ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: SaleManager.getSalesByStatus("pendiente")
                clip: true

                delegate: ItemDelegate {
                    width: ListView.view.width
                    contentItem: RowLayout {
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

                        StatusBadge {
                            status: modelData.status
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        }

                        CustomButton {
                            text: "Facturar"
                            type: 2
                            onClicked: createInvoice(modelData.id)
                        }
                    }
                }
            }
        }
    }

    function createInvoice(saleId) {
        var sale = SaleManager.getSale(saleId)
        var invoiceId = SaleManager.createInvoice(
            saleId,
            sale.clientName,
            "",
            sale.total,
            UserManager.currentUser.id
        )

        if (invoiceId > 0) {
            appWindow.showToast("Factura emitida correctamente")
            SaleManager.refreshSales()
        } else {
            appWindow.showToast("Error al emitir factura", true)
        }
    }
}
