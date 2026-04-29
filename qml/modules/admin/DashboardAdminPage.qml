import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Dashboard Administrativo"
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
                title: "Métricas del Negocio"

                content: GridLayout {
                    columns: Math.min(3, Math.floor(parent.width / 250))
                    columnSpacing: Theme.spacingMd
                    rowSpacing: Theme.spacingMd

                    Repeater {
                        model: [
                            { label: "Ventas Hoy", value: SaleManager.todaySalesCount.toString(), desc: "transacciones", color: Theme.accent },
                            { label: "Total Hoy", value: SaleManager.todaySalesTotal.toFixed(2), desc: "CUP", color: Theme.success },
                            { label: "Gastos Mes", value: ExpenseManager.monthExpenses.toFixed(2), desc: "CUP", color: Theme.error },
                            { label: "Productos", value: ProductManager.rowCount().toString(), desc: "ítems", color: Theme.info },
                            { label: "Stock Bajo", value: ProductManager.lowStockCount.toString(), desc: "alertas", color: Theme.warning },
                            { label: "Nómina Pend.", value: PayrollManager.totalPayroll.toFixed(2), desc: "CUP", color: Theme.primary }
                        ]

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.minimumHeight: 100
                            radius: Theme.radiusSm
                            color: modelData.color
                            opacity: 0.08

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.spacingMd

                                Label {
                                    text: modelData.label
                                    font.pixelSize: 12
                                    color: modelData.color
                                    Layout.alignment: Qt.AlignLeft
                                }

                                Label {
                                    text: modelData.value
                                    font.pixelSize: 28
                                    font.weight: Font.Bold
                                    color: Theme.textPrimary
                                    Layout.alignment: Qt.AlignLeft
                                }

                                Label {
                                    text: modelData.desc
                                    font.pixelSize: 11
                                    color: Theme.textSecondary
                                    Layout.alignment: Qt.AlignLeft
                                }
                            }
                        }
                    }
                }
            }

            CustomCard {
                Layout.fillWidth: true
                title: "Reporte Financiero del Mes"

                content: ColumnLayout {
                    spacing: Theme.spacingMd

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "Ingresos:"
                            font.pixelSize: 14
                            color: Theme.textSecondary
                            Layout.fillWidth: true
                        }
                        Label {
                            id: incomeLabel
                            text: "0.00 CUP"
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            color: Theme.success
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "Gastos:"
                            font.pixelSize: 14
                            color: Theme.textSecondary
                            Layout.fillWidth: true
                        }
                        Label {
                            id: expenseLabel
                            text: "0.00 CUP"
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
                            text: "Resultado Neto:"
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            color: Theme.textPrimary
                            Layout.fillWidth: true
                        }
                        Label {
                            id: netLabel
                            text: "0.00 CUP"
                            font.pixelSize: 20
                            font.weight: Font.Bold
                            color: Theme.textPrimary
                        }
                    }
                }
            }

            CustomButton {
                Layout.fillWidth: true
                text: "Generar Reporte ONAT"
                type: 2
                onClicked: appWindow.showToast("Reporte ONAT generado")
            }
        }
    }

    Component.onCompleted: {
        var report = ReportManager.getFinancialReport(
            new Date(new Date().setDate(1)),
            new Date()
        )
        incomeLabel.text = report.totalIncome.toFixed(2) + " CUP"
        expenseLabel.text = report.totalExpenses.toFixed(2) + " CUP"
        netLabel.text = report.netResult.toFixed(2) + " CUP"
        netLabel.color = report.netResult >= 0 ? Theme.success : Theme.error
    }
}
