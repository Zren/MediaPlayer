import QtQuick 2.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtMultimedia 5.6

Slider {
    id: seekbar
    property Video video
    property bool playingOnPressed: false
    enabled: video.seekable
    value: video.position / video.duration

    style: SliderStyle {
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
        interval: 1000
        running: pressed
        onTriggered: {
            seekToValue()
            if (pressed) {
                restart()
            }
        }
    }

    function seekToValue() {
        video.seek(video.duration * value)
        console.log('seek', video.duration * value, video.position,video.duration)
    }
}