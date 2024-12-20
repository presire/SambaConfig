import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Material
import QtQuick.Controls.Universal


ApplicationWindow {
    id:            warningDialog
    title:         warningDialog.messageTitle
    width:         warningColumn.width
    height:        Math.round(Math.min(warningColumn.height + warningOKBtn.height + 20, warningDialog.viewHeight))
    minimumWidth:  warningColumn.width
    minimumHeight: Math.round(Math.min(warningColumn.height + warningOKBtn.height + 20, warningDialog.viewHeight))
    maximumWidth:  warningColumn.width
    maximumHeight: Math.round(Math.min(warningColumn.height + warningOKBtn.height + 20, warningDialog.viewHeight))
    flags:         Qt.Dialog
    modality:      Qt.WindowModal

    property string messageTitle: ""
    property string messageText:  ""
    property int    viewWidth:    0
    property int    viewHeight:   0
    property bool   bDark:        false
    property int    fontPadding:  0
    property string returnValue:  ""

    Settings {
        id: settings
        property string style: warningDialog.bDark ? "Material" : "Universal"
    }

    ScrollView {
        id:            scrollWarning
        width:         parent.width
        height:        parent.height * 0.8
        contentWidth:  warningColumn.width   // The important part
        contentHeight: warningColumn.height  // Same
        clip :         true                  // Prevent drawing column outside the scrollview borders

        ColumnLayout {
            id: warningColumn
            spacing: 20

            RowLayout {
                width: parent.width

                Layout.fillWidth: true
                Layout.margins:   20

                spacing:          0

                Image {
                    id:       warningIcon
                    source:   "../Image/Warning.png"
                    fillMode: Image.Stretch

                    Layout.alignment:   Qt.AlignTop | Qt.AlignVCenter
                    Layout.rightMargin: 20
                }

                Label {
                    text:           warningDialog.messageText
                    font.pointSize: 12 + warningDialog.fontPadding
                    textFormat:     Label.RichText
                    wrapMode:       Label.WordWrap

                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth:  true
                    Layout.fillHeight: true
                }
            }
        }
    }

    Button {
        id:             warningOKBtn
        text:           qsTr("OK") + "(<u>O</u>)"
        implicitWidth:  Math.round(warningColumn.width / 5) > 200 ? 300 : 200
        implicitHeight: Math.round(warningColumn.height / 15) > 50 ? 70 : 50
        font.pointSize: 12 + warningDialog.fontPadding
        focus:          true

        anchors.top:              scrollWarning.bottom
        anchors.bottomMargin:     20
        anchors.horizontalCenter: parent.horizontalCenter

        contentItem: Label {
            text:       parent.text
            font:       parent.font
            textFormat: Label.RichText
            color:      warningDialog.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
            opacity:    enabled ? 1.0 : 0.3
            elide:      Label.ElideRight

            horizontalAlignment: Label.AlignHCenter
            verticalAlignment:   Label.AlignVCenter
        }

        background: Rectangle {
            color:        parent.focus ? border.color : "transparent"
            opacity:      parent.focus ? 0.8 : 1
            border.color: warningDialog.bDark ? "#10980a" : "#20a81a"
            border.width: parent.focus ? 3 : 1
            radius:       5
            anchors.fill: parent
        }

        Connections {
            target: warningOKBtn
            function onClicked() {
                warningDialog.close();
            }
        }

        Keys.onPressed: {
            if (event.key === Qt.Key_Return) {
                // If pressed [Return] key, focused [OK] button
                // Close Warning Dialog
                warningDialog.close()
            }
        }

        Shortcut {
            sequence: "Alt+O"
            onActivated: {
                warningOKBtn.clicked()
            }
        }
    }
}
