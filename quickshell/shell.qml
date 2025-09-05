//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

// Adjust this to make the shell smaller or larger

import "./components/common/"
import "./components/taskbar/"
import "./components/mediaControls/"
import "./components/onScreenDisplay/"
import "./components/sidebarRight/"



import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell

ShellRoot {
    id: root
    property bool enableBar: true
    property bool enableMediaControls: true
    property bool enableReloadPopup: true
    property bool enableOnScreenDisplayBrightness: true
    property bool enableOnScreenDisplayVolume: true
    property bool enableSidebarRight: true



    LazyLoader { active: root.enableBar; component: Bar {}}
    LazyLoader { active: root.enableMediaControls; component: MediaControls {} }
    LazyLoader { active: root.enableReloadPopup; component: ReloadPopup {} }
    LazyLoader { active: root.enableOnScreenDisplayBrightness; component: OnScreenDisplayBrightness {} }
    LazyLoader { active: root.enableOnScreenDisplayVolume; component: OnScreenDisplayVolume {} }
    LazyLoader { active: root.enableSidebarRight; component: SidebarRight {} }

}