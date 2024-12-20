import QtCore
import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Universal


ApplicationWindow {
    id:            errorDialog
    title:         errorDialog.messageTitle
    width:         Math.max(errorColumn.width, 640)
    height:        errorColumn.height
    minimumWidth:  Math.max(errorColumn.width, 640)
    minimumHeight: errorColumn.height
    maximumWidth:  Math.max(errorColumn.width, 640)
    maximumHeight: errorColumn.height
    flags:         Qt.Dialog
    modality:      Qt.WindowModal

    property string messageTitle: ""
    property string messageText:  ""
    property int    mainWidth:    640
    property int    mainHeight:   480
    property bool   bDark:        false
    property int    fontPadding:  0
    property string returnValue:  ""

    Settings {
        id: settings
        property string style: errorDialog.bDark ? "Material" : "Universal"
    }

    ColumnLayout {
        id: errorColumn
        spacing: 20

        RowLayout {
            width: parent.width

            Layout.fillWidth: true
            Layout.margins: 20

            spacing: 0

            Image {
                id: errorIcon
                source: "qrc:/Image/Critical.png"
                fillMode: Image.Stretch
                Layout.preferredWidth:  errorDialog.width <= 640 ? 32 : 48
                Layout.preferredHeight: errorDialog.width <= 640 ? 32 : 48

                Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
                Layout.leftMargin:  (errorDialog.width - errorIcon.width - errorLabel.width - 60) / 2
                Layout.rightMargin: 20
            }

            Label {
                id: errorLabel
                text:           errorDialog.messageText
                font.pointSize: 12 + errorDialog.fontPadding
                textFormat:     Label.RichText
                wrapMode:       Label.WordWrap

                verticalAlignment:   Label.AlignVCenter
                Layout.maximumWidth: errorDialog.width - errorIcon.width - 60
                Layout.fillHeight:   true
            }
        }

        Button {
            id: errorOKBtn
            text:           qsTr("OK") + "(<u>O</u>)"
            implicitWidth:  Math.round(errorColumn.width / 5) > 200 ? 300 : 200
            implicitHeight: Math.round(errorColumn.height / 15) > 50 ? 70 : 50
            font.pointSize: 12 + errorDialog.fontPadding
            focus:          true

            Layout.leftMargin: (errorDialog.width - errorOKBtn.width) / 2
            Layout.bottomMargin: 20

            contentItem: Label {
                text:       parent.text
                font:       parent.font
                textFormat: Label.RichText
                color:      errorDialog.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                opacity:    enabled ? 1.0 : 0.3
                elide:      Label.ElideRight

                horizontalAlignment: Label.AlignHCenter
                verticalAlignment:   Label.AlignVCenter
            }

            background: Rectangle {
                color:        parent.pressed ? border.color : "transparent"
                opacity:      parent.pressed ? 0.8 : 1
                border.color: errorDialog.bDark ? "#10980a" : "#20a81a"
                border.width: parent.pressed ? 0 : 2
                radius:       5
                anchors.fill: parent
            }

            Connections {
                target: errorOKBtn
                function onClicked() {
                    errorDialog.close();
                }
            }

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Return) {
                    // If pressed [Return] key, focused [OK] button
                    // Close ErrorDialog
                    errorDialog.close()
                }
            }

            Shortcut {
                sequence: "Alt+O"
                onActivated: {
                    errorOKBtn.clicked()
                }
            }
        }
    }
}
