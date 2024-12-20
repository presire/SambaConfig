import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Universal
import "../CustomQML"


Page {
    id: pageSambaConfig
    title: qsTr("Sanba Config")
    objectName: "pageSambaConfig"
    focus: true

    property var    parentName:        null
    property var    sambaServerConfig: null
    property int    fontPadding:       0
    property bool   bDark:             false
    property bool   bServerMode:       true
    property string localFileName:     ""
    property string remoteFileName:    ""
    property bool   bReadSuccess:      false


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

    CompletePopup {
        id: completePopup

        viewTitle: ""
        positionY: 0
        viewWidth: pageSambaConfig.width
        fontPadding: 0
        parentName: pageSambaConfig.parentName
    }
}
