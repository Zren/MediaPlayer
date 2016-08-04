import QtQuick 2.1
import QtQuick.Controls 1.4

Row {
    property string key
    property string value
    spacing: 10
    Text {
        text: key
        color: "#bbb"
        width: 120
        horizontalAlignment: Text.AlignRight
    }
    Text {
        text: value
        color: "#bbb"
    }
}
