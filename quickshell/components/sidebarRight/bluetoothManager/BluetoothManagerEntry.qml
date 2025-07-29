import "root:/services"
import "root:/components/common"
import "root:/components/common/widgets"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell


Item {
    id: root
    required property string model
    property list<string> dissectedModel: model.split("@")
    property string name: dissectedModel[0]
    property bool connected: dissectedModel[1] == "1"
    implicitHeight: rowLayout.implicitHeight

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        spacing: 6

        StyledText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft
            color: Appearance.m3colors.m3onSurface
            font.pixelSize: Appearance.font.pixelSize.larger
            text: model
        }
    }
}