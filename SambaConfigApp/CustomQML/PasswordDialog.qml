import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Material
import QtQuick.Controls.Universal


ApplicationWindow {
    id: passwordDialog
    title: passwordDialog.messageTitle
    width: Math.max(authSelectColumn.width, authInputColumn.width) //authSelectColumn.width
    height: Math.max(authSelectColumn.height, authInputColumn.height) //authSelectColumn.height
    minimumWidth: Math.max(authSelectColumn.width, authInputColumn.width) //authSelectColumn.width
    minimumHeight: Math.max(authSelectColumn.height, authInputColumn.height) //authSelectColumn.height
    maximumWidth: Math.max(authSelectColumn.width, authInputColumn.width) //authSelectColumn.width
    maximumHeight: Math.max(authSelectColumn.height, authInputColumn.height) //authSelectColumn.height

    flags: Qt.Dialog
    modality: Qt.WindowModal

    property string messageTitle: ""
    property string messageText:  ""
    property string password:     ""
    property bool   bDark:        false
    property int    fontPadding:  0
    property int    returnValue:  1

    Settings {
        id: settings
        property string style: passwordDialog.bDark ? "Material" : "Universal"
    }

    Component.onCompleted: {
        passwordDialog.title = qsTr("Warning")
    }

    StackLayout {
        id: stackLayout
        width: parent.width
        height: parent.height

        currentIndex: 0

        Component.onCompleted: {
            animationLayout.start()
        }

        onCurrentIndexChanged: {
            animationLayout.start()
        }

        ParallelAnimation {
            id: animationLayout
            running: true
            NumberAnimation {
                target: stackLayout
                properties: "x"
                from: stackLayout.width / 5
                to: 20
                duration: 150
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: stackLayout
                properties: "opacity"
                from: 0.0
                to: 1.0
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        // Authentication selection screen.
        Item {
            id: authSelect

            ColumnLayout {
                id: authSelectColumn

                RowLayout {
                    spacing: 20

                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    Layout.rightMargin: 40

                    Image {
                        id: authSelectIcon
                        source: "../Image/Key.png"
                        fillMode: Image.Stretch

                        Layout.alignment: Qt.AlignVCenter
                    }

                    Label {
                        text: qsTr("To run sshd commands on a remote server, you must have administrator privileges on the remote server.") + "<br>" +
                              qsTr("Input the remote server's administrator password and run with administrator privileges?") + "<br><br>" +
                              qsTr("<u><B>Note that may be a security risk.</B></u>")
                        font.pointSize: 12 + passwordDialog.fontPadding

                        textFormat: Label.RichText
                        wrapMode: Label.WordWrap

                        verticalAlignment: Label.AlignVCenter
                        Layout.fillHeight: true
                    }
                }

                RowLayout {
                    spacing: 20

                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 50
                    Layout.rightMargin: 40
                    Layout.bottomMargin: 20

                    Button {
                        id: okBtn
                        text: qsTr("OK")
                        implicitWidth: Math.max(200, parent.width / 5)
                        implicitHeight: Math.max(50, parent.height / 5)
                        font.pointSize: 12 + passwordDialog.fontPadding

                        contentItem: Label {
                            text: parent.text
                            font: parent.font
                            opacity: enabled ? 1.0 : 0.3
                            color: passwordDialog.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                            horizontalAlignment: Label.AlignHCenter
                            verticalAlignment: Label.AlignVCenter
                            elide: Label.ElideRight
                        }

                        background: Rectangle {
                            implicitWidth: parent.width
                            implicitHeight: parent.height
                            color: "transparent"
                            opacity: enabled ? 1 : 0.3
                            border.color: parent.pressed ? "#10980a" : "#20a81a"
                            border.width: parent.pressed ? 3 : 2
                            radius: 2
                        }

                        onClicked: {
                            // Next View.
                            stackLayout.currentIndex = 1

                            passwordDialog.title = qsTr("Input Password")
                            passwordInput.focus = true
                        }
                    }

                    Button {
                        id: cancelBtn
                        text: qsTr("Cancel")
                        implicitWidth: Math.max(200, parent.width / 5)
                        implicitHeight: Math.max(50, parent.height / 5)
                        font.pointSize: 12 + passwordDialog.fontPadding

                        contentItem: Label {
                            text: parent.text
                            font: parent.font
                            opacity: enabled ? 1.0 : 0.3
                            color: passwordDialog.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                            horizontalAlignment: Label.AlignHCenter
                            verticalAlignment: Label.AlignVCenter
                            elide: Label.ElideRight
                        }

                        background: Rectangle {
                            implicitWidth: parent.width
                            implicitHeight: parent.height
                            color: "transparent"
                            opacity: enabled ? 1 : 0.3
                            border.color: parent.pressed ? "#10980a" : "#20a81a"
                            border.width: parent.pressed ? 3 : 2
                            radius: 2
                        }

                        onClicked: {
                            // Cancel.
                            passwordDialog.returnValue = 1
                            passwordDialog.close();
                        }
                    }
                }
            }
        }

        // Password input screen.
        Item {
            id: authInput

            ColumnLayout {
                id: authInputColumn
                width: parent.width

                RowLayout {
                    spacing: 20

                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    Layout.rightMargin: 40

                    Image {
                        id: passwordIcon
                        source: "../Image/Lock.png"
                        fillMode: Image.Stretch

                        Layout.alignment: Qt.AlignVCenter
                    }

                    Label {
                        id: authInputLabel
                        text: qsTr("Input the administrator password for the remote server.")
                        font.pointSize: 12 + passwordDialog.fontPadding
                        color: passwordDialog.bDark ? "#ffffff" : "#000000"

                        textFormat: Label.RichText
                        wrapMode: Label.WordWrap

                        verticalAlignment: Label.AlignVCenter
                        Layout.fillHeight: true
                    }
                }

                TextField {
                    id: passwordInput
                    text: ""
                    width: Math.round(parent.width / 2)
                    implicitWidth: Math.round(parent.width / 2)

                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    Layout.rightMargin: 40

                    focus: true
                    selectedTextColor: "#393939"
                    horizontalAlignment: TextField.AlignHCenter
                    verticalAlignment: TextField.AlignVCenter
                    placeholderText: ""

                    echoMode: TextField.Password
                    passwordMaskDelay: 1000

                    selectByMouse: true
                    renderType: Text.QtRendering
                }

                RowLayout {
                    spacing: 20

                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 50
                    Layout.rightMargin: 40
                    Layout.bottomMargin: 20

                    Button {
                        id: passwordOKBtn
                        text: qsTr("OK")
                        implicitWidth: Math.max(200, parent.width / 5)
                        implicitHeight: Math.max(50, parent.height / 5)

                        contentItem: Label {
                            text: parent.text
                            font: parent.font
                            opacity: enabled ? 1.0 : 0.3
                            color: passwordDialog.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                            horizontalAlignment: Label.AlignHCenter
                            verticalAlignment: Label.AlignVCenter
                            elide: Label.ElideRight
                        }

                        background: Rectangle {
                            implicitWidth: parent.width
                            implicitHeight: parent.height
                            color: "transparent"
                            opacity: enabled ? 1 : 0.3
                            border.color: parent.pressed ? "#10980a" : "#20a81a"
                            border.width: parent.pressed ? 3 : 2
                            radius: 2
                        }

                        Connections {
                            target: passwordOKBtn
                            function onClicked() {
                                // Download.
                                passwordDialog.password = passwordInput.text
                                passwordDialog.returnValue = 0
                                passwordDialog.close();
                            }
                        }
                    }

                    Button {
                        id: passwordCancelBtn
                        text: qsTr("Cancel")
                        implicitWidth: Math.max(200, parent.width / 5)
                        implicitHeight: Math.max(50, parent.height / 5)

                        contentItem: Label {
                            text: parent.text
                            font: parent.font
                            opacity: enabled ? 1.0 : 0.3
                            color: passwordDialog.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                            horizontalAlignment: Label.AlignHCenter
                            verticalAlignment: Label.AlignVCenter
                            elide: Label.ElideRight
                        }

                        background: Rectangle {
                            implicitWidth: parent.width
                            implicitHeight: parent.height
                            color: "transparent"
                            opacity: enabled ? 1 : 0.3
                            border.color: parent.pressed ? "#10980a" : "#20a81a"
                            border.width: parent.pressed ? 3 : 2
                            radius: 2
                        }

                        Connections {
                            target: passwordCancelBtn
                            function onClicked() {
                                // Cancel.
                                passwordDialog.returnValue = 1
                                passwordDialog.close();
                            }
                        }
                    }
                }
            }
        }
    }
}
