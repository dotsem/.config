import "root:/services"
import "root:/components/common"
import "root:/components/common/widgets"
import QtQuick.Layouts
import Quickshell
import QtQuick


Item {
    id: root
    
    ColumnLayout {
                    id: bluetoothManagerColumnLayout
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 10
                    spacing: 10

                    Repeater {
                        model: Bluetooth.bluetoothDevices
                        
                        // StyledText {
                        //     Layout.fillWidth: true
                        //     Layout.alignment: Qt.AlignLeft
                        //     color: Appearance.m3colors.m3onSurface
                        //     font.pixelSize: Appearance.font.pixelSize.larger
                        //     text: modelData
                        // }

                        BluetoothManagerEntry {
                            Layout.fillWidth: true
                            required property string modelData
                            model: modelData
                        }
                    }
                }
}