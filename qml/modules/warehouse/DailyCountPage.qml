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
    property var modifiedItems: ({})
    property var productList: []
    property int squared: 0
    property int pending: 0
    property string selectedCategory: "Todas"
    property var scrollPosition: 0

    function editedCount() {
        return Object.keys(modifiedItems).length
    }

function buildProductList() {
        var allProducts = ProductManager.getAllProductsList()
        var list = []
        console.log("Total productos:", allProducts.length)
        for (var i = 0; i < allProducts.length; i++) {
            var product = allProducts[i]
            if (product && product.id) {
                if (selectedCategory === "Todas" || product.category === selectedCategory) {
                    list.push({
                        id: product.id,
                        code: product.code || "",
                        name: product.name || "",
                        category: product.category || "",
                        stock: product.stock || 0
                    })
                }
            }
        }
        return list
    }


    function updateProductList() {
        if (inventoryListView) {
            scrollPosition = inventoryListView.contentY || 0
        }
        productList = buildProductList()
        recalcSummary()
        timerRestaurar.start()
    }

    Timer {
        id: timerRestaurar
        interval: 50
        repeat: false
        onTriggered: {
            if (inventoryListView) {
                inventoryListView.contentY = scrollPosition
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            initializeCounts()
        }
    }

    Component.onCompleted: {
        initializeCounts()
    }

    function initializeCounts() {
        var newCountItems = {}
        var productCount = ProductManager.rowCount()
        for (var i = 0; i < productCount; i++) {
            var product = ProductManager.getProduct(i)
            newCountItems[product.id] = product.stock || 0
        }
        countItems = newCountItems
        modifiedItems = ({})
        updateProductList()
    }

    onSelectedCategoryChanged: updateProductList()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        // Resumen del conteo
        CustomCard {
            Layout.fillWidth: true
            title: "Conteo del " + Qt.formatDate(new Date(), "dd/MM/yyyy")
            subtitle: "Compare el stock real con el sistema"

            content: ColumnLayout {
                spacing: Theme.spacingSm

                RowLayout {
                    spacing: Theme.spacingMd

                    // Cuadrados
                    Rectangle {
                        Layout.fillWidth: true
                        height: 80
                        radius: Theme.radiusMd
                        color: "#C8E6C9"
                        border.color: "#388E3C"
                        border.width: 2

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Label {
                                text: "✅"
                                font.pixelSize: 32
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Cuadrados"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: "#1B5E20"
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: squared
                                font.pixelSize: 28
                                font.weight: Font.Bold
                                color: "#1B5E20"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    // Pendientes
                    Rectangle {
                        Layout.fillWidth: true
                        height: 80
                        radius: Theme.radiusMd
                        color: "#FFCDD2"
                        border.color: "#D32F2F"
                        border.width: 2

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Label {
                                text: "⚠️"
                                font.pixelSize: 32
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: "Pendientes"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: "#B71C1C"
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: pending
                                font.pixelSize: 28
                                font.weight: Font.Bold
                                color: "#B71C1C"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }

                // Progreso
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSm

                    Label {
                        text: "Editados: " + editedCount() + " / " + productList.length + " productos"
                        font.pixelSize: 12
                        color: Theme.textSecondary
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 8
                        radius: 4
                        color: Theme.divider

                        Rectangle {
                            height: 8
                            radius: 4
                            color: Theme.primary
                            width: productList.length > 0 ?
                                   (editedCount() / productList.length) * parent.width : 0
                        }
                    }
                }
            }
        }

        // Filtro de categoría
        CustomCard {
            Layout.fillWidth: true
            title: "Filtrar por Categoría"

            content: RowLayout {
                spacing: Theme.spacingMd

                ComboBox {
                    id: categoryFilter
                    Layout.fillWidth: true
                    model: ProductManager.getCategories(true)
                    textRole: "category"
                    currentIndex: 0
                    onCurrentIndexChanged: {
                        var item = model.get ? model.get(currentIndex) : model[currentIndex]
                        selectedCategory = currentIndex === 0 ? "Todas" : (item ? (item.category || item) : "Todas")
                    }
                }

                CustomButton {
                    text: "🔄 Limpiar"
                    type: 0
                    onClicked: {
                        selectedCategory = "Todas"
                        categoryFilter.currentIndex = 0
                    }
                }
            }
        }

        // Lista de productos
        CustomCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Inventario - Ingrese Stock Físico"

            content: ListView {
                id: inventoryListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: productList
                clip: true

                delegate: ItemDelegate {
                    id: delegateItem
                    width: ListView.view.width

                    property int productId: modelData.id || 0
                    property int expectedStock: modelData.stock || 0

                    // ← BINDING VIVO: se reevalúa cuando countItems cambia
                    property int actualStock: {
                        var c = countItems
                        return c[productId] !== undefined ? c[productId] : expectedStock
                    }

                    property int difference: actualStock - expectedStock

                    // ← BINDING VIVO: se reevalúa cuando modifiedItems cambia
                    property bool isEdited: {
                        var m = modifiedItems
                        return m[productId] !== undefined
                    }

                    contentItem: ColumnLayout {
                        spacing: Theme.spacingSm

                        // Header
                        RowLayout {
                            Layout.fillWidth: true

                            Rectangle {
                                width: 6
                                height: 50
                                radius: 3
                                color: {
                                    if (!delegateItem.isEdited) return "#BDBDBD"
                                    if (delegateItem.difference === 0) return "#4CAF50"
                                    if (delegateItem.difference > 0) return "#FF9800"
                                    return "#F44336"
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                RowLayout {
                                    Label {
                                        text: modelData.name || ""
                                        font.pixelSize: 15
                                        font.weight: Font.Medium
                                        color: Theme.textPrimary
                                        Layout.fillWidth: true
                                    }
                                    Rectangle {
                                        visible: delegateItem.isEdited
                                        height: 20
                                        radius: 10
                                        color: delegateItem.difference === 0 ? "#C8E6C9" : (delegateItem.difference > 0 ? "#FFE0B2" : "#FFCDD2")

                                        Label {
                                            anchors.centerIn: parent
                                            anchors.margins: 6
                                            text: delegateItem.difference === 0 ? "✓ OK" : (delegateItem.difference > 0 ? "+" + delegateItem.difference : delegateItem.difference)
                                            font.pixelSize: 11
                                            font.weight: Font.Bold
                                            color: delegateItem.difference === 0 ? "#1B5E20" : (delegateItem.difference > 0 ? "#E65100" : "#B71C1C")
                                        }
                                    }
                                }

                                Label {
                                    text: (modelData.code || "") + " | " + (modelData.category || "")
                                    font.pixelSize: 11
                                    color: Theme.textSecondary
                                }
                            }
                        }

                        // Controles
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingMd

                            // Stock Sistema
                            Rectangle {
                                Layout.fillWidth: true
                                height: 60
                                radius: Theme.radiusMd
                                color: "#E3F2FD"
                                border.color: "#1976D2"
                                border.width: 1

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2

                                    Label {
                                        text: "Stock Sistema"
                                        font.pixelSize: 10
                                        color: "#0D47A1"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Label {
                                        text: delegateItem.expectedStock
                                        font.pixelSize: 24
                                        font.weight: Font.Bold
                                        color: "#0D47A1"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }

                            // Stock Físico
                            Rectangle {
                                Layout.fillWidth: true
                                height: 60
                                radius: Theme.radiusMd
                                color: delegateItem.isEdited ? "#E8EAF6" : "#F5F5F5"
                                border.color: delegateItem.isEdited ? "#3F51B5" : "#9E9E9E"
                                border.width: delegateItem.isEdited ? 2 : 1

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2

                                    Label {
                                        text: "Stock Físico"
                                        font.pixelSize: 10
                                        color: delegateItem.isEdited ? "#303F9F" : "#757575"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    SpinBox {
                                        id: spinBox
                                        from: 0
                                        to: 99999
                                        width: 140
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        // ← BINDING VIVO al actualStock del delegate
                                        value: delegateItem.actualStock

                                        // ← CLAVE: onValueModified recibe el valor NUEVO directamente
                                        onValueModified: {
                                            var pid = delegateItem.productId
                                            var val = spinBox.value

                                            // 1. Actualizar countItems
                                            var newCount = Object.assign({}, countItems)
                                            newCount[pid] = val
                                            countItems = newCount

                                            // 2. Actualizar modifiedItems
                                            var newModified = Object.assign({}, modifiedItems)
                                            newModified[pid] = true
                                            modifiedItems = newModified

                                            // 3. ← CLAVE: recalcular resumen PASANDO el valor directo
                                            // No esperar a que countItems se propague
                                            recalcSummaryWithValue(pid, val)
                                        }
                                    }
                                }
                            }

                            // Diferencia
                            Rectangle {
                                Layout.fillWidth: true
                                height: 60
                                radius: Theme.radiusMd
                                color: {
                                    if (!delegateItem.isEdited) return "#F5F5F5"
                                    if (delegateItem.difference === 0) return "#C8E6C9"
                                    if (delegateItem.difference > 0) return "#FFE0B2"
                                    return "#FFCDD2"
                                }
                                border.color: {
                                    if (!delegateItem.isEdited) return "#9E9E9E"
                                    if (delegateItem.difference === 0) return "#388E3C"
                                    if (delegateItem.difference > 0) return "#F57C00"
                                    return "#D32F2F"
                                }
                                border.width: 1

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2

                                    Label {
                                        text: "Diferencia"
                                        font.pixelSize: 10
                                        color: {
                                            if (!delegateItem.isEdited) return "#757575"
                                            if (delegateItem.difference === 0) return "#1B5E20"
                                            if (delegateItem.difference > 0) return "#E65100"
                                            return "#B71C1C"
                                        }
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Label {
                                        text: delegateItem.isEdited ? (delegateItem.difference > 0 ? "+" + delegateItem.difference : delegateItem.difference) : "-"
                                        font.pixelSize: 22
                                        font.weight: Font.Bold
                                        color: {
                                            if (!delegateItem.isEdited) return "#9E9E9E"
                                            if (delegateItem.difference === 0) return "#1B5E20"
                                            if (delegateItem.difference > 0) return "#E65100"
                                            return "#B71C1C"
                                        }
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Botones
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingMd

            CustomButton {
                Layout.fillWidth: true
                text: "🗑️ Limpiar Todo"
                type: 0
                onClicked: {
                    initializeCounts()
                    appWindow.showToast("Conteos reiniciados")
                }
            }

            CustomButton {
                Layout.fillWidth: true
                text: "💾 Guardar Conteo (" + editedCount() + ")"
                type: editedCount() > 0 ? 2 : 0
                enabled: editedCount() > 0
                onClicked: saveCount()
            }
        }
    }

    // ← NUEVO: recalcular todo desde countItems (usado en inicialización y cambio de categoría)
    function recalcSummary() {
        var sq = 0
        var pe = 0

        for (var i = 0; i < productList.length; i++) {
            var product = productList[i]
            var productId = product.id
            var expected = product.stock || 0
            var actual = countItems[productId] !== undefined ? countItems[productId] : expected

            if (actual === expected) {
                sq++
            } else {
                pe++
            }
        }

        squared = sq
        pending = pe
    }

    // ← NUEVO: recalcular con un valor específico que acaba de cambiar (más rápido y confiable)
    function recalcSummaryWithValue(changedProductId, newValue) {
        var sq = 0
        var pe = 0

        for (var i = 0; i < productList.length; i++) {
            var product = productList[i]
            var productId = product.id
            var expected = product.stock || 0

            // Usar el nuevo valor si es el producto que cambió, sino leer de countItems
            var actual
            if (productId === changedProductId) {
                actual = newValue
            } else {
                actual = countItems[productId] !== undefined ? countItems[productId] : expected
            }

            if (actual === expected) {
                sq++
            } else {
                pe++
            }
        }

        squared = sq
        pending = pe
    }

    function saveCount() {
        var modifiedKeys = Object.keys(modifiedItems)

        if (modifiedKeys.length === 0) {
            appWindow.showToast("No hay conteos para guardar", true)
            return
        }

        var savedCount = 0
        var failedCount = 0
        var unchangedCount = 0
        var diffCount = 0

        for (var i = 0; i < productList.length; i++) {
            var product = productList[i]
            var productId = product.id

            if (!modifiedItems[productId]) continue

            var actualQuantity = countItems[productId]
            var expectedStock = product.stock || 0

            var reason
            if (actualQuantity !== expectedStock) {
                var diff = actualQuantity - expectedStock
                reason = "Conteo físico: " + (diff > 0 ? "+" : "") + diff
                diffCount++
            } else {
                reason = "Conteo físico: sin diferencias"
                unchangedCount++
            }

            var success = ProductManager.adjustStock(productId, actualQuantity, reason)
            if (success) {
                savedCount++
            } else {
                failedCount++
            }
        }

        ProductManager.refreshProducts()

        var msg = "✅ Conteo guardado: " + savedCount + " productos"
        if (diffCount > 0) msg += "\n⚠️ " + diffCount + " con diferencia ajustada"
        if (unchangedCount > 0) msg += "\n✓ " + unchangedCount + " sin cambios"
        if (failedCount > 0) msg += "\n❌ Fallidos: " + failedCount

        appWindow.showToast(msg, failedCount > 0)

        initializeCounts()
    }
}
