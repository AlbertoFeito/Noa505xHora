# Skill: qt-qml-multimedia-graphics

## description
Multimedia y gráficos avanzados en QML: video, audio, cámara, OpenGL, Qt3D, shaders y efectos visuales.

## context
- **Módulos**: QtMultimedia, Qt3D, QtQuick3D, QtGraphicalEffects
- **Formatos**: MP4, H.264, AAC, WAV, MP3
- **Shaders**: GLSL, QML ShaderEffect

## patterns

### Reproductor de video
```qml
import QtQuick
import QtMultimedia

Video {
    id: video
    width: 800; height: 600
    source: "file:///path/to/video.mp4"

    MouseArea {
        anchors.fill: parent
        onClicked: video.playbackState === MediaPlayer.PlayingState ? video.pause() : video.play()
    }

    VideoOutput {
        anchors.fill: parent
        source: video
    }

    // Controles
    Row {
        anchors.bottom: parent.bottom
        Button { text: "Play"; onClicked: video.play() }
        Button { text: "Pause"; onClicked: video.pause() }
        Slider {
            from: 0; to: video.duration
            value: video.position
            onMoved: video.position = value
        }
    }
}
```

### Cámara con QtMultimedia
```qml
import QtQuick
import QtMultimedia

Item {
    width: 640; height: 480

    Camera {
        id: camera
    }

    VideoOutput {
        anchors.fill: parent
        source: camera
        fillMode: VideoOutput.PreserveAspectCrop
    }

    ImageCapture {
        id: imageCapture
        onImageSaved: console.log("Saved to", path)
    }

    Button {
        text: "Capture"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: imageCapture.capture()
    }
}
```

### ShaderEffect personalizado
```qml
import QtQuick

Item {
    width: 400; height: 400

    Image {
        id: sourceImage
        source: "image.jpg"
        visible: false
    }

    ShaderEffect {
        anchors.fill: parent
        property variant source: sourceImage
        property real blurRadius: 0.0

        vertexShader: "
            uniform highp mat4 qt_Matrix;
            attribute highp vec4 qt_Vertex;
            attribute highp vec2 qt_MultiTexCoord0;
            varying highp vec2 coord;
            void main() {
                coord = qt_MultiTexCoord0;
                gl_Position = qt_Matrix * qt_Vertex;
            }
        "

        fragmentShader: "
            varying highp vec2 coord;
            uniform sampler2D source;
            uniform lowp float qt_Opacity;
            uniform highp float blurRadius;

            void main() {
                lowp vec4 tex = texture2D(source, coord);
                gl_FragColor = tex * qt_Opacity;
            }
        "

        NumberAnimation on blurRadius {
            from: 0; to: 10
            duration: 1000
            loops: Animation.Infinite
            easing.type: Easing.InOutQuad
        }
    }
}
```

### Qt3D básico
```qml
import QtQuick
import Qt3D.Core
import Qt3D.Render
import Qt3D.Input
import Qt3D.Extras

Entity {
    id: sceneRoot

    Camera {
        id: camera
        projectionType: CameraLens.PerspectiveProjection
        fieldOfView: 45
        nearPlane: 0.1
        farPlane: 1000.0
        position: Qt.vector3d(0, 0, 20)
        upVector: Qt.vector3d(0, 1, 0)
        viewCenter: Qt.vector3d(0, 0, 0)
    }

    OrbitCameraController { camera: camera }

    components: [
        RenderSettings {
            activeFrameGraph: ForwardRenderer {
                camera: camera
                clearColor: "#333"
            }
        },
        InputSettings { }
    ]

    Entity {
        components: [
            SphereMesh { radius: 5 },
            PhongMaterial { diffuse: "red" },
            Transform {
                rotation: fromAxisAndAngle(Qt.vector3d(1, 0, 0), 45)
            }
        ]
    }
}
```

## best_practices
- Usar `VideoOutput` con `fillMode: PreserveAspectFit` para evitar distorsión
- Liberar recursos de cámara cuando no se usan (`camera.stop()`)
- Usar `QtGraphicalEffects` en lugar de shaders custom cuando sea posible
- Implementar fallback para dispositivos sin soporte OpenGL
- Usar `MediaPlayer` en lugar de `Video` para control más fino
- Precargar recursos multimedia en background
- Usar `Audio` para efectos de sonido; `MediaPlayer` para música

## common_mistakes
- No manejar permisos de cámara/micrófono en móviles
- Cargar videos grandes en memoria
- No liberar recursos de cámara (batería)
- Shaders sin fallback para GLES2
- No manejar rotación de pantalla en video
- Usar formatos de video no soportados

## references
- [QtMultimedia](https://doc.qt.io/qt-6/qtmultimedia-index.html)
- [Qt3D](https://doc.qt.io/qt-6/qt3d-index.html)
- [QtGraphicalEffects](https://doc.qt.io/qt-6/qtgraphicaleffects-index.html)
