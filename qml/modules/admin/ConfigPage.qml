import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Configuración"
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
                title: "Datos de la Empresa"

                content: ColumnLayout {
                    spacing: Theme.spacingMd

                    CustomTextField {
                        id: companyNameField
                        Layout.fillWidth: true
                        label: "Nombre de la Empresa"
                        text: "505 X HORA"
                    }

                    CustomTextField {
                        id: companyAddressField
                        Layout.fillWidth: true
                        label: "Dirección"
                    }

                    CustomTextField {
                        id: companyPhoneField
                        Layout.fillWidth: true
                        label: "Teléfono"
                    }

                    CustomButton {
                        Layout.fillWidth: true
                        text: "Guardar"
                        type: 2
                        onClicked: {
                            AppController.updateConfig("empresa_nombre", companyNameField.text)
                            AppController.updateConfig("empresa_direccion", companyAddressField.text)
                            AppController.updateConfig("empresa_telefono", companyPhoneField.text)
                            appWindow.showToast("Configuración guardada")
                        }
                    }
                }
            }

            CustomCard {
                Layout.fillWidth: true
                title: "Horarios de Operación"

                content: ColumnLayout {
                    spacing: Theme.spacingMd

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "Atención al Cliente:"
                            font.pixelSize: 14
                            color: Theme.textSecondary
                            Layout.fillWidth: true
                        }
                        Label {
                            text: "09:00 - 16:00"
                            font.pixelSize: 14
                            color: Theme.textPrimary
                            font.weight: Font.Medium
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "Jornada Laboral:"
                            font.pixelSize: 14
                            color: Theme.textSecondary
                            Layout.fillWidth: true
                        }
                        Label {
                            text: "08:30 - 17:00"
                            font.pixelSize: 14
                            color: Theme.textPrimary
                            font.weight: Font.Medium
                        }
                    }

                    Label {
                        text: "Mantenimiento de transporte: Sábados"
                        font.pixelSize: 13
                        color: Theme.warning
                        Layout.fillWidth: true
                    }
                }
            }

            CustomCard {
                Layout.fillWidth: true
                title: "Gestión de Usuarios"

                content: ColumnLayout {
                    spacing: Theme.spacingMd

                    CustomButton {
                        Layout.fillWidth: true
                        text: "Ver Usuarios"
                        type: 1
                        onClicked: appWindow.showToast("Gestión de usuarios - en desarrollo")
                    }
                }
            }
        }
    }
}
