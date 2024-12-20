import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Universal
import "../CustomQML"


ApplicationWindow {
    id: mainWindow
    objectName: "MainWindow"

    x: 0
    y: 0
    width: 1280
    minimumWidth: 1024
    height: 800
    minimumHeight: 600

    visible: true
    visibility: Window.Windowed
    title: qsTr("SambaConfig for PC")

    color: mainWindow.bDark ? "#202020" : "#f0f0f0"

    property int  fontCheck:        1
    property int  fontPadding:      fontCheck === 0 ? -3 : fontCheck === 1 ? 0 : 3
    property bool bDark:            ApplicationState.getColorMode()
    property bool bServerMode:      ApplicationState.getServerMode()
    property bool bFirstSystemd:    ApplicationState.getFirstSystemd()
    property var  aryPrevIndexes:   []
    property var  aryFowardIndexes: []
    property int  nextIndex:        0
    property bool allowClose:       false


    // Dynamic application of themes
    Material.theme: mainWindow.bDark ? Material.Dark : Material.Light
    Universal.theme: mainWindow.bDark ? Universal.Dark : Universal.Light

    // Quit software.
    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: {
            saveApplicationState()
            mainWindow.close()
        }
    }

    // Return to Welcome screen.
    Shortcut {
        sequences: ["Shift+Esc", "Home"]
        onActivated: {
            if (stackLayout.currentIndex !== 0) {
                if (stackLayout.currentIndex === 5) {
                    mainWindow.fnSaveModeSettings("", 2)
                }
                else {
                    aryFowardIndexes = []
                    aryPrevIndexes   = []
                    stackLayout.currentIndex = 0
                }
            }
        }
    }

    Component.onCompleted: {
        // If forgot to turn off the temporary overwrite flag for a theme, remove the flag.
        ApplicationState.setColorModeOverWrite(false)

        // Load font size settings.
        mainWindow.fontCheck    = ApplicationState.getFontSize()

        // Set [Server mode] or [Client mode]
        mainWindow.bServerMode  = ApplicationState.getServerMode()

        // Load the welcome screen.
        stackLayout.currentIndex = 0
    }

    // Open quit dialog.
    onClosing: function(closeEvent) {
        if (!allowClose) {
            closeEvent.accepted = false

            var component = Qt.createComponent("qrc:/qt/qml/Main/CustomQML/QuitDialog.qml");
            if (component.status === Component.Ready) {
                var quitDialog = component.createObject(mainWindow, {
                                                            mainWidth: Math.round(Math.min(mainWindow.width, mainWindow.height) / 10 * 9),
                                                            bDark: mainWindow.bDark,
                                                            fontPadding: mainWindow.fontPadding,
                                                            applicationState: ApplicationState});
                quitDialogConnection.target = quitDialog
                quitDialog.show();
            }
        }
    }

    Connections {
        id: quitDialogConnection
        function onVisibleChanged() {
            if(!target.visible) {
                if (target.returnValue === 0) {
                    // Remove tmp files.
                    ApplicationState.removeTmpFiles()

                    // Save Application State
                    saveApplicationState()

                    // Exit SambaConfig
                    mainWindow.allowClose = true
                    mainWindow.close()
                }
            }
        }
    }

    function saveApplicationState() {
        // Save window state
        let bMaximized = false
        if (mainWindow.visibility === Window.Maximized) {
            bMaximized = true;
            ApplicationState.setMainWindowState(ApplicationState.getMainWindowX(),
                                                ApplicationState.getMainWindowY(),
                                                ApplicationState.getMainWindowWidth(),
                                                ApplicationState.getMainWindowHeight(),
                                                bMaximized)
        }
        else {
            ApplicationState.setMainWindowState(x, y, width, height, bMaximized)
        }

        // Save color mode
        if (mainWindow.bDark === false && ApplicationState.getColorModeOverWrite() === 1) {
            ApplicationState.setColorMode(true)
        }
        else if (mainWindow.bDark === true && ApplicationState.getColorModeOverWrite() === 1) {
            ApplicationState.setColorMode(false)
        }

        ApplicationState.setColorModeOverWrite(false)
    }

    // Press the [Back] or [Foward] button on the mouse to move to other screen from other screens.
    signal screenMoved(string viewName, int move)
    onScreenMoved: (viewName, move) => {
        fnScreenMove(viewName, move)
    }

    function fnScreenMove(viewName, move) {
        // If changing settings on [Mode] screen.
        if (stackLayout.currentIndex === 5) {
            fontCheck = ApplicationState.getFontSize()
        }

        // Move screen.
        if (move === 0) {
            // Next screen.
            fnPrevIndex(stackLayout.currentIndex)
        }
        else if (move === 1) {
            // Previous screen.
            fnFowardIndex(stackLayout.currentIndex)
        }
        else if (move === 2) {
            // Back to [Welcome] screen.
            aryFowardIndexes = []
            aryPrevIndexes   = []
            stackLayout.currentIndex = 0
        }
        else if (move === 3) {
            // Move to specify screen using side button.
            stackLayout.currentIndex = mainWindow.nextIndex
        }
    }

    function fnSaveModeSettings(viewName, move) {
        fontCheck = ApplicationState.getFontSize()

        // If changing settings on [Mode] screen.
        if (stackLayout.currentIndex === 5) {
            modeSettings.fnSaveModeSettings(viewName, move)
        }
    }

    // When mouse back button is pressed, return to previous view.
    function fnPrevIndex(index) {
        if (aryPrevIndexes.length > 0) {
            let tmparyFowardIndexes = []
            tmparyFowardIndexes.push(index)

            if (aryFowardIndexes.length > 0) {
                for (let i = 0; i < aryFowardIndexes.length; i++) {
                    tmparyFowardIndexes.push(aryFowardIndexes[i])
                }
            }

            aryFowardIndexes = tmparyFowardIndexes

            stackLayout.currentIndex = aryPrevIndexes.pop()
        }
    }

    // When mouse foward button is pressed, advance to next view.
    function fnFowardIndex(index) {
        if (aryFowardIndexes.length > 0) {
            aryPrevIndexes.push(index)

            stackLayout.currentIndex = aryFowardIndexes.shift()
        }
    }

    // Index change using side button.
    function fnIndexChange(index) {
        aryFowardIndexes = []
        aryPrevIndexes.push(stackLayout.currentIndex)

        if (aryPrevIndexes[aryPrevIndexes.length - 1] === 5) {
            mainWindow.nextIndex = index
            modeSettings.fnSaveModeSettings("", 3)
        }
        else {
            stackLayout.currentIndex = index
        }
    }

    Row {
        anchors.fill:        parent
        anchors.leftMargin:  10
        anchors.rightMargin: 10

        spacing: 0

        ScrollView {
            id:            menuScrollView
            width:         Math.round(mainWindow.width / 7) < 250 ? 250 : Math.round(mainWindow.width / 7) < 300 ? Math.round(mainWindow.width / 7) : 300
            height:        parent.height
            contentHeight: columnMenu.implicitHeight  // Explicitly specify the height of the left pane of the screen.
            clip:          true

            ScrollBar.vertical.policy:   ScrollBar.AsNeeded
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                id:                    columnMenu
                width:                 menuScrollView.width
                Layout.preferredWidth: Math.min(mainWindow.width / 7, 300)
                Layout.minimumWidth:   250
                Layout.maximumWidth:   300
                Layout.alignment:      Qt.AlignTop | Qt.AlignHCenter

                spacing: 30

                RoundButton {
                    id:             btnSamba
                    text:           qsTr("Samba")
                    implicitWidth:  parent.width
                    font.pointSize: 15 + mainWindow.fontPadding
                    flat:           false

                    Layout.fillWidth: true
                    Layout.topMargin: 60

                    contentItem: Label {
                        text: btnSamba.text
                        font: btnSamba.font
                        opacity: enabled ? 1.0 : 0.3
                        color: btnSamba.pressed ? "#6060ff" : mainWindow.bDark ? "#ffffff" : "#000000"

                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.AlignVCenter
                        elide: Label.ElideRight
                    }

                    background: Rectangle {
                        opacity: enabled ? 1 : 0.3
                        color: "transparent"
                        border.color: btnSamba.pressed ? "#6060ff" : mainWindow.bDark ? "#ffffff" : "#000000"
                        border.width: btnSamba.pressed ? 5 : 4
                        radius: 50
                    }

                    Connections {
                        target: btnSamba
                        function onClicked() {
                            if (stackLayout.currentIndex !== 1) {
                                mainWindow.fnIndexChange(1)
                                stackLayout.currentIndex = 1
                            }
                        }
                    }

                    ToolTip {
                        id: btnSambaToolTip
                        text: qsTr("Move to the Samba settings screen")
                        visible: btnSamba.hovered
                        delay: 500
                        timeout: 5000
                    }
                }

                RoundButton {
                    id: btnSambaTest
                    text: qsTr("Samba Test")
                    implicitWidth: parent.width
                    font.pointSize: 15 + mainWindow.fontPadding
                    flat: false

                    Layout.fillWidth: true

                    contentItem: Label {
                        text: btnSambaTest.text
                        font: btnSambaTest.font
                        opacity: enabled ? 1.0 : 0.3
                        color: btnSambaTest.pressed ? "#6060ff" : mainWindow.bDark ? "#ffffff" : "#000000"

                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.AlignVCenter
                        elide: Label.ElideRight
                    }

                    background: Rectangle {
                        opacity: enabled ? 1 : 0.3
                        color: "transparent"
                        border.color: btnSambaTest.pressed ? "#6060ff" : mainWindow.bDark ? "#ffffff" : "#000000"
                        border.width: btnSambaTest.pressed ? 5 : 4
                        radius: 50
                    }

                    Connections {
                        target: btnSambaTest
                        function onClicked() {
                            if (stackLayout.currentIndex !== 2) {
                                mainWindow.fnIndexChange(2)
                                stackLayout.currentIndex = 2
                            }
                        }
                    }

                    ToolTip {
                        id:      btnSambaTestToolTip
                        text:    qsTr("Move to the Samba test screen")
                        visible: btnSambaTest.hovered
                        delay:   500
                        timeout: 5000
                    }
                }

                RoundButton {
                    id: btnUserSettings
                    text: qsTr("Samba User")
                    implicitWidth: parent.width
                    font.pointSize: 15 + mainWindow.fontPadding
                    flat: false

                    Layout.fillWidth: true

                    contentItem: Label {
                        text: btnUserSettings.text
                        font: btnUserSettings.font
                        opacity: enabled ? 1.0 : 0.3
                        color: btnUserSettings.pressed ? "#6060ff" : mainWindow.bDark ? "#ffffff" : "#000000"

                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.AlignVCenter
                        elide: Label.ElideRight
                    }

                    background: Rectangle {
                        opacity: enabled ? 1 : 0.3
                        color: "transparent"
                        border.color: btnUserSettings.pressed ? "#6060ff" : mainWindow.bDark ? "#ffffff" : "#000000"
                        border.width: btnUserSettings.pressed ? 5 : 4
                        radius: 50
                    }

                    Connections {
                        target: btnUserSettings
                        function onClicked() {
                            if (stackLayout.currentIndex !== 3) {
                                mainWindow.fnIndexChange(3)
                                stackLayout.currentIndex = 3
                            }
                        }
                    }

                    ToolTip {
                        id:      btnUserSettingsToolTip
                        text:    qsTr("Move to the Samba user settings screen")
                        visible: btnUserSettings.hovered
                        delay:   500
                        timeout: 5000
                    }
                }

                RoundButton {
                    id: btnFirewalld
                    text: qsTr("Firewalld")
                    implicitWidth: parent.width
                    font.pointSize: 15 + mainWindow.fontPadding
                    flat: false

                    Layout.fillWidth: true

                    contentItem: Label {
                        text: btnFirewalld.text
                        font: btnFirewalld.font
                        opacity: enabled ? 1.0 : 0.3
                        color: btnFirewalld.pressed ? "#6060ff" : mainWindow.bDark ? "#ffffff" : "#000000"

                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.AlignVCenter
                        elide: Label.ElideRight
                    }

                    background: Rectangle {
                        opacity: enabled ? 1 : 0.3
                        color: "transparent"
                        border.color: btnFirewalld.pressed ? "#6060ff" : mainWindow.bDark ? "#ffffff" : "#000000"
                        border.width: btnFirewalld.pressed ? 5 : 4
                        radius: 50
                    }

                    Connections {
                        target: btnFirewalld
                        function onClicked() {
                            if (stackLayout.currentIndex !== 4) {
                                mainWindow.fnIndexChange(4)
                                stackLayout.currentIndex = 4
                            }
                        }
                    }

                    ToolTip {
                        id:      btnFirewalldToolTip
                        text:    qsTr("Move to the Firewalld settings screen")
                        visible: btnFirewalld.hovered
                        delay:   500
                        timeout: 5000
                    }
                }

                RoundButton {
                    id: btnSettings
                    text: qsTr("Mode")
                    implicitWidth: parent.width
                    font.pointSize: 15 + mainWindow.fontPadding
                    flat: false

                    Layout.fillWidth: true

                    contentItem: Label {
                        text: btnSettings.text
                        font: btnSettings.font
                        opacity: enabled ? 1.0 : 0.3
                        color: btnSettings.pressed ? "#6060ff" : mainWindow.bDark ? "#ffffff" : "#000000"

                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.AlignVCenter
                        elide: Label.ElideRight
                    }

                    background: Rectangle {
                        opacity: enabled ? 1 : 0.3
                        color: "transparent"
                        border.color: btnSettings.pressed ? "#6060ff" : mainWindow.bDark ? "#ffffff" : "#000000"
                        border.width: btnSettings.pressed ? 5 : 4
                        radius: 50
                    }

                    Connections {
                        target: btnSettings
                        function onClicked() {
                            if (stackLayout.currentIndex !== 5) {
                                mainWindow.fnIndexChange(5)
                                stackLayout.currentIndex = 5
                            }
                        }
                    }

                    ToolTip {
                        id:      btnSettingsToolTip
                        text:    qsTr("Move to the application settings screen")
                        visible: btnSettings.hovered
                        delay:   500
                        timeout: 5000
                    }
                }

                RoundButton {
                    id: btnAboutQt
                    text: qsTr("About Qt")
                    implicitWidth: parent.width
                    font.pointSize: 15 + mainWindow.fontPadding
                    flat: false

                    Layout.fillWidth: true

                    contentItem: Label {
                        text: btnAboutQt.text
                        font: btnAboutQt.font
                        opacity: enabled ? 1.0 : 0.3
                        color: btnAboutQt.pressed ? "#6060ff" : mainWindow.bDark ? "#ffffff" : "#000000"

                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.AlignVCenter
                        elide: Label.ElideRight
                    }

                    background: Rectangle {
                        opacity: enabled ? 1 : 0.3
                        color: "transparent"
                        border.color: btnAboutQt.pressed ? "#6060ff" : mainWindow.bDark ? "#ffffff" : "#000000"
                        border.width: btnAboutQt.pressed ? 5 : 4
                        radius: 50
                    }

                    Connections {
                        target: btnAboutQt
                        function onClicked() {
                            if (stackLayout.currentIndex !== 6) {
                                mainWindow.fnIndexChange(6)
                                stackLayout.currentIndex = 6
                            }
                        }
                    }

                    ToolTip {
                        id:      btnAboutQtToolTip
                        text:    qsTr("Show description of Qt")
                        visible: btnAboutQt.hovered
                        delay:   500
                        timeout: 5000
                    }
                }

                RoundButton {
                    id: btnQuit
                    text: qsTr("Quit")
                    implicitWidth: parent.width
                    font.pointSize: 15 + mainWindow.fontPadding
                    flat: false

                    Layout.fillWidth: true

                    contentItem: Label {
                        text: btnQuit.text
                        font: btnQuit.font
                        opacity: enabled ? 1.0 : 0.3
                        color: btnQuit.pressed ? "#6060ff" : mainWindow.bDark ? "#ffffff" : "#000000"

                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.AlignVCenter
                        elide: Label.ElideRight
                    }

                    background: Rectangle {
                        opacity: enabled ? 1 : 0.3
                        color: "transparent"
                        border.color: btnQuit.pressed ? "#6060ff" : mainWindow.bDark ? "#ffffff" : "#000000"
                        border.width: btnQuit.pressed ? 5 : 4
                        radius: 50
                    }

                    Connections {
                        target: btnQuit
                        function onClicked() {
                            mainWindow.close()
                        }
                    }

                    ToolTip {
                        id: btnQuitToolTip
                        text: qsTr("Quit the application")
                        visible: btnQuit.hovered
                        delay: 500
                        timeout: 5000
                    }
                }

                ColumnLayout {
                    id: columnSambaServiceMenu
                    width: parent.width

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                    Layout.topMargin: 50

                    spacing: 20

                    property bool bSambaService: SambaService.bSambaService
                    property bool bNMBService:   SambaService.bNMBService

                    Label {
                        id: labelSambaService
                        text: {
                            if (mainWindow.bServerMode) {
                                qsTr("Samba Service :") + "<br>" + "<span style=\"color: #10980a;\"><b>" + qsTr("(this computer)") + "</b></span>"
                            }
                            else {
                                qsTr("Samba Service :") + "<br>" + "<span style=\"color: #10980a;\"><b>" + qsTr("(Remote server)") + "</b></span>"
                            }
                        }
                        width: parent.availableWidth
                        font.pointSize: 12 + mainWindow.fontPadding

                        textFormat: Label.RichText
                        wrapMode: Label.WordWrap

                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.AlignVCenter
                        Layout.fillWidth: true
                    }

                    Label {
                        id: labelStartSamba
                        text: columnSambaServiceMenu.bSambaService === false ? qsTr("Start / Restart") + "<br>" + qsTr("(inactive)") :
                                                                               qsTr("Start / Restart") + "<br>" + qsTr("(running)") //qsTr("Start / Restart")
                        width: parent.availableWidth
                        visible: mainWindow.bServerMode ? true : false

                        font.pointSize: 12 + mainWindow.fontPadding
                        color: mainWindow.bDark ? columnSambaServiceMenu.bSambaService === false ? "white" : "steelblue" : columnSambaServiceMenu.bSambaService === false ? "black" : "blue"

                        textFormat: Label.RichText
                        wrapMode: Label.WordWrap

                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.AlignVCenter
                        Layout.fillWidth: true

                        Rectangle {
                            y: parent.height
                            width: columnMenu.width
                            height: 3

                            color: mainWindow.bDark ? "steelblue" : "blue"

                            radius: 10
                            opacity: 0.8
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                let ret = SambaService.setSystemdService("smb", "StartUnit")
                                if (ret === 0) {
                                }

                                SambaService.checkSystemdServiceAsync("smb")
                            }
                        }

                        Component.onCompleted: {
                            if (mainWindow.bFirstSystemd) {
                                SambaService.checkSystemdServiceAsync("smb")
                            }
                        }
                    }

                    Label {
                        id:             labelStopSamba
                        text:           qsTr("Stop")
                        width:          parent.availableWidth
                        color:          columnSambaServiceMenu.bSambaService === false ? "grey" : mainWindow.bDark ? "crimson" : "#a00000"
                        font.pointSize: 12 + mainWindow.fontPadding
                        visible:        mainWindow.bServerMode ? true : false
                        wrapMode:       Label.WordWrap

                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment:   Label.AlignVCenter
                        Layout.fillWidth:    true

                        Rectangle {
                            y:       parent.height
                            width:   columnMenu.width
                            height:  3

                            color:   columnSambaServiceMenu.bSambaService === false ? "grey" : mainWindow.bDark ? "crimson" : "#a00000"

                            radius:  10
                            opacity: 0.8
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  columnSambaServiceMenu.bSambaService ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled:      columnSambaServiceMenu.bSambaService ? true : false

                            onClicked: {
                                let ret = SambaService.setSystemdService("smb", "StopUnit")
                                if (ret === 0) {
                                }

                                SambaService.checkSystemdServiceAsync("smb")
                            }
                        }
                    }

                    Label {
                        id: labelRemoteRestartSamba
                        text: qsTr("Start / Restart") + "<br>" + qsTr("(Unknown Status)")
                        width: parent.availableWidth
                        visible: mainWindow.bServerMode ? false : true
                        enabled: false

                        font.pointSize: 12 + mainWindow.fontPadding

                        wrapMode: Label.WordWrap

                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.AlignVCenter
                        Layout.fillWidth: true

                        Rectangle {
                            y: parent.height
                            width: columnMenu.width
                            height: 3

                            color: parent.enabled ? mainWindow.bDark ? "steelblue" : "blue" : parent.color

                            radius: 10
                            opacity: 0.8
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: parent.enabled ? true : false

                            onClicked: {
                                // Client Mode.
                                //mainWindow.fnExecSSHServiceRemote(true)
                            }
                        }
                    }

                    Label {
                        id: labelRemoteStopSamba
                        text: qsTr("Stop") + "<br>" + qsTr("(Unknown Status)")
                        width: parent.availableWidth
                        visible: mainWindow.bServerMode ? false : true
                        enabled: false

                        font.pointSize: 12 + mainWindow.fontPadding

                        wrapMode: Label.WordWrap

                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.AlignVCenter
                        Layout.fillWidth: true

                        Rectangle {
                            y: parent.height
                            width: columnMenu.width
                            height: 3

                            color: parent.color

                            radius: 10
                            opacity: 0.8
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: parent.enabled ? true : false

                            onClicked: {
                                // Client Mode.
                                //mainWindow.fnExecSSHServiceRemote(false)
                            }
                        }
                    }

                    Label {
                        id: labelRemoteStatusSamba
                        text: qsTr("Get Status")
                        width: parent.availableWidth
                        visible: mainWindow.bServerMode ? false : true

                        font.pointSize: 12 + mainWindow.fontPadding

                        wrapMode: Label.WordWrap

                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.AlignVCenter
                        Layout.fillWidth: true

                        Rectangle {
                            y: parent.height
                            width: columnMenu.width
                            height: 3

                            color: mainWindow.bDark ? "steelblue" : "blue"

                            radius: 10
                            opacity: 0.8
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                // Client Mode.
                                let iRet = SambaService.executeRemoteSSHService(mainWindow.width, mainWindow.height, mainWindow.bDark, mainWindow.fontPadding,
                                                                              false, true)

                                if (iRet === 0) {
                                }
                                else {
                                    // Error.
                                    let errMsg = SambaService.getErrorMessage()
                                    let componentDialog = Qt.createComponent("qrc:///ExtendQML/ErrorDialog.qml");
                                    if (componentDialog.status === Component.Ready) {
                                        let errorDialog = componentDialog.createObject(mainWindow,
                                                                                       {mainWidth: mainWindow.width, mainHeight: mainWindow.height,
                                                                                        bDark: mainWindow.bDark,
                                                                                        messageTitle: qsTr("Exec Error"),
                                                                                        messageText: qsTr("Failed to get status for smb(d).service.") + "<br>" + errMsg});
                                        errorDialog.show();
                                    }
                                }
                            }
                        }
                    }

                    Label {
                        id: labelNMBService
                        text: {
                            if (mainWindow.bServerMode) {
                                qsTr("NMB Service :") + "<br>" + "<span style=\"color: #10980a;\"><b>" + qsTr("(this computer)") + "</b></span>"
                            }
                            else {
                                qsTr("NMB Service :") + "<br>" + "<span style=\"color: #10980a;\"><b>" + qsTr("(Remote server)") + "</b></span>"
                            }
                        }
                        width: parent.availableWidth
                        font.pointSize: 12 + mainWindow.fontPadding

                        textFormat: Label.RichText
                        wrapMode: Label.WordWrap

                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.AlignVCenter
                        Layout.fillWidth: true
                    }

                    Label {
                        id: labelStartNMB
                        text: columnSambaServiceMenu.bNMBService === false ? qsTr("Start / Restart") + "<br>" + qsTr("(inactive)") :
                                                                             qsTr("Start / Restart") + "<br>" + qsTr("(running)")
                        width: parent.availableWidth
                        visible: mainWindow.bServerMode ? true : false

                        font.pointSize: 12 + mainWindow.fontPadding
                        color: mainWindow.bDark ? columnSambaServiceMenu.bNMBService === false ? "white" : "steelblue" : columnSambaServiceMenu.bNMBService === false ? "black" : "blue"

                        textFormat: Label.RichText
                        wrapMode: Label.WordWrap

                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.AlignVCenter
                        Layout.fillWidth: true

                        Rectangle {
                            y: parent.height
                            width: columnMenu.width
                            height: 3

                            color: mainWindow.bDark ? "steelblue" : "blue"

                            radius: 10
                            opacity: 0.8
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                let ret = SambaService.setSystemdService("nmb", "StartUnit")
                                if (ret === 0) {
                                    //labelStartNMB.text = qsTr("Start / Restart") + "<br>" + qsTr("(running)")
                                    //columnSambaServiceMenu.bNMBService = true
                                }

                                SambaService.checkSystemdServiceAsync("nmb")
                            }
                        }

                        Component.onCompleted: {
                            if (mainWindow.bFirstSystemd) {
                                SambaService.checkSystemdServiceAsync("nmb")
                            }
                        }
                    }

                    Label {
                        id: labelStopNMB
                        text: qsTr("Stop")
                        width: parent.availableWidth
                        visible: mainWindow.bServerMode ? true : false

                        font.pointSize: 12 + mainWindow.fontPadding
                        color: columnSambaServiceMenu.bNMBService === false ? "grey" : mainWindow.bDark ? "crimson" : "#a00000"

                        wrapMode: Label.WordWrap

                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.AlignVCenter
                        Layout.fillWidth: true

                        Rectangle {
                            y: parent.height
                            width: columnMenu.width
                            height: 3

                            color: columnSambaServiceMenu.bNMBService === false ? "grey" : mainWindow.bDark ? "crimson" : "#a00000"

                            radius: 10
                            opacity: 0.8
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: columnSambaServiceMenu.bNMBService ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: columnSambaServiceMenu.bNMBService ? true : false

                            onClicked: {
                                let ret = SambaService.setSystemdService("nmb", "StopUnit")
                                if (ret === 0) {
                                    // labelStartNMB.text = qsTr("Start / Restart") + "<br>" + qsTr("(inactive)")
                                    // labelStartNMB.update()
                                    // columnSambaServiceMenu.bNMBService = false
                                }

                                SambaService.checkSystemdServiceAsync("nmb")
                            }
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                RoundButton {
                    id:     btnHome
                    text:   ""
                    width:  80
                    height: 80
                    icon {
                        source: pressed ? "qrc:/Image/HomeButtonPressed.png" : "qrc:/Image/HomeButton.png"
                        width:  width
                        height: height
                        color:  "transparent"
                    }

                    padding:             0
                    Layout.topMargin:    20
                    Layout.bottomMargin: 20
                    Layout.alignment:    Qt.AlignHCenter

                    background: Rectangle {
                        color: "transparent"
                    }

                    onClicked: {
                        aryFowardIndexes = []
                        aryPrevIndexes   = []

                        stackLayout.currentIndex = 0
                    }

                    ToolTip {
                        id: btnHomeToolTip
                        text: qsTr("Return to the welcome screen")
                        visible: btnHome.hovered
                        delay: 500
                        timeout: 5000
                    }
                }
            }
        }

        StackLayout {
            id: stackLayout
            width: parent.width - columnMenu.width
            height: parent.height

            currentIndex: 0

            onCurrentIndexChanged: {
                animationLayout.start()
            }

            ParallelAnimation {
                id: animationLayout

                NumberAnimation {
                    target: stackLayout
                    property: "x"
                    from: (stackLayout.width) / 2 //columnMenu.width + 500
                    to: columnMenu.width
                    duration: 250
                    easing.type: Easing.OutQuad
                }

                NumberAnimation {
                    target: stackLayout
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }

            WelcomeSambaConfig {
                id: welcomeView
                parentName:  mainWindow
                fontPadding: mainWindow.fontPadding
            }

            SambaConfig {
                parentName:      mainWindow
                fontPadding:     mainWindow.fontPadding
                bDark:           mainWindow.bDark
                bServerMode:     mainWindow.bServerMode
            }

            SambaTest {
                parentName:      mainWindow
                fontPadding:     mainWindow.fontPadding
                bDark:           mainWindow.bDark
                bServerMode:     mainWindow.bServerMode
            }

            SambaUserSettings {
                parentName:      mainWindow
                fontPadding:     mainWindow.fontPadding
                bDark:           mainWindow.bDark
                bServerMode:     mainWindow.bServerMode
            }

            Firewalld {
                parentName:      mainWindow
                fontCheck:       mainWindow.fontCheck
                fontPadding:     mainWindow.fontPadding
                bDark:           mainWindow.bDark
                bServerMode:     mainWindow.bServerMode
            }

            ModeSettings {
                id: modeSettings
                parentName:       mainWindow
                bOldTheme:        mainWindow.bDark
                bOldServerMode:   mainWindow.bServerMode
                bOldFirstSystemd: mainWindow.bFirstSystemd
                oldFontCheck:     mainWindow.fontCheck
            }

            AboutQt {
                id: aboutQtView
                parentName:  mainWindow
                fontPadding: mainWindow.fontPadding
            }
        }
    }
}
