import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Comisiones"
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
                title: "Reporte de Comisiones"

                content: ColumnLayout {
                    Label {
                        text: "Desempeño de Mensajeros"
                        font.pixelSize: 16
                        font.weight: Font.Medium
                        color: Theme.textPrimary
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 300
                        model: ReportManager.getMessengerPerformance(
                            new Date(new Date().setDate(1)),
                            new Date()
                        )
                        clip: true

                        delegate: ItemDelegate {
                            width: ListView.view.width
                            contentItem: RowLayout {
                                Label {
                                    text: modelData.messengerName
                                    font.pixelSize: 14
                                    color: Theme.textPrimary
                                    Layout.fillWidth: true
                                }
                                Label {
                                    text: modelData.deliveries + " entregas"
                                    font.pixelSize: 12
                                    color: Theme.textSecondary
                                }
                                Label {
                                    text: modelData.commissionTotal.toFixed(2) + " CUP"
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    color: Theme.accent
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
