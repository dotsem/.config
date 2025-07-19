import "root:/components/common"
import "root:/components/common/widgets"
import "root:/services"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Item {
    id: root
    property bool borderless: Config.options.bar.borderless
    readonly property var chargeState: Battery.chargeState
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isPluggedIn: Battery.isPluggedIn
    readonly property real percentage: Battery.percentage
    readonly property bool isFull: percentage >= Config.options.battery.full / 100
    readonly property bool isLow: percentage <= Config.options.battery.low / 100
    readonly property bool isCritical: percentage <= Config.options.battery.critical / 100

    readonly property color textColor: Appearance.m3colors.darkmode ? Appearance.batteryColor.normalLight :  Appearance.batteryColor.normalDark 

    implicitWidth: rowLayout.implicitWidth + rowLayout.spacing * 2
    implicitHeight: 32

    function colorBasedOnState(normalColor: color, chargeColor: color, fullBatteryColor: color, lowBatteryColor: color, criticalBatteryColor: color): color {
        if (isFull) {
            return fullBatteryColor
        } else if (isCharging) {
            return chargeColor
        } else if (isCritical)  {
            return criticalBatteryColor
        } else if (isLow) {
            return lowBatteryColor
        } else {
            return normalColor
        }
    }

    RowLayout {
        id: rowLayout

        spacing: 4
        anchors.centerIn: parent

        Rectangle {
            implicitWidth: (isCharging ? (boltIconLoader?.item?.width ?? 0) : 0)

            Behavior on implicitWidth {
                animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            color: (isCharging) ? Appearance.batteryColor.charging : textColor
            text: `${Math.round(percentage * 100)}%`
        }

        CircularProgress {
            Layout.alignment: Qt.AlignVCenter
            lineWidth: 2
            value: percentage
            size: 26
            primaryColor: colorBasedOnState(textColor, Appearance.batteryColor.charging, Appearance.batteryColor.full, Appearance.batteryColor.low, Appearance.batteryColor.critical)
            secondaryColor: colorBasedOnState("#00000000", Appearance.batteryColor.chargingBg, Appearance.batteryColor.fullBg, Appearance.batteryColor.lowBg, Appearance.batteryColor.criticalBg)
            fill: (isLow && !isCharging)

            MaterialSymbol {
                anchors.centerIn: parent
                fill: 1
                text: "battery_full"
                iconSize: Appearance.font.pixelSize.normal
                color:  colorBasedOnState(textColor, Appearance.batteryColor.charging, Appearance.batteryColor.full, Appearance.batteryColor.low, Appearance.batteryColor.critical)
            }

        }

    }

    Loader {
        id: boltIconLoader
        active: true
        anchors.left: rowLayout.left
        anchors.verticalCenter: rowLayout.verticalCenter

        Connections {
            target: root
            function onIsChargingChanged() {
                if (isCharging) boltIconLoader.active = true
            }
        }

        sourceComponent: MaterialSymbol {
            id: boltIcon

            text: "bolt"
            iconSize: Appearance.font.pixelSize.large
            color: Appearance.batteryColor.charging
            visible: opacity > 0 // Only show when charging
            opacity: isCharging ? 1 : 0 // Keep opacity for visibility
            onVisibleChanged: {
                if (!visible) boltIconLoader.active = false
            }

            Behavior on opacity {
                animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
            }

        }
    }

}
