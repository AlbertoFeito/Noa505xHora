import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"
import ".."

Page {
    id: profilePage
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Perfil de Usuario"
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
                title: UserManager.currentUser.fullName || "Usuario"
                subtitle: roleLabel(UserManager.currentUser.role || "")

                content: ColumnLayout {
                    spacing: Theme.spacingMd

                    RowLayout {
                        Label { text: "Usuario:"; font.pixelSize: 14; color: Theme.textSecondary }
                        Label { text: UserManager.currentUser.username || ""; font.pixelSize: 14; color: Theme.textPrimary; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                    }

                    RowLayout {
                        Label { text: "Teléfono:"; font.pixelSize: 14; color: Theme.textSecondary }
                        Label { text: UserManager.currentUser.phone || "No especificado"; font.pixelSize: 14; color: Theme.textPrimary; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                    }

                    RowLayout {
                        Label { text: "Email:"; font.pixelSize: 14; color: Theme.textSecondary }
                        Label { text: UserManager.currentUser.email || "No especificado"; font.pixelSize: 14; color: Theme.textPrimary; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                    }
                }
            }

            CustomCard {
                Layout.fillWidth: true
                title: "Horarios"

                content: ColumnLayout {
                    spacing: Theme.spacingSm

                    RowLayout {
                        Label { text: "Atención al Cliente:"; font.pixelSize: 14; color: Theme.textSecondary; Layout.fillWidth: true }
                        Label { text: "09:00 - 16:00"; font.pixelSize: 14; color: Theme.textPrimary; font.weight: Font.Medium }
                    }

                    RowLayout {
                        Label { text: "Jornada Laboral:"; font.pixelSize: 14; color: Theme.textSecondary; Layout.fillWidth: true }
                        Label { text: "08:30 - 17:00"; font.pixelSize: 14; color: Theme.textPrimary; font.weight: Font.Medium }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Theme.divider
                    }

                    Label {
                        text: "Recuerde: El cuadre final debe realizarse antes de las 17:00"
                        font.pixelSize: 12
                        color: Theme.warning
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }

            CustomButton {
                Layout.fillWidth: true
                text: "Cerrar Sesión"
                destructive: true
                onClicked: UserManager.logout()
            }
        }
    }

    function roleLabel(role) {
        switch(role) {
            case "comercial": return "Departamento Comercial"
            case "almacen": return "Encargado de Almacén"
            case "mensajero": return "Mensajero / Ayudante"
            case "custodio": return "Custodio"
            case "administrador": return "Administrador / Propietario"
            default: return role
        }
    }
}
