# Skill: qt-qml-deployment

## description
Deployment y distribucion de aplicaciones QML: empaquetado para Windows, Linux, macOS, Android, iOS y WebAssembly. Incluye static linking, installers y app stores.

## context
- **Herramientas**: windeployqt, macdeployqt, linuxdeployqt, Qt Installer Framework
- **Plataformas**: Desktop, Mobile, Embedded, WebAssembly
- **Formatos**: MSI, DMG, AppImage, APK, IPA, WASM

## patterns

### Windows Deployment (Tu PC: C:\Qt6\6.9.3\mingw_64)
```batch
:: Tu configuración Qt: C:\Qt6\6.9.3\mingw_64
:: Compilar en Release con CMake
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=C:/Qt6/6.9.3/mingw_64
cmake --build . --parallel

:: Desplegar dependencias (windeployqt desde Qt)
C:\Qt6\6.9.3\mingw_64\bin\windeployqt.exe --release --qmldir .\qml .\release\505XHORA.exe

:: Incluir MinGW runtime si es necesario
:: El compilador está en: C:\Qt6\Tools\mingw1310_64\bin

:: Crear installer con Qt Installer Framework
C:\Qt6\Tools\QtIFW\4.4.1\bin\binarycreator.exe -c config\config.xml -p packages 505XHORAInstaller.exe
```

### Linux Deployment (AppImage)
```bash
# Compilar
qmake CONFIG+=release
make -j$(nproc)

# Usar linuxdeployqt
wget -c "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
chmod a+x linuxdeployqt-continuous-x86_64.AppImage

./linuxdeployqt-continuous-x86_64.AppImage ./MyApp -appimage -qmake=/usr/bin/qmake

# Resultado: MyApp-x86_64.AppImage
```

### macOS Deployment
```bash
# Compilar
qmake CONFIG+=release
make

# Desplegar
macdeployqt MyApp.app -dmg -qmldir=./qml

# Notarizar para distribucion (macOS 10.15+)
xcrun altool --notarize-app --primary-bundle-id "com.myapp" \
    --username "developer@example.com" --password "@keychain:AC_PASSWORD" \
    --file MyApp.dmg
```

### Android Deployment (Tu PC: D:\instaladores\android\androidqt6.9)
```bash
# Tu Android SDK: D:\instaladores\android\androidqt6.9
# Versiones disponibles:
#   - Platforms: android-31, android-34, android-35, android-36
#   - NDK: 27.1.12297006, 27.2.12479018
#   - Build tools: 35.0.0, 36.0.0

# Configurar variables de entorno (en Qt Creator: Tools > Options > Devices)
export ANDROID_SDK=D:/instaladores/android/androidqt6.9
export ANDROID_NDK=D:/instaladores/android/androidqt6.9/ndk/27.2.12479018
export ANDROID_PLATFORM=android-35
export ANDROID_BUILD_TOOLS=35.0.0

# Compilar APK con Qt Android
C:\Qt6\6.9.3\android_arm64_v8a\bin\qmake -spec android-clang CONFIG+=release
cmake --build . --parallel
cmake --install --prefix android-build

# Deploy con androiddeployqt
C:\Qt6\6.9.3\mingw_64\bin\androiddeployqt.exe \
    --input android-lib505XHORA.so-deployment-settings.json \
    --output android-build \
    --android-platform android-35 \
    --gradle \
    --release

# Firmar APK
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
    -keystore my-release-key.keystore \
    android-build/build/outputs/apk/release/505XHORA-release-unsigned.apk \
    alias_name

zipalign -v 4 android-build-release-unsigned.apk 505XHORA-release.apk

# Instalar en dispositivo
adb install 505XHORA-release.apk
```

### Configurar en Qt Creator
1. **Tools > Options > Devices > Android**
2. **Android SDK**: `D:\instaladores\android\androidqt6.9`
3. **NDK**: `27.2.12479018`
4. **JDK**: (el que tengas configurado, ej. JDK 17)
5. **Apply** y luego en tu proyecto: **Project > Build > Run > Android**

### WebAssembly (Tu PC: D:\instaladores\emsdk + C:\Qt6\6.9.3\wasm_singlethread)
```bash
# Tu emsdk: D:\instaladores\emsdk
# Tu Qt WebAssembly: C:\Qt6\6.9.3\wasm_singlethread

# Activar emsdk (PowerShell en Windows)
D:\instaladores\emsdk\emsdk_env.ps1

# O en CMD:
# call D:\instaladores\emsdk\emsdk_env.bat

# Instalar y activar versión de emscripten recomendada
D:\instaladores\emsdk\emsdk.exe install latest
D:\instaladores\emsdk\emsdk.exe activate latest

# Compilar para WebAssembly con Qt
# IMPORTANTE: Usar el qmake de wasm_singlethread
C:\Qt6\6.9.3\wasm_singlethread\bin\qmake CONFIG+=release
cmake --build . --parallel

# Los outputs quedan en la carpeta de build como .wasm y .js
# Arrancar servidor web simple
python -m http.server 8080
# Abrir http://localhost:8080/505XHORA.html
```

### Configurar WebAssembly en Qt Creator
1. **Tools > Options > Devices > WebAssembly**
2. **emsdk**: `D:\instaladores\emsdk`
3. **Qt for WebAssembly**: `C:\Qt6\6.9.3\wasm_singlethread`
4. **Apply**

### iOS Deployment
```bash
# Compilar con Xcode
qmake -spec macx-ios-clang CONFIG+=release
make

# Crear IPA
xcodebuild -scheme MyApp archive -archivePath MyApp.xcarchive
xcodebuild -exportArchive -archivePath MyApp.xcarchive \
    -exportPath MyApp.ipa \
    -exportOptionsPlist exportOptions.plist

# exportOptions.plist debe incluir:
# - teamID
# - method (app-store, ad-hoc, enterprise, development)
# - provisioningProfiles
```

### Qt Installer Framework config.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Installer>
    <Name>MyApp</Name>
    <Version>1.0.0</Version>
    <Title>MyApp Installer</Title>
    <Publisher>MyCompany</Publisher>
    <StartMenuDir>MyApp</StartMenuDir>
    <TargetDir>@HomeDir@/MyApp</TargetDir>
    <AdminTargetDir>@RootDir@/MyApp</AdminTargetDir>
    <RemoteRepositories>
        <Repository>
            <Url>https://updates.myapp.com</Url>
            <Enabled>1</Enabled>
            <DisplayName>MyApp Updates</DisplayName>
        </Repository>
    </RemoteRepositories>
</Installer>
```

### package.xml para Qt Installer Framework
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Package>
    <DisplayName>MyApp Core</DisplayName>
    <Description>Core application files</Description>
    <Version>1.0.0</Version>
    <ReleaseDate>2026-04-28</ReleaseDate>
    <Default>true</Default>
    <Script>installscript.qs</Script>
</Package>
```

### installscript.qs (Qt Script para Installer)
```javascript
function Component() {
    // Constructor
}

Component.prototype.createOperations = function() {
    component.createOperations();

    // Crear acceso directo en Windows
    if (systemInfo.productType === "windows") {
        component.addOperation("CreateShortcut",
            "@TargetDir@/MyApp.exe",
            "@StartMenuDir@/MyApp.lnk",
            "workingDirectory=@TargetDir@");
    }

    // Registrar extension de archivo
    component.addOperation("RegisterFileType",
        ".myapp",
        "@TargetDir@/MyApp.exe '%1'",
        "MyApp Document",
        "application/x-myapp");
}
```

## best_practices
- Usar windeployqt/macdeployqt para copiar dependencias automaticamente
- Incluir todas las DLLs de Qt necesarias (Qt5Core, Qt5Gui, Qt5Qml, Qt5Quick, etc.)
- Verificar que QML plugins esten en el directorio correcto (qml/)
- Usar static linking solo si es necesario (licencia LGPL)
- Firmar binarios en Windows (SignTool) y macOS (codesign)
- Probar en maquina limpia (sin Qt instalado)
- Usar Qt Installer Framework para updates automaticos
- Para Android: usar Android App Bundle (AAB) para Google Play
- Para iOS: configurar correctamente provisioning profiles y signing
- Para WebAssembly: usar compresion gzip/brotli en servidor web

## common_mistakes
- Olvidar incluir plugins de plataforma (platforms/qwindows.dll)
- No incluir archivos de traduccion (.qm)
- Falta de Visual C++ Redistributables en Windows
- No firmar aplicaciones (warnings de seguridad)
- Paths absolutos en el codigo
- No probar en maquina sin Qt instalado
- Olvidar permisos en AndroidManifest.xml
- No configurar entitlements en iOS
- Olvidar iconos y metadata para app stores
- No optimizar assets (imagenes, fuentes) antes de deploy

---

## Deployment del Proyecto 505XHORA

### Build y Deploy en Windows (MÉTODO VERIFICADO 505XHORA)
```batch
:: El build del IDE ya está en: build/Desktop_Qt_6_9_3_MinGW_64_bit-Release

:: 1. Compilar (usa el build del IDE)
cmake --build build/Desktop_Qt_6_9_3_MinGW_64_bit-Release --parallel

:: 2. Copiar exe a deploy
Copy-Item build\Desktop_Qt_6_9_3_MinGW_64_bit-Release\505XHORA.exe deploy\

:: 3. Deployment (solo una vez o si borraste deploy)
C:\Qt6\6.9.3\mingw_64\bin\windeployqt.exe --release --qmldir D:\2026\505XHORA\qml D:\2026\505XHORA\deploy\505XHORA.exe
```

### Resultado del Deploy
- **Archivos**: ~1345 archivos
- **Tamaño**: ~104 MB
- **Contenido**:
  - 505XHORA.exe
  - Qt6*.dll (Core, Gui, Quick, Sql, etc.)
  - libgcc_s_seh-1.dll, libstdc++-6.dll, libwinpthread-1.dll (MinGW runtime)
  - platforms/qwindows.dll
  - sqldrivers/ (SQLite)
  - qml/ (componentes QML y Quick Controls)
  - translations/ (traducciones Qt)

### Solución de Errores Comunes
- **QML component not found**: verificar qrc con prefix correcto (ej. `/qml`)
- **Theme undefined**: usar singleton con `qmlRegisterSingletonType`
- **Style warnings**: agregar `import QtQuick.Controls.Material` y configurar estilo en main.qml

---

## Tu Entorno de Desarrollo (PC: Guerra)

| Componente | Ruta |
|------------|------|
| **Qt Core** | `C:\Qt6\6.9.3\mingw_64` |
| **Qt Docs** | `C:\Qt6\Docs\Qt-6.9.3` |
| **Qt Examples** | `C:\Qt6\Examples\Qt-6.9.3` |
| **Compiler** | `C:\Qt6\Tools\mingw1310_64\bin` |
| **CMake** | `C:\Qt6\Tools\CMake_64\bin` |
| **Qt IFW** | `C:\Qt6\Tools\QtIFW\4.4.1\bin` |
| **WebAssembly** | `C:\Qt6\6.9.3\wasm_singlethread` |
| **Emsdk** | `D:\instaladores\emsdk` |
| **Android SDK** | `D:\instaladores\android\androidqt6.9` |
| **Android NDK** | `D:\instaladores\android\androidqt6.9\ndk\27.2.12479018` |
| **Android Platforms** | `android-31, 34, 35, 36` |
| **Qt Android** | `C:\Qt6\6.9.3\android_arm64_v8a` |

### Compilación y Deployment (MÉTODO VERIFICADO 505XHORA)

El Qt Creator ya crea la carpeta `build/Desktop_Qt_6_9_3_MinGW_64_bit-Release` o `-Debug`.

```batch
:: 1. Compilar en el build del IDE (Release o Debug según corresponda)
cmake --build build/Desktop_Qt_6_9_3_MinGW_64_bit-Release --parallel

:: 2. Copiar exe a deploy
Copy-Item build\Desktop_Qt_6_9_3_MinGW_64_bit-Release\505XHORA.exe deploy\

:: 3. Ejecutar windeployqt (copia todas las dependencias Qt a deploy)
C:\Qt6\6.9.3\mingw_64\bin\windeployqt.exe --release --qmldir D:\2026\505XHORA\qml D:\2026\505XHORA\deploy\505XHORA.exe

:: 4. Ejecutar desde deploy
Start-Process -FilePath "D:\2026\505XHORA\deploy\505XHORA.exe"
```

### Cómo actualizar solo el exe (sin regenerar todo el deployment)
```batch
:: Si solo cambiaste código y ya tienes el deploy con todas las dependencias:
cmake --build build/Desktop_Qt_6_9_3_MinGW_64_bit-Release --parallel
Copy-Item build\Desktop_Qt_6_9_3_MinGW_64_bit-Release\505XHORA.exe deploy\
Start-Process -FilePath "D:\2026\505XHORA\deploy\505XHORA.exe"
```

### Nueva compilación desde cero (si borraste todo)
```batch
:: 1. Configurar CMake con compiladores MinGW
cmake -B build -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH=C:/Qt6/6.9.3/mingw_64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=C:/Qt6/Tools/mingw1310_64/bin/c++.exe -DCMAKE_MAKE_PROGRAM=C:/Qt6/Tools/mingw1310_64/bin/mingw32-make.exe

:: 2. Compilar
cmake --build build/Desktop_Qt_6_9_3_MinGW_64_bit-Release --parallel

:: 3. Deployment (solo una vez)
New-Item -ItemType Directory -Force -Path deploy
Copy-Item build\Desktop_Qt_6_9_3_MinGW_64_bit-Release\505XHORA.exe deploy\
C:\Qt6\6.9.3\mingw_64\bin\windeployqt.exe --release --qmldir D:\2026\505XHORA\qml D:\2026\505XHORA\deploy\505XHORA.exe

:: 4. Ejecutar
Start-Process -FilePath "D:\2026\505XHORA\deploy\505XHORA.exe"
```

## references
- [Qt Deployment Guide](https://doc.qt.io/qt-6/deployment.html)
- [Qt Installer Framework](https://doc.qt.io/qtifw/)
- [windeployqt](https://doc.qt.io/qt-6/windows-deployment.html)
- [macdeployqt](https://doc.qt.io/qt-6/macos-deployment.html)
- [Android Deployment](https://doc.qt.io/qt-6/android-deployment.html)
- [iOS Deployment](https://doc.qt.io/qt-6/ios-deployment.html)
- [WebAssembly](https://doc.qt.io/qt-6/wasm.html)
- [linuxdeployqt](https://github.com/probonopd/linuxdeployqt)
