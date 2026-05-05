import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Control de Calidad"
        showBack: true
    }

    property var selectedSale: null
    property var checklistItems: [
        { id: 1, text: "Verificar envoltura y embalaje", checked: false },
        { id: 2, text: "Comprobar funcionamiento del equipo", checked: false },
        { id: 3, text: "Revisar fecha de caducidad (si aplica)", checked: false },
        { id: 4, text: "Confirmar cantidad y productos", checked: false },
        { id: 5, text: "Etiquetar correctamente", checked: false }
    ]

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width

        ColumnLayout {
            width: parent.width
            anchors.margins: Theme.spacingMd
            spacing: Theme.spacingMd

            // Seleccionar venta a verificar
            CustomCard {
                Layout.fillWidth: true
                title: "Seleccionar Venta para Verificar"
                subtitle: "Ventas en estado 'facturado'"

                Component.onCompleted: {
                    console.log("QualityCheck: loaded, facturado sales:", SaleManager.getSalesByStatus("facturado").length)
                }

                content: ListView {
                    Layout.fillWidth: true
                    height: 150
                    model: SaleManager.getSalesByStatus("facturado")
                    clip: true

                    delegate: ItemDelegate {
                        width: ListView.view.width
                        onClicked: {
                            selectedSale = modelData
                            console.log("Selected sale:", modelData.saleNumber)
                            // Reset checklist
                            for (var i = 0; i < checklistItems.length; i++) {
                                checklistItems[i].checked = false
                            }
                            checklistView.model = null
                            checklistView.model = checklistItems
                        }

                        contentItem: RowLayout {
                            Label {
                                text: "Venta #" + modelData.saleNumber + " - " + (modelData.clientName || "Sin cliente")
                                font.pixelSize: 13
                                color: Theme.textPrimary
                                Layout.fillWidth: true
                            }
                            Label {
                                text: modelData.total.toFixed(2) + " CUP"
                                font.pixelSize: 12
                                color: Theme.success
                            }
                        }
                    }
                }
            }

            // Venta seleccionada
            CustomCard {
                Layout.fillWidth: true
                visible: selectedSale !== null
                title: "Venta #" + (selectedSale ? selectedSale.saleNumber : "")
                subtitle: (selectedSale ? selectedSale.clientName : "") + " - Total: " + (selectedSale ? selectedSale.total.toFixed(2) : "0") + " CUP"

                content: ListView {
                    Layout.fillWidth: true
                    height: 100
                    model: selectedSale ? SaleManager.getSaleItems(selectedSale.id) : []
                    clip: true

                    delegate: Label {
                        width: ListView.view.width
                        text: "• " + modelData.productName + " (x" + modelData.quantity + ")"
                        font.pixelSize: 12
                        color: Theme.textSecondary
                    }
                }
            }

            // Checklist
            CustomCard {
                Layout.fillWidth: true
                visible: selectedSale !== null
                title: "Checklist de Verificación"
                subtitle: "Marque todos los puntos antes de aprobar"

                content: ColumnLayout {
                    spacing: Theme.spacingSm

                    // Function to handle checkbox
                    function toggleCheck(index, checked) {
                        checklistItems[index].checked = checked
                        checklistView.model = null
                        checklistView.model = checklistItems
                    }

                    ListView {
                        id: checklistView
                        Layout.fillWidth: true
                        model: checklistItems
                        height: 200

                        delegate: RowLayout {
                            width: ListView.view.width
                            spacing: Theme.spacingSm

                            CheckBox {
                                checked: modelData.checked
                                onCheckedChanged: {
                                    // Directly toggle and force array change
                                    var temp = checklistItems[index]
                                    temp.checked = checked
                                    checklistItems[index] = temp
                                    // Force refresh
                                    checklistItems = checklistItems.slice()
                                }
                            }

                            Label {
                                text: modelData.text
                                font.pixelSize: 14
                                color: modelData.checked ? Theme.success : Theme.textPrimary
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // Progress
                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "Completado: " + getCheckedCount() + "/" + checklistItems.length
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: getCheckedCount() === checklistItems.length ? Theme.success : Theme.warning
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: getCheckedCount() === checklistItems.length ? "✅ Listo" : "⏳ Pendiente"
                            font.pixelSize: 13
                            color: getCheckedCount() === checklistItems.length ? Theme.success : Theme.textSecondary
                        }
                    }

                    CustomButton {
                        Layout.fillWidth: true
                        text: "✅ Aprobar y Preparar"
                        type: getCheckedCount() === checklistItems.length ? 2 : 0

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (getCheckedCount() < checklistItems.length) {
                                    appWindow.showToast("Debe completar todos los puntos del checklist", true)
                                    return
                                }
                                console.log("QC approved for sale:", selectedSale.saleNumber)
                                // Update status to "preparado"
                                SaleManager.updateSaleStatus(selectedSale.id, "preparado")
                                appWindow.showToast("Control aprobado - Venta #" + selectedSale.saleNumber + " preparada")
                                var saleNum = selectedSale.saleNumber
                                selectedSale = null
                                SaleManager.refreshSales()
                                // Force refresh by navigating away and back
                                appWindow.goBack()
                                Qt.callLater(function() {
                                    appWindow.navigateTo("modules/warehouse/QualityCheckPage.qml")
                                })
                            }
                        }
                    }
                }
            }

            // Historial de controles realizados
            CustomCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "Historial de Controles"
                subtitle: "Verificaciones realizadas"

                Component.onCompleted: {
                    console.log("QC page loaded")
                }

                content: ListView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    model: SaleManager.getSalesByStatus("preparado")
                    clip: true

                    delegate: ItemDelegate {
                        width: ListView.view.width
                        contentItem: RowLayout {
                            Label {
                                text: "✅ " + modelData.saleNumber + " - " + (modelData.clientName || "Sin cliente")
                                font.pixelSize: 12
                                color: Theme.success
                                Layout.fillWidth: true
                            }
                            Label {
                                text: modelData.total.toFixed(2) + " CUP"
                                font.pixelSize: 11
                                color: Theme.textSecondary
                            }
                        }
                    }
                }
            }
        }
    }

    function getCheckedCount() {
        var count = 0
        for (var i = 0; i < checklistItems.length; i++) {
            if (checklistItems[i].checked) count++
        }
        return count
    }

    function toggleCheck(index, checked) {
        checklistItems[index].checked = checked
        // Force refresh of the checklist
        var temp = checklistItems
        checklistItems = []
        checklistItems = temp
    }
}