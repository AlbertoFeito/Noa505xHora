# Skill: qt-qml-styling-theming

## description
Estilos, temas y diseño visual en QML: Material Design, Custom Controls, theming dinámico, dark/light mode y recursos gráficos.

## context
- **Frameworks**: Qt Quick Controls 2, Material, Universal, Fusion
- **Librerías**: qml-material, Fluid, Muse Framework
- **Recursos**: Qt Resource System, FontAwesome, SVG

## patterns

### Material Design básico
```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

ApplicationWindow {
    visible: true
    width: 400; height: 600

    // Configuración Material
    Material.theme: Material.Dark
    Material.accent: Material.Purple
    Material.primary: Material.BlueGrey
    Material.foreground: "white"
    Material.background: "#121212"

    Column {
        anchors.centerIn: parent
        spacing: 20

        Button {
            text: "Primary Action"
            highlighted: true
        }

        Button {
            text: "Secondary Action"
            flat: true
        }

        Slider {
            from: 0; to: 100; value: 50
            Material.accent: Material.Orange
        }
    }
}
```

### Sistema de temas personalizado
```qml
// Theme.qml (Singleton)
pragma Singleton
import QtQuick

QtObject {
    property bool darkMode: false

    property color primary: darkMode ? "#BB86FC" : "#6200EE"
    property color primaryVariant: darkMode ? "#3700B3" : "#3700B3"
    property color secondary: darkMode ? "#03DAC6" : "#03DAC6"
    property color background: darkMode ? "#121212" : "#FFFFFF"
    property color surface: darkMode ? "#1E1E1E" : "#FFFFFF"
    property color error: "#CF6679"
    property color onPrimary: darkMode ? "#000000" : "#FFFFFF"
    property color onSecondary: "#000000"
    property color onBackground: darkMode ? "#FFFFFF" : "#000000"
    property color onSurface: darkMode ? "#FFFFFF" : "#000000"

    property int smallPadding: 8
    property int mediumPadding: 16
    property int largePadding: 24

    property font headline1: ({ family: "Roboto", pixelSize: 96, weight: Font.Light })
    property font body: ({ family: "Roboto", pixelSize: 14, weight: Font.Normal })
}
```

```qml
// main.qml
import QtQuick
import QtQuick.Controls
import "Theme.qml" as Theme

Rectangle {
    color: Theme.background

    Text {
        text: "Hello Themed World"
        color: Theme.onBackground
        font: Theme.headline1
    }

    Button {
        background: Rectangle {
            color: Theme.primary
            radius: 4
        }
        contentItem: Text {
            text: "Themed Button"
            color: Theme.onPrimary
        }
    }
}
```

### Custom Control completo
```qml
// Card.qml
import QtQuick
import QtQuick.Controls
import QtGraphicalEffects

Rectangle {
    id: card
    property string title: ""
    property string description: ""
    property url imageSource: ""
    property color cardColor: "white"
    property real elevation: 2

    width: 300; height: 200
    color: cardColor
    radius: 8

    // Sombra
    RectangularGlow {
        id: effect
        anchors.fill: card
        glowRadius: card.elevation * 2
        spread: 0.2
        color: "#20000000"
        cornerRadius: card.radius + glowRadius
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8

        Image {
            width: parent.width; height: 100
            source: card.imageSource
            fillMode: Image.PreserveAspectCrop
            visible: card.imageSource !== ""
        }

        Text {
            text: card.title
            font { family: "Roboto"; pixelSize: 20; weight: Font.Medium }
            color: "#212121"
        }

        Text {
            text: card.description
            font { family: "Roboto"; pixelSize: 14 }
            color: "#757575"
            wrapMode: Text.Wrap
            elide: Text.ElideRight
        }
    }

    // Ripple effect
    Ripple {
        anchors.fill: parent
        pressed: mouseArea.pressed
        active: mouseArea.containsMouse
        color: "#20000000"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
}
```

### FontAwesome en QML
```qml
import QtQuick

FontLoader {
    id: fontAwesome
    source: "qrc:/fonts/fontawesome-webfont.ttf"
}

Text {
    font.family: fontAwesome.name
    font.pixelSize: 24
    text: ""  // icon-user
    color: "#333"
}
```

## best_practices
- Usar `QtQuick.Controls.Material` o `Universal` para consistencia cross-platform
- Crear un sistema de temas centralizado (Singleton) para fácil mantenimiento
- Implementar transiciones suaves entre temas (ColorAnimation)
- Usar `implicitWidth`/`implicitHeight` en controles custom para layouts automáticos
- Preferir SVG sobre PNG para iconos (escalado sin pérdida)
- Usar `Qt.labs.settings` para persistir preferencias de tema
- Seguir Material Design guidelines para spacing, typography y elevation

## common_mistakes
- Hardcodear colores en múltiples archivos
- No usar `font.family` consistente
- Olvidar `hoverEnabled: true` en controles interactivos
- Usar imágenes de baja resolución
- No manejar estados `pressed`, `hovered`, `disabled`
- Ignorar accesibilidad (contraste, tamaños de fuente)

## references
- [qml-material](https://github.com/papyros/qml-material)
- [Fluid](https://github.com/lirios/fluid)
- [Material Design Guidelines](https://material.io/design)
- [Qt Quick Controls Styling](https://doc.qt.io/qt-6/qtquickcontrols2-customize.html)
