import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Nuevo Vale de Venta"
        showBack: true
    }

    property var saleItems: []
    property double subtotal: 0
    property double total: subtotal + parseFloat(deliveryCostField.text || 0)

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width

        ColumnLayout {
            width: parent.width
            anchors.margins: Theme.spacingMd
            spacing: Theme.spacingMd

            // Datos del cliente
            CustomCard {
                Layout.fillWidth: true
                title: "Datos del Cliente"

                content: GridLayout {
                    columns: 2
                    columnSpacing: Theme.spacingMd
                    rowSpacing: Theme.spacingMd

                    CustomTextField {
                        id: clientNameField
                        Layout.fillWidth: true
                        label: "Nombre del Cliente"
                        required: true
                    }

                    CustomTextField {
                        id: clientPhoneField
                        Layout.fillWidth: true
                        label: "Teléfono"
                        inputMethodHints: Qt.ImhDigitsOnly
                    }

                    CustomTextField {
                        id: clientAddressField
                        Layout.fillWidth: true
                        Layout.columnSpan: 2
                        label: "Dirección de Entrega"
                        placeholderText: "Dejar vacío si es venta en local"
                    }
                }
            }

            // Productos
            CustomCard {
                Layout.fillWidth: true
                title: "Productos"

                content: ColumnLayout {
                    spacing: Theme.spacingMd

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSm

                        ComboBox {
                            id: productCombo
                            Layout.fillWidth: true
                            model: ProductManager
                            textRole: "name"
                            valueRole: "id"
                            displayText: currentIndex >= 0 ? currentText : "Seleccionar producto..."
                        }

                        SpinBox {
                            id: quantitySpin
                            from: 1
                            to: 999
                            value: 1
                        }

                        CustomButton {
                            text: "Agregar"
                            type: 2
                            onClicked: addItem()
                        }
                    }

                    // Items agregados
                    ListView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.min(200, saleItems.length * 56)
                        model: saleItems
                        visible: saleItems.length > 0

                        delegate: ItemDelegate {
                            width: ListView.view.width
                            contentItem: RowLayout {
                                Label {
                                    text: modelData.productName
                                    font.pixelSize: 14
                                    color: Theme.textPrimary
                                    Layout.fillWidth: true
                                }
                                Label {
                                    text: modelData.quantity + " x " + modelData.unitPrice.toFixed(2) + " = " + modelData.totalPrice.toFixed(2)
                                    font.pixelSize: 13
                                    color: Theme.textSecondary
                                }
                                ToolButton {
                                    text: "✕"
                                    onClicked: removeItem(index)
                                    contentItem: Text {
                                        text: parent.text
                                        color: Theme.error
                                        font.pixelSize: 14
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle { color: "transparent" }
                                }
                            }
                        }
                    }

                    Label {
                        visible: saleItems.length === 0
                        text: "Agregue productos a la venta"
                        font.pixelSize: 13
                        color: Theme.textDisabled
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // Totales y entrega
            CustomCard {
                Layout.fillWidth: true
                title: "Totales"

                content: GridLayout {
                    columns: 2
                    columnSpacing: Theme.spacingMd
                    rowSpacing: Theme.spacingMd

                    CustomTextField {
                        id: deliveryCostField
                        Layout.fillWidth: true
                        label: "Costo de Mensajería"
                        text: "0"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                    }

                    CustomTextField {
                        id: commissionField
                        Layout.fillWidth: true
                        label: "Comisión Gestor"
                        text: "0"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                    }

                    ComboBox {
                        id: paymentTypeCombo
                        Layout.fillWidth: true
                        model: ["efectivo", "transferencia"]
                        currentIndex: 0
                    }

                    CustomTextField {
                        id: notesField
                        Layout.fillWidth: true
                        label: "Notas"
                        placeholderText: "Observaciones adicionales"
                    }

                    RowLayout {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true

                        Label {
                            text: "Subtotal:"
                            font.pixelSize: 16
                            color: Theme.textSecondary
                        }
                        Label {
                            text: subtotal.toFixed(2) + " CUP"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            color: Theme.textPrimary
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    RowLayout {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true

                        Label {
                            text: "TOTAL:"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            color: Theme.accent
                        }
                        Label {
                            text: total.toFixed(2) + " CUP"
                            font.pixelSize: 24
                            font.weight: Font.Bold
                            color: Theme.accent
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }

            CustomButton {
                Layout.fillWidth: true
                text: "Crear Vale de Venta"
                type: 2

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("DEBUG: Button clicked! clientName:" + clientNameField.text + " items:" + saleItems.length)
                        console.log("DEBUG: enabled check - name empty:", clientNameField.text === "")
                        createSale()
                    }
                }
            }
        }
    }

    function addItem() {
        if (productCombo.currentIndex < 0) return
        var productId = productCombo.currentValue
        var productName = productCombo.currentText
        var unitPrice = 0

        // Buscar precio del producto
        for (var i = 0; i < ProductManager.rowCount(); i++) {
            if (ProductManager.data(ProductManager.index(i, 0), 257) === productId) { // IdRole = 257
                unitPrice = ProductManager.data(ProductManager.index(i, 0), 263) // SalePriceRole
                break
            }
        }

        var qty = quantitySpin.value
        var totalPrice = qty * unitPrice

        saleItems.push({
            productId: productId,
            productName: productName,
            quantity: qty,
            unitPrice: unitPrice,
            totalPrice: totalPrice
        })

        recalculate()
    }

    function removeItem(index) {
        saleItems.splice(index, 1)
        recalculate()
    }

    function recalculate() {
        subtotal = 0
        for (var i = 0; i < saleItems.length; i++) {
            subtotal += saleItems[i].totalPrice
        }
    }

    function createSale() {
        console.log("createSale called")
        console.log("clientName:", clientNameField.text)
        console.log("saleItems length:", saleItems.length)
        console.log("createdBy:", UserManager.currentUser.id)

        if (!clientNameField.text || clientNameField.text.trim() === "") {
            appWindow.showToast("Ingrese nombre del cliente", true)
            return
        }

        if (saleItems.length === 0) {
            appWindow.showToast("Agregue al menos un producto", true)
            return
        }

        var createdById = 0
        if (UserManager.currentUser && UserManager.currentUser.id) {
            createdById = UserManager.currentUser.id
        }

        console.log("Calling SaleManager.createSale with", createdById)

        var saleId = SaleManager.createSale(
            clientNameField.text.trim(),
            clientPhoneField.text,
            clientAddressField.text,
            saleItems,
            paymentTypeCombo.currentText,
            parseFloat(deliveryCostField.text || 0),
            parseFloat(commissionField.text || 0),
            createdById,
            notesField.text
        )

        console.log("Sale created, saleId:", saleId)

        if (saleId > 0) {
            var sale = SaleManager.getSale(saleId)
            appWindow.showToast("Vale creado: " + (sale && sale.saleNumber ? sale.saleNumber : saleId))
            appWindow.goBack()
        } else {
            appWindow.showToast("Error al crear el vale", true)
        }
    }
}
