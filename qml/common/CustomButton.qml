import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import ".."

Button {
    id: control
    property bool destructive: false
    property bool outline: false
    property int type: 0 // 0=default, 1=primary, 2=accent

    implicitWidth: Math.max(120, contentItem.implicitWidth + 32)
    implicitHeight: 44

    font.pixelSize: 14
    font.weight: Font.Medium

    background: Rectangle {
        implicitWidth: control.implicitWidth
        implicitHeight: control.implicitHeight
        radius: Theme.radiusMd
        color: {
            if (destructive) return control.down ? "#C62828" : "#F44336"
            if (outline) return "transparent"
            if (type === 1) return control.down ? Theme.primaryDark : Theme.primary
            if (type === 2) return control.down ? Theme.accentDark : Theme.accent
            return control.down ? "#BDBDBD" : "#E0E0E0"
        }
        border.width: outline ? 1 : 0
        border.color: destructive ? "#F44336" : (type === 1 ? Theme.primary : Theme.accent)

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    contentItem: Text {
        text: control.text
        font: control.font
        color: {
            if (destructive) return "white"
            if (outline) return (type === 1 ? Theme.primary : (type === 2 ? Theme.accent : Theme.textPrimary))
            if (type === 0) return Theme.textPrimary
            return "white"
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
