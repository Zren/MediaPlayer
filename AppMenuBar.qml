import QtQuick 2.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Private 1.0

MenuBar {
    id: menuBar

    // style: MenuBarStyle {
    //     function formatMnemonic(text, underline) {
    //         return underline ? StyleHelpers.stylizeMnemonics(text) : StyleHelpers.removeMnemonics(text)
    //     }
   
    //     background: Rectangle {
    //         visible: window.menuBarVisible
    //         color: "#dcdcdc"
    //         height: window.menuBarVisible ? 20 : 0
    //     }
    //     itemDelegate: Rectangle {
    //         visible: window.menuBarVisible
    //         implicitWidth: text.width + 12
    //         implicitHeight: window.menuBarVisible ? text.height + 4 : 0
    //         color: styleData.open ? "#49d" : "transparent"

    //         Text {
    //             visible: window.menuBarVisible
    //             id: text
    //             text: formatMnemonic(styleData.text, styleData.underlineMnemonic)
    //             anchors.centerIn: parent
    //             renderType: Text.NativeRendering
    //             color: styleData.open ? "white" : "highlight"
    //             font.pointSize: window.menuBarVisible ? 10 : 1
    //         }
    //         Component.onCompleted: {
    //             console.log('window.menuBarVisible', window.menuBarVisible)
    //         }
    //     }
    // }

    // Binding {
    //     target: window
    //     onMenuBarVisible: {
    //         // menuBar.style = visibleStyle
    //         menuBar.style = hiddenStyle
    //     }
    // }

    // http://stackoverflow.com/a/27326837/947742
    // property real hideValue: visible ? 1 : 0
    // Behavior on hideValue {
    //     NumberAnimation {duration: 200}
    // }
    // __contentItem.transform: Scale { yScale: hideValue }


    Menu {
        title: "File"

        // MenuItem {
        //     text: "Quick Open File..."
        //     shortcut: "Ctrl+Q"
        //     onTriggered: openFileDialog.open()
        // }

        // MenuSeparator {}

        MenuItem {
            text: "Open File..."
            shortcut: "Ctrl+O"
            onTriggered: openFileDialog.open()
        }

        // MenuItem {
        //     text: "Open Directory..."
        // }

        Menu {
            id: recentFilesMenu
            title: "Recent Files"
            enabled: items.length > 0
        }

        MenuSeparator {}

        // MenuItem {
        //     text: "Properties"
        //     shortcut: "Shift+F10"
        // }

        MenuItem {
            text: "Exit"
            shortcut: "Alt+X"
            onTriggered: Qt.quit()
        }
    }




    Menu {
        title: "View"

        MenuItem {
            text: "Hide Menu"
            shortcut: "Ctrl+0"
            checkable: true
            checked: window.hideMenuBar
            onTriggered: {
                window.hideMenuBar = !window.hideMenuBar
            }
        }

        MenuItem {
            text: "Seek Bar"
            shortcut: "Ctrl+1"
            checkable: true
            checked: window.seekBarVisible
            onTriggered: window.seekBarVisible = !window.seekBarVisible
        }

        MenuItem {
            text: "Controls"
            shortcut: "Ctrl+2"
            checkable: true
            checked: window.controlBarVisible
            onTriggered: window.controlBarVisible = !window.controlBarVisible
        }

        MenuItem {
            text: "Statistics"
            shortcut: "Ctrl+4"
            checkable: true
            checked: window.statisticsVisible
            onTriggered: window.statisticsVisible = !window.statisticsVisible
        }

        MenuItem {
            text: "Status"
            shortcut: "Ctrl+5"
            checkable: true
            checked: window.statusBarVisible
            onTriggered: window.statusBarVisible = !window.statusBarVisible
        }

        Menu {
            title: "Presets"

            MenuItem {
                text: "Minimal"
                shortcut: "1"
                onTriggered: {
                    window.bordersVisible = false
                    window.titleBarVisible = false
                    window.menuBarVisible = false
                    window.seekBarVisible = false
                    window.controlBarVisible = false
                    window.statusBarVisible = false
                }
            }

            MenuItem {
                text: "Compact"
                shortcut: "2"
                onTriggered: {
                    window.bordersVisible = true
                    window.titleBarVisible = false
                    window.menuBarVisible = false
                    window.seekBarVisible = false
                    window.controlBarVisible = true
                    window.statusBarVisible = false
                }
            }

            MenuItem {
                text: "Normal"
                shortcut: "3"
                onTriggered: {
                    window.bordersVisible = true
                    window.titleBarVisible = true
                    window.menuBarVisible = true
                    window.seekBarVisible = true
                    window.controlBarVisible = true
                    window.statusBarVisible = true
                }
            }
        }

        MenuSeparator {}

        MenuItem {
            text: "Full Screen"
            shortcut: "Ctrl+Return"
            checkable: true
            checked: window.isFullscreen
            onTriggered: window.toggleFullscreen()
        }

        MenuSeparator {}

        Menu {
            title: "On Top"

            MenuItem {
                text: "Never"
                shortcut: window.alwaysOnTop == 'always' ? "Ctrl+A" : null
                checkable: true
                checked: window.alwaysOnTop == 'never'
                onTriggered: window.alwaysOnTop = 'never'
            }

            MenuItem {
                text: "Always"
                shortcut: window.alwaysOnTop == 'never' ? "Ctrl+A" : null
                checkable: true
                checked: window.alwaysOnTop == 'always'
                onTriggered: window.alwaysOnTop = 'always'
            }

            MenuItem {
                text: "While Playing"
                checkable: true
                checked: window.alwaysOnTop == 'whilePlaying'
                onTriggered: window.alwaysOnTop = 'whilePlaying'
            }
        }

        MenuSeparator {}

        MenuItem {
            text: "Options"
            shortcut: "O"
        }
    }



    Menu {
        title: "Play"

        MenuItem {
            text: "Play/Pause"
            shortcut: "Space"
            enabled: video.source && video.isLoaded
            onTriggered: window.togglePlay()
        }

        MenuItem {
            text: "Stop"
            shortcut: "."
            enabled: video.source && video.isLoaded
            onTriggered: window.stopVideo()
        }

        MenuSeparator {}

        Menu {
            title: "Volume"

            MenuItem {
                text: "Up"
                shortcut: "Up"
                onTriggered: video.volume = Math.min(1, video.volume + 0.1) // +10%
            }

            MenuItem {
                text: "Down"
                shortcut: "Down"
                onTriggered: video.volume = Math.max(0, video.volume - 0.1) // -10%
            }

            MenuItem {
                text: "Mute"
                shortcut: "Ctrl+M"
                onTriggered: video.muted = !video.muted
            }
        }
    }




    Menu {
        title: "Navigate"

        MenuItem {
            text: "Previous"
            shortcut: "PgUp"
            enabled: video.source && video.isLoaded
            onTriggered: window.previousVideo()
        }

        MenuItem {
            text: "Next"
            shortcut: "PgDown"
            enabled: video.source && video.isLoaded
            onTriggered: window.nextVideo()
        }
    }



    Menu {
        title: "Help"

        MenuItem {
            text: "Home Page"
        }

        MenuSeparator {}

        MenuItem {
            text: "About"
        }
    }
}
