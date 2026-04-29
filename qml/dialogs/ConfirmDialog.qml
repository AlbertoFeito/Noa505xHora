import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"
import ".."

Dialog {
    id: dialog
    title: "Confirmar Acción"
    modal: true
    width: 400
    anchors.centerIn: parent
    standardButtons: Dialog.Yes | Dialog.No

    property string message: "¿Está seguro?"

    contentItem: Label {
        text: dialog.message
        font.pixelSize: 14
        color: Theme.textPrimary
        wrapMode: Text.WordWrap
    }
}
