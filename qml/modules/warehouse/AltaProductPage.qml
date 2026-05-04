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

                    // Código con botón para generar automáticamente
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSm

                        CustomTextField {
                            id: codeField
                            Layout.fillWidth: true
                            label: "Código"
                            placeholder: "PROD-0001"
                        }

                        CustomButton {
                            text: "🔄"
                            onClicked: codeField.text = ProductManager.generateProductCode()
                            ToolTip.text: "Generar código automático"
                        }
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
                        model: ProductManager.getCategories(false)
                        textRole: "category"
                        currentIndex: 0  // SinCategoría por defecto (sin "Todas")
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
                        label: "Precio de Compra (CUP) *"
                        placeholder: "0.00"
                        inputMethodHints: Qt.ImhDigitsOnly
                    }

                    // Campo lote (identifica diferentes compras del mismo producto)
                    CustomTextField {
                        id: loteField
                        Layout.fillWidth: true
                        label: "Lote"
                        placeholder: "Número de lote (opcional)"
                    }

                    // Proveedor con ComboBox
                    Label {
                        text: "Proveedor *"
                        font.pixelSize: 12
                        color: Theme.textSecondary
                    }

                    ComboBox {
                        id: supplierCombo
                        Layout.fillWidth: true
                        textRole: "name"
                        currentIndex: 0

                        Component.onCompleted: {
                            var suppliers = AppController.getSuppliersList()
                            // Agregar opción "Sin proveedor" al inicio
                            var list = [{"name": "Seleccionar proveedor", "id": 0}]
                            for (var i = 0; i < suppliers.length; i++) {
                                list.push(suppliers[i])
                            }
                            model = list
                        }
                    }

                    // Botón para agregar nuevo proveedor rápido
                    CustomButton {
                        text: "+ Nuevo Proveedor"
                        type: 1
                        onClicked: addSupplierDialog.open()
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
        // Validar campos requeridos obligatorios
        if (!codeField.text || codeField.text.trim() === "") {
            appWindow.showToast("❌ El código es obligatorio", true)
            return
        }

        if (!nameField.text || nameField.text.trim() === "") {
            appWindow.showToast("❌ El nombre es obligatorio", true)
            return
        }

        var purchasePrice = parseFloat(purchasePriceField.text) || 0
        if (purchasePrice <= 0) {
            appWindow.showToast("❌ El precio de compra es obligatorio", true)
            return
        }

        // Proveedor del ComboBox
        var supplier = supplierCombo.currentText
        if (!supplier || supplier === "Seleccionar proveedor") {
            appWindow.showToast("❌ Seleccione un proveedor", true)
            return
        }

        var unit = unitCombo.currentText
        if (!unit || unit === "") {
            appWindow.showToast("❌ La unidad es obligatoria", true)
            return
        }

        var category = categoryCombo.currentText
        if (!category || category === "") {
            appWindow.showToast("Seleccione una categoría", true)
            return
        }

        var salePrice = parseFloat(salePriceField.text) || 0
        var stock = parseInt(stockField.text) || 0
        var minStock = parseInt(minStockField.text) || 0
        var lote = loteField.text.trim()

        var success = ProductManager.addProduct(
            codeField.text.trim(),
            nameField.text.trim(),
            category,
            salePrice,
            stock,
            unit,
            descriptionField.text,
            minStock,
            purchasePrice,
            supplier,
            lote
        )

        if (success) {
            appWindow.showToast("✅ Producto guardado correctamente")

            // Limpiar formulario
            codeField.text = ""
            nameField.text = ""
            salePriceField.text = ""
            purchasePriceField.text = ""
            loteField.text = ""
            supplierCombo.currentIndex = 0
            stockField.text = ""
            minStockField.text = ""
            descriptionField.text = ""
            unitCombo.currentIndex = 0

            // Refrescar categorías en caso de que se haya creado una nueva
            ProductManager.refreshProducts()
        } else {
            appWindow.showToast("❌ Error al guardar producto", true)
        }
    }

    // Diálogo para agregar nuevo proveedor
    Dialog {
        id: addSupplierDialog
        title: "Nuevo Proveedor"
        modal: true
        width: 400
        anchors.centerIn: parent

        ColumnLayout {
            spacing: Theme.spacingMd

            CustomTextField {
                id: newSupplierName
                Layout.fillWidth: true
                label: "Nombre *"
                placeholder: "Nombre del proveedor"
            }

            CustomTextField {
                id: newSupplierContact
                Layout.fillWidth: true
                label: "Persona de contacto"
                placeholder: "Nombre del contacto"
            }

            CustomTextField {
                id: newSupplierPhone
                Layout.fillWidth: true
                label: "Teléfono"
                placeholder: "Teléfono"
            }

            CustomTextField {
                id: newSupplierEmail
                Layout.fillWidth: true
                label: "Email"
                placeholder: "email@ejemplo.com"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingMd

                CustomButton {
                    Layout.fillWidth: true
                    text: "Cancelar"
                    type: 1
                    onClicked: addSupplierDialog.close()
                }

                CustomButton {
                    Layout.fillWidth: true
                    text: "Guardar"
                    type: 2
                    onClicked: {
                        if (!newSupplierName.text || newSupplierName.text.trim() === "") {
                            appWindow.showToast("❌ El nombre es obligatorio", true)
                            return
                        }
                        var success = AppController.addSupplier(
                            newSupplierName.text.trim(),
                            newSupplierContact.text.trim(),
                            newSupplierPhone.text.trim(),
                            newSupplierEmail.text.trim(),
                            ""
                        )
                        if (success) {
                            appWindow.showToast("✅ Proveedor agregado")
                            addSupplierDialog.close()
                            // Limpiar campos
                            newSupplierName.text = ""
                            newSupplierContact.text = ""
                            newSupplierPhone.text = ""
                            newSupplierEmail.text = ""
                            // Recargar proveedores en el ComboBox
                            supplierCombo.currentIndex = 0
                            var suppliers = AppController.getSuppliersList()
                            var list = [{"name": "Seleccionar proveedor", "id": 0}]
                            for (var i = 0; i < suppliers.length; i++) {
                                list.push(suppliers[i])
                            }
                            supplierCombo.model = list
                        } else {
                            appWindow.showToast("❌ Error al agregar proveedor", true)
                        }
                    }
                }
            }
        }
    }
}