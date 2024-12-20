import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls.Material
import QtQuick.Controls.Universal
import "../CustomQML"

Item {
    id: root

    property int  viewWidth:   0
    property int  viewHeight:  0
    property int  fontPadding: 0
    property bool bDark:       false
    property bool bServerMode: true
    property bool bAllUsers:   true
    property var  users:       []
    property var  sambaConfig: null

    // ListModelをusersプロパティと同期させる関数
    function syncUsersToModel() {
        selectedUsersModel.clear()
        for (let i = 0; i < root.users.length; i++) {
            selectedUsersModel.append({"username": root.users[i]})
        }
    }

    // 初期化時にusersの値をListViewに反映
    Component.onCompleted: {
        if (!root.bAllUsers && root.users.length > 0) {
            syncUsersToModel()
        }
    }

    Connections {
        target: validUserManager

        function onPdbEditPathFound(path) {
            textPDBEditPath.text = path
        }

        function onValidUserLoaded(success, validusers, errorMessage) {
            if (success) {
                userComboBox.enabled = true
                userComboBox.model   = validusers

                completePopup.viewTitle   = qsTr("Valid users loaded successfully")
                completePopup.fontPadding = parentName.fontPadding
                completePopup.bAutoClose  = false
                completePopup.open()
            }
            else {
                userComboBox.enabled = false
                userComboBox.model   = []

                // Display error pop-up.
                errorPopup.viewTitle   = qsTr("Failed to load valid users") + "\n" + errorMessage
                errorPopup.fontPadding = root.fontPadding
                errorPopup.bAutoClose  = true
                errorPopup.open()

                // let componentDialog = Qt.createComponent("qrc:/qt/qml/Main/CustomQML/ErrorDialog.qml");
                // if (componentDialog.status === Component.Error) {
                //     console.error(qsTr("Error loading component: "), componentDialog.errorString());
                // }
                // else if (componentDialog.status === Component.Ready) {
                //     let errorDialog = componentDialog.createObject(root,
                //                                                    {mainWidth:    root.width,
                //                                                     mainHeight:   root.height,
                //                                                     bDark:        root.bDark,
                //                                                     messageTitle: qsTr("Failed to load valid users"),
                //                                                     messageText:  errorMessage});
                //     errorDialog.show();
                // }
            }
        }
    }

    ListModel {
        id: selectedUsersModel
    }

    ScrollView {
        id: scrollView
        width: parent.viewWidth
        height: parent.viewHeight
        contentWidth: tabAccessColumn.width
        contentHeight: tabAccessColumn.height
        clip: true
        padding: 20

        ScrollBar.vertical.interactive: true

        ColumnLayout {
            id: tabAccessColumn
            width: scrollView.width - 40
            spacing: 10

            ButtonGroup {
                id: optionGroup
                buttons: tabAccessColumn.children

                onClicked: {
                    root.bAllUsers = specificAllUsersRadio.checked
                }

                Component.onCompleted: {
                    // 初期状態でラジオボタンを設定
                    specificAllUsersRadio.checked = bAllUsers
                    specificUsersRadio.checked    = !bAllUsers
                }
            }

            RadioButton {
                id:   specificAllUsersRadio
                text: qsTr("Allow access to everyone")
                checked: root.bAllUsers
                ButtonGroup.group: optionGroup
            }

            RadioButton {
                id:      specificUsersRadio
                text:    qsTr("Only allow access to specific users")
                checked: !root.bAllUsers
                ButtonGroup.group: optionGroup
            }

            RowLayout {
                width:             parent.width
                visible:           specificUsersRadio.checked
                Layout.alignment:  Qt.AlignVCenter | Qt.AlignHCenter

                spacing: 10

                TextField {
                    id:                 textPDBEditPath
                    text:               FileDialogHelper.selectedFile
                    placeholderText:    ""
                    implicitWidth:      root.width * 0.5
                    color:              root.bDark ? "white" : "black"
                    font.pointSize:     14 + root.fontPadding
                    enabled:            root.bServerMode ? true : false

                    horizontalAlignment:    TextField.AlignLeft
                    verticalAlignment:      TextField.AlignVCenter

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
                                color:  root.bDark ? "#303050" : "#e0e0ff"
                            }
                        }
                    ]

                    // for custom place holder text
                    Text {
                        id:      customPlaceholder
                        text:    root.bServerMode ? qsTr("Click the right icon, select \"pdbedit\" Ex: /usr/bin/pdbedit") :
                                                    qsTr("Click the right icon, select \"pdbedit\" on remote server")
                        color:   root.bDark ? "white" : "black"
                        opacity: textPDBEditPath.placeholderOpacity
                        visible: !textPDBEditPath.text && !textPDBEditPath.activeFocus
                        font:    textPDBEditPath.font
                        elide:   Text.ElideRight
                        anchors {
                            left:           parent.left
                            right:          parent.right
                            leftMargin:     textPDBEditPath.leftPadding
                            rightMargin:    textPDBEditPath.rightPadding
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    Component.onCompleted: {
                        validUserManager.isPDBEditAvailable()
                    }
                }

                RoundButton {
                    id:     btnSambaFileSelect
                    text:   ""
                    width:  64
                    height: 64

                    icon.source: root.bServerMode ? pressed ? "qrc:/Image/FileButtonPressed.png" : "qrc:/Image/FileButton.png"
                                                  : pressed ? "qrc:/Image/FileNetworkButtonPressed.png" : "qrc:/Image/FileNetworkButton.png"
                    icon.width:  width
                    icon.height: height
                    icon.color:  "transparent"

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
                                                                    {mainWidth:   root.viewWidth,   mainHeight: root.viewHeight,
                                                                     fontPadding: root.fontPadding, bDark:      root.bDark,
                                                                     bServerMode: root.bServerMode,
                                                                     rootDirectory: fileSelectDialog.getFirstDirectory("file://" + textPDBEditPath.text)})
                                dialog.fileSelected.connect(function(filePath) {
                                    textPDBEditPath.text = filePath
                                })
                                dialog.show()
                            }
                        }
                        else {
                            // Client Mode.
                        }
                    }
                }
            }

            RowLayout {
                visible:          specificUsersRadio.checked
                spacing:          10
                Layout.alignment: Qt.AlignHCenter

                ComboBox {
                    id:             userComboBox
                    implicitWidth:  Math.round(tabAccessColumn.width / 3)
                    font.pointSize: 14 + root.fontPadding
                    enabled:        false
                    model:          []

                    onActivated: {
                        var selectedUser = currentText

                        // duplicate check.
                        for (var i = 0; i < selectedUsersModel.count; i++) {
                            if (selectedUsersModel.get(i).username === selectedUser) {
                                // Do not add if already exists.
                                return
                            }
                        }

                        // Add to Model.
                        selectedUsersModel.append({"username": selectedUser, "checked": true})

                        // Add to array variable.
                        root.users.push(selectedUser)
                    }
                }

                Button {
                    id:             getSambaUserOKBtn
                    text:           qsTr("Get Users / Groups") + "(<u>O</u>)"
                    implicitWidth:  Math.round(tabAccessColumn.width / 5) > 200 ? 300 : 200
                    implicitHeight: Math.round(tabAccessColumn.height / 15) > 50 ? 70 : 50
                    focus:          true

                    contentItem: Label {
                        text:                parent.text
                        textFormat:          Label.RichText
                        font:                parent.font
                        opacity:             enabled ? 1.0 : 0.3
                        color:               root.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
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
                        validUserManager.loadValidUser(textPDBEditPath.text)
                    }

                    Shortcut {
                        sequence:    "Alt+O"
                        onActivated: getSambaUserOKBtn.clicked()
                    }
                }
            }

            // [+]ボタン
            Button {
                id:      addButton
                text:    "+"
                width:   40
                height:  40
                visible: specificUsersRadio.checked
                z:       1

                Layout.alignment: Qt.AlignLeft
                Layout.margins:   5

                onClicked: {
                    selectedUsersModel.append({"username": ""})
                }
            }

            Rectangle {
                id:           rectUsersList
                color:        "transparent"
                border.color: "gray"
                border.width: 1
                radius:       5
                clip:         true
                visible:      specificUsersRadio.checked

                Layout.fillWidth:       true
                Layout.preferredHeight: Math.min(userListView.contentHeight + 20, Math.round(root.height * 0.5))

                ScrollView {
                    anchors.fill:                parent
                    ScrollBar.vertical.policy:   ScrollBar.AsNeeded
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ListView {
                        id:              userListView
                        anchors.fill:    parent
                        anchors.margins: 10
                        model:           selectedUsersModel
                        focus:           true

                        delegate: Item {
                            width:  userListView.width
                            height: userTextField.height

                            TextField {
                                id:                     userTextField
                                width:                  parent.width
                                text:                   model.username
                                placeholderText:        ""
                                color:                  root.bDark ? "white" : "black"
                                font.pointSize:         14 + root.fontPadding
                                Layout.fillWidth:       true
                                Layout.preferredHeight: 50

                                property real placeholderOpacity: 0.5  // Property to control the opacity of placeholders

                                background: Rectangle {
                                    color:        parent.activeFocus ? root.bDark ? "#505050" : "#e0e0ff" : root.bDark ? "black" : "#e0e0e0"
                                    border.width: parent.activeFocus ? root.bDark ? 2 : 1 : 1
                                    border.color: parent.activeFocus ? root.bDark ? "dodgerblue" : "lightblue" : root.bDark ? "grey" : "lightgrey"
                                }

                                states: [
                                    State {
                                        name: "focused"
                                        when: activeFocus
                                        PropertyChanges {
                                            target: background
                                            color:  root.bDark ? "#303050" : "#e0e0ff"
                                        }
                                    }
                                ]

                                // for custom place holder text
                                Text {
                                    text:    qsTr("")
                                    color:   root.bDark ? "white" : "black"
                                    opacity: userTextField.placeholderOpacity
                                    visible: !userTextField.text && !userTextField.activeFocus
                                    font:    userTextField.font
                                    elide:   Text.ElideRight

                                    anchors {
                                        left:           parent.left
                                        right:          parent.right
                                        leftMargin:     userTextField.leftPadding
                                        rightMargin:    userTextField.rightPadding
                                        verticalCenter: parent.verticalCenter
                                    }
                                }

                                // テキスト変更時にusers配列を更新
                                onTextChanged: {
                                    if (model.username !== text) {
                                        model.username = text

                                        let tempUsers  = []
                                        for (let i = 0; i < selectedUsersModel.count; i++) {
                                            tempUsers.push(selectedUsersModel.get(i).username)
                                        }

                                        root.users = tempUsers
                                    }
                                }

                                // Delete キーのハンドリング
                                Keys.onPressed: function(event) {
                                    if (event.key === Qt.Key_Delete) {
                                        selectedUsersModel.remove(model.index)

                                        let tempUsers = []
                                        for (let i = 0; i < selectedUsersModel.count; i++) {
                                            tempUsers.push(selectedUsersModel.get(i).username)
                                        }

                                        root.users     = tempUsers
                                        event.accepted = true
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill:    parent
                                acceptedButtons: Qt.RightButton
                                z:               1

                                onClicked: function(mouse) {
                                    if (mouse.button === Qt.RightButton) {
                                        contextMenu.popup()
                                    }
                                }

                                Menu {
                                    id: contextMenu

                                    MenuItem {
                                        text: qsTr("Delete")
                                        onTriggered: {
                                            selectedUsersModel.remove(model.index)
                                            let tempUsers = []
                                            for (let i = 0; i < selectedUsersModel.count; i++) {
                                                tempUsers.push(selectedUsersModel.get(i).username)
                                            }
                                            root.users = tempUsers
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    CompletePopup {
        id:          completePopup
        viewTitle:   ""
        positionY:   Math.round((root.height - completePopup.height) / 10)
        viewWidth:   root.width
        fontPadding: 0
        parentName:  root.parentName
    }

    // Error pop-up
    ErrorPopup {
        id:          errorPopup
        viewTitle:   ""
        positionY:   Math.round((root.height - errorPopup.height) / 10)
        viewWidth:   root.width
        fontPadding: 0
        bAutoClose:  true
    }
}
