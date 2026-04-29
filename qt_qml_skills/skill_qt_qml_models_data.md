# Skill: qt-qml-models-data

## description
Manejo de modelos de datos en QML: ListModel, XmlListModel, QAbstractListModel, delegates, sorting, filtering y proxy models.

## context
- **Patrones**: MVC, MVVM
- **Clases C++**: QAbstractListModel, QSortFilterProxyModel, QStringListModel
- **Componentes QML**: ListView, GridView, PathView, Repeater, TableView

## patterns

### ListModel básico
```qml
ListModel {
    id: fruitModel
    ListElement { name: "Apple"; cost: 2.45 }
    ListElement { name: "Banana"; cost: 1.95 }
    ListElement { name: "Orange"; cost: 3.25 }
}

ListView {
    width: 200; height: 300
    model: fruitModel
    delegate: Rectangle {
        width: parent.width; height: 40
        color: index % 2 === 0 ? "#f0f0f0" : "white"

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left; anchors.leftMargin: 10
            text: name + " ($" + cost + ")"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: fruitModel.remove(index)
        }
    }

    section.property: "name"
    section.criteria: ViewSection.FirstCharacter
    section.delegate: Rectangle {
        width: parent.width; height: 20
        color: "lightblue"
        Text { anchors.centerIn: parent; text: section }
    }
}
```

### QAbstractListModel desde C++
```cpp
// FruitModel.h
#include <QAbstractListModel>
#include <QVector>

struct Fruit {
    QString name;
    double cost;
};

class FruitModel : public QAbstractListModel {
    Q_OBJECT
public:
    enum FruitRoles {
        NameRole = Qt::UserRole + 1,
        CostRole
    };

    explicit FruitModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addFruit(const QString &name, double cost);
    Q_INVOKABLE void removeFruit(int index);

private:
    QVector<Fruit> m_fruits;
};

// FruitModel.cpp
int FruitModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent)
    return m_fruits.count();
}

QVariant FruitModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_fruits.count())
        return QVariant();

    const Fruit &fruit = m_fruits.at(index.row());
    switch (role) {
        case NameRole: return fruit.name;
        case CostRole: return fruit.cost;
        default: return QVariant();
    }
}

QHash<int, QByteArray> FruitModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[CostRole] = "cost";
    return roles;
}

void FruitModel::addFruit(const QString &name, double cost) {
    beginInsertRows(QModelIndex(), m_fruits.count(), m_fruits.count());
    m_fruits.append({name, cost});
    endInsertRows();
}
```

### SortFilterProxyModel en QML
```qml
import QtQuick
import QtQuick.Controls
import Qt.labs.qmlmodels

ListView {
    model: SortFilterProxyModel {
        sourceModel: fruitModel
        sortRole: "cost"
        sortOrder: Qt.AscendingOrder
        filterRole: "name"
        filterString: searchField.text
        filterCaseSensitivity: Qt.CaseInsensitive
    }

    delegate: ItemDelegate {
        text: model.name + " - $" + model.cost
    }
}
```

### Editable TableView
```qml
TableView {
    model: TableModel {
        TableModelColumn { display: "name" }
        TableModelColumn { display: "cost" }
        rows: [
            { name: "Apple", cost: 2.45 },
            { name: "Banana", cost: 1.95 }
        ]
    }

    delegate: Rectangle {
        implicitWidth: 100
        implicitHeight: 40
        border.width: 1

        TextInput {
            anchors.fill: parent
            text: model.display
            onEditingFinished: model.display = text
        }
    }
}
```

## best_practices
- Usar `QAbstractListModel` para datasets grandes (>1000 items)
- Implementar `beginInsertRows`/`endInsertRows` para notificar cambios
- Usar `Q_INVOKABLE` para métodos accesibles desde QML
- Preferir `ListElement` sobre `append()` en JavaScript para datos estáticos
- Usar `section` en ListView para agrupar datos
- Implementar `canFetchMore`/`fetchMore` para lazy loading
- Usar `SortFilterProxyModel` para ordenar/filtrar sin modificar el modelo original

## common_mistakes
- Modificar el modelo sin notificar a las vistas (crash o UI desactualizada)
- Usar `ListModel` para datasets grandes (problemas de memoria)
- Olvidar definir `roleNames()` (propiedades no accesibles desde QML)
- No usar `beginResetModel`/`endResetModel` para cambios masivos
- Acceder a roles por índice numérico en lugar de nombre

## references
- [SortFilterProxyModel](https://github.com/oKcerG/SortFilterProxyModel)
- [Qt Models Documentation](https://doc.qt.io/qt-6/model-view-programming.html)
- [QML ListView](https://doc.qt.io/qt-6/qml-qtquick-listview.html)
