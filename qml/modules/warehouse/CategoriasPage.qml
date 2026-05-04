import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    // Modelo para categorías con refresh manual
    property var categoriesModel: []

    header: NavigationBar {
        pageTitle: "Categorías de Productos"
        showBack: true
        actions: [
            {
                text: "🔄",
                action: function() { refreshCategories() }
            }
        ]
    }

    Component.onCompleted: {
        refreshCategories()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        // Agregar nueva categoría
        CustomCard {
            Layout.fillWidth: true
            title: "Agregar Nueva Categoría"

            content: RowLayout {
                spacing: Theme.spacingMd

                CustomTextField {
                    id: newCategoryField
                    Layout.fillWidth: true
                    placeholder: "Nombre de la nueva categoría"
                }

                CustomButton {
                    text: "➕ Agregar"
                    type: 2
                    onClicked: addCategory()
                }
            }
        }

        // Info importante
        CustomCard {
            Layout.fillWidth: true
            title: "Importante"
            elevation: 0

            content: ColumnLayout {
                spacing: Theme.spacingSm

                Label {
                    text: "• Solo puede eliminar categorías vacías (0 productos)"
                    font.pixelSize: 12
                    color: Theme.textSecondary
                    wrapMode: Text.WordWrap
                }
                Label {
                    text: "• Los productos sin categoría se asignan a 'SinCategoría'"
                    font.pixelSize: 12
                    color: Theme.textSecondary
                    wrapMode: Text.WordWrap
                }
            }
        }

        // Lista de categorías existentes
        CustomCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Categorías Existentes"
            subtitle: categoriesModel.length > 0 ? (categoriesModel.length - 1) + " categorías" : "0 categorías"

            content: ListView {
                id: categoriesList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: categoriesModel
                clip: true

                delegate: ItemDelegate {
                    width: ListView.view.width
                    visible: modelData.category !== "" // Ocultar opción "Todas"

                    contentItem: RowLayout {
                        Label {
                            text: modelData.category === "SinCategoría" ? "📦" : "🏷️"
                            font.pixelSize: 18
                            color: modelData.category === "SinCategoría" ? Theme.warning : Theme.info
                        }

                        Label {
                            text: modelData.category || "Sin nombre"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: modelData.category === "SinCategoría" ? Theme.warning : Theme.textPrimary
                            Layout.fillWidth: true
                        }

                        Label {
                            text: (modelData.count || 0) + " productos"
                            font.pixelSize: 12
                            color: Theme.textSecondary
                        }

                        // Botón eliminar (excepto SinCategoría y categorías con productos)
                        ToolButton {
                            visible: modelData.category !== "SinCategoría" && (modelData.count || 0) === 0
                            text: "🗑️"
                            onClicked: deleteCategory(modelData.category)
                        }
                    }
                }
            }
        }

        // Botón crear categoría SinCategoría si no existe
        CustomButton {
            Layout.fillWidth: true
            text: "➕ Crear 'SinCategoría' por defecto"
            type: hasSinCategoria ? 0 : 1
            visible: !hasSinCategoria
            onClicked: createSinCategoria()
        }
    }

    function refreshCategories() {
        categoriesModel = ProductManager.getCategories()
    }

    function addCategory() {
        var newCategory = newCategoryField.text.trim()

        // Validar que no esté vacío
        if (!newCategory || newCategory === "") {
            appWindow.showToast("Ingrese el nombre de la categoría", true)
            return
        }

        // Validar que no exista ya (ignorando mayúsculas/minúsculas)
        for (var i = 0; i < categoriesModel.length; i++) {
            if (categoriesModel[i].category.toLowerCase() === newCategory.toLowerCase()) {
                appWindow.showToast("La categoría '" + newCategory + "' ya existe", true)
                return
            }
        }

        // Validar longitud máxima
        if (newCategory.length > 50) {
            appWindow.showToast("El nombre es muy largo (máx 50 caracteres)", true)
            return
        }

        // Validar caracteres permitidos
        var validPattern = /^[a-zA-Z0-9\s\-áéíóúÁÉÍÓÚñÑ]+$/
        if (!validPattern.test(newCategory)) {
            appWindow.showToast("Solo letras, números, espacios y guiones", true)
            return
        }

        // Llamar al método para agregar categoría
        var success = AppController.addCategory(newCategory)

        if (success) {
            appWindow.showToast("Categoría agregada: " + newCategory)
            newCategoryField.text = ""
            refreshCategories()
        } else {
            appWindow.showToast("Error al agregar categoría", true)
        }
    }

    function deleteCategory(categoryName) {
        var success = AppController.deleteCategory(categoryName)
        if (success) {
            appWindow.showToast("Categoría eliminada: " + categoryName)
            refreshCategories()
        } else {
            appWindow.showToast("No se puede eliminar (tiene productos)", true)
        }
    }

    function createSinCategoria() {
        // Crear la categoría SinCategoría si no existe
        var exists = false
        for (var i = 0; i < categoriesModel.length; i++) {
            if (categoriesModel[i].category === "SinCategoría") {
                exists = true
                break
            }
        }

        if (!exists) {
            var success = AppController.addCategory("SinCategoría")
            if (success) {
                appWindow.showToast("Categoría 'SinCategoría' creada")
                refreshCategories()
            }
        }
    }

    // Verificar si existe SinCategoría
    function hasSinCategoria() {
        for (var i = 0; i < categoriesModel.length; i++) {
            if (categoriesModel[i].category === "SinCategoría") {
                return true
            }
        }
        return false
    }
}