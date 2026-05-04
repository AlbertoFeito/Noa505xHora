import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Gestión de Productos"
        showBack: true
    }

    property var productsModel: []
    property var filterCategory: ""
    property var editingProduct: null

    Component.onCompleted: {
        refreshProducts()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        // Filtro por categoría
        CustomCard {
            Layout.fillWidth: true
            title: "Filtrar por Categoría"

            content: RowLayout {
                spacing: Theme.spacingMd

                ComboBox {
                    id: filterCombo
                    Layout.fillWidth: true
                    model: ProductManager.getCategories()
                    textRole: "category"
                    currentIndex: 0
                    onCurrentIndexChanged: {
                        filterCategory = currentIndex === 0 ? "" : model[currentIndex].category
                        refreshProducts()
                    }
                }

                CustomButton {
                    text: "➕ Nuevo"
                    type: 2
                    onClicked: appWindow.navigateTo("modules/warehouse/AltaProductPage.qml")
                }
            }
        }

        // Lista de productos
        CustomCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Productos"
            subtitle: productsModel.length + " productos"

            content: ListView {
                id: productList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: productsModel
                clip: true

                delegate: ItemDelegate {
                    width: ListView.view.width

                    contentItem: ColumnLayout {
                        spacing: Theme.spacingSm

                        RowLayout {
                            Layout.fillWidth: true

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Label {
                                    text: modelData.name
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    color: Theme.textPrimary
                                }

                                Label {
                                    text: "Código: " + modelData.code + " | Categoría: " + (modelData.category || "SinCategoría") + " | Proveedor: " + (modelData.supplier || "N/A")
                                    font.pixelSize: 11
                                    color: Theme.textSecondary
                                }

                                Label {
                                    text: "Lote: " + (modelData.lote || "N/A")
                                    font.pixelSize: 10
                                    color: Theme.textSecondary
                                    visible: modelData.lote
                                }
                            }

                            // Stock info
                            ColumnLayout {
                                Label {
                                    text: "Stock"
                                    font.pixelSize: 10
                                    color: Theme.textSecondary
                                }
                                Label {
                                    text: modelData.stock
                                    font.pixelSize: 18
                                    font.weight: Font.Medium
                                    color: modelData.stock <= modelData.minStock ? Theme.error : Theme.success
                                }
                            }

                            // Precio
                            ColumnLayout {
                                Label {
                                    text: "Precio"
                                    font.pixelSize: 10
                                    color: Theme.textSecondary
                                }
                                Label {
                                    text: modelData.salePrice.toFixed(2) + " CUP"
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    color: Theme.success
                                }
                            }

                            // Botón editar
                            ToolButton {
                                text: "✏️"
                                onClicked: {
                                    openEditPanel(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Panel para editar producto - overlay centrado
    Rectangle {
        id: editPanel
        visible: false
        anchors.fill: parent
        color: "#80000000"

        Rectangle {
            width: 400
            height: 520
            anchors.centerIn: parent
            color: Theme.background
            radius: Theme.radiusMd

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingLg
                spacing: Theme.spacingMd

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "✏️ Editar Producto"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: Theme.textPrimary
                    }
                    Item { Layout.fillWidth: true }
                    MouseArea {
                        width: 32
                        height: 32
                        onClicked: editPanel.visible = false
                        Label {
                            text: "✕"
                            font.pixelSize: 18
                            color: Theme.textSecondary
                            anchors.centerIn: parent
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.divider
                }

                // Nombre
                CustomTextField {
                    id: editName
                    Layout.fillWidth: true
                    label: "Nombre"
                    placeholder: "Nombre del producto"
                }

                // Código
                CustomTextField {
                    id: editCode
                    Layout.fillWidth: true
                    label: "Código"
                    placeholder: "Código del producto"
                }

                // Precios
                RowLayout {
                    CustomTextField {
                        id: editSalePrice
                        Layout.fillWidth: true
                        label: "Precio Venta"
                        placeholder: "0.00"
                    }
                    CustomTextField {
                        id: editPurchasePrice
                        Layout.fillWidth: true
                        label: "Precio Compra"
                        placeholder: "0.00"
                    }
                }

                // Stock mínimo
                CustomTextField {
                    id: editMinStock
                    Layout.fillWidth: true
                    label: "Stock Mínimo"
                    placeholder: "0"
                }

                // Categoría
                ColumnLayout {
                    Label {
                        text: "Categoría"
                        font.pixelSize: 12
                        color: Theme.textSecondary
                    }
                    ComboBox {
                        id: editCategoryCombo
                        Layout.fillWidth: true
                        model: ProductManager.getCategories()
                        textRole: "category"
                    }
                }

                Item { Layout.fillHeight: true }

                // Botones
                RowLayout {
                    CustomButton {
                        Layout.fillWidth: true
                        text: "Cancelar"
                        type: 0
                        onClicked: editPanel.visible = false
                    }

                    CustomButton {
                        Layout.fillWidth: true
                        text: "💾 Guardar"
                        type: 2
                        onClicked: doSaveProduct()
                    }
                }
            }
        }
    }

    function openEditPanel(product) {
        editingProduct = product
        editName.text = product.name
        editCode.text = product.code
        editSalePrice.text = product.salePrice.toString()
        editPurchasePrice.text = product.purchasePrice ? product.purchasePrice.toString() : "0"
        editMinStock.text = product.minStock ? product.minStock.toString() : "0"

        // Buscar índice de la categoría actual
        var cats = ProductManager.getCategories()
        for (var i = 0; i < cats.length; i++) {
            if (cats[i].category === product.category) {
                editCategoryCombo.currentIndex = i
                break
            }
        }

        editPanel.visible = true
    }

    function doSaveProduct() {
        if (!editingProduct) return

        var fields = {
            "name": editName.text,
            "code": editCode.text,
            "salePrice": parseFloat(editSalePrice.text) || 0,
            "purchasePrice": parseFloat(editPurchasePrice.text) || 0,
            "minStock": parseInt(editMinStock.text) || 0,
            "category": editCategoryCombo.currentText
        }

        console.log("Guardando producto:", JSON.stringify(fields))

        if (ProductManager.updateProduct(editingProduct.id, fields)) {
            appWindow.showToast("Producto actualizado")
            refreshProducts()
            editPanel.visible = false
        } else {
            appWindow.showToast("Error al actualizar", true)
        }
    }

    function refreshProducts() {
        var all = ProductManager.getAllProductsList()

        if (filterCategory && filterCategory !== "") {
            var filtered = []
            for (var i = 0; i < all.length; i++) {
                if (all[i].category === filterCategory) {
                    filtered.push(all[i])
                }
            }
            productsModel = filtered
        } else {
            productsModel = all
        }
    }
}