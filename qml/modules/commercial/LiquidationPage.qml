import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Liquidación de Cobros"
        showBack: true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        CustomCard {
            Layout.fillWidth: true
            title: "Ventas por Liquidar"

            content: ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: SaleManager.getSalesByStatus("entregado")
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

                        CustomButton {
                            text: "Liquidar"
                            type: 2
                            onClicked: liquidateSale(modelData)
                        }
                    }
                }
            }
        }
    }

    function liquidateSale(sale) {
        // En una app real, esto abriría un diálogo de liquidación
        var success = SaleManager.createLiquidation(
            sale.id,
            sale.messengerId || 0,
            sale.total,
            sale.paymentType,
            0,
            "",
            UserManager.currentUser.id
        )

        if (success) {
            appWindow.showToast("Liquidación realizada correctamente")
            SaleManager.refreshSales()
        } else {
            appWindow.showToast("Error en la liquidación", true)
        }
    }
}
