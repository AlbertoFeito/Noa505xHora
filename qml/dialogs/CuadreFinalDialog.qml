import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"
import ".."

Dialog {
    id: dialog
    title: "Cuadre Final del Día"
    modal: true
    width: 500
    height: 600
    anchors.centerIn: parent
    standardButtons: Dialog.Ok | Dialog.Cancel

    property double expectedCash: 0
    property double actualCash: 0

    contentItem: ColumnLayout {
        spacing: Theme.spacingMd

        CustomCard {
            Layout.fillWidth: true
            title: "Resumen Financiero"

            content: ColumnLayout {
                spacing: Theme.spacingSm

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "Ventas del Día:"
                        font.pixelSize: 14
                        color: Theme.textSecondary
                        Layout.fillWidth: true
                    }
                    Label {
                        text: SaleManager.todaySalesTotal.toFixed(2) + " CUP"
                        font.pixelSize: 14
                        color: Theme.textPrimary
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "Gastos del Día:"
                        font.pixelSize: 14
                        color: Theme.textSecondary
                        Layout.fillWidth: true
                    }
                    Label {
                        text: ExpenseManager.todayExpenses.toFixed(2) + " CUP"
                        font.pixelSize: 14
                        color: Theme.error
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.divider
                }

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "EFECTIVO ESPERADO:"
                        font.pixelSize: 16
                        font.weight: Font.Medium
                        color: Theme.textPrimary
                        Layout.fillWidth: true
                    }
                    Label {
                        text: expectedCash.toFixed(2) + " CUP"
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        color: Theme.accent
                    }
                }
            }
        }

        CustomTextField {
            id: countedCashField
            Layout.fillWidth: true
            label: "Efectivo Contado Físicamente"
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onTextChanged: {
                actualCash = parseFloat(text || 0)
                differenceLabel.text = (actualCash - expectedCash).toFixed(2) + " CUP"
                differenceLabel.color = Math.abs(actualCash - expectedCash) < 0.01 ? Theme.success : Theme.error
            }
        }

        Label {
            id: differenceLabel
            text: "0.00 CUP"
            font.pixelSize: 18
            font.weight: Font.Bold
            color: Theme.success
            Layout.alignment: Qt.AlignHCenter
        }

        CustomTextField {
            id: reasonField
            Layout.fillWidth: true
            label: "Justificación (si hay diferencia)"
            visible: Math.abs(actualCash - expectedCash) > 0.01
        }
    }

    onAccepted: {
        if (Math.abs(actualCash - expectedCash) > 0.01 && reasonField.text === "") {
            appWindow.showToast("Debe justificar la diferencia", true)
            dialog.open()
            return
        }
        // Realizar cuadre
    }
}
