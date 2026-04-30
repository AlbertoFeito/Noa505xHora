import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Alta de Producto"
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
                title: "Datos del Producto"

                content: ColumnLayout {
                    spacing: Theme.spacingMd

                    CustomTextField {
                        id: codeField
                        Layout.fillWidth: true
                        label: "Código"
                        placeholder: "Código único del producto"
                    }

                    CustomTextField {
                        id: nameField
                        Layout.fillWidth: true
                        label: "Nombre"
                        placeholder: "Nombre del producto"
                    }

                    // Categoría con ComboBox
                    Label {
                        text: "Categoría"
                        font.pixelSize: 12
                        color: Theme.textSecondary
                    }

                    ComboBox {
                        id: categoryCombo
                        Layout.fillWidth: true
                        model: ProductManager.getCategories()
                        textRole: "category"
                        currentIndex: 0

                        // Botón para agregar nueva categoría
                        ToolButton {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: "+"
                            onClicked: {
                                // Guardar categoría actual y abrir dialogo
                                appWindow.navigateTo("modules/warehouse/CategoriasPage.qml")
                            }
                        }
                    }

                    CustomTextField {
                        id: salePriceField
                        Layout.fillWidth: true
                        label: "Precio de Venta (CUP)"
                        placeholder: "0.00"
                        inputMethodHints: Qt.ImhDigitsOnly
                    }

                    CustomTextField {
                        id: purchasePriceField
                        Layout.fillWidth: true
                        label: "Precio de Compra (CUP)"
                        placeholder: "0.00"
                        inputMethodHints: Qt.ImhDigitsOnly
                    }

                    CustomTextField {
                        id: stockField
                        Layout.fillWidth: true
                        label: "Stock Inicial"
                        placeholder: "0"
                        inputMethodHints: Qt.ImhDigitsOnly
                    }

                    CustomTextField {
                        id: minStockField
                        Layout.fillWidth: true
                        label: "Stock Mínimo"
                        placeholder: "0"
                        inputMethodHints: Qt.ImhDigitsOnly
                    }

                    // Unidad
                    Label {
                        text: "Unidad"
                        font.pixelSize: 12
                        color: Theme.textSecondary
                    }

                    ComboBox {
                        id: unitCombo
                        Layout.fillWidth: true
                        model: ["unidad", "kg", "lb", "litro", "metro", "par", "bulto", "caja"]
                        currentIndex: 0
                    }

                    CustomTextField {
                        id: descriptionField
                        Layout.fillWidth: true
                        label: "Descripción"
                        placeholder: "Descripción opcional"
                    }

                    CustomButton {
                        Layout.fillWidth: true
                        text: "✅ Guardar Producto"
                        type: 2
                        onClicked: saveProduct()
                    }
                }
            }
        }
    }

    function saveProduct() {
        // Validar campos requeridos
        if (!codeField.text || codeField.text.trim() === "") {
            appWindow.showToast("Ingrese el código del producto", true)
            return
        }

        if (!nameField.text || nameField.text.trim() === "") {
            appWindow.showToast("Ingrese el nombre del producto", true)
            return
        }

        var category = categoryCombo.currentText
        if (!category || category === "") {
            appWindow.showToast("Seleccione una categoría", true)
            return
        }

        var salePrice = parseFloat(salePriceField.text) || 0
        var purchasePrice = parseFloat(purchasePriceField.text) || 0
        var stock = parseInt(stockField.text) || 0
        var minStock = parseInt(minStockField.text) || 0
        var unit = unitCombo.currentText

        var success = ProductManager.addProduct(
            codeField.text.trim(),
            nameField.text.trim(),
            category,
            salePrice,
            stock,
            unit,
            descriptionField.text,
            minStock
        )

        if (success) {
            appWindow.showToast("Producto guardado correctamente")

            // Limpiar formulario
            codeField.text = ""
            nameField.text = ""
            salePriceField.text = ""
            purchasePriceField.text = ""
            stockField.text = ""
            minStockField.text = ""
            descriptionField.text = ""
            unitCombo.currentIndex = 0

            // Refrescar categorías en caso de que se haya creado una nueva
            ProductManager.refreshProducts()
        } else {
            appWindow.showToast("Error al guardar producto", true)
        }
    }
}