import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Categorías de Productos"
        showBack: true
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

        // Lista de categorías existentes
        CustomCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Categorías Existentes"

            content: ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: ProductManager.getCategories()
                clip: true

                delegate: ItemDelegate {
                    width: ListView.view.width
                    contentItem: RowLayout {
                        Label {
                            text: modelData.category
                            font.pixelSize: 14
                            color: Theme.textPrimary
                            Layout.fillWidth: true
                        }
                        Label {
                            text: modelData.count + " productos"
                            font.pixelSize: 12
                            color: Theme.textSecondary
                        }
                    }
                }
            }
        }
    }

    function addCategory() {
        var newCategory = newCategoryField.text.trim()

        if (!newCategory || newCategory === "") {
            appWindow.showToast("Ingrese el nombre de la categoría", true)
            return
        }

        // Llamar al método para agregar categoría
        var success = AppController.addCategory(newCategory)

        if (success) {
            appWindow.showToast("Categoría agregada: " + newCategory)
            newCategoryField.text = ""
            // Refrescar la lista
            ProductManager.refreshProducts()
        } else {
            appWindow.showToast("Error al agregar categoría", true)
        }
    }
}