import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Control de Calidad"
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
                title: "Checklist de Verificación"
                subtitle: "Revise antes de la entrega"

                content: ColumnLayout {
                    spacing: Theme.spacingMd

                    Repeater {
                        model: [
                            "Verificar envoltura y embalaje",
                            "Comprobar funcionamiento del equipo",
                            "Revisar fecha de caducidad (si aplica)",
                            "Confirmar cantidad y productos",
                            "Etiquetar correctamente"
                        ]

                        delegate: RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingSm

                            CheckBox {
                                id: checkBox
                            }

                            Label {
                                text: modelData
                                font.pixelSize: 14
                                color: checkBox.checked ? Theme.textSecondary : Theme.textPrimary
                                Layout.fillWidth: true
                            }
                        }
                    }

                    CustomButton {
                        Layout.fillWidth: true
                        text: "Marcar como Verificado"
                        type: 2
                        onClicked: appWindow.showToast("Control de calidad completado")
                    }
                }
            }
        }
    }
}
