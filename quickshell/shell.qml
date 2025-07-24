//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

// Adjust this to make the shell smaller or larger
//@ pragma Env QT_SCALE_FACTOR=1

import "./components/common/"
import "./components/taskbar/"
import "./components/mediaControls/"

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell

ShellRoot {
    property bool enableBar: true
    property bool enableMediaControls: true
    property bool enableReloadPopup: true



    LazyLoader { active: enableBar; component: Bar {}}
    LazyLoader { active: enableMediaControls; component: MediaControls {} }
    LazyLoader { active: enableReloadPopup; component: ReloadPopup {} }


}