import QtQuick 2.2
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtMultimedia 5.7

AppWindow {
    id: window
    width: videoWidth
    height: videoHeight + controlBar.height

    title: {
        var s = "";
        if (filename) {
            s += filename;
            s += " - "
        }

        s += "MediaPlayer";
        return s;
    }
    property string filename: {
        if (video.source) {
            var filename = video.source.toString();
            filename = filename.substr(filename.lastIndexOf('/') + 1);
            return filename;
        } else {
            return "";
        }
    }
    property bool isFullscreen: visibility == 5 // QWindow::FullScreen
    property bool isPlaying: video.playbackState == MediaPlayer.PlayingState
    property bool isLoaded: video.hasVideo || video.hasAudio || false
    onIsPlayingChanged: {
        updateAlwaysOnTopFlag()
    }

    property int videoWidth: 400
    property int videoHeight: 400

    menuBarVisible: !hideMenuBar && !isFullscreen
    property bool hideMenuBar: false

    property bool bordersVisible: true
    property bool titleBarVisible: true
    property bool seekBarVisible: true
    property bool controlBarVisible: true
    property bool statisticsVisible: false
    property bool statusBarVisible: true
    property string alwaysOnTop: 'never' // 'always', 'whilePlaying'
    
    onAlwaysOnTopChanged: {
        updateAlwaysOnTopFlag()
    }
    onBordersVisibleChanged: setWindowFlag(!bordersVisible, Qt.FramelessWindowHint)
    onTitleBarVisibleChanged: {
        return  // Not working right

        if (titleBarVisible) {
            setWindowFlag(false, Qt.CustomizeWindowHint)
            setWindowFlag(true, Qt.WindowTitleHint)
        } else {
            // setWindowFlag(true, Qt.CustomizeWindowHint)
            // setWindowFlag(false, Qt.WindowTitleHint) // removes the borders?
        }
    }

    function setWindowFlag(flagIt, flag) {
        // if (flagIt && !(window.flags & flag)) {
        if (flagIt) {
            window.flags |= flag; // Add the flag
        // } else if (!flagIt && (window.flags & flag)) {
        } else {
            window.flags = window.flags & ~flag; // Remove the flag
        }
    }

    function updateAlwaysOnTopFlag() {
        var flagIt;
        if (alwaysOnTop == 'never') {
            flagIt = false;
        } else if (alwaysOnTop == 'never') {
            flagIt = true;
        } else if (isPlaying) { // 'whilePlaying'
            flagIt = true;
        } else { // !isPlaying + 'whilePlaying'
            flagIt = false;
        }

        setWindowFlag(flagIt, Qt.WindowStaysOnTopHint)
    }


    AppContextMenu { id: contextMenu }
    AppMenuBar { id: appMenuBar }
    menuBar: appMenuBar

    OpenFileDialog { id: openFileDialog }

    Rectangle {
        color: "#000"
        anchors.fill: parent
    }
    Video {
        id: video
        anchors.fill: parent
        anchors.bottomMargin: isFullscreen ? 0 : controlBar.height
    
        onStatusChanged: {
            console.log('video.status', status)
            if (status == MediaPlayer.Loaded) {
                window.onVideoLoad()
            }
        }
    }

    MouseArea {
        anchors.fill: video
        acceptedButtons: Qt.AllButtons
        onClicked: {
            if (mouse.button == Qt.LeftButton) {
                if (video.playbackState == MediaPlayer.PlayingState) {
                    video.pause()
                } else { // Paused/Stopped
                    video.play()
                }
            } else if (mouse.button == Qt.RightButton) {
                contextMenu.popup()
            }
        }
        onDoubleClicked: window.toggleFullscreen()
    }

    MouseArea {
        id: controlBarHitBox
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: controlBar.height
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true

        Column {
            id: controlBar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            opacity: !window.isFullscreen || controlBarHitBox.containsMouse ? 1 : 0

            Rectangle {
                width: parent.width
                height: 1
                color: "#050405"
            }

            // Row 1: Seekbar
            Rectangle {
                visible: window.seekBarVisible || window.isFullscreen
                width: parent.width
                height: 1
                color: "#24272c"
            }
            SeekBarSlider {
                id: seekbar
                visible: window.seekBarVisible || window.isFullscreen
                video: video
                width: parent.width
                height: 19

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    text: window.filename
                    color: "#eee"
                    opacity: 0.8
                }
            }
            Rectangle {
                visible: window.seekBarVisible || window.isFullscreen
                width: parent.width
                height: 1
                color: "#050405"
            }
            
            // Row 2: Playback Control Buttons + Volume Control
            Rectangle {
                visible: window.controlBarVisible || window.isFullscreen
                width: parent.width
                height: 1
                color: "#24272c"
            }
            Rectangle {
                visible: window.controlBarVisible || window.isFullscreen
                width: parent.width
                height: 26
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#312f31" }
                    GradientStop { position: 1.0; color: "#141214" }
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    height: parent.height

                    ControlBarButton {
                        iconSource: isPlaying ? "media-playback-pause.svg" : "media-playback-start.svg"
                        onClicked: {
                            if (isPlaying) {
                                video.pause()
                            } else {
                                video.play()
                            }
                        }
                    }

                    ControlBarButton {
                        iconSource: "media-playback-stop.svg"
                        onClicked: {
                            stopVideo()
                        }
                    }

                    ControlBarButton {
                        iconSource: "media-skip-backward.svg"
                        onClicked: {
                            previousVideo()
                        }
                    }

                    ControlBarButton {
                        iconSource: "media-skip-forward.svg"
                        onClicked: {
                            nextVideo()
                        }
                    }
                }
                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    height: parent.height

                    ControlBarButton {
                        iconSource: video.muted ? "audio-volume-muted.svg" : "audio-volume-high.svg"
                        onClicked: video.muted = !video.muted
                    }

                    VolumeSlider {
                        id: volumeSlider
                        width: 36
                        height: parent.height
                        value: video.volume


                        onValueChanged: {
                            video.volume = value
                            video.muted = false
                            console.log('volume', value, video.volume)
                        }
                    }
                }
            }
            Rectangle {
                visible: window.controlBarVisible || window.isFullscreen
                width: parent.width
                height: 1
                color: "#050405"
            }

            // Row 3: Stats
            Rectangle {
                visible: window.statisticsVisible || window.isFullscreen
                width: parent.width
                height: 1
                color: "#24272c"
            }
            Rectangle {
                visible: window.statisticsVisible || window.isFullscreen
                width: parent.width
                height: childrenRect.height
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#19181a" }
                    GradientStop { position: 1.0; color: "#0e1115" }
                }

                Column {
                    width: parent.width

                    StatisticRow { key: "Media"; value: "" + video.metaData.mediaType }
                    StatisticRow { key: "Video"; value: "" + video.hasVideo + " (" + video.metaData.videoCodec + ") (" + video.metaData.videoBitRate + ")" }
                    StatisticRow { key: "Audio"; value: "" + video.hasAudio + " (" + video.metaData.audioCodec + ") (" + video.metaData.audioBitRate + ")" }
                    StatisticRow { key: "Buffer"; value: "" + video.bufferProgress }
                    StatisticRow { key: "Playback"; value: "" + video.playbackRate }
                }
            }
            Rectangle {
                visible: window.statisticsVisible || window.isFullscreen
                width: parent.width
                height: 1
                color: "#050405"
            }

            // Row 4: Status + Playback Position / Duration
            Rectangle {
                visible: window.statusBarVisible || window.isFullscreen
                width: parent.width
                height: 1
                color: "#24272c"
            }
            Rectangle {
                visible: window.statusBarVisible || window.isFullscreen
                width: parent.width
                height: 23
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#19181a" }
                    GradientStop { position: 1.0; color: "#0e1115" }
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    height: parent.height

                    Text {
                        id: statusText
                        anchors.verticalCenter: parent.verticalCenter
                        text: {
                            var s = ""
                            if (video.playbackState == MediaPlayer.PlayingState) {
                                s += "Playing"
                            } else if (video.playbackState == MediaPlayer.PausedState) {
                                s += "Paused"
                            } else if (video.playbackState == MediaPlayer.StoppedState) {
                                s += "Stopped"
                            }

                            if (video.errorString) {
                                s += (s.length ? ' ' : '') + '(' + video.errorString + ')'
                            }
                            return s
                        }
                        color: "#716f71"
                    }
                }
                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    height: parent.height

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: formatTime(video.position) + " / " + formatTime(video.duration)
                        color: "#716f71"
                    }
                }
            }
            Rectangle {
                visible: window.statusBarVisible || window.isFullscreen
                width: parent.width
                height: 1
                color: "#050405"
            }
        }
    }

    

    DropArea {
        id: dropArea
        anchors.fill: parent
        onEntered: {
            console.log("onEntered")
        }
        onDropped: {
            console.log("onDropped")
            if (drop.hasUrls) {
                console.log('urls', drop.urls)
                for (var i = 0; i < drop.urls.length; i++) {
                    var url = drop.urls[i];
                    console.log('url', url);
                    drop.accept(Qt.CopyAction)
                    window.loadAndPlayVideo(url)
                    break;
                }
            }
        }
        onExited: {
            console.log("onExited")
        }
    }

    function loadAndPlayVideo(filepath) {
        video.source = filepath
    }

    function onVideoLoad() {
        if (video.metaData.resolution) {
            window.videoWidth = video.metaData.resolution.width
            window.videoHeight = video.metaData.resolution.height
            if (width >= Screen.desktopAvailableWidth || height >= Screen.desktopAvailableHeight) {
                window.visibility = Window.Maximized
            }
            console.log('resized', window.width, window.height)
        }
        video.play()
    }

    function previousVideo() {
        console.log('previousVideo')
    }

    function nextVideo() {
        console.log('nextVideo')
    }

    function toggleFullscreen() {
        if (window.isFullscreen) {
            window.show()
        } else {
            window.showFullScreen()
        }
    }

    function togglePlay() {
        if (isPlaying) {
            video.pause()
        } else {
            video.play()
        }
    }

    function stopVideo() {
        video.stop() // = video.restart()
        video.pause()
    }

    function zeroPad(n) {
        var s = n.toString();
        if (s.length == 0) s = "0";
        if (s.length == 1) s = "0" + s;
        return s;
    }
    function formatTime(t) {
        var totalSeconds = Math.floor(t / 1000);
        var seconds = totalSeconds % 60;
        var hours = Math.floor(totalSeconds / 3600);
        var minutes = Math.floor((totalSeconds - hours * 3600) / 60);
        return zeroPad(hours) + ":" + zeroPad(minutes) + ":" + zeroPad(seconds);
    }

    Component.onCompleted: {
        console.log('args', Qt.application.arguments)
        var args = Qt.application.arguments;
        if (args[0].lastIndexOf('/qmlscene') === args[0].length - '/qmlscene'.length) { // endswith
            // args[1] == Main.qml
            if (args.length >= 3) {
                var filepath = args[2];
                if (args[2].indexOf('--appargs=') === 0) {
                    filepath = args[2].substr('--appargs='.length);
                }
                loadAndPlayVideo(filepath);
            } else {
                // Testing
                var filepath = "tests/test.mp4"
                loadAndPlayVideo(filepath)
            }
        }
    }
}
