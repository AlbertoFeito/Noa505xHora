import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import "common"
import "pages"
import "."

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1280
    height: 800
    title: qsTr("Sistema 505 X HORA")
    minimumWidth: 1024
    minimumHeight: 768

    // Material Design theme
    Material.theme: Material.Light
    Material.primary: Material.BlueGrey
    Material.accent: Material.Teal
    Material.foreground: "#212121"

    // Estado de la app
    property bool isLoggedIn: UserManager.isLoggedIn
    property string currentRole: UserManager.currentUser.role || ""
    property var currentUser: UserManager.currentUser

    onIsLoggedInChanged: {
        if (isLoggedIn) {
            stackView.clear()
            stackView.push(Qt.resolvedUrl("pages/DashboardPage.qml"))
        } else {
            stackView.clear()
            stackView.push(Qt.resolvedUrl("pages/LoginPage.qml"))
        }
    }

    Connections {
        target: UserManager
        function onLoginSuccess() {
            showToast("Bienvenido, " + UserManager.currentUser.fullName)
        }
        function onLoginFailed(error) {
            showToast(error, true)
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: LoginPage {}
    }

    // Toast notification
    Rectangle {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        width: toastLabel.implicitWidth + 48
        height: 48
        radius: 24
        color: toastIsError ? "#D32F2F" : "#323232"
        opacity: toastTimer.running ? 1 : 0
        visible: opacity > 0

        property bool toastIsError: false

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        Label {
            id: toastLabel
            anchors.centerIn: parent
            text: ""
            color: "white"
            font.pixelSize: 14
        }

        Timer {
            id: toastTimer
            interval: 3000
            onTriggered: toast.opacity = 0
        }
    }

    function showToast(message, isError = false) {
        toastLabel.text = message
        toast.toastIsError = isError
        toast.opacity = 1
        toastTimer.restart()
    }

    function navigateTo(page, props) {
        stackView.push(Qt.resolvedUrl(page), props || {})
    }

    function goBack() {
        if (stackView.depth > 1) stackView.pop()
    }
}
