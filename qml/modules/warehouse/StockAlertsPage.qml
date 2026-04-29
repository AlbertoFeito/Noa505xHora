import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../.."

Page {
    id: page
    background: Rectangle { color: Theme.background }

    header: NavigationBar {
        pageTitle: "Alertas de Stock"
        showBack: true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        CustomCard {
            Layout.fillWidth: true
            title: "Productos Bajo Stock Mínimo"
            subtitle: ProductManager.lowStockCount + " alertas"

            content: ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: ProductManager.getLowStockProducts()
                clip: true

                delegate: ItemDelegate {
                    width: ListView.view.width
                    contentItem: RowLayout {
                        Label {
                            text: modelData.name
                            font.pixelSize: 14
                            color: Theme.textPrimary
                            Layout.fillWidth: true
                        }
                        Label {
                            text: modelData.stock + " / " + modelData.minStock + " mín."
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: Theme.error
                        }
                    }
                }
            }
        }
    }
}
