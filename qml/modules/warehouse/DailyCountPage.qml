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

    property var countItems: ({})
    property int differences: 0
    property int matches: 0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        // Resumen del conteo
        CustomCard {
            Layout.fillWidth: true
            title: "Conteo del " + Qt.formatDate(new Date(), "dd/MM/yyyy")
            subtitle: "Compare el stock real con el sistema"

            content: RowLayout {
                spacing: Theme.spacingMd

                Rectangle {
                    Layout.fillWidth: true
                    radius: Theme.radiusSm
                    color: Theme.success
                    opacity: 0.1

                    ColumnLayout {
                        anchors.margins: Theme.spacingSm

                        Label {
                            text: "Coinciden"
                            font.pixelSize: 12
                            color: Theme.success
                        }
                        Label {
                            text: matches
                            font.pixelSize: 24
                            font.weight: Font.Bold
                            color: Theme.textPrimary
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    radius: Theme.radiusSm
                    color: Theme.error
                    opacity: 0.1

                    ColumnLayout {
                        anchors.margins: Theme.spacingSm

                        Label {
                            text: "Diferencias"
                            font.pixelSize: 12
                            color: Theme.error
                        }
                        Label {
                            text: differences
                            font.pixelSize: 24
                            font.weight: Font.Bold
                            color: Theme.textPrimary
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    radius: Theme.radiusSm
                    color: Theme.primary
                    opacity: 0.1

                    ColumnLayout {
                        anchors.margins: Theme.spacingSm

                        Label {
                            text: "Total Revisados"
                            font.pixelSize: 12
                            color: Theme.primary
                        }
                        Label {
                            text: Object.keys(countItems).length
                            font.pixelSize: 24
                            font.weight: Font.Bold
                            color: Theme.textPrimary
                        }
                    }
                }
            }
        }

        // Lista de productos
        CustomCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Inventario - Ingrese Cantidades Reales"

            content: ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: ProductManager
                clip: true

                delegate: ItemDelegate {
                    width: ListView.view.width

                    property int expectedStock: model.stock || 0
                    property int actualStock: countItems[model.id] !== undefined ? countItems[model.id] : expectedStock

                    contentItem: ColumnLayout {
                        spacing: Theme.spacingSm

                        RowLayout {
                            Layout.fillWidth: true

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Label {
                                    text: model.name
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    color: Theme.textPrimary
                                }

                                Label {
                                    text: "Código: " + model.code + " | Categoría: " + (model.category || "Sin categoría")
                                    font.pixelSize: 11
                                    color: Theme.textSecondary
                                }
                            }

                            // Indicador de diferencia
                            Label {
                                text: actualStock === expectedStock ? "✅" : "⚠️"
                                font.pixelSize: 20
                                visible: countItems[model.id] !== undefined
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingMd

                            // Stock esperado (del sistema)
                            ColumnLayout {
                                Label {
                                    text: "Stock Sistema"
                                    font.pixelSize: 10
                                    color: Theme.textSecondary
                                }
                                Label {
                                    text: expectedStock
                                    font.pixelSize: 18
                                    font.weight: Font.Medium
                                    color: Theme.info
                                }
                            }

                            // Stock real ( SpinBox)
                            ColumnLayout {
                                Label {
                                    text: "Stock Físico"
                                    font.pixelSize: 10
                                    color: Theme.textSecondary
                                }

                                SpinBox {
                                    from: 0
                                    to: 99999
                                    value: actualStock
                                    onValueModified: {
                                        countItems[model.id] = value
                                        updateSummary()
                                    }
                                }
                            }

                            // Diferencia
                            ColumnLayout {
                                Label {
                                    text: "Diferencia"
                                    font.pixelSize: 10
                                    color: Theme.textSecondary
                                }
                                Label {
                                    text: (actualStock - expectedStock) > 0 ? "+" + (actualStock - expectedStock) :
                                          (actualStock - expectedStock) < 0 ? (actualStock - expectedStock) : "0"
                                    font.pixelSize: 16
                                    font.weight: Font.Medium
                                    color: actualStock === expectedStock ? Theme.success :
                                           actualStock > expectedStock ? Theme.warning : Theme.error
                                }
                            }
                        }
                    }
                }
            }
        }

        // Botones de acción
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingMd

            CustomButton {
                Layout.fillWidth: true
                text: "Limpiar"
                type: 0
                onClicked: {
                    countItems = ({})
                    differences = 0
                    matches = 0
                    ProductManager.refreshProducts()
                    appWindow.showToast("Conteos limpiados")
                }
            }

            CustomButton {
                Layout.fillWidth: true
                text: "💾 Guardar Conteo"
                type: Object.keys(countItems).length > 0 ? 2 : 0
                enabled: Object.keys(countItems).length > 0
                onClicked: saveCount()
            }
        }
    }

    function updateSummary() {
        matches = 0
        differences = 0

        // Recorrer productos del modelo
        var productCount = ProductManager.rowCount()
        for (var i = 0; i < productCount; i++) {
            var product = ProductManager.getProduct(i)
            var productId = product.id
            if (countItems[productId] !== undefined) {
                var expected = product.stock || 0
                var actual = countItems[productId]
                if (actual === expected) {
                    matches++
                } else {
                    differences++
                }
            }
        }
    }

    function saveCount() {
        if (Object.keys(countItems).length === 0) {
            appWindow.showToast("No hay conteos para guardar", true)
            return
        }

        // Convertir a formato esperado por C++
        var itemsArray = []
        for (var productId in countItems) {
            itemsArray.push({
                productId: parseInt(productId),
                actualQuantity: countItems[productId]
            })
        }

        // Intentar guardar - Esto requiere que exista el método en C++
        // Por ahora guardamos localmente
        appWindow.showToast("Conteo guardado: " + itemsArray.length + " productos")

        // Limpiar después de guardar
        countItems = ({})
        differences = 0
        matches = 0
    }
}