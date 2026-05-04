import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Historial de Movimientos"
        showBack: true
    }

    // Estado
    property var allMovements: []

    Component.onCompleted: {
        loadAllMovements()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        // Filtros
        CustomCard {
            Layout.fillWidth: true
            title: "Filtros"

            content: ColumnLayout {
                spacing: Theme.spacingMd

                RowLayout {
                    spacing: Theme.spacingMd

                    ComboBox {
                        id: typeFilter
                        Layout.fillWidth: true
                        model: ["Todos", "Entradas", "Salidas"]
                        currentIndex: 0
                        onCurrentIndexChanged: {
                            filterMovements()
                        }
                    }

                    ComboBox {
                        id: productFilter
                        Layout.fillWidth: true
                        model: allProductsModel
                        textRole: "name"
                        currentIndex: 0
                        onCurrentIndexChanged: {
                            filterMovements()
                        }
                    }
                }

                CustomButton {
                    text: "🔄 Actualizar"
                    type: 1
                    onClicked: loadAllMovements()
                }
            }
        }

        // Resumen
        CustomCard {
            Layout.fillWidth: true
            title: "Resumen"

            content: RowLayout {
                Label {
                    text: "📥 Entradas: " + totalEntries
                    font.pixelSize: 14
                    color: Theme.success
                    Layout.fillWidth: true
                }

                Label {
                    text: "📤 Salidas: " + totalExits
                    font.pixelSize: 14
                    color: Theme.error
                    Layout.fillWidth: true
                }

                Label {
                    text: "📊 Total: " + allMovements.length
                    font.pixelSize: 14
                    font.weight: Font.Bold
                }
            }
        }

        // Lista de movimientos
        CustomCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Movimientos (" + allMovements.length + ")"

            content: ListView {
                id: movementsList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: filteredMovements
                clip: true

                delegate: ItemDelegate {
                    width: ListView.view.width
                    contentItem: ColumnLayout {
                        spacing: 4

                        RowLayout {
                            Label {
                                text: modelData.type === "Entrada" ? "📥" : "📤"
                                font.pixelSize: 16
                                color: modelData.type === "Entrada" ? Theme.success : Theme.error
                            }

                            Label {
                                text: modelData.productCode + " - " + modelData.productName
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: Theme.textPrimary
                                Layout.fillWidth: true
                            }

                            Label {
                                text: (modelData.type === "Entrada" ? "+" : "-") + modelData.quantity
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: modelData.type === "Entrada" ? Theme.success : Theme.error
                            }
                        }

                        RowLayout {
                            Label {
                                text: "📅 " + modelData.dateFormatted
                                font.pixelSize: 10
                                color: Theme.textSecondary
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                text: modelData.notes || ""
                                font.pixelSize: 10
                                color: Theme.info
                            }
                        }

                        Label {
                            text: "Stock: " + modelData.previousStock + " → " + modelData.newStock
                            font.pixelSize: 10
                            color: Theme.textSecondary
                        }
                    }
                }
            }
        }
    }

    // Propiedades
    property var allProductsModel: []
    property var filteredMovements: []
    property int totalEntries: 0
    property int totalExits: 0

    function loadAllMovements() {
        // Cargar productos para el filtro
        var products = ProductManager.getAllProductsList()
        var productList = [{"id": 0, "name": "Todos los productos"}]
        for (var i = 0; i < products.length; i++) {
            productList.push(products[i])
        }
        allProductsModel = productList

        // Cargar entradas
        var entries = InventoryManager.getRecentEntries(100)
        var exits = InventoryManager.getRecentExits(100)

        // Combinar
        var movements = []

        // Procesar entradas
        for (var j = 0; j < entries.length; j++) {
            var e = entries[j]
            var dateStr = e.date || ""
            var dateFormatted = dateStr.length > 16 ? dateStr.substring(0, 16) : dateStr

            movements.push({
                type: "Entrada",
                productId: e.productId,
                productCode: e.productCode || "N/A",
                productName: e.productName || "Producto",
                quantity: e.addedQuantity,
                previousStock: e.previousStock,
                newStock: e.newStock,
                notes: e.notes || "",
                date: e.date || "",
                dateFormatted: dateFormatted
            })
        }

        // Procesar salidas
        for (var k = 0; k < exits.length; k++) {
            var s = exits[k]
            var dateStr2 = s.date || ""
            var dateFormatted2 = dateStr2.length > 16 ? dateStr2.substring(0, 16) : dateStr2

            movements.push({
                type: "Salida",
                productId: s.productId,
                productCode: s.productCode || "N/A",
                productName: s.productName || "Producto",
                quantity: s.quantity,
                previousStock: s.previousStock,
                newStock: s.newStock,
                notes: s.reason || "",
                date: s.date || "",
                dateFormatted: dateFormatted2
            })
        }

        // Ordenar por fecha (más reciente primero)
        movements.sort(function(a, b) {
            return (a.date > b.date) ? -1 : (a.date < b.date) ? 1 : 0
        })

        allMovements = movements

        // Calcular totales
        totalEntries = entries.length
        totalExits = exits.length

        filterMovements()
    }

    function filterMovements() {
        var typeSelected = typeFilter.currentText
        var productSelected = productFilter.currentIndex > 0 ? productFilter.model[productFilter.currentIndex] : null

        var filtered = []

        for (var i = 0; i < allMovements.length; i++) {
            var m = allMovements[i]

            var typeMatch = typeSelected === "Todos" ||
                          (typeSelected === "Entradas" && m.type === "Entrada") ||
                          (typeSelected === "Salidas" && m.type === "Salida")

            var productMatch = !productSelected || m.productId === productSelected.id

            if (typeMatch && productMatch) {
                filtered.push(m)
            }
        }

        filteredMovements = filtered
    }
}