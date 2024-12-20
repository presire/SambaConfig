import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Universal

Item {
    id: root
    objectName: "pageAboutQt"
    focus: true

    property var parentName: null
    property int fontPadding: 0

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.ForwardButton | Qt.BackButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.ForwardButton) {
                parentName.screenMoved("", 1)
            }
            else if (mouse.button === Qt.BackButton) {
                parentName.screenMoved("", 0)
            }
        }
    }

    Component.onCompleted: {
        flickable.flickableDirection = Flickable.VerticalFlick
        flickable.boundsBehavior = Flickable.StopAtBounds
        flickable.ScrollBar.vertical = vbar
    }

    ScrollBar {
        id: vbar
        hoverEnabled: true
        active: hovered || pressed
        orientation: Qt.Vertical
        size: flickable.height / flickable.contentHeight
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.height
        clip: true

        Column {
            id: contentColumn
            width: flickable.width
            spacing: 10

            Item {
                width: parent.width
                height: Math.max(imgQt.height, aboutQtLabelHeader.height) + 40

                Image {
                    id: imgQt
                    source: "qrc:/ScreenIcon/Image/Qt.png"
                    fillMode: Image.PreserveAspectFit
                    width: 100
                    height: width
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    x: 20
                }

                Label {
                    id: aboutQtLabelHeader
                    text: qsTr("About Qt")
                    anchors.left: imgQt.right
                    anchors.right: parent.right
                    anchors.verticalCenter: imgQt.verticalCenter
                    leftPadding: 20
                    rightPadding: 20
                    font.pointSize: 20 + root.fontPadding
                    font.bold: true
                    wrapMode: Label.WordWrap
                }
            }

            Label {
                id: aboutQtLabel1
                text: qsTr("This software is developed with Qt %1.%2.%3.").arg(Qt_VERSION_MAJOR).arg(Qt_VERSION_MINOR).arg(Qt_VERSION_PATCH) + "\n\n" +
                      "Qt is a C++ toolkit for cross-platform application development." + "\n" +
                      "Qt provides single-source portability across all major desktop operating systems." + "\n" +
                      "It is also available for embedded Linux and other embedded and mobile operating systems." + "\n\n" +
                      "Qt is available under multiple licensing options designed to accommodate the needs of our various users."  + "\n\n" +
                      "Qt licensed under our commercial license agreement is appropriate for development of proprietary/commercial software " +
                      "where you do not want to share any source code with third parties or otherwise cannot comply with the terms of GNU (L)GPL." + "\n\n" +
                      "Qt licensed under GNU (L)GPL is appropriate for the development of Qt applications provided you can comply with the terms and " +
                      "conditions of the respective licenses."
                width: parent.width
                font.pointSize: 14 + root.fontPadding
                wrapMode: Label.WordWrap
                padding: 20
            }

            Label {
                id: aboutQtLabel2
                text: "<html><head/><body><p>Please see <a href=\"http://qt.io/licensing/\">qt.io/licensing</a> for an overview of Qt licensing.</p></body></html>"
                width: parent.width
                font.pointSize: 14 + root.fontPadding
                textFormat: Label.RichText
                wrapMode: Label.WordWrap
                padding: 20

                MouseArea {
                    id: mouseArea1
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Qt.openUrlExternally("http://qt.io/licensing/")
                    }
                }
            }

            Label {
                id: aboutQtLabel3
                text: "Copyright (C) 2024 The Qt Company Ltd and other contributors." + "\n" +
                      "Qt and the Qt logo are trademarks of The Qt Company Ltd." + "\n" +
                      "Qt is The Qt Company Ltd product developed as an open source project."
                width: parent.width
                font.pointSize: 14 + root.fontPadding
                wrapMode: Label.WordWrap
                padding: 20
            }

            Label {
                id: aboutQtLabel4
                text: "<html><head/><body><p>See <a href=\"http://qt.io/\">qt.io</a> for more information.</p></body></html>"
                width: parent.width
                font.pointSize: 14 + root.fontPadding
                textFormat: Label.RichText
                wrapMode: Label.WordWrap
                padding: 20

                MouseArea {
                    id: mouseArea2
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Qt.openUrlExternally("http://qt.io/")
                    }
                }
            }
        }
    }
}
