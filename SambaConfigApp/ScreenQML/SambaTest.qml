import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Universal
import "../CustomQML"


Item {
    id: root
    objectName: "pageSambaTest"
    focus: true

    // Property
    property var    parentName:      null
    property bool   bServerMode:     true
    property bool   bDark:           false
    property int    fontPadding:     0
    property int    option:          0
    property string localFileName:   ""
    property string remoteFilePath:  ""


//    // Set Downloaded file from remote server.
//    Connections {
//        target: Testparm
//        function onDownloadSambaFileFromServer(remoteFilePath, contents) {
//            root.remoteFilePath = remoteFilePath
//            textSambaFilePath.text = "remote:/" + remoteFilePath
//        }
//    }

//    // Set Downloaded file from remote server.
//    Connections {
//        target: Testparm
//        function onReadTestparmResult(status: int, message: string) {
//            if (status === 0) {
//                // If testparm command is test mode, create message.
//                if (root.option === 0) {
//                    message = qsTr("Success.") + "<br>" + qsTr("There is nothing wrong with smb.conf file.")
//                }

//                // Display result.
//                outputLabel.text = message

//                // Display success popup.
//                completePopup.viewTitle   = qsTr("The testparm command was successfully executed on remote server")
//                completePopup.fontPadding = root.fontPadding
//                completePopup.bAutoClose   = false
//                completePopup.open()
//            }
//            else {
//                // Error.
//                let componentDialog = Qt.createComponent("qrc:/qt/qml/Main/CustomQML/ErrorDialog.qml");
//                if (componentDialog.status === Component.Ready) {
//                    let errorDialog = componentDialog.createObject(root,
//                                                                   {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
//                                                                    messageTitle: qsTr("Exec Error"),
//                                                                    messageText: qsTr("The testparm failed to execute.") + "<br>" + message});
//                    errorDialog.show();
//                }
//            }

//            Testparm.disconnectFromServer()
//        }
//    }

//    function fnExecuteRemoteTestparmCommand() {
//        let componentDialog = null
//        let errorDialog     = null

//        if (remoteFilePath === "") {
//            // Error.
//            componentDialog = Qt.createComponent("qrc:/qt/qml/Main/CustomQML/ErrorDialog.qml");
//            if (componentDialog.status === Component.Ready) {
//                errorDialog = componentDialog.createObject(root,
//                                                           {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
//                                                            messageTitle: qsTr("Exec Error"),
//                                                            messageText: qsTr("Do not select smb.conf file on remote server.") + "<br>"});
//                errorDialog.show();
//            }
//        }
//        else {
//            let iRet = Testparm.executeRemoteTestparmCommand(commandEdit.text, root.remoteFilePath, root.option)

//            if (iRet !== 0) {
//                // Error.
//                let errMsg = Testparm.getErrorMessage()
//                componentDialog = Qt.createComponent("qrc:/qt/qml/Main/CustomQML/ErrorDialog.qml");
//                if (componentDialog.status === Component.Ready) {
//                    errorDialog = componentDialog.createObject(root,
//                                                               {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
//                                                                messageTitle: qsTr("Exec Error"),
//                                                                messageText: qsTr("Failed to execute the testparm command.") + "<br>" + errMsg});
//                    errorDialog.show();
//                }
//            }
//        }
//    }

    MouseArea {
        id: mouseAreaSambaTest
        anchors.fill: parent
        acceptedButtons: Qt.ForwardButton | Qt.BackButton  // Enable "ForwardButton" and "BackButton" on mouse
        hoverEnabled: true
        cursorShape: optionCheck.hoverd ? Qt.PointingHandCursor : Qt.ArrowCursor
        z: 1

        // Single click
        onClicked: function(mouse) {
            if (mouse.button === Qt.ForwardButton) {
                parentName.screenMoved("", 1)
            }
            else if (mouse.button === Qt.BackButton) {
                parentName.screenMoved("", 0)
            }
        }

        onMouseXChanged: function(mouseX, mouseY, cursorShape) {
            let optionX  = optionCheck.mapToItem(root, 0, 0).x
            let optionY  = optionCheck.mapToItem(root, 0, 0).y
            let commandX = commandCheck.mapToItem(root, 0, 0).x
            let commandY = commandCheck.mapToItem(root, 0, 0).y

            if (mouseX >= optionX && mouseX <= (optionX + optionCheck.width) &&
                mouseY >= optionY && mouseY <= (optionY + optionCheck.height)) {
                    cursorShape = Qt.PointingHandCursor
            }
            else if (mouseX >= commandX && mouseX <= (commandX + commandCheck.width) &&
                     mouseY >= commandY && mouseY <= (commandY + commandCheck.height)) {
                cursorShape = Qt.PointingHandCursor
            }
            else {
                cursorShape = Qt.ArrowCursor
            }
        }
    }

    ScrollView {
        id: scrollSambaTest
        anchors.fill: parent
        clip : true                          // Prevent drawing column outside the scrollview borders

        ColumnLayout {
            id: sambaTestColumn
            width: scrollSambaTest.width
            spacing: 5

            Label {
                text: qsTr("Check the syntax in smb.conf")

                textFormat: Label.RichText
                font.pointSize: 14 + root.fontPadding

                wrapMode: Label.WordWrap

                verticalAlignment: Label.AlignVCenter
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                Layout.topMargin: 50
                Layout.leftMargin: (root.width - width) / 2
            }

            RowLayout {
                width: parent.width
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: (root.width - width) / 2

                spacing: 10

                TextField {
                    id:                 textSambaFilePath
                    text:               FileDialogHelper.selectedFile
                    placeholderText:    ""
                    implicitWidth:      root.width * 0.5
                    color:              root.bDark ? "white" : "black"
                    font.pointSize:     14 + root.fontPadding
                    enabled:            root.bServerMode ? true : false

                    horizontalAlignment:    TextField.AlignLeft
                    verticalAlignment:      TextField.AlignVCenter

                    property real placeholderOpacity: 0.5  // プレースホルダーのopacityを制御するプロパティ

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
                        id: customPlaceholder
                        text: root.bServerMode ? qsTr("Click the right icon, select \"smb.conf\" Ex: /etc/samba/smb.conf") :
                                                 qsTr("Click the right icon, select \"smb.conf\" on remote server")
                        color: root.bDark ? "white" : "black"
                        opacity: textSambaFilePath.placeholderOpacity
                        visible: !textSambaFilePath.text && !textSambaFilePath.activeFocus
                        font: textSambaFilePath.font
                        elide: Text.ElideRight
                        anchors {
                            left: parent.left
                            right: parent.right
                            leftMargin: textSambaFilePath.leftPadding
                            rightMargin: textSambaFilePath.rightPadding
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    Component.onCompleted: {
                        text = ApplicationState.getSambaTestFile()
                    }
                }

                RoundButton {
                    id: btnSambaFileSelect
                    text: ""
                    width: 64
                    height: 64

                    icon.source: root.bServerMode ? pressed ? "qrc:/Image/FileButtonPressed.png" : "qrc:/Image/FileButton.png"
                                                  : pressed ? "qrc:/Image/FileNetworkButtonPressed.png" : "qrc:/Image/FileNetworkButton.png"
                    icon.width: width
                    icon.height: height
                    icon.color: "transparent"

                    padding: 0

                    Layout.leftMargin: 20

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
                        }
                        else {
                            // Client Mode.
                            Testparm.downloadSambaConfigFile(parentName.width, parentName.height, root.bDark, root.fontPadding)
                        }
                    }
                }
            }

            GridLayout {
                id: gridOptionCommand
                width: parent.width

                rows: 1
                columns: 2
                columnSpacing: root.width * 0.1 - parent.spacing
                Layout.topMargin: 20

                // testparm Option.
                Rectangle {
                    implicitWidth: root.width * 0.45
                    implicitHeight: optionCheck.height + (optionCheck.bChecked ? optionColumn.height : 0)
                    color: "transparent"

                    Layout.column: 0
                    Layout.row: 0
                    Layout.columnSpan: 1
                    Layout.rowSpan: 1

                    Layout.alignment: Qt.AlignTop

                    Label {
                        id: optionCheck
                        text: qsTr("Output option (click)")
                        font.pointSize: 14 + root.fontPadding
                        wrapMode: Label.WordWrap

                        verticalAlignment: Label.AlignVCenter
                        anchors.horizontalCenter: parent.horizontalCenter

                        property bool bChecked: false

                        MouseArea {
                            id: mouseAreaOption
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            propagateComposedEvents: true
                            z: 2

                            onEntered: {}
                            onExited: {}

                            onClicked: {
                                if (!optionCheck.bChecked) {
                                    optionCheck.text = qsTr("Output option")
                                }
                                else {
                                    optionCheck.text = qsTr("Output option (click)")
                                }

                                optionCheck.bChecked = !optionCheck.bChecked
                            }
                        }
                    }

                    ColumnLayout {
                        id: optionColumn
                        width: parent.width
                        visible: optionCheck.bChecked ? true : false

                        spacing: 0

                        anchors.top: optionCheck.bottom

                        ButtonGroup {
                            id: optionGroup
                            buttons: optionColumn.children

                            onClicked: {
                                root.option = optiontBtn.checked ? 0 : optionTBtn.checked ? 1 : optionTDBtn.checked ? 2 : 3
                            }
                        }

                        RadioButton {
                            id: optiontBtn
                            text: qsTr("Display only valid settings.")
                            checked: true
                            font.pointSize: 12 + root.fontPadding

                            ButtonGroup.group: optionGroup

                            Layout.leftMargin: (parent.width - optionTDBtn.width) / 2
                        }

                        RadioButton {
                            id: optionTBtn
                            text: qsTr("Display detailed output.")
                            font.pointSize: 12 + root.fontPadding

                            ButtonGroup.group: optionGroup

                            Layout.leftMargin: (parent.width - optionTDBtn.width) / 2
                        }

                        RadioButton {
                            id: optionTDBtn
                            text: qsTr("Display all parameters and values.")
                            font.pointSize: 12 + root.fontPadding

                            ButtonGroup.group: optionGroup

                            Layout.leftMargin: (parent.width - optionTDBtn.width) / 2
                        }
                    }
                }

                // testparm Command Path
                Rectangle {
                    implicitWidth: root.width * 0.45
                    implicitHeight: commandCheck.height + (commandCheck.bChecked ? commandEdit.height : 0)
                    color: "transparent"

                    Layout.column: 1
                    Layout.row: 0
                    Layout.columnSpan: 1
                    Layout.rowSpan: 1

                    Layout.alignment: Qt.AlignTop

                    Label {
                        id: commandCheck
                        text: qsTr("Command Path (click)")
                        font.pointSize: 14 + root.fontPadding
                        wrapMode: Label.WordWrap

                        verticalAlignment: Label.AlignVCenter
                        anchors.horizontalCenter: parent.horizontalCenter

                        property bool bChecked: false

                        MouseArea {
                            id: mouseAreaCommand
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            propagateComposedEvents: true
                            z: 2

                            onEntered: {}
                            onExited: {}

                            onClicked: {
                                if (!commandCheck.bChecked) {
                                    commandCheck.text = qsTr("Command Path")
                                }
                                else {
                                    commandCheck.text = qsTr("Command Path (click)")
                                }

                                commandCheck.bChecked = !commandCheck.bChecked
                            }
                        }
                    }

                    TextField {
                        id: commandEdit
                        text: "/usr/bin/testparm"
                        width: Math.round((parent.implicitWidth) * 0.8)
                        implicitWidth: Math.round((parent.implicitWidth) * 0.8)
                        visible: commandCheck.bChecked ? true : false

                        font.pointSize: 14 + root.fontPadding
                        placeholderText: qsTr("testparm Command Path")

                        anchors.top: commandCheck.bottom
                        horizontalAlignment: TextField.AlignLeft
                        verticalAlignment: TextField.AlignVCenter
                    }
                }
            }

            Button {
                id: execTestparmBtn
                text: qsTr("Check") + " " + "(<u>C</u>)"
                implicitWidth: Math.round(root.width / 5) > 200 ? 300 : 200
                implicitHeight: Math.round(root.height / 15) > 50 ? 70 : 50

                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20

                property bool isClicked: false

                contentItem: Label {
                    text: parent.text
                    font: parent.font
                    color: root.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                    elide: Label.ElideRight

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                }

                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: parent.height
                    color: parent.isClicked ? "#10980a" : "transparent"
                    opacity: parent.isClicked ? 0.8 : 1
                    border.color: root.bDark ? "#10980a" : "#20a81a"
                    radius: 5
                }

                onPressed: {
                    isClicked = true
                }

                onReleased: {
                    isClicked = false
                }

                onFocusChanged: {
                    isClicked = false
                }

                onClicked: {
                    let iRet = 0
                    if (root.bServerMode) {
                        // Server Mode.
                        iRet = Testparm.executeTestparmCommand(commandEdit.text, textSambaFilePath.text, root.option)

                        if (iRet === 0){
                            // Display result.
                            let messageTestparm  = Testparm.getCommandResult()
                            outputLabel.text = messageTestparm

                            // Display success popup.
                            completePopup.viewTitle   = qsTr("The testparm command was successfully executed")
                            completePopup.fontPadding = parentName.fontPadding
                            completePopup.bAutoClose   = false
                            completePopup.open()
                        }
                        else if (iRet === 1) {
                            // If password authentication is canceled.
                        }
                        else {
                            // Error.
                            let errMsg = Testparm.getErrorMessage()
                            let componentDialog = Qt.createComponent("qrc:/qt/qml/Main/CustomQML/ErrorDialog.qml");
                            if (componentDialog.status === Component.Error) {
                                console.error("Error loading component:", componentDialog.errorString());
                            }
                            else if (componentDialog.status === Component.Ready) {
                                let errorDialog = componentDialog.createObject(root,
                                                                               {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
                                                                                messageTitle: qsTr("Exec Error"),
                                                                                messageText: qsTr("Failed to execute the testparm command.") + "<br>" + errMsg});
                                errorDialog.show();
                            }
                        }
                    }
                    else {
                        // Client Mode.
                        root.fnExecuteRemoteTestparmCommand()
                    }

                    ApplicationState.setSambaTestFile(textSambaFilePath.text)
                }

                Shortcut {
                    sequence: "Alt+C"
                    onActivated: {
                        if (execTestparmBtn.enabled) {
                            execTestparmBtn.clicked()
                        }
                    }
                }
            }

            Rectangle {
                implicitWidth: root.width * 0.7
                implicitHeight: Math.max(800, root.height * 0.7)
                color: root.bDark ? "#303030" : "#d0d0d0"
                border.color: "darkgrey"
                border.width: 2
                radius: 5
                Layout.topMargin: 20
                Layout.leftMargin: (root.width - width) / 2
                Layout.bottomMargin: 20

                Flickable {
                    id: flick
                    width: parent.width
                    height: parent.height
                    contentWidth: parent.width
                    contentHeight: outputLabel.implicitHeight + bottomPadding
                    clip: true

                    property int bottomPadding: 20  // Set bottom margin

                    ScrollBar.vertical: ScrollBar {
                        active: true
                        policy: ScrollBar.AsNeeded
                    }

                    Label {
                        id: outputLabel
                        text: qsTr("Results are output here...")
                        color: root.bDark ? "white" : "black"
                        font.pointSize: 14 + root.fontPadding
                        smooth: true
                        wrapMode: Label.WordWrap

                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: 10
                        }

                        horizontalAlignment: Label.AlignJustify
                        verticalAlignment:   Label.AlignVCenter
                    }
                }
            }
        }
    }

    CompletePopup {
        id: completePopup

        viewTitle: ""
        positionY: Math.round((root.height - completePopup.height) / 10)
        viewWidth: root.width
        fontPadding: 0
        parentName: root.parentName
    }
}
