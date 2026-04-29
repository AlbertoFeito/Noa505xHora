import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Conteo Físico Diario"
        showBack: true
    }

    property var countItems: []

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        CustomCard {
            Layout.fillWidth: true
            title: "Conteo de Productos"
            subtitle: Qt.formatDate(new Date(), "dd/MM/yyyy")

            content: ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: ProductManager
                clip: true

                delegate: ItemDelegate {
                    width: ListView.view.width
                    contentItem: RowLayout {
                        Label {
                            text: model.name
                            font.pixelSize: 14
                            color: Theme.textPrimary
                            Layout.fillWidth: true
                        }
                        Label {
                            text: "Esperado: " + model.stock
                            font.pixelSize: 12
                            color: Theme.textSecondary
                        }
                        SpinBox {
                            from: 0
                            to: 9999
                            value: model.stock
                            onValueModified: updateCount(model.id, value)
                        }
                    }
                }
            }
        }

        CustomButton {
            Layout.fillWidth: true
            text: "Guardar Conteo"
            type: 2
            onClicked: saveCount()
        }
    }

    function updateCount(productId, actualQty) {
        for (var i = 0; i < countItems.length; i++) {
            if (countItems[i].productId === productId) {
                countItems[i].actualQuantity = actualQty
                return
            }
        }
        countItems.push({ productId: productId, actualQuantity: actualQty })
    }

    function saveCount() {
        if (countItems.length === 0) {
            appWindow.showToast("No hay cambios para guardar", true)
            return
        }

        var success = InventoryService.performDailyCount(
            new Date(),
            countItems,
            UserManager.currentUser.id
        )

        if (success) {
            appWindow.showToast("Conteo guardado correctamente")
            ProductManager.refreshProducts()
        } else {
            appWindow.showToast("Error al guardar conteo", true)
        }
    }
}
