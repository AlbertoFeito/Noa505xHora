import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Reportar Incidente"
        showBack: true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        CustomCard {
            Layout.fillWidth: true
            title: "Nuevo Reporte de Incidente"

            content: ColumnLayout {
                spacing: Theme.spacingMd

                ComboBox {
                    id: saleCombo
                    Layout.fillWidth: true
                    model: SaleManager.getSalesByStatus("en_transito")
                    textRole: "saleNumber"
                    valueRole: "id"
                    displayText: currentIndex >= 0 ? (currentText + " - " + model.get(currentIndex).clientName) : "Seleccionar entrega..."
                }

                CustomTextField {
                    id: incidentField
                    Layout.fillWidth: true
                    label: "Descripción del Incidente"
                    placeholderText: "Describa lo ocurrido con el cliente o la entrega"
                }

                CustomButton {
                    Layout.fillWidth: true
                    text: "Enviar Reporte"
                    type: 2
                    onClicked: reportIncident()
                }
            }
        }
    }

    function reportIncident() {
        if (saleCombo.currentIndex < 0 || incidentField.text === "") {
            appWindow.showToast("Complete todos los campos", true)
            return
        }

        if (SaleManager.updateDeliveryStatus(saleCombo.currentValue, "incidente", 0, incidentField.text)) {
            appWindow.showToast("Incidente reportado")
            appWindow.goBack()
        }
    }
}
