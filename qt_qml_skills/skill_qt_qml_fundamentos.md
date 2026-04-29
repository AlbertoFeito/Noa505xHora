# Skill: qt-qml-fundamentos

## description
Fundamentos completos de Qt/QML: sintaxis, elementos básicos, propiedades, señales, estados y animaciones. Basado en Qt6 QML Book y repositorios oficiales.

## context
- **Framework**: Qt 6.x / Qt 5.15+
- **Lenguaje**: QML (Qt Meta Language) + JavaScript
- **Backend**: C++ con Qt
- **Plataformas**: Desktop (Windows/Linux/macOS), Mobile (Android/iOS), Embedded, WebAssembly

## patterns

### Estructura básica de archivo QML
```qml
import QtQuick
import QtQuick.Controls

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Button {
        text: "Click me"
        anchors.centerIn: parent
        onClicked: console.log("Clicked!")
    }
}
```

### Propiedades y bindings
```qml
Rectangle {
    id: root
    width: 200
    height: width * 0.75  // Binding automático
    color: mouseArea.pressed ? "red" : "blue"

    MouseArea {
        id: mouseArea
        anchors.fill: parent
    }
}
```

### Señales y handlers
```qml
Item {
    signal userClicked(string name, int age)

    Component.onCompleted: {
        userClicked.connect(function(name, age) {
            console.log("User:", name, "Age:", age)
        })
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.userClicked("John", 25)
    }
}
```

### Estados y transiciones
```qml
Rectangle {
    id: box
    width: 100; height: 100
    color: "red"

    states: [
        State {
            name: "expanded"
            PropertyChanges { target: box; width: 200; height: 200; color: "blue" }
        }
    ]

    transitions: [
        Transition {
            from: ""; to: "expanded"
            NumberAnimation { properties: "width,height"; duration: 500 }
            ColorAnimation { duration: 300 }
        }
    ]

    MouseArea {
        anchors.fill: parent
        onClicked: box.state = box.state === "expanded" ? "" : "expanded"
    }
}
```

### Animaciones
```qml
// Animación básica
NumberAnimation on opacity {
    from: 0; to: 1
    duration: 1000
    easing.type: Easing.InOutQuad
}

// Animación secuencial
SequentialAnimation {
    NumberAnimation { target: rect; property: "x"; to: 100; duration: 500 }
    NumberAnimation { target: rect; property: "y"; to: 100; duration: 500 }
    RotationAnimation { target: rect; to: 360; duration: 1000 }
}

// Behavior (animación automática al cambiar propiedad)
Behavior on x {
    SpringAnimation { spring: 2; damping: 0.2 }
}
```

### Componentes reutilizables
```qml
// CustomButton.qml
import QtQuick
import QtQuick.Controls

Button {
    id: control
    property color accentColor: "#2196F3"

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 40
        color: control.down ? Qt.darker(control.accentColor, 1.2) : control.accentColor
        radius: 4

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    contentItem: Text {
        text: control.text
        font: control.font
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
```

## best_practices
- Usar `id` descriptivos y únicos por archivo
- Preferir `anchors` sobre `x/y` para layouts responsivos
- Usar `property alias` para exponer propiedades internas
- Implementar `Component.onCompleted` para inicialización
- Usar `qsTr()` para todas las cadenas visibles (internacionalización)
- Separar lógica de presentación: QML para UI, C++ para lógica de negocio
- Evitar lógica compleja en QML; usar funciones JavaScript solo para UI
- Usar `QtObject` para propiedades internas que no necesitan ser elementos visuales

## common_mistakes
- Modificar propiedades de `id` desde fuera sin usar signals/slots
- Olvidar `anchors.fill: parent` en MouseArea
- Usar `var` en lugar de tipos específicos (`int`, `real`, `string`)
- Crear bindings circulares (A depende de B y B depende de A)
- No manejar `Component.onDestruction` para cleanup
- Usar `eval()` o `with` en JavaScript de QML

## references
- [Qt6 QML Book](https://github.com/qmlbook/qmlbook)
- [QML Coding Guidelines](https://wiki.qt.io/QML_Coding_Conventions)
- [Qt Quick Documentation](https://doc.qt.io/qt-6/qtquick-index.html)
