import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Material
import QtQuick.Controls.Universal
import SambaModel 1.0
import "../CustomQML"


Item {
    id: root
    objectName: "pageSambaConfig"
    focus: true

    property var    parentName:      null
    property int    fontPadding:     0
    property bool   bDark:           false
    property bool   bServerMode:     true
    property string localFileName:   ""
    property string remoteFileName:  ""
    property bool   bReadSuccess:    false
    property int    selectedIndex:   -1
    property var    headerWidths:    [parent.width * 0.3, parent.width * 0.20, parent.width * 0.1, parent.width * 0.1, parent.width * 0.30]

    Connections {
        target: sambaConfigReader
        function onConfigLoaded(sections) {
            // Display success popup.
            completePopup.viewTitle   = qsTr("Samba config file loaded successfully")
            completePopup.fontPadding = root.fontPadding
            completePopup.bAutoClose  = false
            completePopup.open()

            // Clear existing model data
            sambaModel.clearShares()

            // 各セクションのキー値をListModelに追加
            sections.forEach(section => {
                if (section.name.toLowerCase() === "global") {
                    // Special section : [global]
                    const shareData = {
                        "directory":   "",        // 通常、[global]セクションでpathキーは使用しない
                        "shareName":   section.name || "",//"global",
                        "permissions": "",        // 通常、[global]セクションでread onlyキーは使用しない
                        "visibility":  "",        // 通常、[global]セクションでbrowseableキーは使用しない
                        "description": section.values["comment"] || "",
                        "bAllUsers":   true,      // 通常、[global]セクションでvalid userキーは使用しない
                        "users":       [],        // 通常、[global]セクションでvalid userキーは使用しない
                        "ports":       section.values["smb ports"] ? section.values["smb ports"].split(/[,\s]+/).filter(port => port.length > 0) : []
                    }

                    sambaModel.updateOrAppendShare(-1, shareData)
                }
                else if (section.name.toLowerCase() === "homes") {
                    // Special section : [homes]
                    const shareData = {
                        "directory":   "",          // 通常、[homes]セクションでpathキーは使用しない
                        "shareName":   "homes",
                        "permissions": section.values["read only"] ? section.values["read only"].toLowerCase() === "yes" ? "Read Only" : "Read/Write" : "Read Only",
                        "visibility":  section.values["browseable"] ? section.values["browseable"].toLowerCase() === "yes" ? "Visible"  : "Hidden" : "Hidden",
                        "description": section.values["comment"] || "",
                        "bAllUsers":   section.values["valid users"] ? false : true,
                        "users":       section.values["valid users"] ? section.values["valid users"].split(/[,\s]+/).filter(user => user.length > 0) : []
                    }

                    sambaModel.updateOrAppendShare(-1, shareData)
                }
                else if (section.name.toLowerCase() === "printers") {
                    // Special section : [printers]
                    const shareData = {
                        "directory":   section.values["path"] || "",
                        "shareName":   "printers",
                        "permissions": "", // printersセクションにはread onlyがない
                        "visibility":  section.values["browseable"] ? section.values["browseable"].toLowerCase() === "yes" ? "Visible"  : "Hidden" : "Hidden",
                        "description": section.values["comment"] || "",
                        "bAllUsers":   true,
                        "users":       []
                    }

                    sambaModel.updateOrAppendShare(-1, shareData)
                }
                else {
                    // User definition section
                    const shareData = {
                        "directory":   section.values["path"] || "",
                        "shareName":   section.name || "",
                        "permissions": section.values["read only"] ?  section.values["read only"].toLowerCase() === "yes" ? "Read Only" : "Read/Write" : "Read Only",
                        "visibility":  section.values["browseable"] ? section.values["browseable"].toLowerCase() === "yes" ? "Visible"  : "Hidden" : "Hidden",
                        "description": section.values["comment"] || "",
                        "bAllUsers":   section.values["valid users"] ? false : true,
                        "users":       section.values["valid users"] ? section.values["valid users"].split(/[,\s]+/).filter(user => user.length > 0) : []
                    }

                    sambaModel.updateOrAppendShare(-1, shareData)
                }
            })

            root.bReadSuccess = true

            // Save used samba config file.
            ApplicationState.setSambaConfigFile(textSambaFilePath.text)
        }

        function onErrorOccurred(error) {
            // Error.
            root.bReadSuccess = false

            let componentDialog = Qt.createComponent("qrc:/qt/qml/Main/CustomQML/ErrorDialog.qml");

            if (componentDialog.status === Component.Error) {
                console.error(qsTr("Error loading component:"), componentDialog.errorString());
            }
            else if (componentDialog.status === Component.Ready) {
                let errorDialog = componentDialog.createObject(root,
                                                               {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
                                                                messageTitle: qsTr("Failed to read a samba config file"),
                                                                messageText: error});
                errorDialog.show();
            }
        }
    }

    Component.onCompleted: {
        textSambaFilePath.text = ApplicationState.getSambaConfigFile()
    }

    MouseArea {
        id: mouseAreaGeneral
        anchors.fill: parent
        acceptedButtons: Qt.ForwardButton | Qt.BackButton  // Enable "ForwardButton" and "BackButton" on mouse

        // Single click
        onClicked: function(mouse) {
            if (mouse.button === Qt.ForwardButton) {
                parentName.screenMoved("", 1)
            }
            else if (mouse.button === Qt.BackButton) {
                parentName.screenMoved("", 0)
            }
        }
    }

    ColumnLayout {
        anchors.fill:    parent
        anchors.margins: 20
        spacing:         0

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 20
            spacing:          10

            TextField {
                id:               textSambaFilePath
                text:             ""
                placeholderText:  ""
                Layout.fillWidth: true

                color:               root.bDark ? "white" : "black"
                font.pointSize:      14 + root.fontPadding
                enabled:             root.bServerMode
                horizontalAlignment: TextField.AlignLeft
                verticalAlignment:   TextField.AlignVCenter

                property real placeholderOpacity: 0.5

                background: Rectangle {
                    color: parent.activeFocus ? root.bDark ? "#505050" : "#e0e0ff" : root.bDark ? "#3f3f3f" : "#e0e0e0"
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
                    opacity: textSambaFilePath.placeholderOpacity
                    visible: !textSambaFilePath.text && !textSambaFilePath.activeFocus
                    font:    textSambaFilePath.font
                    elide:   Text.ElideRight
                    anchors {
                        left:           parent.left
                        right:          parent.right
                        leftMargin:     textSambaFilePath.leftPadding
                        rightMargin:    textSambaFilePath.rightPadding
                        verticalCenter: parent.verticalCenter
                    }
                }
            }

            RoundButton {
                id:     btnSambaFileSelect
                text:   ""
                Layout.preferredWidth:  64
                Layout.preferredHeight: 64

                icon.source: root.bServerMode ? pressed ? "qrc:/Image/FileButtonPressed.png" : "qrc:/Image/FileButton.png"
                                              : pressed ? "qrc:/Image/FileNetworkButtonPressed.png" : "qrc:/Image/FileNetworkButton.png"
                icon.width:  width
                icon.height: height
                icon.color:  "transparent"

                padding: 0

                background: Rectangle {
                    color: "transparent"
                }

                onClicked: {
                    if (root.bServerMode) {
                        // Server Mode.
                        var component = Qt.createComponent("qrc:/qt/qml/Main/CustomQML/FileSelectDialog.qml")
                        if (component.status === Component.Ready) {
                            var dialog = component.createObject(root,
                                                                {mainWidth:   root.width,       mainHeight: root.height,
                                                                 fontPadding: root.fontPadding, bDark:      root.bDark,
                                                                 bServerMode: root.bServerMode,
                                                                 rootDirectory: fileSelectDialog.getFirstDirectory("file://" + textSambaFilePath.text)})
                            dialog.fileSelected.connect(function(filePath) {
                                textSambaFilePath.text = filePath
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

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20

            spacing:          30

            Button {
                id:                     readButton
                text:                   qsTr("Read") + "(<u>R</u>)"
                Layout.preferredWidth:  Math.max(200, Math.min(Math.round(root.width / 5), 250))
                Layout.preferredHeight: Math.max(35,  Math.min(Math.round(root.height / 20), 70))
                font.pointSize:         14 + root.fontPadding

                Layout.alignment:       Qt.AlignHCenter

                contentItem: Label {
                    text:                parent.text
                    font:                parent.font
                    textFormat:          Label.RichText
                    opacity:             enabled ? 1.0 : 0.3
                    color:               root.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                    elide:               Label.ElideRight
                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment:   Label.AlignVCenter
                }

                background: Rectangle {
                    color:        parent.pressed ? border.color : "transparent"
                    opacity:      enabled ? parent.pressed ? 0.8 : 1 : 0.3
                    border.color: root.bDark ? "#10980a" : "#20a81a"
                    border.width: parent.pressed ? 0 : 2
                    radius:       5
                    anchors.fill: parent
                }

                onClicked: {
                    // Read smb.conf file.
                    sambaConfigReader.loadConfig(textSambaFilePath.text)
                }

                Shortcut {
                    sequence: "Alt+R"
                    onActivated: {
                        readButton.clicked()
                    }
                }
            }

            Button {
                id:                     writeButton
                text:                   qsTr("Write") + "(<u>W</u>)"
                Layout.preferredWidth:  Math.max(200, Math.min(Math.round(root.width / 5), 250))
                Layout.preferredHeight: Math.max(35,  Math.min(Math.round(root.height / 20), 70))
                font.pointSize:         14 + root.fontPadding
                enabled:                root.bReadSuccess

                Layout.alignment:       Qt.AlignHCenter

                contentItem: Label {
                    text:                parent.text
                    font:                parent.font
                    opacity:             enabled ? 1.0 : 0.3
                    color:               root.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                    elide:               Label.ElideRight
                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment:   Label.AlignVCenter
                }

                background: Rectangle {
                    color:        parent.pressed ? border.color : "transparent"
                    opacity:      enabled ? parent.pressed ? 0.8 : 1 : 0.3
                    border.color: root.bDark ? "#10980a" : "#20a81a"
                    border.width: parent.pressed ? 0 : 2
                    radius:       5
                    anchors.fill: parent
                }

                onClicked: {
                    // Write smb.conf file.
                }

                Shortcut {
                    sequence: "Alt+W"
                    onActivated: {
                        writeButton.clicked()
                    }
                }
            }
        }

        Button {
            id: addButton
            text:   "+"
            width:  40
            height: 40
            //enabled: root.bReadSuccess

            onClicked: {
                // Add a new item to the listModel
                openEditWindow(-1)
            }
        }

        // Header Row
        ListModel {
            id: headerModel
            ListElement { name: "Directory";   }
            ListElement { name: "Share name";  }
            ListElement { name: "Permissions"; }
            ListElement { name: "Visibility";  }
            ListElement { name: "Description"; }
        }

        Rectangle {
            id: headerRow
            Layout.fillWidth: true
            height: 30
            color: root.bDark ? "#505050" : "#e0e0e0"
            border.width: 1
            border.color: root.bDark ? "lightgrey" : "darkgrey"

            Layout.topMargin: 20

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: headerModel

                    delegate: Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: root.headerWidths[index]

                        Label {
                            text:           headerModel.get(index).name
                            font.pointSize: 12 + root.fontPadding
                            font.bold:      true
                            color:          root.bDark ? "white" : "black"

                            verticalAlignment:   Label.AlignVCenter
                            horizontalAlignment: Label.AlignLeft

                            anchors.fill:        parent
                            leftPadding:         5
                        }

                        // Vertical line
                        Rectangle {
                            width:   1
                            height:  parent.height
                            color:   root.bDark ? "white" : "black"
                            opacity: 0.5

                            Layout.alignment: Qt.AlignRight
                        }

                        // MouseArea {
                        //     width: 5
                        //     height: parent.height
                        //     cursorShape: Qt.SplitHCursor
                        //     anchors.right: parent.right

                        //     property int startX
                        //     property int startWidth

                        //     onPressed: {
                        //         startX     = mouseX
                        //         startWidth = root.headerWidths[index]
                        //     }

                        //     onPositionChanged: {
                        //         if (pressed) {
                        //             //var delta                     = mouse.x - startX
                        //             //root.headerWidths[index]     += delta
                        //             //root.headerWidths[index + 1] -= delta

                        //             var newWidth             = Math.max(50, startWidth + mouseX - startX)
                        //             root.headerWidths[index] = newWidth
                        //             console.log(root.headerWidths[index])
                        //         }
                        //     }
                        // }
                    }
                }
            }
        }

        // SambaModelのインスタンスを作成
        SambaModel {
            id: sambaModel
        }

        ListView {
            id:                listView
            Layout.fillWidth:  true
            Layout.fillHeight: true
            clip:              true

            model: sambaModel

            delegate: Rectangle {
                width:  listView.width
                height: 50
                color:  index === selectedIndex ? "#3daee9" :
                        root.bDark              ? index % 2 === 0 ? "#606060" : "#6f6f6f" :
                                                  index % 2 === 0 ? "#f0f0f0" : "#ffffff"
                border.width: 1
                border.color: root.bDark ? "lightgrey" : "darkgrey"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 0
                    spacing: 0

                    Repeater {
                        model: ["directory", "shareName", "permissions", "visibility", "description"]

                        delegate: Item {
                            Layout.preferredWidth: root.headerWidths[index]
                            Layout.fillHeight:     true

                            Text {
                                text: modelData === "directory"   ? directory   :
                                      modelData === "shareName"   ? shareName   :
                                      modelData === "permissions" ? permissions :
                                      modelData === "visibility"  ? visibility  :
                                      description
                                font.pointSize:     12 + root.fontPadding
                                color:              root.bDark ? "white" : "black"
                                elide:              Text.ElideRight
                                verticalAlignment:  Text.AlignVCenter
                                anchors.fill:       parent
                                anchors.leftMargin: 5
                            }

                            Rectangle {
                                width:            1
                                height:           parent.height
                                color:            root.bDark ? "white" : "black"
                                opacity:          0.5
                                Layout.alignment: Qt.AlignRight
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        root.selectedIndex = index
                    }

                    onDoubleClicked: {
                        openEditWindow(index)
                    }
                }
            }
        }
    }

    function openEditWindow(index) {
        var component = Qt.createComponent("EditShareWindow.qml")
        if (component.status === Component.Ready) {
            // getItemDataメソッドを使用してデータを取得
            var initialData = index !== -1 ? sambaModel.getItemData(index) : {}

            console.log("Retrieved data:", JSON.stringify(initialData))

            var window = component.createObject(root, {
                width:       Math.max(800, root.width),
                height:      Math.max(600, Math.round(root.height * 3 / 4)),
                bDark:       root.bDark,
                fontPadding: root.fontPadding,
                itemData:    initialData,
                index:       index
            })

            window.accepted.connect(function(newData) {
                sambaModel.updateOrAppendShare(index, newData)
            })

            window.show()
        }
        else if (component.status === Component.Error) {
            console.error("Error loading component:", component.errorString())
        }
    }

    CompletePopup {
        id: completePopup

        viewTitle: ""
        positionY: 0
        viewWidth: root.width
        fontPadding: 0
        parentName: root.parentName
    }
}
