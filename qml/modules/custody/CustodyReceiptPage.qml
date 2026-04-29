import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Recibo de Custodia"
        showBack: true
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width

        ColumnLayout {
            width: parent.width
            anchors.margins: Theme.spacingMd
            spacing: Theme.spacingMd

            CustomCard {
                Layout.fillWidth: true
                title: "Cuadre Final del Día"
                subtitle: Qt.formatDate(new Date(), "dd/MM/yyyy")

                content: ColumnLayout {
                    spacing: Theme.spacingMd

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
                            font.pixelSize: 16
                            font.weight: Font.Medium
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
                            font.pixelSize: 16
                            font.weight: Font.Medium
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
                            text: "Efectivo Esperado:"
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            color: Theme.textPrimary
                            Layout.fillWidth: true
                        }
                        Label {
                            id: expectedCashLabel
                            text: (SaleManager.todaySalesTotal - ExpenseManager.todayExpenses).toFixed(2) + " CUP"
                            font.pixelSize: 20
                            font.weight: Font.Bold
                            color: Theme.accent
                        }
                    }

                    CustomTextField {
                        id: actualCashField
                        Layout.fillWidth: true
                        label: "Efectivo Contado"
                        placeholderText: "Ingrese monto físico"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                    }

                    CustomTextField {
                        id: differenceReasonField
                        Layout.fillWidth: true
                        label: "Justificación (si hay diferencia)"
                        placeholderText: "Obligatorio si no cuadra"
                    }
                }
            }

            CustomCard {
                Layout.fillWidth: true
                title: "Productos en Almacén"

                content: RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "Total productos registrados:"
                        font.pixelSize: 14
                        color: Theme.textSecondary
                        Layout.fillWidth: true
                    }
                    Label {
                        text: ProductManager.rowCount().toString()
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: Theme.textPrimary
                    }
                }
            }

            CustomCard {
                Layout.fillWidth: true
                title: "Confirmar Custodia"

                content: ColumnLayout {
                    spacing: Theme.spacingMd

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "Entregado por:"
                            font.pixelSize: 14
                            color: Theme.textSecondary
                            Layout.fillWidth: true
                        }
                        Label {
                            text: UserManager.currentUser.fullName || ""
                            font.pixelSize: 14
                            color: Theme.textPrimary
                            font.weight: Font.Medium
                        }
                    }

                    CustomTextField {
                        id: custodyPinField
                        Layout.fillWidth: true
                        label: "PIN de Confirmación"
                        echoMode: TextInput.Password
                        inputMethodHints: Qt.ImhDigitsOnly
                    }

                    CustomButton {
                        Layout.fillWidth: true
                        text: "Confirmar Recepción"
                        type: 1
                        onClicked: confirmCustody()
                    }
                }
            }
        }
    }

    function confirmCustody() {
        var expected = SaleManager.todaySalesTotal - ExpenseManager.todayExpenses
        var actual = parseFloat(actualCashField.text || 0)
        var diff = actual - expected

        if (Math.abs(diff) > 0.01 && differenceReasonField.text === "") {
            appWindow.showToast("Debe justificar la diferencia", true)
            return
        }

        // Realizar cuadre
        var recSuccess = SaleManager.performDailyReconciliation(
            new Date(),
            expected,
            actual,
            SaleManager.todaySalesTotal,
            ExpenseManager.todayExpenses,
            differenceReasonField.text,
            UserManager.currentUser.id
        )

        if (!recSuccess) {
            appWindow.showToast("Error en el cuadre", true)
            return
        }

        // Crear custodia
        var custodySuccess = SaleManager.createCustodyRecord(
            new Date(),
            "ambos",
            actual,
            ProductManager.rowCount(),
            UserManager.currentUser.id,
            UserManager.currentUser.id,
            "Custodia del día"
        )

        if (custodySuccess) {
            appWindow.showToast("Custodia confirmada correctamente")
            appWindow.goBack()
        } else {
            appWindow.showToast("Error al registrar custodia", true)
        }
    }
}
