import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel


ApplicationWindow {
    id:            root
    visible:       true
    width:         1024
    minimumWidth:  800
    height:        768
    minimumHeight: 600
    title:         qsTr("Select a smb.conf file")
    color:         root.bDark ? "#2e2f30" : "#f0f0f0"

    property int    mainWidth:     0
    property int    mainHeight:    0
    property bool   bDark:         false
    property int    fontCheck:     0
    property int    fontPadding:   0
    property bool   bServerMode:   true
    property string rootDirectory: "file:///"
    property var    nameFilters:   ["*"]
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

    // Timer to solve initial focus problem
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

    // Search function
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

    // Check directory permissions
    function checkDirectoryPermissions(path) {
        var bRet = fileSelectDialog.getPermissions(path);
        if (!bRet) {
            // Display error pop-up.
            errorPopup.viewTitle   = qsTr("Cannot open due to lack of permissions")
            errorPopup.fontPadding = root.fontPadding
            errorPopup.bAutoClose  = true
            errorPopup.open()
        }

        return bRet
    }

    // Remove search string from pop-up
    function clearSearch() {
        searchBuffer = ""
    }

    // Search pop-up
    Rectangle {
        id:      searchPopup
        width:   200
        height:  40
        color:   "#3daee9"
        radius:  5
        visible: searchBuffer.length > 0
        z:       1000

        anchors {
            top:     parent.top
            right:   parent.right
            margins: 10
        }

        Text {
            anchors.centerIn: parent
            text:  qsTr("Search word: ") + searchBuffer
            color: root.bDark ? "white" : "black"
        }
    }

    FolderListModel {
        id:               folderModel
        folder:           root.rootDirectory
        nameFilters:      root.nameFilters
        showDirs:         true
        showDotAndDotDot: false
        sortField:        FolderListModel.Name

        // Remove search pop-up string if directory is changed
        onFolderChanged: {
            clearSearch()
        }
    }

    // Custom sorting model
    ListModel {
        id: sortedModel

        function updateModel() {
            clear()

            var tempList = []
            for (var i = 0; i < folderModel.count; i++) {
                var isDir = folderModel.isFolder(i)
                var fileName = folderModel.get(i, "fileName")

                // For directories, always show.
                // For files, show only if matching current filter.
                if (isDir || matchesFilter(fileName)) {
                    tempList.push({
                        fileName: fileName,
                        fileURL: folderModel.get(i, "fileURL"),
                        fileIsDir: isDir,
                        fileSize: folderModel.get(i, "fileSize"),
                        fileModified: folderModel.get(i, "fileModified")
                    })
                }
            }

            tempList.sort(function(a, b) {
                if (a.fileIsDir !== b.fileIsDir) {
                    return a.fileIsDir ? -1 : 1
                }
                return a.fileName.toLowerCase().localeCompare(b.fileName.toLowerCase())
            })

            for (var j = 0; j < tempList.length; j++) {
                append(tempList[j])
            }
        }

        // Function to check if a file matches the current filter.
        function matchesFilter(fileName) {
            if (root.nameFilters[0] === "*") return true

            if (root.nameFilters[0] === "*.conf") {
                return fileName.toLowerCase().endsWith(".conf")
            }

            return false
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

    signal fileSelected(string filePath)

    function openSelectedFile() {
        if (listView.currentIndex >= 0 && !sortedModel.get(listView.currentIndex).fileIsDir) {
            var filePath = sortedModel.get(listView.currentIndex).fileURL.toString().replace("file://", "")
            fileSelected(filePath)  // Send signal.
            root.close()            // Close file select file dialog.
        }
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
                width:  48
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
                color:            root.bDark ? "white" : "black"
                font.pointSize:   14 + root.fontPadding
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
                    model: [qsTr("Name"), qsTr("Size"), qsTr("Type"), qsTr("Modified")]
                    delegate: Rectangle {
                        width: index === 0 ? nameColumnWidth.width :
                                             (index === 1 ? sizeColumnWidth.width : (index === 2 ? typeColumnWidth.width : parent.width - nameColumnWidth.width - sizeColumnWidth.width - typeColumnWidth.width))
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
                                    else if (index === 1) sizeColumnWidth.width = newWidth
                                    else if (index === 2) typeColumnWidth.width = newWidth
                                }
                            }
                        }
                    }
                }
            }
        }

        ScrollView {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            clip:              true

            ListView {
                id:                 listView
                anchors.fill:       parent
                model:              sortedModel
                focus:              true
                keyNavigationWraps: true

                Item {
                    id:    nameColumnWidth
                    width: 200
                }

                Item {
                    id:    sizeColumnWidth
                    width: 100
                }

                Item {
                    id:    typeColumnWidth
                    width: 100
                }

                delegate: ItemDelegate {
                    width:       ListView.view.width
                    height:      30
                    highlighted: ListView.isCurrentItem

                    background: Rectangle {
                        color:        parent.highlighted ? "#3daee9" : "transparent"
                        anchors.fill: parent
                    }

                    contentItem: Row {
                        spacing: 0

                        Text {
                            text:   fileName
                            width:  nameColumnWidth.width
                            height: parent.height
                            elide:  Text.ElideRight
                            color:  parent.parent.highlighted ? "white" : root.bDark ? "#eff0f1" : "black"
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            text:   fileIsDir ? "" : fileSize
                            width:  sizeColumnWidth.width
                            height: parent.height
                            color:  parent.parent.highlighted ? "white" : root.bDark ? "#eff0f1" : "black"
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            text: fileIsDir ? "Directory" : "File"
                            width: typeColumnWidth.width
                            height: parent.height
                            color:  parent.parent.highlighted ? "white" : root.bDark ? "#eff0f1" : "black"
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            text: fileModified.toLocaleString(Qt.locale(), qsTr("yyyy/M/d h:mm:ss t"))
                            //text: fileModified.toLocaleString(Qt.locale(), "yyyy年M月d日 h時mm分ss秒 t")
                            width: parent.parent.width - nameColumnWidth.width - sizeColumnWidth.width - typeColumnWidth.width
                            height: parent.height
                            color:  parent.parent.highlighted ? "white" : root.bDark ? "#eff0f1" : "black"
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    onClicked: {
                        listView.currentIndex = index
                        if (!fileIsDir) {
                            fileNameInput.text = fileName
                        }

                        // Ensure the ListView gets focus when any part of the delegate is focused
                        listView.forceActiveFocus()
                    }

                    onDoubleClicked: {
                         if (fileIsDir) {
                            if (!checkDirectoryPermissions(fileURL)) {
                                return
                            }

                            var targetUrl         = fileURL
                            folderModel.folder    = targetUrl
                            listView.currentIndex = -1

                            // Wait until the folderModel component has been updated before performing the operation
                            folderModel.statusChanged.connect(function() {
                                if (folderModel.status === FolderListModel.Ready) {
                                    // Disconnect to run only once
                                    folderModel.statusChanged.disconnect(arguments.callee)

                                    // Ensure that the listView component is present before performing the operation.
                                    if (listView && listView.count > 0) {
                                        listView.currentIndex = 0
                                        forceActiveFocus()
                                    }
                                }
                            })
                        }
                        else {
                            openSelectedFile()
                        }
                    }
                }

                Keys.onTabPressed: function(event) {
                    if (event.modifiers & Qt.ShiftModifier) {
                        addressBar.forceActiveFocus();
                    }
                    else {
                        fileNameInput.forceActiveFocus();
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
                        if (sortedModel.get(currentIndex).fileIsDir) {
                            if (!checkDirectoryPermissions(sortedModel.get(currentIndex).fileURL)) {
                                return
                            }

                            folderModel.folder = sortedModel.get(currentIndex).fileURL
                            currentIndex = -1

                            // Wait until the folderModel component has been updated before performing the operation
                            folderModel.statusChanged.connect(function() {
                                if (folderModel.status === FolderListModel.Ready) {
                                    // Disconnect to run only once
                                    folderModel.statusChanged.disconnect(arguments.callee)

                                    // Ensure that the listView component is present before performing the operation.
                                    if (listView && count > 0) {
                                        currentIndex = 0
                                        forceActiveFocus()
                                    }
                                }
                            })
                        }
                        else {
                            openSelectedFile()
                        }
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
                            clearSearch()
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
                            // The Delete key normally deletes the character behind the cursor,
                            // but since the search buffer does not track the current cursor position,
                            // it does nothing here.
                            event.accepted = true
                            break
                        case Qt.Key_Tab:
                            // Disable [Tab] key.
                            event.accepted = true
                            break
                        case Qt.Key_Return:
                        case Qt.Key_Enter:
                            if (currentItem) {
                                if (sortedModel.get(currentIndex).fileIsDir) {
                                    if (!checkDirectoryPermissions(sortedModel.get(currentIndex).fileURL)) {
                                        return
                                    }

                                    folderModel.folder = sortedModel.get(currentIndex).fileURL
                                    currentIndex = -1

                                    // Wait until the folderModel component has been updated before performing the operation
                                    folderModel.statusChanged.connect(function() {
                                        if (folderModel.status === FolderListModel.Ready) {
                                            // Disconnect to run only once
                                            folderModel.statusChanged.disconnect(arguments.callee)

                                            // Ensure that the listView component is present before performing the operation.
                                            if (listView && count > 0) {
                                                currentIndex = 0
                                                forceActiveFocus()
                                            }
                                        }
                                    })
                                }
                                else {
                                    openSelectedFile()
                                }
                            }
                            event.accepted = true
                            break
                        default:
                            // Search by text input.
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

            Label {
                text: qsTr("File(N):")
                color: root.bDark ? "white" : "black"
            }

            TextField {
                id: fileNameInput
                color:            root.bDark ? "white" : "black"
                font.pointSize:   14 + root.fontPadding
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
                            color:  root.bDark ? "#303050" : "#e0e0ff"
                        }
                    }
                ]
            }

            Label {
                text:  qsTr("Type:")
                color: root.bDark ? "white" : "black"
            }

            ComboBox {
                id: fileTypeCmbBox
                Layout.preferredWidth: 200
                currentIndex:          0

                model: [qsTr("All files (*)"), qsTr("config files (*.conf)")]

                contentItem: Label {
                    text:                parent.displayText
                    font.pointSize:      12 + root.fontPadding
                    color:               parent.enabled ? root.bDark ? "white" : "black" : "darkgrey"
                    verticalAlignment:   Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    leftPadding:         10
                }

                background: Rectangle {
                    implicitWidth:  200
                    implicitHeight: fileNameInput.height
                    color:          parent.down ? "blue" : "transparent"
                    border.color:   parent.enabled ? parent.hovered ? "blue" : "gray" : "darkgrey"
                    border.width:   1
                    opacity:        0.3
                    radius:         2
                }

                delegate: ItemDelegate {
                    width:       parent.width
                    highlighted: pressed || visualFocus

                    contentItem: Text {
                        text:          modelData
                        color:         parent.hovered ? "blue" : root.bDark ? "white" : "black"
                        font {
                            family:    parent.font.family
                            pointSize: parent.font.pointSize
                            bold:      fileTypeCmbBox.currentIndex === index  // Bold if it matches the current index.
                        }
                        elide:             Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                onCurrentIndexChanged: {
                    // Update filters according to ComboBox selection.
                    if (currentIndex === 0) {
                        root.nameFilters = ["*"]
                    }
                    else {
                        root.nameFilters = ["*.conf"]
                    }

                    // Update model after filter changes.
                    sortedModel.updateModel()
                }
            }
        }

        RowLayout {
            Layout.fillWidth:    true
            Layout.alignment:    Qt.AlignRight
            spacing:             Math.max(20, Math.min(root.width * 0.025, 100))

            Button {
                id:             openBtn
                text:           qsTr("Open") + "(<u>O</u>)"
                implicitWidth:  Math.max(150, Math.min(root.width * 0.15, 250))
                implicitHeight: Math.max(35, Math.min(root.height * 0.05, 70))
                font.pointSize: 12 + root.fontPadding
                flat:           false

                contentItem: Label {
                    text:       parent.text
                    textFormat: Label.RichText
                    font:       parent.font
                    opacity:    enabled ? 1.0 : 0.3
                    color:      root.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                    elide:      Label.ElideRight

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
                    if (sortedModel.get(listView.currentIndex).fileIsDir) {
                        if (!checkDirectoryPermissions(sortedModel.get(listView.currentIndex).fileURL)) {
                             return
                        }

                        folderModel.folder    = sortedModel.get(listView.currentIndex).fileURL
                        listView.currentIndex = -1

                        // Wait until the folderModel component has been updated before performing the operation
                        folderModel.statusChanged.connect(function() {
                            if (folderModel.status === FolderListModel.Ready) {
                                // Disconnect to run only once
                                folderModel.statusChanged.disconnect(arguments.callee)

                                // Ensure that the listView component is present before performing the operation.
                                if (listView && listView.count > 0) {
                                    listView.currentIndex = 0
                                    listView.forceActiveFocus()
                                }
                            }
                        })
                    }
                    else {
                        openSelectedFile()
                    }
                }

                Shortcut {
                    sequence: "Alt+O"
                    onActivated: {
                        openBtn.clicked()
                    }
                }
            }

            Button {
                id:     cancelBtn
                text:   qsTr("Cancel") + "(<u>C</u>)"
                implicitWidth:  Math.max(150, Math.min(root.width * 0.15, 250))
                implicitHeight: Math.max(35, Math.min(root.height * 0.05, 70))
                font.pointSize: 12 + root.fontPadding
                focus:  true
                flat:   false

                contentItem: Label {
                    text:       parent.text
                    textFormat: Label.RichText
                    font:       parent.font
                    opacity:    enabled ? 1.0 : 0.3
                    color:      root.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                    elide:      Label.ElideRight

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

    // Monitor the variable searchBuffer for changes
    // Hide pop-up if all strings in the pop-up are deleted
    onSearchBufferChanged: {
        if (searchBuffer.length === 0) {
            searchPopup.visible = false
        }
        else {
            searchPopup.visible = true
        }
    }

    // When the back button of the mouse is pressed, it moves up one directory.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.BackButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.BackButton) {
                goToParentFolder()
            }
        }
    }

    // Error pop-up
    ErrorPopup {
        id:          errorPopup

        viewTitle:   ""
        positionY:   Math.round((root.height - errorPopup.height) / 10)
        viewWidth:   root.width
        fontPadding: 0
        bAutoClose:  true
    }
}
