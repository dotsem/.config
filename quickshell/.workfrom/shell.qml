// //@ pragma UseQApplication
// //@ pragma Env QS_NO_RELOAD_POPUP=1
// //@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

// // Adjust this to make the shell smaller or larger
// //@ pragma Env QT_SCALE_FACTOR=1

// import "./components/common/"
// import "./components/background/"
// import "./components/bar/"
// import "./components/cheatsheet/"
// import "./components/dock/"
// import "./components/mediaControls/"
// import "./components/notificationPopup/"
// import "./components/onScreenKeyboard/"
// import "./components/overview/"
// import "./components/screenCorners/"
// import "./components/session/"
// import "./components/sidebarLeft/"
// import QtQuick
// import QtQuick.Controls
// import QtQuick.Layouts
// import QtQuick.Window
// import Quickshell
// import "./services/"

// ShellRoot {
//     // Enable/disable components here. False = not loaded at all, so rest assured
//     // no unnecessary stuff will take up memory if you decide to only use, say, the overview.
//     property bool enableBar: true
//     property bool enableBackground: false
//     property bool enableCheatsheet: true
//     property bool enableDock: true
//     property bool enableMediaControls: true
//     property bool enableNotificationPopup: true
//     property bool enableOnScreenDisplayBrightness: true
//     property bool enableOnScreenDisplayVolume: true
//     property bool enableOnScreenKeyboard: true
//     property bool enableOverview: true
//     property bool enableReloadPopup: true
//     property bool enableScreenCorners: false
//     property bool enableSession: true
//     property bool enableSidebarLeft: true
//     property bool enableSidebarRight: true

//     // Force initialization of some singletons
//     Component.onCompleted: {
//         MaterialThemeLoader.reapplyTheme()
//         Cliphist.refresh()
//         FirstRunExperience.load()
//     }

//     LazyLoader { active: enableBar; component: Bar {} }
//     LazyLoader { active: enableBackground; component: Background {} }
//     LazyLoader { active: enableCheatsheet; component: Cheatsheet {} }
//     LazyLoader { active: enableDock && Config.options.dock.enable; component: Dock {} }
//     LazyLoader { active: enableMediaControls; component: MediaControls {} }
//     LazyLoader { active: enableNotificationPopup; component: NotificationPopup {} }
//     LazyLoader { active: enableOnScreenDisplayBrightness; component: OnScreenDisplayBrightness {} }
//     LazyLoader { active: enableOnScreenDisplayVolume; component: OnScreenDisplayVolume {} }
//     LazyLoader { active: enableOnScreenKeyboard; component: OnScreenKeyboard {} }
//     LazyLoader { active: enableOverview; component: Overview {} }
//     LazyLoader { active: enableReloadPopup; component: ReloadPopup {} }
//     LazyLoader { active: enableScreenCorners; component: ScreenCorners {} }
//     LazyLoader { active: enableSession; component: Session {} }
//     LazyLoader { active: enableSidebarLeft; component: SidebarLeft {} }
//     LazyLoader { active: enableSidebarRight; component: SidebarRight {} }
// }

