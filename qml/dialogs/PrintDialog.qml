import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"
import ".."

Dialog {
    id: dialog
    title: "Imprimir Documento"
    modal: true
    width: 450
    anchors.centerIn: parent
    standardButtons: Dialog.Ok | Dialog.Cancel

    property string documentType: "factura"
    property int documentId: 0

    contentItem: ColumnLayout {
        spacing: Theme.spacingMd

        Label {
            text: "Tipo: " + dialog.documentType.toUpperCase()
            font.pixelSize: 14
            color: Theme.textSecondary
        }

        Label {
            text: "Seleccione la impresora y presione OK para imprimir."
            font.pixelSize: 13
            color: Theme.textSecondary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        ComboBox {
            Layout.fillWidth: true
            model: ["Impresora Principal", "Impresora Térmica (58mm)", "Impresora Térmica (80mm)"]
        }
    }
}
