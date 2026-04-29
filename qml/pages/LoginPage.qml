import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"
import ".."

Page {
    id: loginPage
    background: Rectangle { color: Theme.background }

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(420, parent.width - 64)
        spacing: Theme.spacingLg

        // Logo area
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.spacingSm

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 80
                height: 80
                radius: 40
                color: Theme.primary

                Label {
                    anchors.centerIn: parent
                    text: "505"
                    font.pixelSize: 28
                    font.weight: Font.Bold
                    color: "white"
                }
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: "Sistema 505 X HORA"
                font.pixelSize: 24
                font.weight: Font.Bold
                color: Theme.textPrimary
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: "Gestión de ventas y operaciones"
                font.pixelSize: 14
                color: Theme.textSecondary
            }
        }

        // Login form
        CustomCard {
            Layout.fillWidth: true
            title: "Iniciar Sesión"
            elevation: 2

            content: ColumnLayout {
                spacing: Theme.spacingMd

                CustomTextField {
                    id: usernameField
                    Layout.fillWidth: true
                    label: "Usuario"
                    placeholder: "Ingrese su usuario"
                    required: true

                    // Reset error on text change
                    onTextChanged: function() {
                        usernameField.showError = false
                        usernameField.errorText = ""
                    }
                }

                CustomTextField {
                    id: passwordField
                    Layout.fillWidth: true
                    label: "Contraseña"
                    placeholder: "Ingrese su contraseña"
                    echoMode: TextInput.Password
                    showTogglePassword: true
                    required: true

                    // Reset error on text change
                    onTextChanged: function() {
                        passwordField.showError = false
                        passwordField.errorText = ""
                    }
                }

                CustomButton {
                    Layout.fillWidth: true
                    text: "Entrar"
                    type: 2
                    onClicked: attemptLogin()
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Usuarios: admin | comercial1 | almacen1 | mensajero1 | custodio1"
                    font.pixelSize: 11
                    color: Theme.textSecondary
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Contraseñas: admin505 | comercial1 | almacen1 | mensajero1 | custodio1"
                    font.pixelSize: 11
                    color: Theme.warning
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: "© 2025 505 X HORA - Sistema de Gestión"
            font.pixelSize: 12
            color: Theme.textDisabled
        }
    }

    function attemptLogin() {
        if (usernameField.text === "" || passwordField.text === "") {
            if (usernameField.text === "") {
                usernameField.showError = true
                usernameField.errorText = "El usuario es requerido"
            } else {
                usernameField.showError = false
            }
            if (passwordField.text === "") {
                passwordField.showError = true
                passwordField.errorText = "La contraseña es requerida"
            } else {
                passwordField.showError = false
            }
            return
        }
        UserManager.login(usernameField.text, passwordField.text)
    }
}