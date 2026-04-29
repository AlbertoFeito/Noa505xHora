# Skill: qt-qml-testing-debugging

## description
Testing y debugging de aplicaciones QML: unit tests, integration tests, mock objects, debugging con Qt Creator y herramientas de profiling.

## context
- **Frameworks**: Qt Test, Squish, Testable
- **Herramientas**: Qt Creator Debugger, GammaRay, QML Profiler
- **Patrones**: TDD, BDD, Page Object Pattern

## patterns

### Unit Test con Qt Test
```qml
// TestCalculator.qml
import QtQuick
import QtTest

TestCase {
    name: "CalculatorTests"

    Calculator {
        id: calculator
    }

    function test_addition() {
        calculator.clear()
        calculator.appendNumber(5)
        calculator.setOperation("+")
        calculator.appendNumber(3)
        compare(calculator.calculate(), 8)
    }

    function test_division_by_zero() {
        calculator.clear()
        calculator.appendNumber(10)
        calculator.setOperation("/")
        calculator.appendNumber(0)
        verify(isNaN(calculator.calculate()))
    }

    function test_signal_emission() {
        var spy = signalSpy.createObject(calculator, { 
            target: calculator, 
            signalName: "resultChanged" 
        })
        calculator.calculate()
        compare(spy.count, 1)
    }
}
```

### Test Runner en C++
```cpp
// main.cpp para tests
#include <QtQuickTest/quicktest.h>
#include <QQmlEngine>
#include <QQmlContext>

int main(int argc, char **argv) {
    QTEST_ADD_GPU_BLACKLIST_SUPPORT
    QTEST_SET_MAIN_SOURCE_PATH
    return quick_test_main(argc, argv, "QMLTests", QUICK_TEST_SOURCE_DIR);
}
```

### Mock de servicios para testing
```qml
// MockApiService.qml
import QtQuick

Item {
    signal requestFinished(var response)
    signal requestError(string error)

    function fetchUsers() {
        // Simular delay de red
        delayTimer.start()
    }

    Timer {
        id: delayTimer
        interval: 100
        onTriggered: {
            requestFinished([
                { id: 1, name: "User 1" },
                { id: 2, name: "User 2" }
            ])
        }
    }
}
```

### Integration Test con Squish-like approach
```qml
// LoginTest.qml
import QtQuick
import QtTest

TestCase {
    name: "LoginFlow"
    when: windowShown

    function test_successful_login() {
        var usernameField = findChild(app, "usernameField")
        var passwordField = findChild(app, "passwordField")
        var loginButton = findChild(app, "loginButton")

        mouseClick(usernameField)
        keyClick("testuser")

        mouseClick(passwordField)
        keyClick("password123")

        mouseClick(loginButton)

        // Esperar navegación
        tryCompare(findChild(app, "mainPage"), "visible", true, 5000)
    }

    function test_invalid_credentials() {
        // ... similar pero verificando mensaje de error
    }
}
```

### Debugging con GammaRay
```bash
# Ejecutar app con GammaRay
~/gammaray/bin/gammaray ./myapp

# O attach a proceso en ejecución
~/gammaray/bin/gammaray --pid $(pgrep myapp)
```

## best_practices
- Escribir tests unitarios para lógica de negocio en C++
- Usar TestCase de QML para testing de UI components
- Crear mocks para servicios externos (API, base de datos)
- Usar `findChild` para localizar elementos en tests de integración
- Implementar `objectName` en todos los elementos testeables
- Usar signalSpy para verificar emisión de señales
- Ejecutar tests en CI/CD con `xvfb-run` en Linux headless
- Usar GammaRay para inspeccionar árbol de objetos y propiedades en runtime

## common_mistakes
- No testear casos de error
- Tests que dependen de estado de otros tests
- No usar `when: windowShown` en tests de UI
- Hardcodear tiempos de espera en lugar de `tryCompare`
- No limpiar estado entre tests
- Olvidar `objectName` en elementos importantes

## references
- [Qt Test Documentation](https://doc.qt.io/qt-6/qttest-index.html)
- [Testable Framework](https://github.com/testable)
- [Squish by froglogic](https://www.froglogic.com/squish/)
- [GammaRay](https://github.com/KDAB/GammaRay)
