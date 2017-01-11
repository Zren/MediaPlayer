import QtQuick 2.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Private 1.0
import QtQuick.Controls.Styles 1.4
import QtMultimedia 5.6

// Fork Slider so that mouseArea is exposed because using a child MouseArea conflictss.
// https://github.com/qt/qtquickcontrols/blob/dev/src/controls/Slider.qml
AppSlider {
    id: seekbar
    property Video video
    property bool playingOnPressed: false
    enabled: video.seekable
    readonly property real videoPosition: video.position / video.duration
    value: videoPosition

    WheelArea {
        id: wheelarea
        anchors.fill: parent
        horizontalMinimumValue: seekbar.minimumValue
        horizontalMaximumValue: seekbar.maximumValue
        verticalMinimumValue: seekbar.minimumValue
        verticalMaximumValue: seekbar.maximumValue

        onVerticalWheelMoved: {
            console.log('onVerticalWheelMoved', verticalDelta)
            if (verticalDelta > 0) { // Scroll up
                seekbar.decrement()
            } else if (verticalDelta < 0) { // Scroll down
                seekbar.increment()
            }
        }

        onHorizontalWheelMoved: {
            console.log('onHorizontalWheelMoved', horizontalDelta)
            if (horizontalDelta > 0) { // Scroll ?
                seekbar.decrement()
            } else if (horizontalDelta < 0) { // Scroll ?
                seekbar.increment()
            }
        }
    }

    mouseArea.hoverEnabled: true
    mouseArea.onPositionChanged: {
        console.log('onPositionChanged', mouse.x, mouseArea.width)
        thumbnail.show(mouse.x)
    }
    mouseArea.onContainsMouseChanged: {
        if (!mouseArea.containsMouse) {
            thumbnail.hide()
        }
    }

    Rectangle {
        id: thumbnail
        border.width: 4
        border.color: "#111"
        color: "#000"
        width: 200 + border.width*2
        height: 200 * window.videoHeight / window.videoWidth + border.width*2
        anchors.bottom: parent.top
        visible: false
        property real position: 0
        onPositionChanged: thumbnailVideo.seekToPosition()
        property int mouseX: 0
        x: Math.max(0, Math.min(mouseX - (width / 2), parent.width - width))

        function show(mouseX) {
            thumbnail.mouseX = mouseX
            if (!debounceShow.running) {
                debounceShow.restart()
            }
        }

        function hide() {
            thumbnail.visible = false
            debounceShow.stop()
        }

        Video {
            id: thumbnailVideo
            anchors.fill: parent
            anchors.margins: parent.border.width
            source: video.source
            onStatusChanged: {
                console.log('thumbnailVideo.status', status)
                if (status == MediaPlayer.Loaded) {
                    thumbnailVideo.play()
                    thumbnailVideo.pause()
                    seekToPosition()
                }
            }
            function seekToPosition() {
                thumbnailVideo.seek(thumbnailVideo.duration * thumbnail.position)
            }
        }
        Timer {
            id: debounceShow
            interval: 100
            repeat: true
            onTriggered: {
                thumbnailVideo.source = video.source
                thumbnail.position = thumbnail.mouseX / mouseArea.width
                thumbnail.visible = true
            }
        }

        Timer {
            running: !thumbnail.visible
            interval: 5000
            onTriggered: {
                thumbnailVideo.source = ""
            }
        }
    }

    property real incrementSize: 5*1000 // 5 seconds
    function decrement() {
        video.seek(video.position - incrementSize)
    }
    function increment() {
        video.seek(video.position + incrementSize)
    }

    style: AppSliderStyle {
        groove: Rectangle {
            implicitWidth: 200
            implicitHeight: control.height
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#060506" }
                GradientStop { position: 1.0; color: "#0d0b0d" }
            }

            Rectangle {
                width: styleData.handlePosition
                implicitHeight: parent.implicitHeight
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#0f0d0f" }
                    GradientStop { position: 1.0; color: "#525052" }
                }
            }
        }
        handle: Rectangle {
            implicitWidth: 5
            implicitHeight: control.height
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#151315" }
                GradientStop { position: 1.0; color: "#9a989a" }
            }
        }
    }

    onPressedChanged: {
        if (video.seekable) {
            seekToValue()
        }
        if (pressed) {
            playingOnPressed = video.playbackState == MediaPlayer.PlayingState
            video.pause()
        } else if (!pressed && playingOnPressed) {
            video.play()
        }
    }

    Timer {
        id: seekDebounce
        interval: 400
        running: seekbar.pressed
        onTriggered: {
            seekToValue()
            if (seekbar.pressed) {
                restart()
            }
        }
    }

    function seekToValue() {
        video.seek(video.duration * value)
        console.log('seek', video.duration * value, video.position, video.duration)
    }
}
