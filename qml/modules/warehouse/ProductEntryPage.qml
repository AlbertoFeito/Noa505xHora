import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Entrada de Productos"
        showBack: true
    }

    // Estado
    property var selectedProduct: null

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        // Buscar producto por categoría
        CustomCard {
            Layout.fillWidth: true
            title: "Buscar Producto"

            content: ColumnLayout {
                spacing: Theme.spacingMd

                // Filtrar por categoría
                ComboBox {
                    id: categoryFilter
                    Layout.fillWidth: true
                    model: ProductManager.getCategories()
                    textRole: "category"
                    currentIndex: 0
                    onCurrentIndexChanged: {
                        productList.model = getFilteredProducts(searchField.text)
                    }
                }

                CustomTextField {
                    id: searchField
                    Layout.fillWidth: true
                    label: ""
                    placeholder: "Buscar por código o nombre..."
                    onTextChanged: {
                        // Filtrar productos
                        productList.model = getFilteredProducts(text)
                    }
                }

                Label {
                    text: "Selecciona un producto:"
                    font.pixelSize: 12
                    color: Theme.textSecondary
                }

                ListView {
                    id: productList
                    Layout.fillWidth: true
                    height: 200
                    model: ProductManager.getAllProductsList()
                    clip: true

                    delegate: ItemDelegate {
                        width: ListView.view.width
                        onClicked: {
                            selectedProduct = modelData
                            productNameLabel.text = modelData.name
                            currentStockLabel.text = "Stock actual: " + modelData.stock
                            quantityField.text = ""
                            invoiceField.text = ""
                            quantityField.focus = true
                        }

                        contentItem: ColumnLayout {
                            spacing: 2

                            RowLayout {
                                Label {
                                    text: modelData.code + " - " + modelData.name
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    color: Theme.textPrimary
                                    Layout.fillWidth: true
                                }
                                Label {
                                    text: "Stock: " + modelData.stock
                                    font.pixelSize: 12
                                    color: Theme.textSecondary
                                }
                            }

                            Label {
                                text: "Categoría: " + (modelData.category || "Sin categoría")
                                font.pixelSize: 11
                                color: Theme.info
                            }
                        }
                    }
                }
            }
        }

        // Producto seleccionado
        CustomCard {
            Layout.fillWidth: true
            title: "Entrada de Productos"
            visible: selectedProduct !== null

            content: ColumnLayout {
                spacing: Theme.spacingMd

                Label {
                    id: productNameLabel
                    text: selectedProduct ? selectedProduct.name : ""
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    color: Theme.textPrimary
                }

                Label {
                    id: currentStockLabel
                    text: selectedProduct ? "Stock actual: " + selectedProduct.stock : ""
                    font.pixelSize: 12
                    color: Theme.textSecondary
                }

                CustomTextField {
                    id: quantityField
                    Layout.fillWidth: true
                    label: "Cantidad a agregar"
                    placeholder: "Ingrese cantidad"
                    inputMethodHints: Qt.ImhDigitsOnly
                }

                CustomTextField {
                    id: invoiceField
                    Layout.fillWidth: true
                    label: "Número de Factura"
                    placeholder: "Número de factura del proveedor"
                }

                CustomButton {
                    text: "✅ Registrar Entrada"
                    type: 2
                    onClicked: registerEntry()
                }
            }
        }

        // Historial de entradas recientes
        CustomCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Entradas Recientes"

            content: ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: InventoryManager.getCountsByDate(new Date())
                clip: true

                delegate: ItemDelegate {
                    width: ListView.view.width
                    contentItem: RowLayout {
                        Label {
                            text: "Producto ID: " + modelData.product_id
                            font.pixelSize: 13
                            color: Theme.textPrimary
                            Layout.fillWidth: true
                        }
                        Label {
                            text: "Cant: " + modelData.actual_quantity
                            font.pixelSize: 12
                            color: Theme.success
                        }
                    }
                }
            }
        }
    }

    // Funciones - ahora usa el método del C++
    function getFilteredProducts(searchText) {
        var all = ProductManager.getAllProductsList()
        var filtered = []

        var lowerSearch = searchText ? searchText.toLowerCase() : ""
        var selectedCategory = categoryFilter.currentText

        for (var i = 0; i < all.length; i++) {
            var p = all[i]

            // Filtrar por categoría si hay una seleccionada
            var categoryMatch = !selectedCategory || selectedCategory === "" || p.category === selectedCategory

            // Filtrar por texto de búsqueda
            var textMatch = !lowerSearch || lowerSearch === "" ||
                p.name.toLowerCase().includes(lowerSearch) ||
                p.code.toLowerCase().includes(lowerSearch)

            if (categoryMatch && textMatch) {
                filtered.push(p)
            }
        }
        return filtered
    }

    function registerEntry() {
        if (!selectedProduct) {
            appWindow.showToast("Seleccione un producto", true)
            return
        }

        var qty = parseInt(quantityField.text)
        if (!qty || qty <= 0) {
            appWindow.showToast("Ingrese cantidad válida", true)
            return
        }

        var invoice = invoiceField.text || "SIN-FACTURA"

        var success = ProductManager.addStock(selectedProduct.id, qty, invoice)

        if (success) {
            appWindow.showToast("Entrada registrada: +" + qty + " unidades")

            // Limpiar
            selectedProduct = null
            productNameLabel.text = ""
            currentStockLabel.text = ""
            quantityField.text = ""
            invoiceField.text = ""
            searchField.text = ""

            // Refrescar lista
            productList.model = ProductManager.getAllProductsList()
            InventoryManager.refreshCounts()
        } else {
            appWindow.showToast("Error al registrar entrada", true)
        }
    }
}