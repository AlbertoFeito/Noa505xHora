import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Registro de Cobros"
        showBack: true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        CustomCard {
            Layout.fillWidth: true
            title: "Cobros Pendientes"

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
                                color: Theme.textPrimary
                            }
                            Label {
                                text: "Total: " + modelData.total.toFixed(2) + " CUP"
                                font.pixelSize: 13
                                color: Theme.accent
                                font.weight: Font.Medium
                            }
                        }
                        CustomButton {
                            text: "Cobrar"
                            type: 2
                            onClicked: collectPayment(modelData)
                        }
                    }
                }
            }
        }
    }

    function collectPayment(sale) {
        var success = SaleManager.createLiquidation(
            sale.id,
            UserManager.currentUser.id,
            sale.total,
            sale.paymentType,
            0,
            "",
            UserManager.currentUser.id
        )

        if (success) {
            appWindow.showToast("Cobro registrado: " + sale.total.toFixed(2) + " CUP")
        }
    }
}
