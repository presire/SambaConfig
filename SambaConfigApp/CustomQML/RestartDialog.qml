import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Material
import QtQuick.Controls.Universal


ApplicationWindow {
    id: restartDialog
    title: qsTr("Restart")
    width: bPP === false ? Math.round(Math.min(mainWidth, mainHeight) / 10 * 9) : mainWidth
    height: restartColumn.height

    flags: Qt.Dialog
    modality: Qt.WindowModal

    property var  parentName:    null
    property int  mainWidth:     640
    property int  mainHeight:    480
    property bool bServerMode:   true
    property bool bFirstSystemd: true
    property int  fontCheck:     1
    property bool bTheme:        false
    property int  langIndex:     0
    property bool bPP:           false  // for PinePhone


    Settings {
        id: settings
        property string style: ApplicationState.getColorMode() ? "Material" : "Universal"
    }

    Shortcut {
        sequence: "Esc"
        onActivated: {
            restartDialog.close()
        }
    }

    Shortcut {
        sequences: ["Left", "Right"]
        onActivated: {
            restartOKBtn.focus ? restartCancelBtn.focus = true : restartOKBtn.focus = true
        }
    }

    onVisibleChanged: {
        restartCancelBtn.focus = true
    }

    Component.onCompleted: {
        // For PinePhone.
        if (bPP) {
            restartDialog.color = parentName.bDark ? "#3f3f3f" : "#f5f5f5"
        }
    }

    ColumnLayout {
        id: restartColumn
        width: parent.width
        spacing: 20

        Label {
            text: qsTr("When you restart this software, the color will change.") + "<br>" +
                  qsTr("Now, would you like to Restart?")
            textFormat: Label.RichText
            wrapMode: Label.WordWrap

            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 20
            Layout.bottomMargin: 20
        }

        RowLayout {
            width: parent.width
            spacing: 20

            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 20

            Button {
                id: restartOKBtn
                text: qsTr("OK") + " " + "(<u>O</u>)"
                enabled: true
                implicitWidth: Math.max(200, parent.width / 5)
                implicitHeight: Math.max(50, parent.height / 5)

                contentItem: Label {
                    text:       parent.text
                    font:       parent.font
                    textFormat: Label.RichText
                    opacity:    enabled ? 1.0 : 0.3
                    color:      ApplicationState.getColorMode() ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                    elide:      Label.ElideRight

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment:   Label.AlignVCenter
                }

                background: Rectangle {
                    color:        parent.focus ? border.color : "transparent"
                    opacity:      parent.focus ? 0.8 : 1
                    border.color: ApplicationState.getColorMode() ? "#10980a" : "#20a81a"
                    border.width: parent.focus ? 3 : 1
                    radius:       5
                    anchors.fill: parent
                }

                onClicked: {
                    // Save window size.
                    let bMaximized = false
                    if(parentName.visibility === Window.Maximized) {
                        bMaximized = true
                    }

                    ApplicationState.setMainWindowState(parentName.x, parentName.y, parentName.width, parentName.height, bMaximized)

                    // Save Server Mode.
                    ApplicationState.setServerMode(restartDialog.bServerMode)

                    // Save Samba / NMB systemd status.
                    ApplicationState.setFirstSystemd(restartDialog.bFirstSystemd)

                    // Save Font.
                    ApplicationState.setFontSize(restartDialog.fontCheck)

                    // Save color mode.
                    ApplicationState.setColorMode(restartDialog.bTheme)
                    ApplicationState.setColorModeOverWrite(false)

                    // Save language.
                    ApplicationState.setLanguage(restartDialog.langIndex)

                    // Remove tmp files.
                    ApplicationState.removeTmpFiles()

                    // Restart software.
                    ApplicationState.restartSoftware()

                    // Do not Show Quit-dialog.
                    parentName.allowClose = true

                    Qt.quit()
                }

                Keys.onReturnPressed: {
                    clicked()
                }

                Shortcut {
                    sequence: "Alt+O"
                    onActivated: {
                        restartOKBtn.clicked()
                    }
                }
            }

            Button {
                id: restartCancelBtn
                text: qsTr("Cancel") + " " + "(<u>C</u>)"
                implicitWidth:  Math.max(200, parent.width / 5)
                implicitHeight: Math.max(50, parent.height / 5)
                focus:          true

                contentItem: Label {
                    text:       parent.text
                    font:       parent.font
                    textFormat: Label.RichText
                    opacity:    enabled ? 1.0 : 0.3
                    color:      ApplicationState.getColorMode() ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                    elide:      Label.ElideRight

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment:   Label.AlignVCenter
                }

                background: Rectangle {
                    color:        parent.focus ? border.color : "transparent"
                    opacity:      parent.focus ? 0.8 : 1
                    border.color: ApplicationState.getColorMode() ? "#10980a" : "#20a81a"
                    border.width: parent.focus ? 3 : 1
                    radius:       5
                    anchors.fill: parent
                }

                onClicked: {
                    restartDialog.close()
                }

                Keys.onReturnPressed: {
                    clicked()
                }

                Shortcut {
                    sequence: "Alt+C"
                    onActivated: {
                        restartCancelBtn.clicked()
                    }
                }
            }
        }
    }
}
