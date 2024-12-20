import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Universal
import "../CustomQML"

Item {
    id: root
    objectName: "pageFirewalld"
    focus: true

    // Property
    property var    parentName:      null
    property bool   bServerMode:     true
    property bool   bDark:           false
    property int    fontCheck:       0
    property int    fontPadding:     0
    property string localFileName:   ""
    property string remoteFilePath:  ""

    // Function to calculate dynamically adjust button gap size
    function calculateSpacing() {
        return Math.max(20, width * 0.05)
    }

    MouseArea {
        id: mouseAreaFirewalld
        anchors.fill: parent
        acceptedButtons: Qt.ForwardButton | Qt.BackButton  // Enable "ForwardButton" and "BackButton" on mouse
        hoverEnabled: true
        z: 1

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

    ScrollView {
        id: scrollView
        width: parent.width
        height : parent.height
        contentWidth: mainColumn.width    // The important part
        contentHeight: mainColumn.height  // Same
        anchors.fill: parent
        clip : false                      // Prevent drawing column outside the scrollview borders
        padding: 20                       // Overall left and right padding

        ColumnLayout {
            id: mainColumn
            x: parent.x
            width: root.width - scrollView.padding * 2      // Adjustment considering scrollView.padding
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 30

            spacing: 20

            Item { Layout.preferredHeight: 30; Layout.fillWidth: true } // 上部のスペース

            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                ComboBox {
                    id: zoneComboBox
                    Layout.preferredWidth: Math.min(root.width / 2, 300)
                    Layout.preferredHeight: 50
                    enabled: !loadingIndicator.running
                    model: []
                }

                Button {
                    id: loadZonesButton
                    text: qsTr("Load Zones")
                    Layout.preferredWidth: Math.min(200, root.width / 5)
                    Layout.preferredHeight: 50
                    font.pointSize: 12 + root.fontPadding

                    contentItem: Text {
                        text:                parent.text
                        font:                parent.font
                        opacity:             enabled ? 1.0 : 0.3
                        color:               root.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                        elide:               Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment:   Text.AlignVCenter
                    }

                    background: Rectangle {
                        id:           buttonBackground
                        color:        parent.pressed ? "#10980a" : "transparent"
                        opacity:      enabled ? 1 : 0.3
                        border.color: parent.pressed ? "#10980a" : "#20a81a"
                        border.width: parent.pressed ? 3 : 2
                        radius:       5
                        anchors.fill: parent
                    }

                    onClicked: {
                        loadingIndicator.running = true
                        FirewalldManager.loadFirewallZones()
                    }

                    enabled: !loadingIndicator.running

                    Shortcut {
                        sequence: "Alt+L"
                        onActivated: {
                            loadZonesButton.clicked()
                        }
                    }
                }

                BusyIndicator {
                    id: loadingIndicator
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    running: false
                }
            }

            TextField {
                id: zoneInput
                placeholderText:    ""
                color:              root.bDark ? "white" : "black"
                font.pointSize:     12 + root.fontPadding
                enabled:            root.bServerMode ? true : false

                Layout.fillWidth:       true
                Layout.preferredHeight: 50

                horizontalAlignment:    TextField.AlignLeft
                verticalAlignment:      TextField.AlignVCenter

                property real placeholderOpacity: 0.5  // Property to control the opacity of placeholders

                background: Rectangle {
                    color: parent.activeFocus ? root.bDark ? "#505050" : "#e0e0ff" : root.bDark ? "black" : "#e0e0e0"
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

                // for custom place holder text
                Text {
                    id: customPlaceholder
                    text: qsTr("Zone (e.g., public)")
                    color: root.bDark ? "white" : "black"
                    opacity: zoneInput.placeholderOpacity
                    visible: !zoneInput.text && !zoneInput.activeFocus
                    font: zoneInput.font
                    elide: Text.ElideRight
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: zoneInput.leftPadding
                        rightMargin: zoneInput.rightPadding
                        verticalCenter: parent.verticalCenter
                    }
                }
            }

            CheckBox {
                id:                     useDefaultCheck
                text:                   qsTr("Use default")
                Layout.preferredHeight: 50
            }

            Label {
                id: defaultPortsLabel
                text:           qsTr("TCP 139 : Used for file and printer sharing and other operations") + "\n" +
                                qsTr("TCP 445 : The NetBIOS-less CIFS port") + "\n" +
                                qsTr("UDP 137 : Used for NetBIOS network browsing") + "\n" +
                                qsTr("UDP 138 : Used for NetBIOS name service")
                width:          parent.width
                font.pointSize: 12 + root.fontPadding
                wrapMode:       Label.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                visible:          !useDefaultCheck.checked

                RoundButton {
                    id:                     btnAddPortButton
                    text:                   ""
                    Layout.preferredWidth:  icon.width
                    Layout.preferredHeight: icon.height
                    icon.source:            pressed ? "qrc:/Image/AddPressed.png" : "qrc:/Image/Add.png"
                    icon.width:             root.fontPadding === -3 ? 24 :
                                            root.fontPadding === 0  ? 36 : 48
                    icon.height:            root.fontPadding === -3 ? 24 :
                                            root.fontPadding === 0  ? 36 : 48
                    icon.color:             "transparent"
                    padding:                0

                    background: Rectangle {
                        color: "transparent"
                    }

                    onClicked: {
                        portModel.append({ port: "",  protocol: "TCP" })
                    }
                }
            }

            Rectangle {
                id: rectPortList
                color: "transparent"
                border.color: "gray"
                border.width: 1
                radius: 5
                clip: true
                visible: !useDefaultCheck.checked

                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(portListView.contentHeight + 20, root.height / 2)

                ScrollView {
                    id: portScrollView
                    anchors.fill: parent
                    anchors.margins: 10
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ListView {
                        id:      portListView
                        width:   portScrollView.width
                        height:  portScrollView.height
                        enabled: !useDefaultCheck.checked
                        visible: !useDefaultCheck.checked
                        spacing: 10     // Add vertical spacing between items

                        model: ListModel {
                            id: portModel
                            ListElement { port: ""; protocol: "TCP" }
                        }

                        delegate: Item {
                            width:  portListView.width - portScrollView.ScrollBar.vertical.width
                            height: 60  // Increased to accommodate padding

                            RowLayout {
                                anchors.fill:        parent
                                anchors.leftMargin:  15  // Left padding
                                anchors.rightMargin: 15  // Right padding
                                spacing:             10

                                TextField {
                                    id: portInput
                                    text:                   port
                                    placeholderText:        ""
                                    color:                  root.bDark ? "white" : "black"
                                    font.pointSize:         12 + root.fontPadding
                                    Layout.fillWidth:       true
                                    Layout.preferredHeight: 50

                                    inputMethodHints:       Qt.ImhDigitsOnly

                                    property real placeholderOpacity: 0.5  // Property to control the opacity of placeholders

                                    background: Rectangle {
                                        color:        parent.activeFocus ? root.bDark ? "#505050" : "#e0e0ff" : root.bDark ? "black" : "#e0e0e0"
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

                                    // for custom place holder text
                                    Text {
                                        text:    qsTr("Port number")
                                        color:   root.bDark ? "white" : "black"
                                        opacity: portInput.placeholderOpacity
                                        visible: !portInput.text && !portInput.activeFocus
                                        font:    portInput.font
                                        elide:   Text.ElideRight

                                        anchors {
                                            left:           parent.left
                                            right:          parent.right
                                            leftMargin:     portInput.leftPadding
                                            rightMargin:    portInput.rightPadding
                                            verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    // Input limit (1 - 65535)
                                    validator: RegularExpressionValidator {
                                        regularExpression: /[1-9][0-9, ]*|65535/
                                    }

                                    // Input limit (No input allowed for 65536 or higher)
                                    onTextEdited: function(acceptableInput, text, displayText) {
                                        if (acceptableInput) {
                                            let ary = text.split(",")
                                            for (let i = 0; i < ary.length; i++) {
                                                let value = ary[i].replace(" ", "")

                                                if (value === "0" || value > 65535) {
                                                    text = displayText
                                                    break
                                                }

                                                let firstCharacter = value.charAt(0)
                                                if (firstCharacter === "0") {
                                                    text = displayText
                                                    break
                                                }
                                            }
                                        }
                                    }

                                    onTextChanged: {
                                        if (text.length > 0 && text.startsWith("0")) {
                                            text = text.replace(/^0+/, "")
                                        }

                                        if (text === "") {
                                            text = ""
                                        }

                                        portModel.setProperty(index, "port", text)
                                    }
                                }

                                ComboBox {
                                    id: protocolComboBox
                                    Layout.preferredWidth:  parent.width / 5
                                    Layout.preferredHeight: 50
                                    font.pointSize:         12 + root.fontPadding
                                    currentIndex:           protocol === "TCP" ? 0 : 1

                                    model:                  ["TCP", "UDP"]

                                    onCurrentTextChanged: {
                                        portModel.setProperty(index, "protocol", currentText)
                                    }
                                }

                                RoundButton {
                                    text: ""
                                    implicitWidth:  icon.width //Math.max(icon.width + 10, 32)   // Icon size + margin、min : 32 pixel
                                    implicitHeight: icon.width //Math.max(icon.height + 10, 32)  // Icon size + margin、min : 32 pixel
                                    icon.source:    pressed ? "qrc:/Image/CloseCursorPressed.png" : "qrc:/Image/CloseCursor.png"
                                    icon.width:     root.fontPadding === -3 ? 24 :
                                                    root.fontPadding === 0  ? 36 : 48
                                    icon.height:    root.fontPadding === -3 ? 24 :
                                                    root.fontPadding === 0  ? 36 : 48
                                    icon.color:     "transparent"
                                    padding:        0

                                    background: Rectangle {
                                        color: "transparent"
                                    }

                                    onClicked: portModel.remove(index)
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing:          calculateSpacing()

                Layout.topMargin: 30

                Button {
                    id:                     openPortButton
                    text:                   qsTr("Open Port")
                    Layout.preferredWidth:  Math.min(200, root.width / 5)
                    Layout.preferredHeight: 50
                    font.pointSize:         12 + root.fontPadding

                    Layout.alignment:       Qt.AlignHCenter

                    contentItem: Text {
                        text:                parent.text
                        font:                parent.font
                        opacity:             enabled ? 1.0 : 0.3
                        color:               root.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                        elide:               Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment:   Text.AlignVCenter
                    }

                    background: Rectangle {
                        color:        parent.pressed ? "#10980a" : "transparent"
                        opacity:      enabled ? 1 : 0.3
                        border.color: parent.pressed ? "#10980a" : "#20a81a"
                        border.width: parent.pressed ? 3 : 2
                        radius:       5
                        anchors.fill: parent
                    }

                    onClicked: {
                        var ports = []

                        if (useDefaultCheck.checked) {
                            ports.push(
                                       {port: 139, protocol: "TCP"},
                                       {port: 445, protocol: "TCP"},
                                       {port: 137, protocol: "UDP"},
                                       {port: 138, protocol: "UDP"}
                            )
                        }
                        else {
                            for (var i = 0; i < portModel.count; i++) {
                                var item = portModel.get(i)
                                ports.push({
                                    port:     parseInt(item.port),
                                    protocol: item.protocol
                                })
                            }
                        }

                        FirewalldManager.openFirewallPorts(zoneInput.text, ports)
                    }
                }

                Button {
                    id:                     closePortButton
                    text:                   qsTr("Close Port")
                    Layout.preferredWidth:  Math.min(200, root.width / 5)
                    Layout.preferredHeight: 50
                    font.pointSize:         12 + root.fontPadding

                    Layout.alignment:       Qt.AlignHCenter

                    contentItem: Text {
                        text:                parent.text
                        font:                parent.font
                        opacity:             enabled ? 1.0 : 0.3
                        color:               root.bDark ? parent.pressed ? "#cccccc" : "#ffffff" : parent.pressed ? "#333333" : "#000000"
                        elide:               Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment:   Text.AlignVCenter
                    }

                    background: Rectangle {
                        color:        parent.pressed ? "#10980a" : "transparent"
                        opacity:      enabled ? 1 : 0.3
                        border.color: parent.pressed ? "#10980a" : "#20a81a"
                        border.width: parent.pressed ? 3 : 2
                        radius:       5
                        anchors.fill: parent
                    }

                    onClicked: {
                        var ports = []

                        if (useDefaultCheck.checked) {
                            ports.push(
                                       {port: 139, protocol: "TCP"},
                                       {port: 445, protocol: "TCP"},
                                       {port: 137, protocol: "UDP"},
                                       {port: 138, protocol: "UDP"}
                            )
                        }
                        else {
                            for (var i = 0; i < portModel.count; i++) {
                                var item = portModel.get(i)
                                ports.push({
                                    port:     parseInt(item.port),
                                    protocol: item.protocol
                                })
                            }
                        }

                        FirewalldManager.closeFirewallPorts(zoneInput.text, ports)
                    }
                }
            }

            // Space at the bottom
            Item {
                Layout.fillHeight: true
            }
        }
    }

    Connections {
        target: FirewalldManager
        function onZonesLoaded(success, zones, errorMessage) {
            loadingIndicator.running = false
            if (success) {
                // Display success popup.
                completePopup.viewTitle   = qsTr("Zones loaded successfully")
                completePopup.fontPadding = root.fontPadding
                completePopup.bAutoClose  = false
                completePopup.open()

                zoneComboBox.model = zones
            }
            else {
                // Error.
                let errMsg          = errorMessage
                let componentDialog = Qt.createComponent("qrc:/qt/qml/Main/CustomQML/ErrorDialog.qml");

                if (componentDialog.status === Component.Error) {
                    console.error("Error loading component:", componentDialog.errorString());
                }
                else if (componentDialog.status === Component.Ready) {
                    let errorDialog = componentDialog.createObject(root,
                                                                   {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
                                                                    messageTitle: qsTr("Failed to open port"),
                                                                    messageText: errorMessage});
                    errorDialog.show();
                }
            }
        }
    }

    // Update TextField when a zone is selected
    Connections {
        target: zoneComboBox
        function onActivated(index) {
            var selectedZone = zoneComboBox.textAt(index)
            if (zoneInput.text.length > 0) {
                zoneInput.text += ", "
            }
            zoneInput.text += selectedZone
        }
    }

    Connections {
        target: FirewalldManager
        function onPortOpeningFinished(success, errorMessage) {
            if (success) {
                // Display success popup.
                completePopup.viewTitle   = qsTr("Port opened successfully")
                completePopup.fontPadding = parentName.fontPadding
                completePopup.bAutoClose  = false
                completePopup.open()
            }
            else {
                // Error.
                let errMsg          = errorMessage
                let componentDialog = Qt.createComponent("qrc:/qt/qml/Main/CustomQML/ErrorDialog.qml");

                if (componentDialog.status === Component.Error) {
                    console.error("Error loading component:", componentDialog.errorString());
                }
                else if (componentDialog.status === Component.Ready) {
                    let errorDialog = componentDialog.createObject(root,
                                                                   {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
                                                                    messageTitle: qsTr("Failed to open port"),
                                                                    messageText: errorMessage});
                    errorDialog.show();
                }
            }
        }
    }

    Connections {
        target: FirewalldManager
        function onPortClosingFinished(success, errorMessage) {
            if (success) {
                // Display success popup.
                completePopup.viewTitle   = qsTr("Port closed successfully")
                completePopup.fontPadding = parentName.fontPadding
                completePopup.bAutoClose  = false
                completePopup.open()
            }
            else {
                // Error.
                let errMsg          = errorMessage
                let componentDialog = Qt.createComponent("qrc:/qt/qml/Main/CustomQML/ErrorDialog.qml");

                if (componentDialog.status === Component.Error) {
                    console.error("Error loading component:", componentDialog.errorString());
                }
                else if (componentDialog.status === Component.Ready) {
                    let errorDialog = componentDialog.createObject(root,
                                                                   {mainWidth: root.width, mainHeight: root.height, bDark: root.bDark,
                                                                    messageTitle: qsTr("Failed to close port"),
                                                                    messageText: errorMessage});
                    errorDialog.show();
                }
            }
        }
    }

    CompletePopup {
        id: completePopup

        viewTitle: ""
        positionY: Math.round((root.height - completePopup.height) / 10)
        viewWidth: root.width
        fontPadding: 0
        parentName: root.parentName
    }
}
