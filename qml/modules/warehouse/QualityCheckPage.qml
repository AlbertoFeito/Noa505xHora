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

                    ListView {
                        id: checklistView
                        Layout.fillWidth: true
                        model: checklistItems
                        height: model.length * 40

                        delegate: RowLayout {
                            width: ListView.view.width
                            spacing: Theme.spacingSm

                            CheckBox {
                                checked: modelData.checked
                                onCheckedChanged: {
                                    checklistItems[index].checked = checked
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
                    Label {
                        text: "Completado: " + getCheckedCount() + "/" + checklistItems.length
                        font.pixelSize: 12
                        color: getCheckedCount() === checklistItems.length ? Theme.success : Theme.textSecondary
                    }

                    CustomButton {
                        Layout.fillWidth: true
                        text: "✅ Aprobar Control de Calidad"
                        type: getCheckedCount() === checklistItems.length ? 2 : 0
                        enabled: getCheckedCount() === checklistItems.length
                        onClicked: {
                            // Aquí se registraría el control de calidad
                            appWindow.showToast("Control de calidad aprobado para venta #" + selectedSale.saleNumber)
                            // Optionally update sale status
                            // SaleManager.updateSaleStatus(selectedSale.id, "verificado")
                            selectedSale = null
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

                content: Label {
                    text: "No hay registros de control de calidad aún"
                    font.pixelSize: 12
                    color: Theme.textSecondary
                    wrapMode: Text.WordWrap
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
}