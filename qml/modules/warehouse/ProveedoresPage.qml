import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Gestión de Proveedores"
        showBack: true
        actions: [
            {
                text: "🔄",
                action: function() { refreshSuppliers() }
            }
        ]
    }

    Component.onCompleted: {
        refreshSuppliers()
    }

    function refreshSuppliers() {
        suppliersModel = AppController.getSuppliersList()
    }

    property var suppliersModel: []

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        // Agregar nuevo proveedor
        CustomCard {
            Layout.fillWidth: true
            title: "Agregar Nuevo Proveedor"

            content: ColumnLayout {
                spacing: Theme.spacingMd

                RowLayout {
                    spacing: Theme.spacingMd

                    CustomTextField {
                        id: newSupplierName
                        Layout.fillWidth: true
                        placeholder: "Nombre del proveedor *"
                    }

                    CustomTextField {
                        id: newSupplierContact
                        Layout.fillWidth: true
                        placeholder: "Persona de contacto"
                    }
                }

                RowLayout {
                    spacing: Theme.spacingMd

                    CustomTextField {
                        id: newSupplierPhone
                        Layout.fillWidth: true
                        placeholder: "Teléfono"
                    }

                    CustomTextField {
                        id: newSupplierEmail
                        Layout.fillWidth: true
                        placeholder: "Email"
                    }
                }

                CustomButton {
                    text: "➕ Agregar Proveedor"
                    type: 2
                    onClicked: addSupplier()
                }
            }
        }

        // Info
        CustomCard {
            Layout.fillWidth: true
            title: "Información"
            elevation: 0

            content: ColumnLayout {
                spacing: Theme.spacingSm

                Label {
                    text: "• Los proveedores se usan al crear productos"
                    font.pixelSize: 12
                    color: Theme.textSecondary
                    wrapMode: Text.WordWrap
                }
                Label {
                    text: "• Puede editar o eliminar proveedores"
                    font.pixelSize: 12
                    color: Theme.textSecondary
                    wrapMode: Text.WordWrap
                }
            }
        }

        // Lista de proveedores
        CustomCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Proveedores Existentes"
            subtitle: suppliersModel.length + " proveedores"

            content: ListView {
                id: supplierList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: suppliersModel
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
                                    text: "Código: " + (modelData.code || "N/A")
                                    font.pixelSize: 11
                                    color: Theme.textSecondary
                                }

                                RowLayout {
                                    spacing: Theme.spacingMd

                                    Label {
                                        text: "📞 " + (modelData.phone || "Sin teléfono")
                                        font.pixelSize: 10
                                        color: Theme.textSecondary
                                        visible: modelData.phone
                                    }

                                    Label {
                                        text: "✉️ " + (modelData.email || "Sin email")
                                        font.pixelSize: 10
                                        color: Theme.textSecondary
                                        visible: modelData.email
                                    }

                                    Label {
                                        text: "👤 " + (modelData.contact_person || "Sin contacto")
                                        font.pixelSize: 10
                                        color: Theme.textSecondary
                                        visible: modelData.contact_person
                                    }
                                }
                            }

                            // Botón editar
                            ToolButton {
                                text: "✏️"
                                onClicked: openEditDialog(modelData)
                            }

                            // Botón eliminar
                            ToolButton {
                                text: "🗑️"
                                onClicked: confirmDelete(modelData)
                            }
                        }
                    }
                }
            }
        }
    }

    function addSupplier() {
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
            // Limpiar campos
            newSupplierName.text = ""
            newSupplierContact.text = ""
            newSupplierPhone.text = ""
            newSupplierEmail.text = ""
            refreshSuppliers()
        } else {
            appWindow.showToast("❌ Error al agregar proveedor", true)
        }
    }

    function confirmDelete(supplier) {
        deleteDialog.supplier = supplier
        deleteDialog.open()
    }

    function deleteSupplier() {
        var supplier = deleteDialog.supplier
        var success = AppController.deleteSupplier(supplier.id)
        if (success) {
            appWindow.showToast("✅ Proveedor eliminado")
            deleteDialog.close()
            refreshSuppliers()
        } else {
            appWindow.showToast("❌ Error al eliminar proveedor", true)
        }
    }

    function openEditDialog(supplier) {
        editDialog.supplier = supplier
        editNameField.text = supplier.name || ""
        editContactField.text = supplier.contact_person || ""
        editPhoneField.text = supplier.phone || ""
        editEmailField.text = supplier.email || ""
        editDialog.open()
    }

    function saveEdit() {
        var supplier = editDialog.supplier
        var success = AppController.updateSupplier(
            supplier.id,
            editNameField.text.trim(),
            editContactField.text.trim(),
            editPhoneField.text.trim(),
            editEmailField.text.trim(),
            ""
        )

        if (success) {
            appWindow.showToast("✅ Proveedor actualizado")
            editDialog.close()
            refreshSuppliers()
        } else {
            appWindow.showToast("❌ Error al actualizar proveedor", true)
        }
    }

    // Dialog para confirmar eliminación
    Dialog {
        id: deleteDialog
        title: "Confirmar Eliminación"
        modal: true
        width: 350
        anchors.centerIn: parent

        property var supplier: null

        contentItem: ColumnLayout {
            spacing: Theme.spacingMd

            Label {
                text: "¿Está seguro que desea eliminar el proveedor \"" + (deleteDialog.supplier ? deleteDialog.supplier.name : "") + "\"?"
                font.pixelSize: 13
                color: Theme.textPrimary
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingMd

                CustomButton {
                    Layout.fillWidth: true
                    text: "Cancelar"
                    type: 1
                    onClicked: deleteDialog.close()
                }

                CustomButton {
                    Layout.fillWidth: true
                    text: "Eliminar"
                    type: 3 // danger
                    onClicked: deleteSupplier()
                }
            }
        }
    }

    // Dialog para editar proveedor
    Dialog {
        id: editDialog
        title: "Editar Proveedor"
        modal: true
        width: 400
        anchors.centerIn: parent

        property var supplier: null

        contentItem: ColumnLayout {
            spacing: Theme.spacingMd

            CustomTextField {
                id: editNameField
                Layout.fillWidth: true
                placeholder: "Nombre *"
            }

            CustomTextField {
                id: editContactField
                Layout.fillWidth: true
                placeholder: "Persona de contacto"
            }

            CustomTextField {
                id: editPhoneField
                Layout.fillWidth: true
                placeholder: "Teléfono"
            }

            CustomTextField {
                id: editEmailField
                Layout.fillWidth: true
                placeholder: "Email"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingMd

                CustomButton {
                    Layout.fillWidth: true
                    text: "Cancelar"
                    type: 1
                    onClicked: editDialog.close()
                }

                CustomButton {
                    Layout.fillWidth: true
                    text: "Guardar"
                    type: 2
                    onClicked: saveEdit()
                }
            }
        }
    }
}