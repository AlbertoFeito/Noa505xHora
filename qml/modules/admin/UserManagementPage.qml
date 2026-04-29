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

    // Refrescar lista
    function refreshList() {
        userListView.model = UserManager.getAllUsers()
    }

    // Filtrar usuarios
    function getFilteredUsers() {
        var allUsers = UserManager.getAllUsers()
        var filtered = []

        for (var i = 0; i < allUsers.length; i++) {
            var user = allUsers[i]

            // Filtro por rol
            if (filterRole !== "todos" && user.role !== filterRole) {
                continue
            }

            // Filtro por estado
            if (!showInactive && !user.isActive) {
                continue
            }

            filtered.push(user)
        }
        return filtered
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

                ColumnLayout {
                    Layout.preferredWidth: 150

                    Label {
                        text: "Rol"
                        font.pixelSize: 11
                        color: Theme.textSecondary
                    }

                    ComboBox {
                        id: roleFilter
                        Layout.fillWidth: true
                        model: ["todos", "administrador", "comercial", "almacen", "mensajero", "custodio"]
                        onCurrentTextChanged: {
                            filterRole = currentText
                            refreshList()
                        }
                    }
                }

                ColumnLayout {
                    Layout.preferredWidth: 150

                    Label {
                        text: "Estado"
                        font.pixelSize: 11
                        color: Theme.textSecondary
                    }

                    ComboBox {
                        id: statusFilter
                        Layout.fillWidth: true
                        model: ["Todos", "Solo activos", "Solo inactivos"]
                        onCurrentIndexChanged: {
                            if (currentIndex === 0) {
                                showInactive = true
                            } else if (currentIndex === 1) {
                                showInactive = false
                            } else {
                                showInactive = true
                                // TODO: filtrar solo inactivos
                            }
                            refreshList()
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                CustomButton {
                    text: "🔄 Actualizar"
                    type: 1
                    onClicked: refreshList()
                }
            }
        }

        // Lista de usuarios
        CustomCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Usuarios (" + getFilteredUsers().length + ")"

            content: ListView {
                id: userListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: getFilteredUsers()
                clip: true

                delegate: ItemDelegate {
                    width: ListView.view.width
                    onClicked: showUserDialog(modelData)

                    contentItem: ColumnLayout {
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                RowLayout {
                                    Label {
                                        text: modelData.fullName || modelData.username
                                        font.pixelSize: 15
                                        font.weight: Font.Medium
                                        color: Theme.textPrimary
                                    }
                                    Label {
                                        text: modelData.isActive ? "🟢" : "🔴"
                                        font.pixelSize: 12
                                    }
                                }

                                Label {
                                    text: "@" + modelData.username + " | " + modelData.role
                                    font.pixelSize: 12
                                    color: Theme.textSecondary
                                }

                                Label {
                                    text: (modelData.phone || "") + " | " + (modelData.email || "")
                                    font.pixelSize: 11
                                    color: Theme.textDisabled
                                    visible: modelData.phone || modelData.email
                                }
                            }

                            ColumnLayout {
                                spacing: 6

                                // Botones de acción
                                RowLayout {
                                    CustomButton {
                                        text: "✏️ Editar"
                                        type: 0
                                        onClicked: {
                                            page.editingUser = modelData
                                            userDialog.open()
                                        }
                                    }

                                    CustomButton {
                                        text: modelData.isActive ? "🛇 Desactivar" : "✅ Activar"
                                        type: modelData.isActive ? 3 : 1
                                        onClicked: toggleUser(modelData.id, modelData.isActive)
                                    }

                                    CustomButton {
                                        text: "🗑️ Eliminar"
                                        type: 3
                                        onClicked: confirmDelete(modelData)
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
        width: 420
        height: 520
        modal: true
        anchors.centerIn: parent

        onOpened: {
            if (page.editingUser) {
                usernameField.text = page.editingUser.username
                passwordField.text = ""
                fullNameField.text = page.editingUser.fullName
                phoneField.text = page.editingUser.phone || ""
                emailField.text = page.editingUser.email || ""
                roleCombo.currentIndex = Math.max(0, roleCombo.model.indexOf(page.editingUser.role))
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

            // Usuario
            ColumnLayout {
                Label {
                    text: "Usuario *"
                    font.pixelSize: 11
                    color: Theme.textSecondary
                }
                CustomTextField {
                    id: usernameField
                    Layout.fillWidth: true
                    label: ""
                    placeholder: "Nombre de usuario"
                }
            }

            // Contraseña
            ColumnLayout {
                Label {
                    text: page.editingUser ? "Contraseña (dejar vacío para mantener)" : "Contraseña *"
                    font.pixelSize: 11
                    color: Theme.textSecondary
                }
                CustomTextField {
                    id: passwordField
                    Layout.fillWidth: true
                    label: ""
                    placeholder: "Contraseña"
                    showTogglePassword: true
                }
            }

            // Nombre completo
            ColumnLayout {
                Label {
                    text: "Nombre Completo *"
                    font.pixelSize: 11
                    color: Theme.textSecondary
                }
                CustomTextField {
                    id: fullNameField
                    Layout.fillWidth: true
                    label: ""
                    placeholder: "Nombre completo"
                }
            }

            // Teléfono y Email
            RowLayout {
                ColumnLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "Teléfono"
                        font.pixelSize: 11
                        color: Theme.textSecondary
                    }
                    CustomTextField {
                        id: phoneField
                        Layout.fillWidth: true
                        label: ""
                        placeholder: "Teléfono"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "Email"
                        font.pixelSize: 11
                        color: Theme.textSecondary
                    }
                    CustomTextField {
                        id: emailField
                        Layout.fillWidth: true
                        label: ""
                        placeholder: "Email"
                    }
                }
            }

            // Rol
            ColumnLayout {
                Label {
                    text: "Rol"
                    font.pixelSize: 11
                    color: Theme.textSecondary
                }
                ComboBox {
                    id: roleCombo
                    Layout.fillWidth: true
                    model: UserManager.availableRoles()
                    Layout.preferredWidth: 200
                }
            }

            // Botones
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: Theme.spacingMd

                CustomButton {
                    text: "Cancelar"
                    type: 0
                    onClicked: userDialog.close()
                }

                CustomButton {
                    text: page.editingUser ? "💾 Guardar" : "➕ Crear"
                    type: 2
                    onClicked: saveUser()
                }
            }
        }
    }

    // Dialog de confirmación eliminar
    Dialog {
        id: confirmDeleteDialog
        title: "Confirmar Eliminación"
        width: 350
        anchors.centerIn: parent
        modal: true

        property var userToDelete: null

        ColumnLayout {
            spacing: Theme.spacingMd

            Label {
                text: "¿Está seguro de eliminar al usuario?"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Label {
                text: userToDelete ? (userToDelete.fullName || userToDelete.username) : ""
                font.weight: Font.Bold
                color: Theme.error
            }

            Label {
                text: "Esta acción no se puede deshacer."
                color: Theme.textSecondary
                font.pixelSize: 12
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight

                CustomButton {
                    text: "Cancelar"
                    type: 0
                    onClicked: confirmDeleteDialog.close()
                }

                CustomButton {
                    text: "🗑️ Eliminar"
                    type: 3
                    onClicked: {
                        if (confirmDeleteDialog.userToDelete) {
                            UserManager.deleteUser(confirmDeleteDialog.userToDelete.id)
                            refreshList()
                        }
                        confirmDeleteDialog.close()
                    }
                }
            }
        }
    }

    function showUserDialog(user = null) {
        page.editingUser = user
        userDialog.open()
    }

    function confirmDelete(user) {
        confirmDeleteDialog.userToDelete = user
        confirmDeleteDialog.open()
    }

    function saveUser() {
        if (!usernameField.text || !fullNameField.text) {
            return
        }

        var success
        if (page.editingUser) {
            // Editar
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
            // Crear
            if (!passwordField.text) {
                passwordField.text = "123456" // Default
            }
            success = UserManager.addUser(
                usernameField.text,
                passwordField.text,
                fullNameField.text,
                roleCombo.currentText,
                phoneField.text
            )
        }

        if (success) {
            userDialog.close()
            page.editingUser = null
            refreshList()
        }
    }

    function toggleUser(userId, isActive) {
        if (isActive) {
            // Desactivar
            UserManager.deactivateUser(userId)
        } else {
            // Reactivar
            var fields = {"isActive": true}
            UserManager.updateUser(userId, fields)
        }
        refreshList()
    }

    Component.onCompleted: refreshList()
}