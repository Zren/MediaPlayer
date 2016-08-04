import QtQuick 2.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Slider {
    width: 36

    style: SliderStyle {
        groove: Item {
            Item {
                anchors.centerIn: parent
                width: groove.width
                height: groove.height

                Image {
                    id: groove
                    source: "volume-control.svg"
                    opacity: 0.5
                }

                Item {
                    anchors.left: parent.left
                    width: groove.width * (styleData.handlePosition / control.width)
                    height: groove.height
                    clip: true

                    Image {
                        width: groove.width
                        source: "volume-control.svg"
                    }
                }
            }
        }
        handle: Item {}
    }
}
