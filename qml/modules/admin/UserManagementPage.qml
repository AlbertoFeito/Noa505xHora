import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    // Estado
    property string filterRole: "todos"
    property bool showInactive: false
    property var editingUser: null

    header: NavigationBar {
        pageTitle: "Gestión de Usuarios"
        showBack: true
        actions: [
            {
                text: "➕",
                action: function() { page.editingUser = null; userDialog.open() }
            }
        ]
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        // Filtros
        CustomCard {
            Layout.fillWidth: true
            title: "Filtros"

            content: RowLayout {
                spacing: Theme.spacingMd

                ComboBox {
                    id: roleFilter
                    Layout.preferredWidth: 150
                    model: ["todos", "administrador", "comercial", "almacen", "mensajero", "custodio"]
                    onCurrentTextChanged: filterRole = currentText
                }

                CheckBox {
                    id: inactiveCheck
                    text: "Mostrar inactivos"
                    onCheckedChanged: showInactive = checked
                }

                Item { Layout.fillWidth: true }

                CustomButton {
                    text: "Actualizar"
                    type: 1
                    onClicked: userListView.forceLayout()
                }
            }
        }

        // Lista de usuarios
        CustomCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Usuarios (" + UserManager.rowCount() + ")"

            content: ListView {
                id: userListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: UserManager.getAllUsers()
                clip: true

                delegate: ItemDelegate {
                    width: ListView.view.width
                    onClicked: showUserDialog(modelData)

                    contentItem: ColumnLayout {
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true

                            ColumnLayout {
                                Layout.fillWidth: true

                                Label {
                                    text: modelData.fullName || modelData.username
                                    font.pixelSize: 15
                                    font.weight: Font.Medium
                                    color: Theme.textPrimary
                                }

                                Label {
                                    text: modelData.username + " | " + modelData.role
                                    font.pixelSize: 12
                                    color: Theme.textSecondary
                                }

                                Label {
                                    text: (modelData.phone || "") + " | " + (modelData.email || "")
                                    font.pixelSize: 11
                                    color: Theme.textDisabled
                                }
                            }

                            ColumnLayout {
                                Label {
                                    text: modelData.isActive ? "🟢 Activo" : "🔴 Inactivo"
                                    font.pixelSize: 12
                                    color: modelData.isActive ? Theme.success : Theme.error
                                }

                                RowLayout {
                                    CustomButton {
                                        text: "✏️"
                                        type: 0
                                        onClicked: {
                                            page.editingUser = modelData
                                            userDialog.open()
                                        }
                                    }

                                    CustomButton {
                                        text: modelData.isActive ? "🛇" : "✅"
                                        type: modelData.isActive ? 3 : 1
                                        onClicked: toggleUser(modelData.id, modelData.isActive)
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Theme.divider
                        }
                    }
                }
            }
        }
    }

    // Dialog para crear/editar usuario
    Dialog {
        id: userDialog
        title: page.editingUser ? "Editar Usuario" : "Nuevo Usuario"
        width: 400

        onOpened: {
            if (page.editingUser) {
                usernameField.text = page.editingUser.username
                passwordField.text = ""
                fullNameField.text = page.editingUser.fullName
                phoneField.text = page.editingUser.phone || ""
                emailField.text = page.editingUser.email || ""
                roleCombo.currentIndex = roleCombo.model.indexOf(page.editingUser.role)
            } else {
                usernameField.text = ""
                passwordField.text = ""
                fullNameField.text = ""
                phoneField.text = ""
                emailField.text = ""
                roleCombo.currentIndex = 1
            }
        }

        ColumnLayout {
            spacing: Theme.spacingMd

            CustomTextField {
                id: usernameField
                label: "Usuario"
                placeholder: "Nombre de usuario"
                required: true
            }

            CustomTextField {
                id: passwordField
                label: "Contraseña"
                placeholder: page.editingUser ? "Dejar vacío para mantener" : "Contraseña"
                showTogglePassword: true
            }

            CustomTextField {
                id: fullNameField
                label: "Nombre Completo"
                placeholder: "Nombre completo"
                required: true
            }

            CustomTextField {
                id: phoneField
                label: "Teléfono"
                placeholder: "Teléfono"
            }

            CustomTextField {
                id: emailField
                label: "Email"
                placeholder: "Email"
            }

            ComboBox {
                id: roleCombo
                model: UserManager.availableRoles()
                currentIndex: 1
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: Theme.spacingMd

                CustomButton {
                    text: "Cancelar"
                    type: 0
                    onClicked: userDialog.close()
                }

                CustomButton {
                    text: page.editingUser ? "Guardar" : "Crear"
                    type: 2
                    onClicked: saveUser()
                }
            }
        }
    }

    function showUserDialog(user = null) {
        page.editingUser = user
        userDialog.open()
    }

    function saveUser() {
        if (!usernameField.text || !fullNameField.text) {
            return
        }

        var success
        if (page.editingUser) {
            var fields = {
                "username": usernameField.text,
                "fullName": fullNameField.text,
                "phone": phoneField.text,
                "email": emailField.text,
                "role": roleCombo.currentText
            }
            if (passwordField.text) {
                fields["password"] = passwordField.text
            }
            success = UserManager.updateUser(page.editingUser.id, fields)
        } else {
            success = UserManager.addUser(
                usernameField.text,
                passwordField.text || "123456",
                fullNameField.text,
                roleCombo.currentText,
                phoneField.text
            )
        }

        if (success) {
            userDialog.close()
            page.editingUser = null
            userListView.forceLayout()
        }
    }

    function toggleUser(userId, isActive) {
        if (isActive) {
            UserManager.deactivateUser(userId)
        } else {
            var fields = {"isActive": true}
            UserManager.updateUser(userId, fields)
        }
        userListView.forceLayout()
    }
}