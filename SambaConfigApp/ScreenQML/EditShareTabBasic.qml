import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls.Material
import QtQuick.Controls.Universal
import "../CustomQML"


Item {
    id: root

    property int    viewWidth:   0
    property int    viewHeight:  0
    property int    fontPadding: 0
    property bool   bDark:       false
    property bool   bServerMode: true
    property string directory:   ""
    property string shareName:   ""
    property string permissions: ""
    property string visibility:  ""
    property string description: ""
    property var    sambaConfig: null

    // Dynamic application of themes
    Material.theme:  root.bDark ? Material.Dark : Material.Light
    Universal.theme: root.bDark ? Universal.Dark : Universal.Light

    Component.onCompleted: {
        if (root.shareName.toLowerCase() === "global") {
            directoryField.enabled    = false
            btnSambaDirSelect.enabled = false
            permissionsCombo.enabled  = false
            visibilityCombo.enabled   = false
            descriptionArea.enabled   = false
        }
    }

    ScrollView {
        id:            scrollView
        width:         parent.viewWidth
        height :       parent.viewHeight
        contentWidth:  tabBasicColumn.width   // The important part
        contentHeight: tabBasicColumn.height  // Same
        clip:          true                   // Prevent drawing column outside the scrollview borders
        padding:       20                     // Overall left and right padding

        ScrollBar.vertical.interactive: true

        ColumnLayout {
            id:         tabBasicColumn
            width:      scrollView.width - 40
            spacing:    10

            Label {
                text:            qsTr("Directory:")
                font.pointSize:  12 + root.fontPadding
            }

            RowLayout {
                Layout.fillWidth: true
                spacing:          10

                TextField {
                    id:               directoryField
                    text:             root.directory
                    placeholderText:  ""
                    Layout.fillWidth: true

                    color:               root.bDark ? "white" : "black"
                    opacity:             enabled ? 1.0 : 0.2
                    font.pointSize:      14 + root.fontPadding
                    enabled:             root.bServerMode
                    horizontalAlignment: TextField.AlignLeft
                    verticalAlignment:   TextField.AlignVCenter

                    property real placeholderOpacity: 0.5

                    background: Rectangle {
                        color:        parent.activeFocus ? root.bDark ? "#505050" : "#e0e0ff" : root.bDark ? "#3f3f3f" : "#e0e0e0"
                        border.width: parent.activeFocus ? root.bDark ? 2 : 1 : 1
                        border.color: parent.activeFocus ? root.bDark ? "dodgerblue" : "lightblue" : root.bDark ? "grey" : "lightgrey"
                    }

                    states: [
                        State {
                            name: "focused"
                            when: activeFocus
                            PropertyChanges {
                                target: background
                                color: root.bDark ? "#303050" : "#e0e0ff"
                            }
                        }
                    ]

                    // for custom place holder text
                    Text {
                        id:      customPlaceholder
                        text:    root.bServerMode ? qsTr("Click the right icon, select \"smb.conf\" Ex: /etc/samba/smb.conf") :
                                                    qsTr("Click the right icon, select \"smb.conf\" on remote server")
                        color:   root.bDark ? "white" : "black"
                        opacity: directoryField.placeholderOpacity
                        visible: !directoryField.text && !directoryField.activeFocus
                        font:    directoryField.font
                        elide:   Text.ElideRight

                        anchors {
                            left:           parent.left
                            right:          parent.right
                            leftMargin:     directoryField.leftPadding
                            rightMargin:    directoryField.rightPadding
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    onTextEdited: {
                        root.directory = text
                    }
                }

                RoundButton {
                    id:     btnSambaDirSelect
                    text:   ""
                    Layout.preferredWidth:  64
                    Layout.preferredHeight: 64
                    icon.source: root.bServerMode ? pressed ? "qrc:/Image/FileButtonPressed.png" : "qrc:/Image/FileButton.png"
                                                  : pressed ? "qrc:/Image/FileNetworkButtonPressed.png" : "qrc:/Image/FileNetworkButton.png"
                    icon.width:  width
                    icon.height: height
                    icon.color:  "transparent"
                    opacity:     enabled ? 1.0 : 0.2
                    padding:     0

                    background: Rectangle {
                        color: "transparent"
                    }

                    onClicked: {
                        if (root.bServerMode) {
                            // Server Mode.
                            var component = Qt.createComponent("qrc:/qt/qml/Main/CustomQML/FolderSelectDialog.qml")
                            if (component.status === Component.Ready) {
                                var dialog = component.createObject(root,
                                                                    {mainWidth:   root.width,       mainHeight: root.height,
                                                                     fontPadding: root.fontPadding, bDark:      root.bDark,
                                                                     bServerMode: root.bServerMode,
                                                                     rootDirectory: fileSelectDialog.getFirstDirectory("file://" + directoryField.text)})
                                dialog.directorySelected.connect(function(filePath) {
                                    //directoryField.text = filePath
                                    root.directory = filePath
                                })
                                dialog.show()
                            }
                            else if (component.status === Component.Error) {
                                console.error("Error loading component:", component.errorString())
                            }
                        }
                        else {
                            // Client Mode.
                            //Testparm.downloadSambaConfigFile(parentName.width, parentName.height, root.bDark, root.fontPadding)
                        }
                    }
                }
            }

            Label {
                text:           qsTr("Share Name:")
                font.pointSize: 12 + root.fontPadding
            }

            TextField {
                id:                  shareNameField
                text:                root.shareName || ""
                placeholderText:     ""
                color:               root.bDark ? "white" : "black"
                font.pointSize:      14 + root.fontPadding
                Layout.fillWidth:    true
                horizontalAlignment: TextField.AlignLeft
                verticalAlignment:   TextField.AlignVCenter

                property real placeholderOpacity: 0.5

                background: Rectangle {
                    color:        parent.activeFocus ? root.bDark ? "#505050" : "#e0e0ff" : root.bDark ? "#3f3f3f" : "#e0e0e0"
                    border.width: parent.activeFocus ? root.bDark ? 2 : 1 : 1
                    border.color: parent.activeFocus ? root.bDark ? "dodgerblue" : "lightblue" : root.bDark ? "grey" : "lightgrey"
                }

                states: [
                    State {
                        name: "focused"
                        when: activeFocus
                        PropertyChanges {
                            target: background
                            color: root.bDark ? "#303050" : "#e0e0ff"
                        }
                    }
                ]

                // for custom place holder text
                Text {
                    text:    root.bServerMode ? qsTr("Click the right icon, select \"smb.conf\" Ex: /etc/samba/smb.conf") :
                                                qsTr("Click the right icon, select \"smb.conf\" on remote server")
                    color:   root.bDark ? "white" : "black"
                    opacity: shareNameField.placeholderOpacity
                    visible: !shareNameField.text && !shareNameField.activeFocus
                    font:    shareNameField.font
                    elide:   Text.ElideRight

                    anchors {
                        left:           parent.left
                        right:          parent.right
                        leftMargin:     shareNameField.leftPadding
                        rightMargin:    shareNameField.rightPadding
                        verticalCenter: parent.verticalCenter
                    }
                }

                onTextEdited: {
                    root.shareName = text
                }
            }

            Label {
                text:           qsTr("Permissions:")
                font.pointSize: 12 + root.fontPadding
            }

            ComboBox {
                id:               permissionsCombo
                font.pointSize:   14 + root.fontPadding
                opacity:          enabled ? 1.0 : 0.2
                Layout.fillWidth: true
                model:            ["Read Only", "Read/Write"]
                currentIndex:     model.indexOf(root.permissions || "Read Only")

                onCurrentIndexChanged: {
                    root.permissions = currentIndex === 0 ? "Read Only" : "Read/Write"
                }
            }

            Label {
                text:           qsTr("Visibility:")
                font.pointSize: 12 + root.fontPadding
            }

            ComboBox {
                id:               visibilityCombo
                font.pointSize:   14 + root.fontPadding
                opacity:          enabled ? 1.0 : 0.2
                Layout.fillWidth: true
                model:            ["Visible", "Hidden"]
                currentIndex:     model.indexOf(root.visibility || "Visible")

                onCurrentIndexChanged: {
                    root.visibility = currentIndex === 0 ? "Visible" : "Hidden"
                }
            }

            Label {
                text:           qsTr("Description:")
                font.pointSize: 12 + root.fontPadding
            }

            TextArea {
                id:                  descriptionArea
                text:                root.description || ""
                font.pointSize:      14 + root.fontPadding
                color:               root.bDark ? "white" : "black"
                opacity:             enabled ? 1.0 : 0.2
                wrapMode:            TextArea.Wrap
                Layout.fillWidth:    true
                horizontalAlignment: TextArea.AlignLeft

                property real placeholderOpacity: 0.5

                background: Rectangle {
                    color:        parent.activeFocus ? root.bDark ? "#505050" : "#e0e0ff" : root.bDark ? "#3f3f3f" : "#e0e0e0"
                    border.width: parent.activeFocus ? root.bDark ? 2 : 1 : 1
                    border.color: parent.activeFocus ? root.bDark ? "dodgerblue" : "lightblue" : root.bDark ? "grey" : "lightgrey"
                }

                states: [
                    State {
                        name: "focused"
                        when: activeFocus
                        PropertyChanges {
                            target: background
                            color: root.bDark ? "#303050" : "#e0e0ff"
                        }
                    }
                ]

                // for custom place holder text
                Text {
                    text:    root.bServerMode ? qsTr("Click the right icon, select \"smb.conf\" Ex: /etc/samba/smb.conf") :
                                                qsTr("Click the right icon, select \"smb.conf\" on remote server")
                    color:   root.bDark ? "white" : "black"
                    opacity: descriptionArea.placeholderOpacity
                    visible: !descriptionArea.text && !descriptionArea.activeFocus
                    font:    descriptionArea.font
                    elide:   Text.ElideRight

                    anchors {
                        left:           parent.left
                        right:          parent.right
                        leftMargin:     descriptionArea.leftPadding
                        rightMargin:    descriptionArea.rightPadding
                        verticalCenter: parent.verticalCenter
                    }
                }

                onTextChanged: {
                    root.description = text
                }
            }
        }
    }
}
