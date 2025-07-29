pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

/**
 * Basic polled Bluetooth state.
 */
Singleton {
    id: root

    property int updateInterval: 1000
    property string bluetoothConnectedDeviceName: ""
    property string bluetoothConnectedDeviceAddress: ""
    property list<string> bluetoothDevices: []
    property list<string> newBluetoothDevices: []
    property bool bluetoothEnabled: false
    property bool bluetoothConnected: false

    function update() {
        updateBluetoothDevice.running = true;
        updateBluetoothStatus.running = true;
        updateBluetoothEnabled.running = true;
        updateBluetoothDevices.running = true;
    }

    Timer {
        interval: 10
        running: true
        repeat: true
        onTriggered: {
            update();
            interval = root.updateInterval;
        }
    }

    // Check if Bluetooth is enabled (controller powered on)
    Process {
        id: updateBluetoothEnabled
        command: ["sh", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo 1 || echo 0"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                root.bluetoothEnabled = (parseInt(data) === 1);
            }
        }
    }

    // Get the name and address of the connected Bluetooth devices
    Process {
        id: updateBluetoothDevice
        command: ["sh", "-c", "bluetoothctl info | awk -F': ' '/Name: /{name=$2} /Device /{addr=$2} END{print name \":\" addr}'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let parts = data.split(":");
                root.bluetoothConnectedDeviceName = parts[0] || "";
                root.bluetoothConnectedDeviceAddress = parts[1] || "";
            }
        }
    }

    // Get 5 last connected Bluetooth devices
    Process {
        id: updateBluetoothDevices
        command: ["sh", "-c", "bluetoothctl devices | grep \"^Device\" | while read -r _ mac name; do connected=$(bluetoothctl info \"$mac\" | grep -q \"Connected: yes\" && echo 1 || echo 0); echo \"${name}@${connected}\"; done | sort -t@ -k2 -r | head -n 10 | paste -sd \"|\" -"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                root.bluetoothDevices = data.split("|");
                console.log("Bluetooth devices:", root.bluetoothDevices);
            }
        }
    }

    // Check if any device is connected
    Process {
        id: updateBluetoothStatus
        command: ["sh", "-c", "bluetoothctl info | grep -q 'Connected: yes' && echo 1 || echo 0"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                root.bluetoothConnected = (parseInt(data) === 1);
            }
        }
    }
}
