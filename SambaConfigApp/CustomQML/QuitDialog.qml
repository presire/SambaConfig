import QtCore
import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Universal


ApplicationWindow {
    id:       quitDialog
    title:    qsTr("Quit SambaConfig")
    width:    mainWidth
    height:   quitColumn.height

    flags:    Qt.Dialog
    modality: Qt.WindowModal

    property var  parentName:       null
    property int  mainWidth:        640
    property int  mainHeight:       480
    property bool bDark:            false
    property bool bPP:              false
    property var  applicationState: null
    property int  fontPadding:      0
    property int  returnValue:      1


    Settings {
        id: settings
        property string style: quitDialog.bDark ? "Material" : "Universal"
    }

    Shortcut {
        sequence: "Esc"
        onActivated: {
            returnValue = 1
            quitDialog.close()
        }
    }

    Shortcut {
        sequences: ["Left", "Right"]
        onActivated: {
            if (quitDialogBtnOK.focus) quitDialogBtnCancel.focus = true
            else quitDialogBtnOK.focus = true
        }
    }

    onVisibleChanged: {
        quitDialogBtnCancel.focus = true
    }

    Component.onCompleted: {
        // For PinePhone.
        if (bPP) {
            quitDialog.color = bDark ? "#3f3f3f" : "#f5f5f5"
        }
    }

    // Update button gaps if dialog width changes
    onWidthChanged: {
        quitColumn.spacing = calculateSpacing()
    }

    // Update button gaps if dialog height changes
    onHeightChanged: {
        quitColumn.spacing = calculateSpacing()
    }

    // Function to calculate dynamic button width
    function calculateButtonWidth() {
        return Math.max(170, Math.min(width * 0.3, 250))
    }

    // Function to calculate dynamic button height
    function calculateButtonHeight() {
        return Math.max(50, Math.min(height * 0.15, 80))
    }

    // Function to calculate dynamically adjust button gap size
    function calculateSpacing() {
        return Math.max(20, width * 0.05)
    }

    ColumnLayout {
        id: quitColumn
        width: parent.width
        spacing: 20

        Label {
            text: qsTr("Do you want to quit SambaConfig?")
            width: parent.width
            font.pointSize: 12

            wrapMode: Label.WordWrap
            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 20
            Layout.bottomMargin: 20
        }

        RowLayout {
            Layout.fillWidth:    true
            spacing:             calculateSpacing()
            Layout.alignment:    Qt.AlignHCenter
            Layout.bottomMargin: 20

            Button {
                id:             quitDialogBtnOK
                text:           qsTr("OK") + "(<u>O</u>)"
                implicitWidth:  calculateButtonWidth()
                implicitHeight: calculateButtonHeight()
                font.pointSize: 14 + quitDialog.fontPadding

                contentItem: Label {
                    text:       parent.text
                    font:       parent.font
                    textFormat: Label.RichText
                    opacity:    enabled ? 1.0 : 0.3
                    color:      quitDialog.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                    elide:      Label.ElideRight

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment:   Label.AlignVCenter
                }

                background: Rectangle {
                    color:        parent.focus ? border.color : "transparent"
                    opacity:      parent.focus ? 0.8 : 1
                    border.color: quitDialog.bDark ? "#10980a" : "#20a81a"
                    radius:       5
                    anchors.fill: parent
                }

                Connections {
                    target: quitDialogBtnOK
                    function onClicked() {
                        // Close QuitDialog
                        returnValue = 0
                        quitDialog.close()
                    }
                }

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Return) {
                        // If pressed [Return] key, focused [OK] button
                        // Close QuitDialog
                        returnValue = 0
                        quitDialog.close()
                    }
                }

                Shortcut {
                    sequence: "Alt+O"
                    onActivated: {
                        quitDialogBtnOK.clicked()
                    }
                }
            }

            Button {
                id:             quitDialogBtnCancel
                text:           qsTr("Cancel") + " " + "(<u>C</u>)"
                implicitWidth:  calculateButtonWidth()
                implicitHeight: calculateButtonHeight()
                font.pointSize: 14 + quitDialog.fontPadding
                focus:          true
                flat:           false

                contentItem: Label {
                    text:       parent.text
                    font:       parent.font
                    textFormat: Label.RichText
                    opacity:    enabled ? 1.0 : 0.3
                    color:      quitDialog.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                    elide:      Label.ElideRight

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment:   Label.AlignVCenter
                }

                background: Rectangle {
                    color:        parent.focus ? border.color : "transparent"
                    opacity:      parent.focus ? 0.8 : 1
                    border.color: quitDialog.bDark ? "#10980a" : "#20a81a"
                    border.width: parent.focus ? 3 : 1
                    radius:       5
                    anchors.fill: parent
                }

                Connections {
                    target: quitDialogBtnCancel
                    function onClicked() {
                        // Close QuitDialog
                        returnValue = 1
                        quitDialog.close();
                    }
                }

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Return) {
                        // If pressed [Return] key, focused [Cancel] button
                        // Close QuitDialog
                        returnValue = 1
                        quitDialog.close();
                    }
                }

                Shortcut {
                    sequence: "Alt+C"
                    onActivated: {
                        quitDialogBtnCancel.clicked()
                    }
                }
            }
        }
    }
}
