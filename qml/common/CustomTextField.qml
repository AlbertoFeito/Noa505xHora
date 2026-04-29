import QtQuick
import QtQuick.Controls
import ".."

// TextField con label flotante estilo Material Design
TextField {
    id: control

    property string label: "Etiqueta"        // Label principal
    property string placeholder: "Escriba..." // Placeholder cuando está vacío
    property bool required: false
    property string errorText: ""
    property bool showError: false
    property bool showTogglePassword: false

    // Configuración visual - AUMENTADA para mejor espaciado
    height: 64
    topPadding: 24        // Espacio para label flotante (antes 12)
    bottomPadding: 8      // Espacio para error text
    leftPadding: 16
    rightPadding: showTogglePassword ? 44 : 16
    font.pixelSize: 16

    // Placeholder nativo - solo cuando está vacío y sin foco
    placeholderText: control.text === "" && !control.activeFocus ? placeholder : ""
    placeholderTextColor: Theme.textDisabled

    // Color del texto
    color: Theme.textPrimary
    selectedTextColor: "white"
    selectionColor: Theme.accent

    // Fondo con borde
    background: Rectangle {
        radius: 4
        color: control.enabled ? Theme.surface : "#F5F5F5"
        border.width: control.activeFocus || showError ? 2 : 1
        border.color: showError ? Theme.error : (control.activeFocus ? Theme.accent : Theme.divider)
    }

    // Label flotante - posición ajustada
    Text {
        id: labelText
        text: control.label + (control.required ? " *" : "")
        font.pixelSize: control.activeFocus || control.text !== "" ? 10 : 14
        color: showError ? Theme.error : (control.activeFocus ? Theme.accent : Theme.textSecondary)

        // Posición del label - ajustada para no solaparse
        x: 16
        y: control.activeFocus || control.text !== "" ? 6 : 20

        // Animación de movimiento
        Behavior on y {
            NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
        }
        Behavior on font.pixelSize {
            NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
        }

        // Siempre visible si hay label definido
        visible: control.label !== ""
    }

    // Error text - posición ajustada debajo del campo
    Text {
        text: errorText
        font.pixelSize: 10
        color: Theme.error
        visible: showError && errorText !== ""
        x: 16
        y: control.height - 2  // Justo debajo del campo
    }

    // Botón de toggle password (mantener presionado para ver)
    MouseArea {
        visible: showTogglePassword
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 32
        height: 32

        onPressedChanged: {
            control.echoMode = pressed ? TextInput.Normal : TextInput.Password
        }

        Text {
            text: control.echoMode === TextInput.Password ? "👁" : "🔒"
            font.pixelSize: 16
            anchors.centerIn: parent
        }
    }
}
