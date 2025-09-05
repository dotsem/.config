pragma ComponentBehavior: Bound
import "root:/components/common"
import "root:/components/common/widgets"
import "root:/services"
import "root:/components/common/functions/string_utils.js" as StringUtils
import "root:/components/common/functions/color_utils.js" as ColorUtils
import "root:/components/common/functions/file_utils.js" as FileUtils
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects

Item {
    id: media
    property bool borderless: Config.options.bar.borderless
    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property string cleanedTitle: StringUtils.cleanMusicTitle(activePlayer?.trackTitle) || qsTr("No media")

    property var artUrl: activePlayer?.trackArtUrl
    property string artDownloadLocation: Directories.coverArt
    property string artFileName: Qt.md5(artUrl) + ".jpg"
    property string artFilePath: `${artDownloadLocation}/${artFileName}`
    property color artDominantColor: ColorUtils.mix((colorQuantizer?.colors[0] ?? Appearance.colors.colPrimary), Appearance.colors.colPrimaryContainer, 0.8) || Appearance.m3colors.m3secondaryContainer
    property bool downloaded: false
    property bool artRegistered: false
    property list<real> visualizerPoints: []
    property real maxVisualizerValue: 1000 // Max value in the data points
    property int visualizerSmoothing: 2 // Number of points to average for smoothing
    property bool hovered: false

    Layout.fillHeight: true
    implicitWidth: rowLayout.implicitWidth + rowLayout.spacing * 2
    implicitHeight: Appearance.sizes.barHeight

    component TrackChangeButton: RippleButton {
        implicitWidth: 24
        implicitHeight: 24

        property var iconName
        colBackground: ColorUtils.transparentize(blendedColors.colSecondaryContainer, 1)
        colBackgroundHover: blendedColors.colSecondaryContainerHover
        colRipple: blendedColors.colSecondaryContainerActive

        contentItem: MaterialSymbol {
            iconSize: Appearance.font.pixelSize.huge
            fill: 1
            horizontalAlignment: Text.AlignHCenter
            color: blendedColors.colOnSecondaryContainer
            text: iconName

            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
        }
    }

    Timer {
        running: media.activePlayer?.playbackState == MprisPlaybackState.Playing
        interval: 1000
        repeat: true
        onTriggered: {
            media.activePlayer.positionChanged();

            if (media.downloaded == false) {
                coverArtDownloader.running = true;
            }
        }
    }

    onArtUrlChanged: {
        if (media.artUrl.length == 0) {
            media.artDominantColor = Appearance.m3colors.m3secondaryContainer;
            return;
        }
        // console.log("PlayerControl: Art URL changed to", media.artUrl)
        // console.log("Download cmd:", coverArtDownloader.command.join(" "))
        media.downloaded = false;
        coverArtDownloader.running = true;
    }

    Process {
        id: coverArtDownloader
        property string targetFile: media.artUrl
        command: ["bash", "-c", `[ -f '${media.artFilePath}' ] || curl -sSL '${targetFile}' -o '${media.artFilePath}'`]
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && exitStatus === 0) {
                fileCheckerProcess.running = true; // start the file check
            } else {
                console.log("Download failed, retrying...");
                Qt.callLater(() => coverArtDownloader.running = true);
            }
        }
    }

    Process {
        id: fileCheckerProcess
        property string filePath: media.artFilePath
        command: ["bash", "-c", `[ -f '${filePath}' ] && echo exists || echo missing`]
        stdout: StdioCollector {
            onStreamFinished: () => {
                var output = this.text;
                if (output.indexOf("exists") !== -1) {
                    media.downloaded = true;
                } else {
                    console.log("Art file missing, retrying download...");
                    Qt.callLater(() => coverArtDownloader.running = true);
                }
            }
        }
    }

    function anyChildHovered() {
        for (let i = 0; i < trackControls.children.length; ++i) {
            const child = trackControls.children[i];
            if (child.hovered === true)
                return true;
        }
        return false;
    }

    MouseArea {
        id: mediaArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: media.hovered = true
        onExited: {
            if (media.anyChildHovered() === false)
                media.hovered = false;
        }
    }

    ColorQuantizer {
        id: colorQuantizer
        source: media.downloaded ? Qt.resolvedUrl(artFilePath) : ""
        depth: 0 // 2^0 = 1 color
        rescaleSize: 1 // Rescale to 1x1 pixel for faster processing
    }

    property bool backgroundIsDark: artDominantColor.hslLightness < 0.5
    property QtObject blendedColors: QtObject {
        property color colLayer0: ColorUtils.mix(Appearance.colors.colLayer0, artDominantColor, (backgroundIsDark && Appearance.m3colors.darkmode) ? 0.6 : 0.5)
        property color colLayer1: ColorUtils.mix(Appearance.colors.colLayer1, artDominantColor, 0.5)
        property color colOnLayer0: ColorUtils.mix(Appearance.colors.colOnLayer0, artDominantColor, 0.5)
        property color colOnLayer1: ColorUtils.mix(Appearance.colors.colOnLayer1, artDominantColor, 0.5)
        property color colSubtext: ColorUtils.mix(Appearance.colors.colOnLayer1, artDominantColor, 0.5)
        property color colPrimary: ColorUtils.mix(ColorUtils.adaptToAccent(Appearance.colors.colPrimary, artDominantColor), artDominantColor, 0.5)
        property color colPrimaryHover: ColorUtils.mix(ColorUtils.adaptToAccent(Appearance.colors.colPrimaryHover, artDominantColor), artDominantColor, 0.3)
        property color colPrimaryActive: ColorUtils.mix(ColorUtils.adaptToAccent(Appearance.colors.colPrimaryActive, artDominantColor), artDominantColor, 0.3)
        property color colSecondaryContainer: ColorUtils.mix(Appearance.m3colors.m3secondaryContainer, artDominantColor, 0.15)
        property color colSecondaryContainerHover: ColorUtils.mix(Appearance.colors.colSecondaryContainerHover, artDominantColor, 0.3)
        property color colSecondaryContainerActive: ColorUtils.mix(Appearance.colors.colSecondaryContainerActive, artDominantColor, 0.5)
        property color colOnPrimary: ColorUtils.mix(ColorUtils.adaptToAccent(Appearance.m3colors.m3onPrimary, artDominantColor), artDominantColor, 0.5)
        property color colOnSecondaryContainer: ColorUtils.mix(Appearance.m3colors.m3onSecondaryContainer, artDominantColor, 0.5)
    }

    StyledRectangularShadow {
        target: background
    }

    Rectangle { // Background
        id: background
        anchors.fill: parent
        anchors.margins: 2
        color: blendedColors.colLayer0
        radius: 8

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: background.width
                height: background.height
                radius: background.radius
            }
        }

        Image {
            id: blurredArt
            anchors.fill: parent
            source: media.downloaded ? Qt.resolvedUrl(artFilePath) : ""
            sourceSize.width: background.width
            sourceSize.height: background.height
            fillMode: Image.PreserveAspectCrop
            cache: false
            antialiasing: true
            asynchronous: true

            layer.enabled: true
            layer.effect: MultiEffect {
                source: blurredArt
                saturation: 0.2
                blurEnabled: true
                blurMax: 100
                blur: 1
            }

            Rectangle {
                anchors.fill: parent
                color: ColorUtils.transparentize(blendedColors.colLayer0, 1)
                radius: root.popupRounding
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: root.contentPadding
            spacing: 15

            Rectangle { // Art background
                id: artBackground
                Layout.fillHeight: true
                implicitWidth: height
                radius: 8
                color: ColorUtils.transparentize(blendedColors.colLayer1, 1)

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: artBackground.width
                        height: artBackground.height
                        radius: artBackground.radius
                    }
                }

                Image { // Art image
                    id: mediaArt
                    property int size: parent.height
                    anchors.fill: parent

                    source: media.downloaded ? Qt.resolvedUrl(artFilePath) : ""
                    fillMode: Image.PreserveAspectCrop
                    cache: false
                    antialiasing: true
                    asynchronous: true

                    width: size
                    height: size
                    sourceSize.width: size
                    sourceSize.height: size
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Revealer {
                    id: defaultView
                    vertical: false
                    reveal: !media.hovered

                    ColumnLayout {
                        id: content
                        z: 1
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        width: 180

                        Layout.rightMargin: 16

                        StyledText {
                            visible: Config.options.bar.verbose
                            width: rowLayout.width - (CircularProgress.size + rowLayout.spacing * 2)
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true // Ensures the text takes up available space
                            Layout.rightMargin: rowLayout.spacing
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight // Truncates the text on the right
                            color: Appearance.colors.colOnLayer1
                            text: `${cleanedTitle}${activePlayer?.trackArtist ? ' • ' + activePlayer.trackArtist : ''}`
                        }
                        Item {
                            id: progressBarContainer
                            Layout.fillWidth: true
                            implicitHeight: progressBar.implicitHeight

                            StyledProgressBar {
                                id: progressBar
                                anchors.fill: parent
                                highlightColor: blendedColors.colPrimary
                                trackColor: blendedColors.colSecondaryContainer
                                value: activePlayer?.position / activePlayer?.length
                                sperm: activePlayer?.isPlaying
                            }

                            WaveVisualizer {
                                id: visualizerCanvas
                                anchors.fill: parent
                                live: activePlayer?.isPlaying
                                points: activePlayer?.visualizerPoints
                                maxVisualizerValue: activePlayer?.maxVisualizerValue
                                smoothing: activePlayer?.visualizerSmoothing
                                color: blendedColors?.colPrimary
                            }
                        }
                    }
                }
            }

            Item {
                id: mediaButtons
                anchors.right: parent.right
                // anchors {
                //     bottom: parent.bottom
                //     left: parent.left
                //     right: parent.right
                // }
                width: 180

                Layout.fillWidth: true
                Layout.fillHeight: true

                Revealer {
                    id: audioControls
                    Layout.fillWidth: true
                    reveal: media.hovered
                    vertical: true

                    RowLayout {
                        id: trackControls
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        TrackChangeButton {
                            iconName: "skip_previous"
                            onClicked: activePlayer?.previous()
                        }

                        RippleButton {
                            id: playPauseButton
                            anchors.right: parent.center
                            anchors.bottom: mediaButtons.top
                            anchors.bottomMargin: 5
                            property real size: 22
                            implicitWidth: size
                            implicitHeight: size
                            onClicked: activePlayer.togglePlaying()

                            buttonRadius: activePlayer?.isPlaying ? Appearance?.rounding.normal : size / 2
                            colBackground: activePlayer?.isPlaying ? blendedColors.colPrimary : blendedColors.colSecondaryContainer
                            colBackgroundHover: activePlayer?.isPlaying ? blendedColors.colPrimaryHover : blendedColors.colSecondaryContainerHover
                            colRipple: activePlayer?.isPlaying ? blendedColors.colPrimaryActive : blendedColors.colSecondaryContainerActive

                            contentItem: MaterialSymbol {
                                iconSize: Appearance.font.pixelSize.huge
                                fill: 1
                                horizontalAlignment: Text.AlignHCenter
                                color: activePlayer?.isPlaying ? blendedColors.colOnPrimary : blendedColors.colOnSecondaryContainer
                                text: activePlayer?.isPlaying ? "pause" : "play_arrow"

                                Behavior on color {
                                    animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                                }
                            }
                        }

                        TrackChangeButton {
                            iconName: "skip_next"
                            onClicked: activePlayer?.next()
                        }
                    }
                }
            }
        }
    }
    // RowLayout { // Real content
    //     id: rowLayout

    //     spacing: 4
    //     anchors.fill: parent

    //     CircularProgress {
    //         Layout.alignment: Qt.AlignVCenter
    //         Layout.leftMargin: rowLayout.spacing
    //         lineWidth: 2
    //         value: activePlayer?.position / activePlayer?.length
    //         size: 26
    //         secondaryColor: Appearance.colors.colSecondaryContainer
    //         primaryColor: Appearance.m3colors.m3onSecondaryContainer

    //         MaterialSymbol {
    //             anchors.centerIn: parent
    //             fill: 1
    //             text: activePlayer?.isPlaying ? "pause" : "music_note"
    //             iconSize: Appearance.font.pixelSize.normal
    //             color: Appearance.m3colors.m3onSecondaryContainer
    //         }

    //     }

    //

    // }

}
