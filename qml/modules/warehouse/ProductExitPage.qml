import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Salida de Productos"
        showBack: true
    }

    // Estado
    property var selectedProduct: null

    Component.onCompleted: {
        Qt.callLater(function() {
            refreshProductList()
            loadExits()
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
                                    color: modelData.stock > 0 ? Theme.success : Theme.error
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

        // 2. SALIDA DE PRODUCTO (visible cuando selecciona producto)
        CustomCard {
            Layout.fillWidth: true
            visible: selectedProduct !== null
            title: "2. Salida de Producto"

            content: ColumnLayout {
                spacing: Theme.spacingMd

                RowLayout {
                    Label {
                        text: selectedProduct ? selectedProduct.code + " - " + selectedProduct.name : ""
                        font.pixelSize: 16
                        font.weight: Font.Medium
                        color: Theme.error
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
                        id: reasonField
                        Layout.fillWidth: true
                        label: "Motivo"
                        placeholder: "Venta, producción, muestra..."
                    }
                }

                CustomButton {
                    text: "📤 Registrar Salida"
                    type: 3
                    onClicked: registerExit()
                }
            }
        }

        // 3. SALIDAS RECIENTES
        CustomCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "3. Salidas Recientes (últimas 10)"

            content: ListView {
                id: exitsListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: exitsList
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
                                text: "-" + modelData.quantity
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: Theme.error
                            }
                        }

                        Label {
                            text: "📅 " + modelData.dateFormatted + " | " + (modelData.reason || "Sin motivo")
                            font.pixelSize: 10
                            color: Theme.textSecondary
                        }
                    }
                }
            }
        }
    }

    // Modelo para salidas
    property var exitsList: []

    function refreshProductList() {
        var all = ProductManager.getAllProductsList()
        var filtered = []

        var lowerSearch = searchField.text ? searchField.text.toLowerCase() : ""
        var selectedIndex = categoryFilter.currentIndex
        var selectedCategory = ""

        if (selectedIndex > 0 && categoryFilter.model.length > selectedIndex) {
            selectedCategory = categoryFilter.model[selectedIndex].category || ""
        }

        for (var i = 0; i < all.length; i++) {
            var p = all[i]
            var categoryMatch = selectedCategory === "Todas" || selectedCategory === "" || p.category === selectedCategory
            var textMatch = !lowerSearch || p.name.toLowerCase().includes(lowerSearch) || p.code.toLowerCase().includes(lowerSearch)

            if (categoryMatch && textMatch && p.stock > 0) {
                filtered.push(p)
            }
        }
        productList.model = filtered
    }

    function selectProduct(product) {
        selectedProduct = product
        quantityField.text = ""
        reasonField.text = ""
        quantityField.focus = true
    }

    function clearSelection() {
        selectedProduct = null
        searchField.text = ""
        refreshProductList()
    }

    function registerExit() {
        if (!selectedProduct) {
            appWindow.showToast("Seleccione un producto", true)
            return
        }

        var qty = parseInt(quantityField.text)
        if (!qty || qty <= 0) {
            appWindow.showToast("Ingrese cantidad válida", true)
            return
        }

        if (qty > selectedProduct.stock) {
            appWindow.showToast("Stock insuficiente (disponible: " + selectedProduct.stock + ")", true)
            return
        }

        var reason = reasonField.text || "Sin motivo"

        // Registrar salida (reducir stock)
        var success = ProductManager.removeStock(selectedProduct.id, qty, reason)

        if (success) {
            appWindow.showToast("Salida registrada: -" + qty + " unidades")

            // Limpiar
            clearSelection()

            // Recargar lista de salidas
            loadExits()
            ProductManager.refreshProducts()
        } else {
            appWindow.showToast("Error al registrar salida", true)
        }
    }

    function loadExits() {
        var exits = InventoryManager.getRecentExits(10)

        var list = []
        for (var i = 0; i < exits.length; i++) {
            var e = exits[i]
            var dateStr = e.date || ""
            var dateFormatted = dateStr.length > 16 ? dateStr.substring(0, 16) : dateStr
            list.push({
                id: e.id,
                productId: e.productId,
                productCode: e.productCode || "N/A",
                productName: e.productName || "Producto",
                quantity: e.quantity,
                reason: e.reason || "",
                dateFormatted: dateFormatted
            })
        }
        exitsList = list
    }
}