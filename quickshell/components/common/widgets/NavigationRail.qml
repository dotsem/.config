import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/components/common/"
import "root:/components/common/widgets/"

ColumnLayout { // Window content with navigation rail and content pane
    id: root
    property bool expanded: true
    property int currentIndex: 0
    spacing: 5
}
