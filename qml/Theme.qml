import QtQuick

pragma Singleton

QtObject {
    // Colores corporativos 505 X HORA
    property color primary: "#37474F"         // BlueGrey 800
    property color primaryLight: "#546E7A"    // BlueGrey 600
    property color primaryDark: "#263238"       // BlueGrey 900
    property color accent: "#009688"          // Teal 500
    property color accentLight: "#4DB6AC"     // Teal 300
    property color accentDark: "#00796B"      // Teal 700

    property color background: "#FAFAFA"
    property color surface: "#FFFFFF"
    property color surfaceVariant: "#F5F5F5"
    property color divider: "#E0E0E0"
    property color textPrimary: "#212121"
    property color textSecondary: "#757575"
    property color textDisabled: "#BDBDBD"

    property color success: "#4CAF50"
    property color warning: "#FF9800"
    property color error: "#F44336"
    property color info: "#2196F3"

    // Estados de venta
    property color statusPending: "#FF9800"
    property color statusInvoiced: "#2196F3"
    property color statusPrepared: "#9C27B0"
    property color statusInTransit: "#00BCD4"
    property color statusDelivered: "#4CAF50"
    property color statusLiquidated: "#2E7D32"

    function statusColor(status) {
        switch(status) {
            case "pendiente": return statusPending;
            case "facturado": return statusInvoiced;
            case "preparado": return statusPrepared;
            case "en_transito": return statusInTransit;
            case "entregado": return statusDelivered;
            case "liquidado": return statusLiquidated;
            default: return textDisabled;
        }
    }

    // Espaciado
    property int spacingXs: 4
    property int spacingSm: 8
    property int spacingMd: 16
    property int spacingLg: 24
    property int spacingXl: 32

    // Bordes
    property int radiusSm: 4
    property int radiusMd: 8
    property int radiusLg: 12

    // Sombras
    property string shadowSm: "#1A000000"
    property string shadowMd: "#33000000"
    property string shadowLg: "#66000000"
}
