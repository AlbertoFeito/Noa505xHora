import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Vale de Entrega"
        showBack: true
    }

    property string currentFilter: "facturado"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        // Filtros por estado
        CustomCard {
            Layout.fillWidth: true
            title: "Filtrar por Estado"

            content: RowLayout {
                spacing: Theme.spacingSm

                ButtonGroup {
                    buttons: [btnFacturado, btnPreparado, btnEntregado]
                }

                CustomButton {
                    id: btnFacturado
                    text: "Facturado (" + SaleManager.getSalesByStatus("facturado").length + ")"
                    type: currentFilter === "facturado" ? 2 : 0
                    onClicked: {
                        currentFilter = "facturado"
                        listaVentas.model = SaleManager.getSalesByStatus("facturado")
                    }
                }

                CustomButton {
                    id: btnPreparado
                    text: "Preparado (" + SaleManager.getSalesByStatus("preparado").length + ")"
                    type: currentFilter === "preparado" ? 2 : 0
                    onClicked: {
                        currentFilter = "preparado"
                        listaVentas.model = SaleManager.getSalesByStatus("preparado")
                    }
                }

                CustomButton {
                    id: btnEntregado
                    text: "Entregado (" + SaleManager.getSalesByStatus("entregado").length + ")"
                    type: currentFilter === "entregado" ? 2 : 0
                    onClicked: {
                        currentFilter = "entregado"
                        listaVentas.model = SaleManager.getSalesByStatus("entregado")
                    }
                }
            }
        }

        // Lista de ventas según filtro
        CustomCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: currentFilter === "facturado" ? "Ventas Facturadas - Por Preparar" :
                   currentFilter === "preparado" ? "Ventas Preparadas - Por Entregar" :
                   "Ventas Entregadas - Completadas"

            content: ListView {
                id: listaVentas
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: SaleManager.getSalesByStatus("facturado")
                clip: true

                delegate: ItemDelegate {
                    width: ListView.view.width
                    contentItem: ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSm

                        // Header de la venta
                        RowLayout {
                            Layout.fillWidth: true
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Label {
                                    text: "Venta #" + modelData.saleNumber
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    color: Theme.textPrimary
                                }
                                Label {
                                    text: modelData.clientName || "Sin cliente"
                                    font.pixelSize: 12
                                    color: Theme.textSecondary
                                }
                                Label {
                                    text: "Total: " + modelData.total.toFixed(2) + " CUP"
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                    color: Theme.success
                                }
                            }

                            // Badge de estado
                            Label {
                                text: modelData.status === "facturado" ? "📋" :
                                      modelData.status === "preparado" ? "📦" :
                                      "✅"
                                font.pixelSize: 24
                            }
                        }

                        // Items de la venta
                        Rectangle {
                            Layout.fillWidth: true
                            radius: Theme.radiusSm
                            color: Theme.backgroundAlt

                            ColumnLayout {
                                anchors.margins: Theme.spacingSm
                                spacing: 2

                                Label {
                                    text: "Productos:"
                                    font.pixelSize: 11
                                    font.weight: Font.Medium
                                    color: Theme.textSecondary
                                }

                                ListView {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: count * 20
                                    model: SaleManager.getSaleItems(modelData.id)
                                    interactive: false

                                    delegate: Label {
                                        width: ListView.view.width
                                        text: "  • " + modelData.productName + " (x" + modelData.quantity + ")"
                                        font.pixelSize: 11
                                        color: Theme.textSecondary
                                    }
                                }
                            }
                        }

                        // Botones de acción según estado
                        RowLayout {
                            Layout.fillWidth: true

                            // Estado: facturado -> preparar
                            CustomButton {
                                visible: modelData.status === "facturado"
                                text: "📦 Preparar"
                                type: 2
                                onClicked: {
                                    if (SaleManager.updateSaleStatus(modelData.id, "preparado")) {
                                        appWindow.showToast("Orden marcada como preparada")
                                        refreshList()
                                    }
                                }
                            }

                            // Estado: preparado -> entregar
                            CustomButton {
                                visible: modelData.status === "preparado"
                                text: "✅ Entregar"
                                type: 1
                                onClicked: {
                                    if (SaleManager.updateSaleStatus(modelData.id, "entregado")) {
                                        appWindow.showToast("Orden marcada como entregada")
                                        refreshList()
                                    }
                                }
                            }

                            // Estado: entregado ->无可逆 (solo ver)
                            Label {
                                visible: modelData.status === "entregado"
                                text: "Entregado el " + (modelData.updatedAt ? modelData.updatedAt : "hoy")
                                font.pixelSize: 12
                                color: Theme.success
                            }
                        }
                    }
                }
            }
        }
    }

    function prepareOrder(saleId) {
        if (SaleManager.updateSaleStatus(saleId, "preparado")) {
            appWindow.showToast("Orden preparada para entrega")
            refreshList()
        }
    }

    function deliverOrder(saleId) {
        if (SaleManager.updateSaleStatus(saleId, "entregado")) {
            appWindow.showToast("Orden entregada")
            refreshList()
        }
    }

    function refreshList() {
        listaVentas.model = SaleManager.getSalesByStatus(currentFilter)
    }
}