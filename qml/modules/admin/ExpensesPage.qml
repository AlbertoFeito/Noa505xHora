import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Gestión de Gastos"
        showBack: true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        CustomCard {
            Layout.fillWidth: true
            title: "Nuevo Gasto"

            content: GridLayout {
                columns: 2
                columnSpacing: Theme.spacingMd
                rowSpacing: Theme.spacingMd

                ComboBox {
                    id: categoryCombo
                    Layout.fillWidth: true
                    model: ExpenseManager.expenseCategories()
                    currentIndex: 0
                }

                CustomTextField {
                    id: amountField
                    Layout.fillWidth: true
                    label: "Monto"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                }

                CustomTextField {
                    id: descField
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    label: "Descripción"
                }

                CustomButton {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    text: "Registrar Gasto"
                    type: 2
                    onClicked: addExpense()
                }
            }
        }

        CustomCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Historial de Gastos"

            content: ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: ExpenseManager
                clip: true

                delegate: ItemDelegate {
                    width: ListView.view.width
                    contentItem: RowLayout {
                        Label {
                            text: Qt.formatDate(model.expenseDate, "dd/MM/yyyy")
                            font.pixelSize: 12
                            color: Theme.textSecondary
                            Layout.preferredWidth: 80
                        }
                        Label {
                            text: model.category.toUpperCase()
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: Theme.accent
                            Layout.preferredWidth: 100
                        }
                        Label {
                            text: model.description || ""
                            font.pixelSize: 13
                            color: Theme.textPrimary
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        Label {
                            text: model.amount.toFixed(2) + " CUP"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: Theme.textPrimary
                        }
                        ToolButton {
                            text: "✕"
                            onClicked: ExpenseManager.deleteExpense(model.id)
                            contentItem: Text {
                                text: parent.text
                                color: Theme.error
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                            }
                            background: Rectangle { color: "transparent" }
                        }
                    }
                }
            }
        }
    }

    function addExpense() {
        if (amountField.text === "") {
            appWindow.showToast("Ingrese el monto", true)
            return
        }

        if (ExpenseManager.addExpense(
            categoryCombo.currentText,
            descField.text,
            parseFloat(amountField.text),
            new Date(),
            "efectivo",
            false,
            UserManager.currentUser.id
        )) {
            appWindow.showToast("Gasto registrado")
            amountField.text = ""
            descField.text = ""
        }
    }
}
