import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel


ApplicationWindow {
    id: root
    visible: true
    width: 1024
    minimumWidth: 800
    height: 768
    minimumHeight: 600
    title: qsTr("Select a directory")
    color: root.bDark ? "#2e2f30" : "#f0f0f0"

    property int    mainWidth:     0
    property int    mainHeight:    0
    property bool   bDark:         false
    property int    fontCheck:     0
    property int    fontPadding:   0
    property bool   bServerMode:   true
    property string rootDirectory: "file:///"
    property string searchBuffer:  ""

    Shortcut {
        sequence: "Alt+left"
        onActivated: {
            goToParentFolder()
        }
    }

    Component.onCompleted: {
        initializeListView()
    }

    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            initializeListView()
        }
    }

    function initializeListView() {
        if (listView.count > 0) {
            listView.currentIndex = 0
            listView.forceActiveFocus()
        }
    }

    function performSearch() {
        var searchText = searchBuffer.toLowerCase()
        for (var i = 0; i < sortedModel.count; i++) {
            var fileName = sortedModel.get(i).fileName.toLowerCase()
            if (fileName.startsWith(searchText)) {
                listView.currentIndex = i
                listView.positionViewAtIndex(i, ListView.Center)
                break
            }
        }
    }

    function checkDirectoryPermissions(path) {
        var bRet = fileSelectDialog.getPermissions(path);
        if (!bRet) {
            errorPopup.viewTitle   = qsTr("Cannot open due to lack of permissions")
            errorPopup.fontPadding = root.fontPadding
            errorPopup.bAutoClose  = true
            errorPopup.open()
        }
        return bRet
    }

    function clearSearch() {
        searchBuffer = ""
    }

    Rectangle {
        id: searchPopup
        width: 200
        height: 40
        color: "#3daee9"
        radius: 5
        visible: searchBuffer.length > 0
        z: 1000

        anchors {
            top: parent.top
            right: parent.right
            margins: 10
        }

        Text {
            anchors.centerIn: parent
            text: "Search: " + searchBuffer
            color: root.bDark ? "white" : "black"
        }
    }

    FolderListModel {
        id: folderModel
        folder: root.rootDirectory
        showDirs: true
        showFiles: false
        showDotAndDotDot: false
        sortField: FolderListModel.Name

        onFolderChanged: {
            clearSearch()
        }
    }

    ListModel {
        id: sortedModel

        function updateModel() {
            clear()

            var tempList = []
            for (var i = 0; i < folderModel.count; i++) {
                tempList.push({
                    fileName: folderModel.get(i, "fileName"),
                    fileURL: folderModel.get(i, "fileURL"),
                    fileModified: folderModel.get(i, "fileModified")
                })
            }

            tempList.sort(function(a, b) {
                return a.fileName.toLowerCase().localeCompare(b.fileName.toLowerCase())
            })

            for (var j = 0; j < tempList.length; j++) {
                append(tempList[j])
            }
        }
    }

    Connections {
        target: folderModel
        function onStatusChanged() {
            if (folderModel.status === FolderListModel.Ready) {
                sortedModel.updateModel()
            }
        }
    }

    signal directorySelected(string dirPath)

    function selectCurrentDirectory() {
        var dirPath;
        if (listView.currentIndex >= 0) {
            if (!checkDirectoryPermissions(sortedModel.get(listView.currentIndex).fileURL.toString())) {
                return
            }
            dirPath = sortedModel.get(listView.currentIndex).fileURL.toString().replace("file://", "")
        }
        else {
            dirPath = folderModel.folder.toString().replace("file://", "")
        }

        directorySelected(dirPath)
        root.close()
    }

    function goToParentFolder() {
        if (folderModel.folder.toString() !== "file:///") {
            var parentFolder = folderModel.parentFolder
            if (String(parentFolder) !== "") {
                folderModel.folder = parentFolder
            }
            listView.forceActiveFocus()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            RoundButton {
                id: upButton
                text: ""
                width: 48
                height: 48
                enabled: folderModel.folder.toString() !== "file:///"

                icon.source: root.bServerMode ? pressed ? "qrc:/Image/UpDirectoryPressed.png" : "qrc:/Image/UpDirectory.png"
                                              : pressed ? "qrc:/Image/FileNetworkButtonPressed.png" : "qrc:/Image/FileNetworkButton.png"
                icon.width: width
                icon.height: height
                icon.color: "transparent"

                padding: 0

                background: Rectangle {
                    color: "transparent"
                }

                onClicked: {
                    goToParentFolder()
                }
            }

            Label {
                text: "Address:"
                color: root.bDark ? "white" : "black"
            }

            TextField {
                id: addressBar
                text: String(folderModel.folder) === "file:///" ? "/" : folderModel.folder.toString().replace("file://", "")
                color: root.bDark ? "white" : "black"
                font.pointSize: 14 + root.fontPadding
                Layout.fillWidth: true

                background: Rectangle {
                    color: parent.activeFocus ? root.bDark ? "#505050" : "#e0e0ff" : root.bDark ? "#3f3f3f" : "#e0e0e0"
                    border.width: parent.activeFocus ? root.bDark ? 2 : 1 : 1
                    border.color: parent.activeFocus ? root.bDark ? "dodgerblue" : "lightblue" : root.bDark ? "grey" : "lightgrey"
                }

                states: [
                    State {
                        name: "focused"
                        when: activeFocus
                        PropertyChanges {
                            target: background
                            color: root.bDark ? "#303050" : "#e0e0ff"
                        }
                    }
                ]

                onAccepted: {
                    folderModel.folder = text.startsWith("/") ? "file://" + text : text
                    listView.currentIndex = -1
                    Qt.callLater(function() {
                        if (listView.count > 0) {
                            listView.currentIndex = 0
                            listView.forceActiveFocus()
                        }
                    })
                }
            }
        }

        Rectangle {
            id: header
            Layout.fillWidth: true
            height: 30
            color: root.bDark ? "#3e3e3e" : "#d0d0d0"

            Row {
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: [qsTr("Name"), qsTr("Modified")]
                    delegate: Rectangle {
                        width: index === 0 ? nameColumnWidth.width : parent.width - nameColumnWidth.width
                        height: parent.height
                        color: "transparent"
                        border.color: "#555555"

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.bold: true
                            color: root.bDark ? "white" : "black"
                        }

                        MouseArea {
                            width: 5
                            height: parent.height
                            anchors.right: parent.right
                            cursorShape: Qt.SplitHCursor
                            property int startX
                            property int originalWidth

                            onPressed: function(mouseX) {
                                startX = mouseX
                                originalWidth = parent.width
                            }

                            onPositionChanged: function(mouseX, pressed) {
                                if (pressed) {
                                    var newWidth = Math.max(50, originalWidth + mouseX - startX)
                                    if (index === 0) nameColumnWidth.width = newWidth
                                }
                            }
                        }
                    }
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: listView
                anchors.fill: parent
                model: sortedModel
                focus: true
                activeFocusOnTab: true
                keyNavigationEnabled: true
                keyNavigationWraps: true

                Item {
                    id: nameColumnWidth
                    width: 200
                }

                delegate: ItemDelegate {
                    width: ListView.view.width
                    height: 30
                    highlighted: ListView.isCurrentItem

                    background: Rectangle {
                        color: parent.highlighted ? "#3daee9" : "transparent"
                        anchors.fill: parent
                    }

                    contentItem: Row {
                        spacing: 0

                        Text {
                            text: fileName
                            width: nameColumnWidth.width
                            height: parent.height
                            elide: Text.ElideRight
                            color: parent.parent.highlighted ? "white" : root.bDark ? "#eff0f1" : "black"
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            text: fileModified.toLocaleString(Qt.locale(), qsTr("yyyy/M/d h:mm:ss t"))
                            width: parent.parent.width - nameColumnWidth.width
                            height: parent.height
                            color: parent.parent.highlighted ? "white" : root.bDark ? "#eff0f1" : "black"
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    onClicked: {
                        listView.currentIndex = index
                        listView.forceActiveFocus()
                    }

                    onDoubleClicked: {
                        if (!checkDirectoryPermissions(fileURL)) {
                            return
                        }

                        var targetUrl = fileURL
                        folderModel.folder = targetUrl
                        listView.currentIndex = -1

                        folderModel.statusChanged.connect(function() {
                            if (folderModel.status === FolderListModel.Ready) {
                                folderModel.statusChanged.disconnect(arguments.callee)

                                if (listView && listView.count > 0) {
                                    listView.currentIndex = 0
                                    forceActiveFocus()
                                }
                            }
                        })
                    }
                }

                Keys.onTabPressed: function(event) {
                    if (event.modifiers & Qt.ShiftModifier) {
                        addressBar.forceActiveFocus();
                    }
                    else {
                        selectBtn.forceActiveFocus();
                    }
                    event.accepted = true;
                }

                Keys.onUpPressed: {
                    if (currentIndex > 0) currentIndex--
                }

                Keys.onDownPressed: {
                    if (currentIndex < count - 1) currentIndex++
                }

                Keys.onReturnPressed: {
                    if (currentItem) {
                        if (!checkDirectoryPermissions(sortedModel.get(currentIndex).fileURL)) {
                            return
                        }

                        folderModel.folder = sortedModel.get(currentIndex).fileURL
                        currentIndex = -1

                        folderModel.statusChanged.connect(function() {
                            if (folderModel.status === FolderListModel.Ready) {
                                folderModel.statusChanged.disconnect(arguments.callee)

                                if (listView && count > 0) {
                                    currentIndex = 0
                                    forceActiveFocus()
                                }
                            }
                        })
                    }
                }

                Keys.onPressed: function(event) {
                    switch (event.key) {
                        case Qt.Key_Home:
                            currentIndex = 0
                            event.accepted = true
                            break
                        case Qt.Key_End:
                            currentIndex = count - 1
                            event.accepted = true
                            break
                        case Qt.Key_PageUp:
                            currentIndex = Math.max(0, currentIndex - Math.floor(height / 30))
                            event.accepted = true
                            break
                        case Qt.Key_PageDown:
                            currentIndex = Math.min(count - 1, currentIndex + Math.floor(height / 30))
                            event.accepted = true
                            break
                        case Qt.Key_Escape:
                            // clearSearch()
                            // event.accepted = true
                            if (searchBuffer.length > 0) {
                                clearSearch()
                            }
                            else {
                                currentIndex   = -1
                                listView.focus = false
                            }

                            event.accepted = true
                            break
                        case Qt.Key_Backspace:
                            if (root.searchBuffer.length > 0) {
                                root.searchBuffer = root.searchBuffer.slice(0, -1)
                                performSearch()
                            }
                            event.accepted = true
                            break
                        case Qt.Key_Delete:
                            event.accepted = true
                            break
                        case Qt.Key_Tab:
                            event.accepted = true
                            break
                        default:
                            if (event.text.length > 0) {
                                root.searchBuffer += event.text
                                performSearch()
                                event.accepted = true
                            }
                            break
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            spacing:          Math.max(20, Math.min(root.width * 0.025, 100))

            Button {
                id:             selectBtn
                text:           qsTr("Select") + "(<u>S</u>)"
                implicitWidth:  Math.max(150, Math.min(root.width * 0.15, 250))
                implicitHeight: Math.max(35, Math.min(root.height * 0.05, 70))
                font.pointSize: 12 + root.fontPadding
                flat:           false

                contentItem: Label {
                    text:                parent.text
                    font:                parent.font
                    textFormat:          Label.RichText
                    opacity:             enabled ? 1.0 : 0.3
                    color:               root.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                    elide:               Label.ElideRight
                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment:   Label.AlignVCenter
                }

                background: Rectangle {
                    color:        parent.pressed ? border.color : "transparent"
                    opacity:      parent.pressed ? 0.8 : 1
                    border.color: root.bDark     ? "#10980a" : "#20a81a"
                    border.width: parent.pressed ? 0 : 2
                    radius:       5
                    anchors.fill: parent
                }

                onClicked: {
                    selectCurrentDirectory()
                }

                Shortcut {
                    sequence: "Alt+S"
                    onActivated: {
                        selectBtn.clicked()
                    }
                }
            }

            Button {
                id:             cancelBtn
                text:           qsTr("Cancel") + "(<u>C</u>)"
                implicitWidth:  Math.max(150, Math.min(root.width * 0.15, 250))
                implicitHeight: Math.max(35, Math.min(root.height * 0.05, 70))
                font.pointSize: 12 + root.fontPadding
                focus:          true
                flat:           false

                contentItem: Label {
                    text:                parent.text
                    font:                parent.font
                    textFormat:          Label.RichText
                    opacity:             enabled ? 1.0 : 0.3
                    color:               root.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                    elide:               Label.ElideRight
                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment:   Label.AlignVCenter
                }

                background: Rectangle {
                    color:        parent.pressed ? border.color : "transparent"
                    opacity:      parent.pressed ? 0.8 : 1
                    border.color: root.bDark     ? "#10980a" : "#20a81a"
                    border.width: parent.pressed ? 0 : 2
                    radius:       5
                    anchors.fill: parent
                }

                onClicked: {
                    root.close()
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

    onSearchBufferChanged: {
        if (searchBuffer.length === 0) {
            searchPopup.visible = false
        }
        else {
            searchPopup.visible = true
        }
    }

    MouseArea {
        anchors.fill:    parent
        acceptedButtons: Qt.BackButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.BackButton) {
                goToParentFolder()
            }
        }
    }

    ErrorPopup {
        id:          errorPopup
        viewTitle:   ""
        positionY:   Math.round((root.height - errorPopup.height) / 10)
        viewWidth:   root.width
        fontPadding: 0
        bAutoClose:  true
    }
}
