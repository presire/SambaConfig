import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Controls.Universal


Item {
    id: root
    implicitWidth: frameList.width    // The important part
    implicitHeight: frameList.height  // Same

    property int  itemHeight:  0
    property int  fontPadding: 0
    property bool bDark:       false

    // Add "ListView"
    signal appendModel(string name)
    onAppendModel: {
        listModel.append({"name" : name});
    }

    function fnGetData() {
        let aryData = []
        for(let i = 0; i < listModel.count; i++) {
            aryData.push(listModel.get(i).name)
        }

        return aryData
    }

    // Clear "ListView"
    signal clearModel()
    onClearModel: {
        listModel.clear()
    }

    Component.onCompleted: {
    }

    Frame {
        id: frameList
        width: parent.width
        implicitWidth: parent.width
        height: listView.count * root.itemHeight <= 200 ? 200 : listView.count * root.itemHeight <= 350 ?
                                                                listView.count * root.itemHeight : 350

        Component {
            id: highlightBar
            Rectangle {
                y: listView.count === 0 ? 0.0 : listView.currentItem == null ? 0.0 : listView.currentItem.y
                width: frameList.width - scrollVBar.width
                height: root.itemHeight
                color: "#0080f0";
                radius: 5
                opacity: 0.5
                enabled: listView.count === 0 ? false : true

                Behavior on y {
                    SpringAnimation {
                        spring: 20
                        damping: 3.0
                    }
                }
            }
        }

        ListView {
            id: listView
            implicitWidth: parent.width
            implicitHeight: parent.height

            focus: true
            clip: true

            currentIndex: -1

            highlight: highlightBar
            highlightFollowsCurrentItem: false

            model: ListModel {
                id: listModel
            }

            onCountChanged: {
                listView.currentIndex = -1
            }

            Keys.onReturnPressed: {
                let a = listView.currentItem
                let b = a.data
                b[1].displayTextChanged()
                //b[1].selectByMouseChanged()
            }

            delegate: Rectangle {
                id: listItem
                width: frameList.width
                height: textName.height
                color: "transparent"

                property int indexOfThisDelegate: index

                Component.onCompleted: {
                    root.itemHeight = listItem.height
                }

                TextField {
                    id: textName
                    text: model.name
                    width: parent.width - 20
                    font.pointSize: 14 + root.fontPadding

                    focus: true
                    cursorVisible: false
                    selectedTextColor: "#393939"
                    horizontalAlignment: TextField.AlignLeft
                    verticalAlignment: TextField.AlignVCenter

                    selectByMouse: true 
                    renderType: TextField.QtRendering

                    background: Rectangle {
                        y: parent.height - 8
                        width: parent.width
                        height: parent.hovered ? 2 : 1
                        color: root.bDark ? "white" : Material.color(Material.DeepPurple, Material.ShadeA700)
                        opacity: parent.hovered ? 1.0 : 0.5
                        border.width: 0
                    }

                    // Save the previous text so that it can be restored when you cancel
                    property string oldText

                    // Notify user that save is being canceled
                    property bool cancelling

                    onPressed: {
                        listView.currentIndex = index;
                    }

                    onHoveredChanged: {
                        listView.currentIndex = index
                    }

                    Keys.onTabPressed: {
                        if (listView.activeFocus) {
                            if (listItem.indexOfThisDelegate === (listView.count - 1)) {
                                listView.currentIndex = -1
                                nextItemInFocusChain().forceActiveFocus()
                            }
                            else {
                                listView.currentIndex = listItem.indexOfThisDelegate + 1;
                                listView.focus = true
                                nextItemInFocusChain().forceActiveFocus()
                            }
                        }
                    }

                    // Cancel the save, and deselect the text input
                    Keys.onEscapePressed: {
                        cancelling = true
                        focus = false
                    }

                    // When cancelling, restore the old text, and clear state.
                    onEditingFinished: {
                        if (cancelling) {
                            text = oldText
                            oldText = ""
                            cancelling = false
                        }
                        else {
                            model.name = displayText
                        }
                    }

                    // When it first gets focus, it saves the text before editing.
                    onActiveFocusChanged: {
                        if (activeFocus) {
                            oldText = text
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton  // Enable "RightButton" on mouse

                        // Single click
                        onClicked: {
                            if (mouse.button === Qt.RightButton) {
                                listView.currentIndex = index;
                                contextMenu.popup()
                            }
                        }
                    }
                }

                Menu {
                    id: contextMenu

                    // Open the selected ListItem(s) in text editor
                    Action {
                        text: "Delete"
                        onTriggered: {
                            listModel.remove(listView.currentIndex);
                        }
                    }

                    delegate: MenuItem {
                        id: menuItem
                        implicitWidth: 250
                        implicitHeight: 40

                        arrow: Canvas {
                            x: parent.width - width
                            implicitWidth: 40
                            implicitHeight: 40
                            visible: menuItem.subMenu
                            onPaint: {
                                let ctx = getContext("2d")
                                ctx.fillStyle = menuItem.highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                                ctx.moveTo(15, 15)
                                ctx.lineTo(width - 15, height / 2)
                                ctx.lineTo(15, height - 15)
                                ctx.closePath()
                                ctx.fill()
                            }
                        }

                        contentItem: Label {
                            leftPadding: menuItem.indicator.width
                            rightPadding: menuItem.arrow.width
                            text: menuItem.text
                            font: menuItem.font
                            color: "black"
                            opacity: enabled ? 1.0 : 0.3
                            horizontalAlignment: Label.AlignLeft
                            verticalAlignment: Label.AlignVCenter
                            elide: Label.ElideRight
                        }

                        background: Rectangle {
                            implicitWidth: 250
                            implicitHeight: 40
                            opacity: enabled ? 1.0 : 0.3
                            color: menuItem.highlighted ? root.bDark ? "steelblue" : "orchid" : "transparent"
                            radius: 2
                        }
                    }

                    background: Rectangle {
                        implicitWidth: 250
                        implicitHeight: 40
                        color: "white"
                        border.color: "#000000"
                        radius: 2
                    }
                }
            }

            // Display vertical scroll bar to ListView
            ScrollBar.vertical: ScrollBar {
                id: scrollVBar
                active: true
                policy: ScrollBar.AlwaysOn
                interactive: true
            }
        }
    }
}
