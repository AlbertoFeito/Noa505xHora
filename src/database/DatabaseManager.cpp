#include "DatabaseManager.h"
#include <QDir>
#include <QCoreApplication>

DatabaseManager::DatabaseManager(QObject *parent) 
    : QObject(parent) 
{
}

DatabaseManager::~DatabaseManager() 
{
    if (m_db.isOpen()) {
        m_db.close();
    }
}

bool DatabaseManager::initialize()
{
    // Usar carpeta data junto al proyecto, no en build
    QString projectDir = QCoreApplication::applicationDirPath();

    // Si estamos en build/, subir al nivel del proyecto
    if (projectDir.contains("build")) {
        projectDir = "D:/2026/505XHORA/data";
    } else {
        projectDir = QCoreApplication::applicationDirPath() + "/data";
    }

    // Crear directorio si no existe
    QDir dir;
    if (!dir.exists(projectDir)) {
        dir.mkpath(projectDir);
    }

    QString dbPath = QDir(projectDir).filePath("505xhora.db");

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(dbPath);
    
    if (!m_db.open()) {
        qCritical() << "Failed to open database:" << m_db.lastError().text();
        return false;
    }
    
    qDebug() << "Database opened at:" << dbPath;
    
    if (!createTables()) {
        qCritical() << "Failed to create tables";
        return false;
    }

    // Migración: agregar columnas supplier y lote a products si no existen
    QSqlQuery checkSupplier(m_db);
    checkSupplier.exec("PRAGMA table_info(products)");
    bool hasSupplier = false, hasLote = false;
    while (checkSupplier.next()) {
        QString colName = checkSupplier.value(1).toString();
        if (colName == "supplier") hasSupplier = true;
        if (colName == "lote") hasLote = true;
    }
    if (!hasSupplier) {
        m_db.exec("ALTER TABLE products ADD COLUMN supplier TEXT");
    }
    if (!hasLote) {
        m_db.exec("ALTER TABLE products ADD COLUMN lote TEXT");
    }

    if (!seedInitialData()) {
        qWarning() << "Failed to seed initial data (may already exist)";
    }
    
    m_initialized = true;
    return true;
}

bool DatabaseManager::isOpen() const 
{
    return m_db.isOpen();
}

QSqlQuery DatabaseManager::executeQuery(const QString &queryStr, const QVariantMap &bindings) 
{
    QSqlQuery query(m_db);
    query.prepare(queryStr);
    
    for (auto it = bindings.begin(); it != bindings.end(); ++it) {
        query.bindValue(":" + it.key(), it.value());
    }
    
    if (!query.exec()) {
        qWarning() << "Query failed:" << query.lastError().text();
        qWarning() << "Query:" << queryStr;
    }
    
    return query;
}

bool DatabaseManager::executeTransaction(const std::function<bool()> &operations) 
{
    if (!m_db.transaction()) {
        return false;
    }
    
    bool success = operations();
    
    if (success) {
        if (!m_db.commit()) {
            qCritical() << "Commit failed:" << m_db.lastError().text();
            m_db.rollback();
            return false;
        }
    } else {
        m_db.rollback();
    }
    
    return success;
}

bool DatabaseManager::createTables() 
{
    QStringList createStatements;
    
    // Tabla de usuarios
    createStatements << R"(
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            full_name TEXT NOT NULL,
            role TEXT NOT NULL CHECK(role IN ('comercial', 'almacen', 'mensajero', 'custodio', 'administrador')),
            phone TEXT,
            email TEXT,
            is_active INTEGER DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    )";
    
    // Tabla de productos
    createStatements << R"(
        CREATE TABLE IF NOT EXISTS products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            code TEXT UNIQUE,
            name TEXT NOT NULL,
            category TEXT,
            description TEXT,
            purchase_price REAL DEFAULT 0,
            sale_price REAL NOT NULL DEFAULT 0,
            stock INTEGER NOT NULL DEFAULT 0,
            min_stock INTEGER DEFAULT 0,
            unit TEXT DEFAULT 'unidad',
            supplier TEXT,
            lote TEXT,
            is_active INTEGER DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    )";

    // Tabla de proveedores
    createStatements << R"(
        CREATE TABLE IF NOT EXISTS suppliers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            code TEXT UNIQUE,
            name TEXT NOT NULL,
            contact_person TEXT,
            phone TEXT,
            email TEXT,
            address TEXT,
            is_active INTEGER DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    )";
    
    // Tabla de ventas (vales)
    createStatements << R"(
        CREATE TABLE IF NOT EXISTS sales (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sale_number TEXT UNIQUE NOT NULL,
            client_name TEXT NOT NULL,
            client_phone TEXT,
            client_address TEXT,
            status TEXT NOT NULL DEFAULT 'pendiente' 
                CHECK(status IN ('pendiente', 'facturado', 'preparado', 'en_transito', 'entregado', 'liquidado')),
            payment_type TEXT DEFAULT 'efectivo' CHECK(payment_type IN ('efectivo', 'transferencia')),
            subtotal REAL DEFAULT 0,
            delivery_cost REAL DEFAULT 0,
            commission REAL DEFAULT 0,
            total REAL DEFAULT 0,
            amount_paid REAL DEFAULT 0,
            notes TEXT,
            created_by INTEGER,
            messenger_id INTEGER,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            delivered_at TIMESTAMP,
            liquidated_at TIMESTAMP,
            FOREIGN KEY (created_by) REFERENCES users(id),
            FOREIGN KEY (messenger_id) REFERENCES users(id)
        )
    )";
    
    // Tabla de items de venta
    createStatements << R"(
        CREATE TABLE IF NOT EXISTS sale_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sale_id INTEGER NOT NULL,
            product_id INTEGER,
            product_name TEXT NOT NULL,
            quantity INTEGER NOT NULL DEFAULT 1,
            unit_price REAL NOT NULL DEFAULT 0,
            total_price REAL NOT NULL DEFAULT 0,
            FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
            FOREIGN KEY (product_id) REFERENCES products(id)
        )
    )";
    
    // Tabla de facturas
    createStatements << R"(
        CREATE TABLE IF NOT EXISTS invoices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            invoice_number TEXT UNIQUE NOT NULL,
            sale_id INTEGER NOT NULL,
            client_name TEXT NOT NULL,
            client_id TEXT,
            total REAL NOT NULL DEFAULT 0,
            tax_amount REAL DEFAULT 0,
            grand_total REAL NOT NULL DEFAULT 0,
            status TEXT DEFAULT 'emitida' CHECK(status IN ('emitida', 'anulada')),
            printed INTEGER DEFAULT 0,
            created_by INTEGER,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (sale_id) REFERENCES sales(id),
            FOREIGN KEY (created_by) REFERENCES users(id)
        )
    )";
    
    // Tabla de entregas / traslados
    createStatements << R"(
        CREATE TABLE IF NOT EXISTS deliveries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sale_id INTEGER NOT NULL,
            messenger_id INTEGER NOT NULL,
            status TEXT NOT NULL DEFAULT 'en_traslado' 
                CHECK(status IN ('en_traslado', 'entregado', 'incidente')),
            delivery_cost REAL DEFAULT 0,
            payment_collected REAL DEFAULT 0,
            payment_type TEXT,
            incident_description TEXT,
            departure_time TIMESTAMP,
            arrival_time TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (sale_id) REFERENCES sales(id),
            FOREIGN KEY (messenger_id) REFERENCES users(id)
        )
    )";
    
    // Tabla de liquidaciones
    createStatements << R"(
        CREATE TABLE IF NOT EXISTS liquidations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sale_id INTEGER NOT NULL,
            messenger_id INTEGER NOT NULL,
            amount REAL NOT NULL DEFAULT 0,
            payment_type TEXT NOT NULL,
            difference REAL DEFAULT 0,
            difference_reason TEXT,
            confirmed INTEGER DEFAULT 0,
            created_by INTEGER,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (sale_id) REFERENCES sales(id),
            FOREIGN KEY (messenger_id) REFERENCES users(id),
            FOREIGN KEY (created_by) REFERENCES users(id)
        )
    )";
    
    // Tabla de inventario / conteo físico
    createStatements << R"(
        CREATE TABLE IF NOT EXISTS inventory_counts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            count_date DATE NOT NULL DEFAULT CURRENT_DATE,
            product_id INTEGER NOT NULL,
            expected_quantity INTEGER NOT NULL DEFAULT 0,
            actual_quantity INTEGER NOT NULL DEFAULT 0,
            difference INTEGER GENERATED ALWAYS AS (actual_quantity - expected_quantity) STORED,
            notes TEXT,
            counted_by INTEGER,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (product_id) REFERENCES products(id),
            FOREIGN KEY (counted_by) REFERENCES users(id)
        )
    )";
    
    // Tabla de gastos
    createStatements << R"(
        CREATE TABLE IF NOT EXISTS expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
            category TEXT NOT NULL CHECK(category IN ('alquiler', 'onat', 'transportista', 'salario', 'combustible', 'mantenimiento', 'otro')),
            description TEXT,
            amount REAL NOT NULL DEFAULT 0,
            payment_method TEXT DEFAULT 'efectivo',
            is_recurrent INTEGER DEFAULT 0,
            recurrence_period TEXT,
            created_by INTEGER,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (created_by) REFERENCES users(id)
        )
    )";
    
    // Tabla de nómina
    createStatements << R"(
        CREATE TABLE IF NOT EXISTS payroll (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            employee_id INTEGER NOT NULL,
            period_start DATE NOT NULL,
            period_end DATE NOT NULL,
            base_salary REAL NOT NULL DEFAULT 0,
            sales_commission REAL DEFAULT 0,
            bonuses REAL DEFAULT 0,
            deductions REAL DEFAULT 0,
            total_pay REAL DEFAULT 0,
            payment_date DATE,
            payment_status TEXT DEFAULT 'pendiente' CHECK(payment_status IN ('pendiente', 'pagado')),
            created_by INTEGER,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (employee_id) REFERENCES users(id),
            FOREIGN KEY (created_by) REFERENCES users(id)
        )
    )";
    
    // Tabla de custodia
    createStatements << R"(
        CREATE TABLE IF NOT EXISTS custody_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            record_date DATE NOT NULL DEFAULT CURRENT_DATE,
            custody_type TEXT NOT NULL CHECK(custody_type IN ('efectivo', 'productos', 'ambos')),
            amount REAL DEFAULT 0,
            product_count INTEGER DEFAULT 0,
            delivered_by INTEGER NOT NULL,
            received_by INTEGER NOT NULL,
            delivery_pin TEXT,
            receipt_pin TEXT,
            notes TEXT,
            confirmed INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (delivered_by) REFERENCES users(id),
            FOREIGN KEY (received_by) REFERENCES users(id)
        )
    )";
    
    // Tabla de cuadre diario
    createStatements << R"(
        CREATE TABLE IF NOT EXISTS daily_reconciliations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            reconciliation_date DATE NOT NULL DEFAULT CURRENT_DATE,
            total_sales REAL DEFAULT 0,
            total_expenses REAL DEFAULT 0,
            expected_cash REAL DEFAULT 0,
            actual_cash REAL DEFAULT 0,
            difference REAL GENERATED ALWAYS AS (actual_cash - expected_cash) STORED,
            difference_reason TEXT,
            is_balanced INTEGER DEFAULT 0,
            closed_by INTEGER,
            closed_at TIMESTAMP,
            FOREIGN KEY (closed_by) REFERENCES users(id)
        )
    )";
    
    // Tabla de mantenimiento
    createStatements << R"(
        CREATE TABLE IF NOT EXISTS maintenance (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            maintenance_date DATE NOT NULL,
            vehicle_description TEXT,
            description TEXT NOT NULL,
            cost REAL DEFAULT 0,
            status TEXT DEFAULT 'programado' CHECK(status IN ('programado', 'en_proceso', 'completado', 'cancelado')),
            created_by INTEGER,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (created_by) REFERENCES users(id)
        )
    )";
    
    // Tabla de configuración
    createStatements << R"(
        CREATE TABLE IF NOT EXISTS config (
            key TEXT PRIMARY KEY,
            value TEXT,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    )";

    // Tabla de proveedores
    createStatements << R"(
        CREATE TABLE IF NOT EXISTS suppliers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            code TEXT UNIQUE NOT NULL,
            name TEXT NOT NULL,
            contact_person TEXT,
            phone TEXT,
            email TEXT,
            address TEXT,
            notes TEXT,
            is_active INTEGER DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    )";

    // Índices para optimización
    createStatements << "CREATE INDEX IF NOT EXISTS idx_sales_status ON sales(status)";
    createStatements << "CREATE INDEX IF NOT EXISTS idx_sales_date ON sales(created_at)";
    createStatements << "CREATE INDEX IF NOT EXISTS idx_sale_items_sale ON sale_items(sale_id)";
    createStatements << "CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(expense_date)";
    createStatements << "CREATE INDEX IF NOT EXISTS idx_inventory_date ON inventory_counts(count_date)";
    createStatements << "CREATE INDEX IF NOT EXISTS idx_payroll_period ON payroll(period_start, period_end)";
    createStatements << "CREATE INDEX IF NOT EXISTS idx_custody_date ON custody_records(record_date)";
    createStatements << "CREATE INDEX IF NOT EXISTS idx_reconciliation_date ON daily_reconciliations(reconciliation_date)";
    
    QSqlQuery query(m_db);
    for (const QString &statement : createStatements) {
        if (!query.exec(statement)) {
            qCritical() << "Failed to execute:" << statement;
            qCritical() << "Error:" << query.lastError().text();
            return false;
        }
    }
    
    return true;
}

bool DatabaseManager::seedInitialData() 
{
    // Verificar si ya existe admin
    QSqlQuery checkQuery(m_db);
    checkQuery.prepare("SELECT COUNT(*) FROM users WHERE role = 'administrador'");
    if (!checkQuery.exec() || !checkQuery.next()) {
        return false;
    }
    
    if (checkQuery.value(0).toInt() > 0) {
        return true; // Ya hay datos iniciales
    }
    
    // Usuario administrador por defecto (password: admin505)
    // En producción usar hashing real
    QStringList seedQueries;
    seedQueries << R"(
        INSERT INTO users (username, password_hash, full_name, role, phone, is_active)
        VALUES ('admin', 'admin505', 'Administrador Principal', 'administrador', '00000000', 1)
    )";
    
    seedQueries << R"(
        INSERT INTO users (username, password_hash, full_name, role, phone, is_active)
        VALUES ('comercial1', 'comercial1', 'Usuario Comercial', 'comercial', '11111111', 1)
    )";
    
    seedQueries << R"(
        INSERT INTO users (username, password_hash, full_name, role, phone, is_active)
        VALUES ('almacen1', 'almacen1', 'Usuario Almacén', 'almacen', '22222222', 1)
    )";
    
    seedQueries << R"(
        INSERT INTO users (username, password_hash, full_name, role, phone, is_active)
        VALUES ('mensajero1', 'mensajero1', 'Usuario Mensajero', 'mensajero', '33333333', 1)
    )";
    
    seedQueries << R"(
        INSERT INTO users (username, password_hash, full_name, role, phone, is_active)
        VALUES ('custodio1', 'custodio1', 'Usuario Custodio', 'custodio', '44444444', 1)
    )";
    
    // Productos de ejemplo
    seedQueries << R"(
        INSERT INTO products (code, name, category, sale_price, stock, min_stock, unit)
        VALUES ('P001', 'Licuadora Oster', 'Electrodomésticos', 8500, 12, 3, 'unidad')
    )";
    
    seedQueries << R"(
        INSERT INTO products (code, name, category, sale_price, stock, min_stock, unit)
        VALUES ('P002', 'Plancha a Vapor', 'Electrodomésticos', 3200, 8, 2, 'unidad')
    )";
    
    seedQueries << R"(
        INSERT INTO products (code, name, category, sale_price, stock, min_stock, unit)
        VALUES ('P003', 'Arroz Saco 5kg', 'Alimentos', 1200, 50, 10, 'saco')
    )";
    
    seedQueries << R"(
        INSERT INTO products (code, name, category, sale_price, stock, min_stock, unit)
        VALUES ('P004', 'Detergente Multiusos', 'Útiles del Hogar', 450, 30, 5, 'unidad')
    )";
    
    seedQueries << R"(
        INSERT INTO products (code, name, category, sale_price, stock, min_stock, unit)
        VALUES ('P005', 'Jabón de Tocador', 'Útiles del Hogar', 180, 100, 20, 'unidad')
    )";
    
    // Configuración por defecto
    seedQueries << R"(
        INSERT INTO config (key, value) VALUES ('horario_atencion_inicio', '09:00')
    )";
    seedQueries << R"(
        INSERT INTO config (key, value) VALUES ('horario_atencion_fin', '16:00')
    )";
    seedQueries << R"(
        INSERT INTO config (key, value) VALUES ('horario_personal_entrada', '08:30')
    )";
    seedQueries << R"(
        INSERT INTO config (key, value) VALUES ('horario_personal_salida', '17:00')
    )";
    seedQueries << R"(
        INSERT INTO config (key, value) VALUES ('dia_mantenimiento', '6')
    )";
    seedQueries << R"(
        INSERT INTO config (key, value) VALUES ('empresa_nombre', '505 X HORA')
    )";
    seedQueries << R"(
        INSERT INTO config (key, value) VALUES ('empresa_direccion', 'Dirección de la empresa')
    )";
    seedQueries << R"(
        INSERT INTO config (key, value) VALUES ('empresa_telefono', '00000000')
    )";
    
    QSqlQuery query(m_db);
    for (const QString &sql : seedQueries) {
        if (!query.exec(sql)) {
            qWarning() << "Seed query failed:" << query.lastError().text();
            // No retornamos false aquí porque algunos datos pueden ya existir
        }
    }
    
    return true;
}
