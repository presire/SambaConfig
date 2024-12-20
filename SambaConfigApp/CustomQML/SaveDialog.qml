import QtCore
import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Universal


ApplicationWindow {
    id:     saveDialog
    title:  qsTr("Save the Settings")
    width:  Math.round(Math.min(mainWidth, mainHeight) / 10 * 9)
    height: saveColumn.height

    flags:    Qt.Dialog
    modality: Qt.WindowModal

    property int    mainWidth:        640
    property int    mainHeight:       480
    property var    applicationState: null
    property int    state:            0
    property int    move:             0
    property int    fontPadding:      0

    property bool   bServerMode:      true
    property bool   bAdminPassword:   true
    property int    iFont:            0
    property bool   bTheme:           false

    Settings {
        id: settings
        property string style: applicationState.getColorMode() ? "Material" : "Universal"
    }

    Shortcut {
        sequence: "Esc"
        onActivated: {
            saveDialog.close()
        }
    }

    Shortcut {
        sequences: ["Left"]
        onActivated: {
            saveYesBtn.focus ? saveCancelBtn.focus = true : saveNoBtn.focus ? saveYesBtn.focus = true : saveNoBtn.focus = true
        }
    }

    Shortcut {
        sequences: ["Right"]
        onActivated: {
            saveYesBtn.focus ? saveNoBtn.focus = true : saveNoBtn.focus ? saveCancelBtn.focus = true : saveYesBtn.focus = true
        }
    }

    onVisibleChanged: {
        saveCancelBtn.focus = true
    }

    ColumnLayout {
        id:      saveColumn
        width:   parent.width
        spacing: 20

        Label {
            text:           qsTr("No data is saved.") + "<br>" +
                            qsTr("Do you want to save it?")
            textFormat:     Label.RichText
            font.pointSize: 12 + warningDialog.fontPadding
            wrapMode:       Label.WordWrap

            horizontalAlignment: Label.AlignHCenter
            verticalAlignment:   Label.AlignVCenter
            Layout.fillWidth:    true
            Layout.fillHeight:   true
            Layout.topMargin:    20
            Layout.bottomMargin: 20
        }

        RowLayout {
            width: parent.width
            spacing: 20

            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 20

            Button {
                id:             saveYesBtn
                text:           qsTr("Yes") + "(<u>Y</u>)"
                implicitWidth:  Math.max(200, parent.width / 5)
                implicitHeight: Math.max(50, parent.height / 5)
                font.pointSize: 12 + warningDialog.fontPadding
                enabled:        true

                contentItem: Label {
                    text:       parent.text
                    font:       parent.font
                    textFormat: Label.RichText
                    opacity:    enabled ? 1.0 : 0.3
                    color:      applicationState.getColorMode() ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                    elide:      Label.ElideRight

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment:   Label.AlignVCenter
                }

                background: Rectangle {
                    color:        parent.focus ? border.color : "transparent"
                    opacity:      parent.focus ? 0.8 : 1
                    border.color: applicationState.getColorMode() ? "#10980a" : "#20a81a"
                    border.width: parent.focus ? 3 : 1
                    radius:       5
                    anchors.fill: parent
                }

                onClicked: {
                    // Save Server Mode.
                    applicationState.setServerMode(bServerMode)

                    // Save Font
                    applicationState.setFontSize(iFont)

                    // Save ColorMode
                    if (bTheme !== applicationState.getColorMode()) {
                        applicationState.setColorModeOverWrite(true)
                    }
                    else {
                        applicationState.setColorModeOverWrite(false)
                    }

                    // Return status value.
                    saveDialog.state = 0

                    // Close dialog.
                    saveDialog.close()
                }

                Keys.onReturnPressed: {
                    clicked()
                }

                Shortcut {
                    sequence: "Alt+Y"
                    onActivated: {
                        saveYesBtn.clicked()
                    }
                }
            }

            Button {
                id:             saveNoBtn
                text:           qsTr("No") + "(<u>N</u>)"
                implicitWidth:  Math.max(200, parent.width / 5)
                implicitHeight: Math.max(50, parent.height / 5)
                font.pointSize: 12 + warningDialog.fontPadding

                contentItem: Label {
                    text:       parent.text
                    font:       parent.font
                    textFormat: Label.RichText
                    opacity:    enabled ? 1.0 : 0.3
                    color:      applicationState.getColorMode() ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                    elide:      Label.ElideRight

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment:   Label.AlignVCenter
                }

                background: Rectangle {
                    color:        parent.focus ? border.color : "transparent"
                    opacity:      parent.focus ? 0.8 : 1
                    border.color: applicationState.getColorMode() ? "#10980a" : "#20a81a"
                    border.width: parent.focus ? 3 : 1
                    radius:       5
                    anchors.fill: parent
                }

                onClicked: {
                    // Return status value.
                    saveDialog.state = 1

                    // Close dialog.
                    saveDialog.close()
                }

                Keys.onReturnPressed: {
                    clicked()
                }

                Shortcut {
                    sequence: "Alt+N"
                    onActivated: {
                        saveNoBtn.clicked()
                    }
                }
            }

            Button {
                id:             saveCancelBtn
                text:           qsTr("Cancel") + "(<u>C</u>)"
                implicitWidth:  Math.max(200, parent.width / 5)
                implicitHeight: Math.max(50, parent.height / 5)
                font.pointSize: 12 + warningDialog.fontPadding

                contentItem: Label {
                    text:       parent.text
                    font:       parent.font
                    textFormat: Label.RichText
                    opacity:    enabled ? 1.0 : 0.3
                    color:      applicationState.getColorMode() ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                    elide:      Label.ElideRight

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment:   Label.AlignVCenter
                }

                background: Rectangle {
                    color:        parent.focus ? border.color : "transparent"
                    opacity:      parent.focus ? 0.8 : 1
                    border.color: applicationState.getColorMode() ? "#10980a" : "#20a81a"
                    border.width: parent.focus ? 3 : 1
                    radius:       5
                    anchors.fill: parent
                }

                onClicked: {
                    // Return status value.
                    saveDialog.state = 2

                    // Close dialog.
                    saveDialog.close()
                }

                Keys.onReturnPressed: {
                    clicked()
                }

                Shortcut {
                    sequence: "Alt+C"
                    onActivated: {
                        saveCancelBtn.clicked()
                    }
                }
            }
        }
    }
}
