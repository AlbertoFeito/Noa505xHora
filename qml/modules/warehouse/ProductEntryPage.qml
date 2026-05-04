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
    property var entriesList: []

    Component.onCompleted: {
        // Usar timer para asegurar que el modelo del combo esté listo
        Qt.callLater(function() {
            refreshProductList()
            loadEntries()
        })
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        // 1. BUSCAR PRODUCTO
        CustomCard {
            Layout.fillWidth: true
            title: "1. Buscar Producto"

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
                        refreshProductList()
                    }
                }

                CustomTextField {
                    id: searchField
                    Layout.fillWidth: true
                    label: "Buscar"
                    placeholder: "por código o nombre..."
                    onTextChanged: {
                        refreshProductList()
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
                    height: 150
                    clip: true

                    delegate: ItemDelegate {
                        width: ListView.view.width
                        onClicked: selectProduct(modelData)

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

        // 2. ENTRADA DE PRODUCTOS (visible cuando selecciona producto)
        CustomCard {
            Layout.fillWidth: true
            visible: selectedProduct !== null
            title: "2. Entrada de Producto"

            content: ColumnLayout {
                spacing: Theme.spacingMd

                RowLayout {
                    Label {
                        text: selectedProduct ? selectedProduct.code + " - " + selectedProduct.name : ""
                        font.pixelSize: 16
                        font.weight: Font.Medium
                        color: Theme.primary
                        Layout.fillWidth: true
                    }

                    CustomButton {
                        text: "❌ Cancelar"
                        type: 1
                        onClicked: clearSelection()
                    }
                }

                RowLayout {
                    spacing: Theme.spacingMd

                    CustomTextField {
                        id: quantityField
                        Layout.fillWidth: true
                        label: "Cantidad"
                        placeholder: "*"
                        inputMethodHints: Qt.ImhDigitsOnly
                    }

                    CustomTextField {
                        id: invoiceField
                        Layout.fillWidth: true
                        label: "Número Factura"
                        placeholder: "del proveedor"
                    }
                }

                CustomButton {
                    text: "✅ Registrar Entrada"
                    type: 2
                    onClicked: registerEntry()
                }
            }
        }

        // 3. ENTRADAS RECIENTES
        CustomCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "3. Entradas Recientes (últimas 10)"

            content: ListView {
                id: entriesListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: entriesList
                clip: true

                delegate: ItemDelegate {
                    width: ListView.view.width
                    contentItem: ColumnLayout {
                        spacing: 4

                        RowLayout {
                            Label {
                                text: modelData.productCode + " - " + modelData.productName
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: Theme.textPrimary
                                Layout.fillWidth: true
                            }
                            Label {
                                text: "+" + modelData.addedQuantity
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: Theme.success
                            }
                        }

                        Label {
                            text: "📅 " + modelData.dateFormatted + " | " + (modelData.notes || "Sin factura")
                            font.pixelSize: 10
                            color: Theme.textSecondary
                        }
                    }
                }
            }
        }
    }

    function refreshProductList() {
        var all = ProductManager.getAllProductsList()
        var filtered = []

        var lowerSearch = searchField.text ? searchField.text.toLowerCase() : ""
        var selectedIndex = categoryFilter.currentIndex
        var selectedCategory = ""

        // Obtener la categoría seleccionada del modelo
        if (selectedIndex > 0 && categoryFilter.model.length > selectedIndex) {
            selectedCategory = categoryFilter.model[selectedIndex].category || ""
        }

        for (var i = 0; i < all.length; i++) {
            var p = all[i]
            // Si selectedCategory es "Todas" o vacío, mostrar todos
            var categoryMatch = selectedCategory === "Todas" || selectedCategory === "" || p.category === selectedCategory
            var textMatch = !lowerSearch || p.name.toLowerCase().includes(lowerSearch) || p.code.toLowerCase().includes(lowerSearch)

            if (categoryMatch && textMatch) {
                filtered.push(p)
            }
        }
        productList.model = filtered
    }

    function selectProduct(product) {
        selectedProduct = product
        quantityField.text = ""
        invoiceField.text = ""
        quantityField.focus = true
    }

    function clearSelection() {
        selectedProduct = null
        searchField.text = ""
        refreshProductList()
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

        // Registrar entrada en base de datos y actualizar stock
        var success = ProductManager.addStock(selectedProduct.id, qty, invoice)

        if (success) {
            appWindow.showToast("Entrada registrada: +" + qty + " unidades")

            // Limpiar
            clearSelection()

            // Recargar lista de entradas
            loadEntries()
            ProductManager.refreshProducts()
        } else {
            appWindow.showToast("Error al registrar entrada", true)
        }
    }

    function loadEntries() {
        // Obtener entradas del InventoryManager
        var entries = InventoryManager.getRecentEntries(10)

        // Debug
        console.log("Entradas recibidas:", JSON.stringify(entries))

        // Convertir a formato para QML
        var list = []
        for (var i = 0; i < entries.length; i++) {
            var e = entries[i]
            var dateStr = e.date || ""
            var dateFormatted = dateStr.length > 16 ? dateStr.substring(0, 16) : dateStr
            list.push({
                id: e.id,
                productId: e.productId,
                productCode: e.productCode || "N/A",
                productName: e.productName || "Producto",
                addedQuantity: e.addedQuantity,
                dateFormatted: dateFormatted,
                notes: e.notes || "",
                previousStock: e.previousStock,
                newStock: e.newStock
            })
        }
        entriesList = list
    }

    function cancelEntry(entry) {
        // Confirmar y reversar entrada
        appWindow.showToast("Entrada cancelada: -" + entry.addedQuantity + " unidades")

        // Restaurar stock anterior
        if (entry.previousStock !== undefined) {
            ProductManager.updateProduct(entry.productId, {"stock": entry.previousStock})
        }

        // Recargar
        ProductManager.refreshProducts()
        loadEntries()
    }
}