# Skill: qt-qml-networking-rest

## description
Comunicación de red en QML/Qt: HTTP requests, REST APIs, WebSockets, JSON parsing, autenticación y manejo de estados de carga.

## context
- **Clases C++**: QNetworkAccessManager, QWebSocket, QJsonDocument, QNetworkReply
- **QML**: XMLHttpRequest, WebSocket
- **Patrones**: Repository pattern, async/await con QML

## patterns

### HTTP Request básico con XMLHttpRequest
```qml
import QtQuick

Item {
    property var responseData: null
    property bool loading: false
    property string error: ""

    function fetchData(url) {
        loading = true
        error = ""

        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                loading = false
                if (xhr.status === 200) {
                    responseData = JSON.parse(xhr.responseText)
                } else {
                    error = "HTTP " + xhr.status + ": " + xhr.statusText
                }
            }
        }
        xhr.open("GET", url)
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.setRequestHeader("Authorization", "Bearer " + authToken)
        xhr.send()
    }
}
```

### REST Client en C++
```cpp
// RestClient.h
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>

class RestClient : public QObject {
    Q_OBJECT
public:
    explicit RestClient(QObject *parent = nullptr);

    Q_INVOKABLE void get(const QString &endpoint);
    Q_INVOKABLE void post(const QString &endpoint, const QJsonObject &data);
    Q_INVOKABLE void put(const QString &endpoint, const QJsonObject &data);
    Q_INVOKABLE void deleteResource(const QString &endpoint);
    Q_INVOKABLE void setAuthToken(const QString &token);

signals:
    void requestStarted();
    void requestFinished(const QJsonDocument &response);
    void requestError(const QString &error);

private:
    QNetworkAccessManager *m_manager;
    QString m_baseUrl = "https://api.example.com/v1/";
    QString m_authToken;

    void handleReply(QNetworkReply *reply);
};

// RestClient.cpp
RestClient::RestClient(QObject *parent) 
    : QObject(parent), m_manager(new QNetworkAccessManager(this)) {
    connect(m_manager, &QNetworkAccessManager::finished, 
            this, &RestClient::handleReply);
}

void RestClient::get(const QString &endpoint) {
    emit requestStarted();
    QNetworkRequest request(QUrl(m_baseUrl + endpoint));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    if (!m_authToken.isEmpty()) {
        request.setRawHeader("Authorization", 
                            "Bearer " + m_authToken.toUtf8());
    }
    m_manager->get(request);
}

void RestClient::handleReply(QNetworkReply *reply) {
    if (reply->error() == QNetworkReply::NoError) {
        QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        emit requestFinished(doc);
    } else {
        emit requestError(reply->errorString());
    }
    reply->deleteLater();
}
```

### WebSocket en QML
```qml
import QtQuick
import QtWebSockets

WebSocket {
    id: socket
    url: "wss://echo.websocket.org"
    active: true

    onTextMessageReceived: {
        console.log("Received:", message)
        messageModel.append({ text: message, isOwn: false })
    }

    onStatusChanged: {
        if (status === WebSocket.Error) {
            console.error("WebSocket error:", errorString)
        } else if (status === WebSocket.Open) {
            console.log("Connected")
        }
    }

    function sendMessage(text) {
        if (socket.status === WebSocket.Open) {
            socket.sendTextMessage(text)
            messageModel.append({ text: text, isOwn: true })
        }
    }
}
```

### Manejo de estados de carga
```qml
import QtQuick
import QtQuick.Controls

Item {
    property bool loading: false
    property bool hasError: false
    property string errorMessage: ""

    states: [
        State {
            name: "loading"
            when: loading
            PropertyChanges { target: loader; visible: true }
            PropertyChanges { target: content; visible: false }
            PropertyChanges { target: errorView; visible: false }
        },
        State {
            name: "error"
            when: hasError && !loading
            PropertyChanges { target: loader; visible: false }
            PropertyChanges { target: content; visible: false }
            PropertyChanges { target: errorView; visible: true }
        },
        State {
            name: "content"
            when: !loading && !hasError
            PropertyChanges { target: loader; visible: false }
            PropertyChanges { target: content; visible: true }
            PropertyChanges { target: errorView; visible: false }
        }
    ]

    BusyIndicator {
        id: loader
        anchors.centerIn: parent
        running: visible
    }

    Column {
        id: errorView
        anchors.centerIn: parent
        Label { text: "Error"; font.bold: true }
        Label { text: errorMessage }
        Button {
            text: "Retry"
            onClicked: reload()
        }
    }

    Item {
        id: content
        anchors.fill: parent
        // Contenido principal
    }
}
```

## best_practices
- Usar QNetworkAccessManager compartido (singleton) para reutilizar conexiones
- Implementar timeout manual (QNetworkAccessManager no tiene timeout por defecto)
- Usar QJsonDocument para parsing/serialization robusto
- Manejar errores de red y HTTP por separado
- Implementar retry con exponential backoff
- Usar HTTPS siempre; configurar SSL properly
- Cachear respuestas cuando sea apropiado
- Usar WebSockets para datos en tiempo real; REST para operaciones CRUD

## common_mistakes
- No manejar errores de red (app se cuelga o crashea)
- Crear nuevo QNetworkAccessManager por request
- No usar deleteLater() en QNetworkReply
- Parsear JSON manualmente con string operations
- No manejar redirects (301/302)
- Hardcodear URLs y credenciales
- No cancelar requests pendientes al salir de una pantalla

## references
- [Qt Network Documentation](https://doc.qt.io/qt-6/qtnetwork-index.html)
- [WebSocket QML](https://doc.qt.io/qt-6/qml-qtwebsockets-websocket.html)
- [QNetworkAccessManager](https://doc.qt.io/qt-6/qnetworkaccessmanager.html)
