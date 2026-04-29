import QtQuick
import QtQuick.Controls
import ".."

Rectangle {
    id: badge
    property string status: "pendiente"
    property string label: status.toUpperCase()

    implicitWidth: textLabel.implicitWidth + 16
    implicitHeight: 24
    radius: 12
    color: {
        switch(status) {
            case "pendiente": return "#FFF3E0"
            case "facturado": return "#E3F2FD"
            case "preparado": return "#F3E5F5"
            case "en_transito": return "#E0F7FA"
            case "entregado": return "#E8F5E9"
            case "liquidado": return "#E8F5E9"
            default: return "#F5F5F5"
        }
    }
    border.width: 1
    border.color: Theme.statusColor(status)

    Label {
        id: textLabel
        anchors.centerIn: parent
        text: badge.label
        font.pixelSize: 11
        font.weight: Font.Medium
        color: Theme.statusColor(status)
    }
}
