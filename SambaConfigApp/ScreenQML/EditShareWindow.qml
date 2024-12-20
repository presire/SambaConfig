import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls.Material
import QtQuick.Controls.Universal


ApplicationWindow {
    id:            editWindow
    title:         index === -1 ? qsTr("Add New Share") : qsTr("Edit Share")
    width:         800
    minimumWidth:  800
    height:        600
    minimumHeight: 600
    modality:      Qt.ApplicationModal
    flags:         Qt.Dialog
    color:         bDark ? "#202020" : "#f0f0f0"

    property bool bDark:        false
    property int  fontPadding:  0
    property var  itemData:     ({})
    property int  index:        -1

    // Dynamic application of themes
    Material.theme:  editWindow.bDark ? Material.Dark : Material.Light
    Universal.theme: editWindow.bDark ? Universal.Dark : Universal.Light

    signal accepted(var data)
    signal rejected()

    Item {
        Shortcut {
            sequence: "Ctrl+PgUp"
            onActivated: {
                if (tabBar.currentIndex !== 0) tabBar.currentIndex = 0
            }
        }

        Shortcut {
            sequence: "Ctrl+PgDown"
            onActivated: {
                if (tabBar.currentIndex !== 1) tabBar.currentIndex = 1
            }
        }
    }

    header: Column {
        id:      header
        width:   parent.width
        spacing: 5

        TabBar {
            id: tabBar
            width: parent.width //Layout.fillWidth: true
            clip: true
            currentIndex: 0

            TabButton {
                id:             tabBasic
                text:           qsTr("Basic")
                font.pointSize: 14 + editWindow.fontPadding

                Rectangle {
                    id:           bgBasic
                    width:        labelBasic.width
                    height:       tabBar.currentItem.height
                    color:        "transparent"
                    border.color: editWindow.bDark ? "white" : "black"
                    border.width: editWindow.bDark ? 0 : 2
                    opacity:      0.3

                    // anchors.left:  labelBasic.left
                    // anchors.right: labelBasic.right
                }

                contentItem: Label {
                    id:    labelBasic
                    text:  parent.text
                    font:  parent.font
                    color: editWindow.bDark ? stackLayout.currentIndex === 0 ? Material.color(Material.Blue, Material.Shade200) : "white" :
                           stackLayout.currentIndex === 0 ? "#0000f0" : "black"
                    elide: Label.ElideRight

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment:   Label.AlignVCenter
                }

                Rectangle {
                    id:      bgSelectBasic
                    width:   tabBar.currentItem.width
                    height:  tabBar.currentItem.height
                    color:   editWindow.bDark ? "transparent" : mouseHover.hovered ? "#808080" : "transparent"
                    opacity: 0.5

                    // anchors.left:  labelBasic.left
                    // anchors.right: labelBasic.right

                    HoverHandler {
                        id: mouseHover
                        acceptedDevices: PointerDevice.Mouse
                    }
                }

                Rectangle {
                    id:      barBasic
                    y:       tabBar.height - height
                    width:   labelBasic.width
                    height:  editWindow.bDark ? 1 : stackLayout.currentIndex === 0 ? 5 : 0
                    color:   "#0000f0"
                    radius:  10
                    opacity: 0.5

                    // anchors.left: labelBasic.left

                    NumberAnimation {
                        id:       basicWidthChange
                        target:   barBasic;
                        property: "width";
                        from:     0;
                        to:       labelBasic.width
                        duration: 350;
                    }
                }

                Connections {
                    target: tabBasic
                    function onPressed() {
                        basicWidthChange.start()
                    }
                }
            }

            TabButton {
                id:             tabAccess
                text:           qsTr("Access")
                font.pointSize: 14 + editWindow.fontPadding

                Rectangle {
                    id:           bgAccess
                    width:        labelAccess.width
                    height:       tabBar.currentItem.height
                    color:        "transparent"
                    border.color: editWindow.bDark ? "white" : "black"
                    border.width: editWindow.bDark ? 0 : 2
                    opacity:      0.3

                    // anchors.left:  labelAccess.left
                    // anchors.right: labelAccess.right
                }

                contentItem: Label {
                    id:    labelAccess
                    text:  parent.text
                    font:  parent.font
                    color: editWindow.bDark ? stackLayout.currentIndex === 1 ? Material.color(Material.Blue, Material.Shade200) : "white" :
                           stackLayout.currentIndex === 1 ? "#0000f0" : "black"
                    elide: Label.ElideRight

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment:   Label.AlignVCenter
                }

                Rectangle {
                    id:      bgSelectAccess
                    width:   tabBar.currentItem.width
                    height:  tabBar.currentItem.height
                    color:   editWindow.bDark ? "transparent" : mouseHoverAccess.hovered ? "#808080" : "transparent"
                    opacity: 0.5

                    // anchors.left:  labelAccess.left
                    // anchors.right: labelAccess.right

                    HoverHandler {
                        id: mouseHoverAccess
                        acceptedDevices: PointerDevice.Mouse
                    }
                }

                Rectangle {
                    id:      barAccess
                    y:       tabBar.height - height
                    width:   labelAccess.width
                    height:  editWindow.bDark ? 0 : stackLayout.currentIndex === 1 ? 5 : 0
                    color:   "#0000f0"
                    radius:  10
                    opacity: 0.5

                    // anchors.left: labelAccess.left

                    NumberAnimation {
                        id:       accessWidthChange
                        target:   barAccess;
                        property: "width";
                        from:     0;
                        to:       labelAccess.width
                        duration: 350;
                    }
                }

                Connections {
                    target: tabAccess
                    function onPressed() {
                        accessWidthChange.start()
                    }
                }
            }
        }
    }

    StackLayout {
        id:           stackLayout
        width:        parent.width
        height:       parent.height - header.height - buttonRow.height - 40
        currentIndex: tabBar.currentIndex

        onCurrentIndexChanged: {
            animationLayout.start()
        }

        ParallelAnimation {
            id: animationLayout

            NumberAnimation {
                target:      stackLayout
                property:    "x"
                from:        (stackLayout.width) / 2
                to:          0
                duration:    250
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target:      stackLayout
                property:    "opacity"
                from:        0.0
                to:          1.0
                duration:    250
                easing.type: Easing.InOutQuad
            }
        }

        EditShareTabBasic {
            id:          basicItem
            viewWidth:   parent.width  //editWindow.width
            viewHeight:  parent.height //editWindow.height - tabBar.height - buttonRow.height - 20
            fontPadding: editWindow.fontPadding
            bDark:       editWindow.bDark
            bServerMode: true
            directory:   editWindow.index === -1 ? ""          : editWindow.itemData.directory   || ""
            shareName:   editWindow.index === -1 ? ""          : editWindow.itemData.shareName   || ""
            permissions: editWindow.index === -1 ? "Read Only" : editWindow.itemData.permissions || "Read Only"
            visibility:  editWindow.index === -1 ? "Visible"   : editWindow.itemData.visibility  || "Visible"
            description: editWindow.index === -1 ? ""          : editWindow.itemData.description || ""
            sambaConfig: null
        }

        EditShareTabAccess {
            id:          accessItem
            viewWidth:   parent.width  //editWindow.width
            viewHeight:  parent.height //editWindow.height - tabBar.height - buttonRow.height - 20
            fontPadding: editWindow.fontPadding
            bDark:       editWindow.bDark
            bServerMode: true
            bAllUsers:   editWindow.index === -1 ? true : editWindow.itemData.bAllUsers
            users:       (editWindow.index === -1 || typeof editWindow.itemData.users === "undefined") ? [] : editWindow.itemData.users
            sambaConfig: null
        }
    }

    RowLayout {
        id: buttonRow
        height:          Math.round(parent.height / 5) > 90 ? 90 :
                         Math.round(parent.height / 5) < 70 ? 70 : Math.round(parent.height / 5)
        anchors.bottom:  parent.bottom
        anchors.right:   parent.right
        anchors.left:    parent.left
        anchors.margins: 20
        spacing:         Math.max(20, Math.min(editWindow.width * 0.025, 100))

        // Spacer
        Item {
            Layout.fillWidth: true
        }

        Button {
            id:             addBtn
            text:           index === -1 ? qsTr("Add") + "(<u>A</u>)" : qsTr("Modify") + "(<u>A</u>)"
            implicitWidth:  Math.max(150, Math.min(editWindow.width * 0.15, 250))
            implicitHeight: Math.max(35, Math.min(editWindow.height * 0.05, 70))
            font.pointSize: 12 + editWindow.fontPadding
            flat:           false

            contentItem: Label {
                text:                parent.text
                textFormat:          Label.RichText
                font:                parent.font
                opacity:             enabled ? 1.0 : 0.3
                color:               editWindow.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                elide:               Label.ElideRight
                horizontalAlignment: Label.AlignHCenter
                verticalAlignment:   Label.AlignVCenter
            }

            background: Rectangle {
                color:        parent.pressed   ? border.color : "transparent"
                opacity:      parent.pressed   ? 0.8 : 1
                border.color: editWindow.bDark ? "#10980a" : "#20a81a"
                border.width: parent.pressed   ? 0 : 2
                radius:       5
                anchors.fill: parent
            }

            onClicked: {
                var newData = {
                    directory:      basicItem.directory,
                    shareName:      basicItem.shareName,
                    permissions:    basicItem.permissions,
                    visibility:     basicItem.visibility,
                    description:    basicItem.description,
                    bAllUsers:      accessItem.bAllUsers,
                    users:          accessItem.users.filter(element => { return element !== "" && element !== null && element !== undefined; })
                }

                editWindow.accepted(editWindow.index, newData)
                editWindow.close()
            }

            Shortcut {
                sequence: "Alt+A"
                onActivated: {
                    addBtn.clicked()
                }
            }
        }

        Button {
            id:             cancelBtn
            text:           qsTr("Cancel") + "(<u>C</u>)"
            implicitWidth:  Math.max(150, Math.min(editWindow.width * 0.15, 250))
            implicitHeight: Math.max(35, Math.min(editWindow.height * 0.05, 70))
            font.pointSize: 12 + editWindow.fontPadding
            flat:           false

            contentItem: Label {
                text:                parent.text
                font:                parent.font
                opacity:             enabled ? 1.0 : 0.3
                color:               editWindow.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                elide:               Label.ElideRight
                horizontalAlignment: Label.AlignHCenter
                verticalAlignment:   Label.AlignVCenter
            }

            background: Rectangle {
                color:        parent.pressed   ? border.color : "transparent"
                opacity:      parent.pressed   ? 0.8 : 1
                border.color: editWindow.bDark ? "#10980a" : "#20a81a"
                border.width: parent.pressed   ? 0 : 2
                radius:       5
                anchors.fill: parent
            }

            onClicked: {
                editWindow.rejected()
                editWindow.close()
            }

            Shortcut {
                sequence: "Alt+C"
                onActivated: {
                    cancelBtn.clicked()
                }
            }
        }
    }
}
