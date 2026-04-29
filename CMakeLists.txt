cmake_minimum_required(VERSION 3.16)
project(505XHORA VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Include directories - allows #include "src/..."
include_directories(${CMAKE_SOURCE_DIR})

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Sql)

set(PROJECT_SOURCES
    main.cpp
    src/utils/RoleEnums.h
    src/utils/Constants.h
    src/database/DatabaseManager.h
    src/database/DatabaseManager.cpp
    src/models/User.h
    src/models/User.cpp
    src/models/Product.h
    src/models/Product.cpp
    src/models/Sale.h
    src/models/Sale.cpp
    src/models/Inventory.h
    src/models/Inventory.cpp
    src/models/Expense.h
    src/models/Expense.cpp
    src/models/Payroll.h
    src/models/Payroll.cpp
    src/services/InventoryService.h
    src/services/InventoryService.cpp
    src/services/ReportService.h
    src/services/ReportService.cpp
    src/controllers/AppController.h
    src/controllers/AppController.cpp
    qml/qml.qrc
)

qt_add_executable(505XHORA
    ${PROJECT_SOURCES}
)

target_link_libraries(505XHORA PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Sql
)

set_target_properties(505XHORA PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)
