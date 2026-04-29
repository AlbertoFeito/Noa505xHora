import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Rectangle {
    id: card
    property string title: ""
    property string subtitle: ""
    property color cardColor: Theme.surface
    property real elevation: 1
    property alias content: contentArea.children
    property alias headerActions: headerActionsArea.children

    width: parent ? parent.width : 300
    height: implicitHeight
    color: cardColor
    radius: Theme.radiusMd

    implicitHeight: header.height + contentArea.height + (title ? Theme.spacingMd : 0) + Theme.spacingMd

    // Shadow effect using borders
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: parent.radius
        border.width: elevation
        border.color: elevation > 0 ? Qt.rgba(0,0,0, elevation * 0.05) : "transparent"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingSm

        RowLayout {
            id: header
            Layout.fillWidth: true
            visible: title !== ""
            spacing: Theme.spacingSm

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Label {
                    text: card.title
                    font.pixelSize: 18
                    font.weight: Font.Medium
                    color: Theme.textPrimary
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Label {
                    text: card.subtitle
                    font.pixelSize: 12
                    color: Theme.textSecondary
                    visible: card.subtitle !== ""
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            Row {
                id: headerActionsArea
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }
        }

        Rectangle {
            id: divider
            Layout.fillWidth: true
            height: 1
            color: Theme.divider
            visible: title !== ""
        }

        ColumnLayout {
            id: contentArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.spacingSm
        }
    }
}
