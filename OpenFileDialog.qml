import QtQuick 2.2
import QtQuick.Dialogs 1.0

FileDialog {
    id: openFileDialog
    title: "Open"
    folder: shortcuts.movies
    nameFilters: [
        "Media files (*.mp4 *.avi)",
        "All files (*)",
    ]

    onAccepted: {
        console.log("You chose: " + fileUrl)
        close()
        window.loadAndPlayVideo(fileUrl)
    }
    onRejected: {
        console.log("Canceled")
        close()
    }
}
