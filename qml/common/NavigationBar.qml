import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Rectangle {
    id: navBar
    property string pageTitle: ""
    property bool showBack: false
    property var actions: []

    height: 56
    color: Theme.primary

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingMd
        anchors.rightMargin: Theme.spacingMd
        spacing: Theme.spacingSm

        ToolButton {
            visible: navBar.showBack
            text: "←"
            font.pixelSize: 20
            onClicked: appWindow.goBack()
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: parent.down ? Qt.rgba(1,1,1,0.2) : "transparent"
                radius: 20
            }
        }

        Label {
            text: navBar.pageTitle
            font.pixelSize: 20
            font.weight: Font.Medium
            color: "white"
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        Row {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            spacing: Theme.spacingSm

            Repeater {
                model: navBar.actions
                delegate: ToolButton {
                    text: modelData.text || ""
                    onClicked: modelData.action ? modelData.action() : undefined

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.down ? Qt.rgba(1,1,1,0.2) : Qt.rgba(1,1,1,0.1)
                        radius: Theme.radiusSm
                    }
                }
            }
        }
    }
}
