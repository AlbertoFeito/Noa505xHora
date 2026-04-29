# Skill: qt-qml-performance

## description
Optimización de rendimiento en aplicaciones QML: profiling, lazy loading, virtualización, caching y mejores prácticas de memoria.

## context
- **Herramientas**: QML Profiler, GammaRay, perf (Linux)
- **Conceptos**: Scene Graph, batch rendering, texture atlas
- **Patrones**: Loader, StackView, ListView virtualization

## patterns

#### Lazy Loading con Loader
```qml
import QtQuick
import QtQuick.Controls

ApplicationWindow {
    visible: true

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainPage
    }

    Component {
        id: mainPage
        Page {
            Button {
                text: "Open Settings"
                onClicked: stackView.push(settingsPage)
            }
        }
    }

    // Lazy loading: settings page solo se carga cuando se necesita
    Component {
        id: settingsPage
        Page {
            Loader {
                anchors.fill: parent
                source: "SettingsPage.qml"
                asynchronous: true  // Carga en thread separado
                visible: status === Loader.Ready

                onStatusChanged: {
                    if (status === Loader.Ready) console.log("Settings loaded")
                }
            }

            BusyIndicator {
                anchors.centerIn: parent
                running: parent.status === Loader.Loading
            }
        }
    }
}
```

#### Virtualización en ListView
```qml
ListView {
    id: listView
    width: 400; height: 600
    model: largeModel  // 100,000+ items

    // Virtualización clave
    cacheBuffer: 200  // Pixels por encima/debajo de viewport
    displayMarginBeginning: 40
    displayMarginEnd: 40

    // Reuse de delegates
    delegate: Rectangle {
        width: ListView.view.width
        height: 80
        color: index % 2 === 0 ? "#f5f5f5" : "white"

        // Cargar imagen solo cuando es visible
        Image {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 60; height: 60
            source: model.thumbnail
            asynchronous: true
            visible: listView.contentY - 100 < y && y < listView.contentY + listView.height + 100
        }

        Text {
            anchors.left: parent.left; anchors.leftMargin: 80
            anchors.verticalCenter: parent.verticalCenter
            text: model.title
        }
    }

    // Scroll performance
    highlightRangeMode: ListView.ApplyRange
    highlightMoveDuration: 200
    maximumFlickVelocity: 2500
}
```

#### Optimización de imágenes
```qml
Image {
    source: "large_image.jpg"

    // Estrategias de optimización
    asynchronous: true           // Carga en background
    cache: true                  // Cachear en memoria
    sourceSize.width: 200        // Escalar al tamaño de display
    sourceSize.height: 200
    fillMode: Image.PreserveAspectFit
    mipmap: true                 // Mejor calidad al escalar

    // Placeholder mientras carga
    Rectangle {
        anchors.fill: parent
        color: "#e0e0e0"
        visible: parent.status === Image.Loading

        BusyIndicator {
            anchors.centerIn: parent
            running: parent.visible
        }
    }
}
```

#### Pool de objetos reutilizables
```qml
// ObjectPool.qml
import QtQuick

QtObject {
    property var pool: []
    property Component itemComponent

    function acquire() {
        if (pool.length > 0) {
            return pool.pop()
        }
        return itemComponent.createObject()
    }

    function release(item) {
        item.parent = null
        pool.push(item)
    }
}
```

## best_practices
- Usar Loader con asynchronous: true para páginas pesadas
- Activar clip: true solo cuando sea necesario (afecta batch rendering)
- Preferir Rectangle con radius sobre Image con sombras
- Usar sourceSize en Image para evitar decodificar imágenes más grandes de lo necesario
- Implementar pagination para listas grandes en lugar de cargar todo
- Usar QSG_VISUALIZE environment variable para debug del scene graph
- Minimizar el número de elementos en el scene graph
- Usar opacity en lugar de visible: false para animaciones (pero no para ocultar permanentemente)

## common_mistakes
- Cargar todas las páginas al inicio (tiempo de arranque largo)
- No usar asynchronous: true en Loader
- Usar clip: true en contenedores grandes
- Crear demasiados elementos visuales (más de 1000)
- No liberar recursos de imágenes grandes
- Usar JavaScript pesado en el thread principal
- No virtualizar listas largas

## references
- [Qt Performance](https://doc.qt.io/qt-6/qtquick-performance.html)
- [GammaRay](https://github.com/KDAB/GammaRay)
- [QML Profiler](https://doc.qt.io/qtcreator/creator-qml-performance-monitor.html)
