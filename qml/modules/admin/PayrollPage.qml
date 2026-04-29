import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Nómina y Salarios"
        showBack: true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        CustomCard {
            Layout.fillWidth: true
            title: "Nueva Nómina"

            content: GridLayout {
                columns: 2
                columnSpacing: Theme.spacingMd
                rowSpacing: Theme.spacingMd

                ComboBox {
                    id: employeeCombo
                    Layout.fillWidth: true
                    model: UserManager
                    textRole: "fullName"
                    valueRole: "id"
                }

                CustomTextField {
                    id: salaryField
                    Layout.fillWidth: true
                    label: "Salario Base"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                }

                CustomTextField {
                    id: commissionField
                    Layout.fillWidth: true
                    label: "Comisión"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: "0"
                }

                CustomTextField {
                    id: bonusField
                    Layout.fillWidth: true
                    label: "Bonos"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: "0"
                }

                CustomTextField {
                    id: deductionField
                    Layout.fillWidth: true
                    label: "Deducciones"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: "0"
                }

                CustomButton {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    text: "Calcular y Guardar"
                    type: 2
                    onClicked: addPayroll()
                }
            }
        }

        CustomCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Nómina Registrada"

            content: ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: PayrollManager
                clip: true

                delegate: ItemDelegate {
                    width: ListView.view.width
                    contentItem: RowLayout {
                        Label {
                            text: model.employeeName || "Empleado"
                            font.pixelSize: 14
                            color: Theme.textPrimary
                            Layout.fillWidth: true
                        }
                        Label {
                            text: Qt.formatDate(model.periodStart, "dd/MM") + " - " + Qt.formatDate(model.periodEnd, "dd/MM")
                            font.pixelSize: 12
                            color: Theme.textSecondary
                        }
                        Label {
                            text: model.totalPay.toFixed(2) + " CUP"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: model.paymentStatus === "pagado" ? Theme.success : Theme.warning
                        }
                        StatusBadge {
                            status: model.paymentStatus === "pagado" ? "liquidado" : "pendiente"
                            label: model.paymentStatus.toUpperCase()
                        }
                    }
                }
            }
        }
    }

    function addPayroll() {
        var today = new Date()
        var startOfPeriod = new Date(today.getFullYear(), today.getMonth(), 1)
        var endOfPeriod = new Date(today.getFullYear(), today.getMonth() + 1, 0)

        if (PayrollManager.addPayroll(
            employeeCombo.currentValue,
            startOfPeriod,
            endOfPeriod,
            parseFloat(salaryField.text || 0),
            parseFloat(commissionField.text || 0),
            parseFloat(bonusField.text || 0),
            parseFloat(deductionField.text || 0),
            UserManager.currentUser.id
        )) {
            appWindow.showToast("Nómina registrada")
            salaryField.text = ""
            commissionField.text = "0"
            bonusField.text = "0"
            deductionField.text = "0"
        }
    }
}
