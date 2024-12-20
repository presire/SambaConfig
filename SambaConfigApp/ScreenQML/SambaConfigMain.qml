import QtCore
import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Universal
import CustomQML 1.0


ApplicationWindow {
    id: mainWindow
    objectName: "MainWindow"

    x: ApplicationState.getMainWindowX()
    y: ApplicationState.getMainWindowY()
    width: ApplicationState.getMainWindowWidth()
    minimumWidth: 1280
    height: ApplicationState.getMainWindowHeight()
    minimumHeight: 800

    visible: true
    visibility: ApplicationState.getMainWindowMaximized() ?  Window.Maximized : Window.Windowed
    title: qsTr("SambaConfig for PC")

    property int  fontCheck:        1
    property int  fontPadding:      mainWindow.fontCheck === 0 ? -3 : mainWindow.fontCheck === 1 ? 0 : 3
    property bool bDark:            false
    property bool bServerMode:      true
    property var  aryPrevIndexes:   []
    property var  aryFowardIndexes: []
    property int  nextIndex:        0
    property bool allowClose:       false


    // テーマの動的適用
    Material.theme: mainWindow.bDark ? Material.Dark : Material.Light
    Universal.theme: mainWindow.bDark ? Universal.Dark : Universal.Light

    // Quit software.
    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: {
            //saveApplicationState()
            mainWindow.close()
        }
    }

    Component.onCompleted: {
        // If forgot to turn off the temporary overwrite flag for a theme, remove the flag.
        ApplicationState.setColorModeOverWrite(false)

        // Load font size settings.
        //mainWindow.fontCheck    = ApplicationState.getFontSize()

        // Set [Server mode] or [Client mode]
        //mainWindow.bServerMode  = ApplicationState.getServerMode()

        // Load the welcome screen.
        stackLayout.currentIndex = 0
    }

    // Open quit dialog.
    // ウィンドウを閉じる前の処理
    onClosing: function(closeEvent) {
        if (!allowClose) {
            closeEvent.accepted = false

            var component = Qt.createComponent("qrc:/qt/customqml/CustomQML/CustomQML/QuitDialog.qml");
            if (component.status === Component.Ready) {
                var quitDialog = component.createObject(mainWindow, {mainWidth: Math.round(Math.min(mainWindow.width, mainWindow.height) / 10 * 9),
                                                        bDark: mainWindow.bDark, applicationState: ApplicationState});
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
        }

        ApplicationState.setMainWindowState(x, y, width, height, bMaximized)

        // Save color mode
        if (ApplicationState.getColorMode() === false && ApplicationState.getColorModeOverWrite() === 1) {
            ApplicationState.setColorMode(true)
        }
        else if (ApplicationState.getColorMode() === true && ApplicationState.getColorModeOverWrite() === 1) {
            ApplicationState.setColorMode(false)
        }

        ApplicationState.setColorModeOverWrite(false)
    }

    Row {
        //x: 10
        //y: 0
        //width: mainWindow.width - 10
        //height: mainWindow.height
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        spacing: 0

        ColumnLayout {
            id: columnMenu
            width: Math.round(mainWindow.width / 7) < 250 ? 250 : Math.round(mainWindow.width / 7) < 300 ? Math.round(mainWindow.width / 7) : 300

            Layout.maximumWidth: 300
            //Layout.fillWidth: true
            //Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

            spacing: 30

            RoundButton {
                id: btnSSHServer
                text: qsTr("Samba")
                implicitWidth: parent.width

                font.pointSize: 15 + mainWindow.fontPadding
                flat: false

                Layout.fillWidth: true
                Layout.topMargin: 60

                contentItem: Label {
                    text: btnSSHServer.text
                    font: btnSSHServer.font
                    opacity: enabled ? 1.0 : 0.3
                    color: btnSSHServer.pressed ? "#6060ff" : ApplicationState.getColorMode() ? "#ffffff" : "#000000"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                background: Rectangle {
                    opacity: enabled ? 1 : 0.3
                    color: "transparent"
                    border.color: btnSSHServer.pressed ? "#6060ff" : ApplicationState.getColorMode() ? "#ffffff" : "#000000"
                    border.width: btnSSHServer.pressed ? 5 : 4
                    radius: 50
                }

                Connections {
                    target: btnSSHServer
                    function onClicked() {
                        if (stackLayout.currentIndex !== 1) {
                            mainWindow.fnIndexChange(1)
                        }
                    }
                }
            }

            RoundButton {
                id: btnSSHTest
                text: qsTr("Samba Test")
                width: parent.width

                font.pointSize: 15 + mainWindow.fontPadding
                flat: false

                Layout.fillWidth: true

                contentItem: Label {
                    text: btnSSHTest.text
                    font: btnSSHTest.font
                    opacity: enabled ? 1.0 : 0.3
                    color: btnSSHTest.pressed ? "#6060ff" : ApplicationState.getColorMode() ? "#ffffff" : "#000000"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                background: Rectangle {
                    opacity: enabled ? 1 : 0.3
                    color: "transparent"
                    border.color: btnSSHTest.pressed ? "#6060ff" : ApplicationState.getColorMode() ? "#ffffff" : "#000000"
                    border.width: btnSSHTest.pressed ? 5 : 4
                    radius: 50
                }

                Connections {
                    target: btnSSHTest
                    function onClicked() {
                        if (stackLayout.currentIndex !== 2) {
                            mainWindow.fnIndexChange(2)
                        }
                    }
                }
            }

            RoundButton {
                id: btnSettings
                text: qsTr("Mode")
                width: parent.availableWidth

                font.pointSize: 15 + mainWindow.fontPadding
                flat: false

                Layout.fillWidth: true

                contentItem: Label {
                    text: btnSettings.text
                    font: btnSettings.font
                    opacity: enabled ? 1.0 : 0.3
                    color: btnSettings.pressed ? "#6060ff" : ApplicationState.getColorMode() ? "#ffffff" : "#000000"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                background: Rectangle {
                    opacity: enabled ? 1 : 0.3
                    color: "transparent"
                    border.color: btnSettings.pressed ? "#6060ff" : ApplicationState.getColorMode() ? "#ffffff" : "#000000"
                    border.width: btnSettings.pressed ? 5 : 4
                    radius: 50
                }

                Connections {
                    target: btnSettings
                    function onClicked() {
                        if (stackLayout.currentIndex !== 3) {
                            mainWindow.fnIndexChange(3)
                        }
                    }
                }
            }

            RoundButton {
                id: btnAboutQt
                text: qsTr("About Qt")
                width: parent.width

                font.pointSize: 15 + mainWindow.fontPadding
                flat: false

                Layout.fillWidth: true

                contentItem: Label {
                    text: btnAboutQt.text
                    font: btnAboutQt.font
                    opacity: enabled ? 1.0 : 0.3
                    color: btnAboutQt.pressed ? "#6060ff" : ApplicationState.getColorMode() ? "#ffffff" : "#000000"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                background: Rectangle {
                    opacity: enabled ? 1 : 0.3
                    color: "transparent"
                    border.color: btnAboutQt.pressed ? "#6060ff" : ApplicationState.getColorMode() ? "#ffffff" : "#000000"
                    border.width: btnAboutQt.pressed ? 5 : 4
                    radius: 50
                }

                Connections {
                    target: btnAboutQt
                    function onClicked() {
                        if (stackLayout.currentIndex !== 4) {
                            //mainWindow.fnIndexChange(4)
                            stackLayout.currentIndex = 1
                        }
                    }
                }
            }

            RoundButton {
                id: btnQuit
                text: qsTr("Quit")
                width: parent.width

                font.pointSize: 15 + mainWindow.fontPadding
                flat: false

                Layout.fillWidth: true

                contentItem: Label {
                    text: btnQuit.text
                    font: btnQuit.font
                    opacity: enabled ? 1.0 : 0.3
                    color: btnQuit.pressed ? "#6060ff" : ApplicationState.getColorMode() ? "#ffffff" : "#000000"

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight
                }

                background: Rectangle {
                    opacity: enabled ? 1 : 0.3
                    color: "transparent"
                    border.color: btnQuit.pressed ? "#6060ff" : ApplicationState.getColorMode() ? "#ffffff" : "#000000"
                    border.width: btnQuit.pressed ? 5 : 4
                    radius: 50
                }

                Connections {
                    target: btnQuit
                    function onClicked() {
                        mainWindow.close()
                    }
                }
            }

            ColumnLayout {
                id: columnSambaServiceMenu
                width: parent.width

                Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                Layout.topMargin: 50

                spacing: 20

                property bool bSambaService: false
                property bool bNMBService:   false

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
                    text: qsTr("Start / Restart")
                    width: parent.availableWidth
                    visible: mainWindow.bServerMode ? true : false

                    font.pointSize: 12 + mainWindow.fontPadding
                    color: ApplicationState.getColorMode() ? columnSambaServiceMenu.bSambaService === false ? "white" : "steelblue" : columnSambaServiceMenu.bSambaService === false ? "black" : "blue"

                    textFormat: Label.RichText
                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth: true

                    Rectangle {
                        y: parent.height
                        width: columnMenu.width
                        height: 3

                        color: ApplicationState.getColorMode() ? "steelblue" : "blue"

                        radius: 10
                        opacity: 0.8
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            let ret = SambaService.setSystemdService("smb", "StartUnit")
                            if (ret === 0) {
                                labelStartSamba.text = qsTr("Start / Restart") + "<br>" + qsTr("(running)")
                                columnSambaServiceMenu.bSambaService = true
                            }

                            SambaService.checkSystemdServiceAsync("smb")
                        }
                    }

                    Component.onCompleted: {
                        let bRet = SambaService.checkSystemdServiceAsync("smb")
                        if (!bRet) {
                            text = qsTr("Start / Restart") + "<br>" + qsTr("(inactive)")
                        }
                        else {
                            columnSambaServiceMenu.bSambaService = true
                            text = qsTr("Start / Restart") + "<br>" + qsTr("(running)")
                        }
                    }
                }

                Label {
                    id: labelStopSamba
                    text: qsTr("Stop")
                    width: parent.availableWidth
                    visible: mainWindow.bServerMode ? true : false

                    font.pointSize: 12 + mainWindow.fontPadding
                    color: columnSambaServiceMenu.bSambaService === false ? "grey" : ApplicationState.getColorMode() ? "crimson" : "#a00000"

                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth: true

                    Rectangle {
                        y: parent.height
                        width: columnMenu.width
                        height: 3

                        color: columnSambaServiceMenu.bSambaService === false ? "grey" : ApplicationState.getColorMode() ? "crimson" : "#a00000"

                        radius: 10
                        opacity: 0.8
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: columnSambaServiceMenu.bSambaService ? Qt.PointingHandCursor : Qt.ArrowCursor
                        enabled: columnSambaServiceMenu.bSambaService ? true : false

                        onClicked: {
                            let ret = SambaService.setSystemdService("smb", "StopUnit")
                            if (ret === 0) {
                                labelStartSamba.text = qsTr("Start / Restart") + "<br>" + qsTr("(inactive)")
                                labelStartSamba.update()
                                columnSambaServiceMenu.bSambaService = false
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

                        color: parent.enabled ? ApplicationState.getColorMode() ? "steelblue" : "blue" : parent.color

                        radius: 10
                        opacity: 0.8
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        enabled: parent.enabled ? true : false

                        onClicked: {
                            // Client Mode.
                            mainWindow.fnExecSSHServiceRemote(true)
                        }
                    }
                }

                Label {
                    id: labelRemoteStopSSH
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
                            mainWindow.fnExecSSHServiceRemote(false)
                        }
                    }
                }

                Label {
                    id: labelRemoteStatusSSH
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

                        color: ApplicationState.getColorMode() ? "steelblue" : "blue"

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
                                                                                    messageText: qsTr("Failed to get status for ssh(d).service.") + "<br>" + errMsg});
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
                    text: qsTr("Start / Restart")
                    width: parent.availableWidth
                    visible: mainWindow.bServerMode ? true : false

                    font.pointSize: 12 + mainWindow.fontPadding
                    color: ApplicationState.getColorMode() ? columnSambaServiceMenu.bNMBService === false ? "white" : "steelblue" : columnSambaServiceMenu.bNMBService === false ? "black" : "blue"

                    textFormat: Label.RichText
                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth: true

                    Rectangle {
                        y: parent.height
                        width: columnMenu.width
                        height: 3

                        color: ApplicationState.getColorMode() ? "steelblue" : "blue"

                        radius: 10
                        opacity: 0.8
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            let ret = SambaService.setSystemdService("nmb", "StartUnit")
                            if (ret === 0) {
                                labelStartNMB.text = qsTr("Start / Restart") + "<br>" + qsTr("(running)")
                                columnSambaServiceMenu.bNMBService = true
                            }
                        }
                    }

                    Component.onCompleted: {
                        let bRet = SambaService.checkSystemdServiceAsync("nmb")
                        if (!bRet) {
                            text = qsTr("Start / Restart") + "<br>" + qsTr("(inactive)")
                        }
                        else {
                            columnSambaServiceMenu.bNMBService = true
                            text = qsTr("Start / Restart") + "<br>" + qsTr("(running)")
                        }
                    }
                }

                Label {
                    id: labelStopNMB
                    text: qsTr("Stop")
                    width: parent.availableWidth
                    visible: mainWindow.bServerMode ? true : false

                    font.pointSize: 12 + mainWindow.fontPadding
                    color: columnSambaServiceMenu.bNMBService === false ? "grey" : ApplicationState.getColorMode() ? "crimson" : "#a00000"

                    wrapMode: Label.WordWrap

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    Layout.fillWidth: true

                    Rectangle {
                        y: parent.height
                        width: columnMenu.width
                        height: 3

                        color: columnSambaServiceMenu.bNMBService === false ? "grey" : ApplicationState.getColorMode() ? "crimson" : "#a00000"

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
                                labelStartNMB.text = qsTr("Start / Restart") + "<br>" + qsTr("(inactive)")
                                labelStartNMB.update()
                                columnSambaServiceMenu.bNMBService = false
                            }
                        }
                    }
                }
            }

            RoundButton {
                id: btnHome
                text: ""
                width: 80
                height: 80

                icon.source: pressed ? "qrc:///Image/HomeButtonPressed.png" : "qrc:///Image/HomeButton.png"
                icon.width: width
                icon.height: height
                icon.color: "transparent"

                padding: 0
                Layout.topMargin: Math.max(0, mainWindow.height - columnSambaServiceMenu.y - columnSambaServiceMenu.height -
                                               btnHome.height - columnMenu.spacing - 30)
                Layout.alignment: Qt.AlignHCenter

                background: Rectangle {
                    color: "transparent"
                }

                onClicked: {
                    aryFowardIndexes = []
                    aryPrevIndexes   = []

                    stackLayout.currentIndex = 0
                }
            }
        }

        StackLayout {
            id: stackLayout
            width: parent.width - columnMenu.width
            height: parent.height
//            anchors.fill: parent
//            anchors.leftMargin: columnMenu.width

            currentIndex: 0

            onCurrentIndexChanged: {
                animationLayout.start()
            }

            ParallelAnimation {
                id: animationLayout

                NumberAnimation {
                    target: stackLayout
                    properties: "x"
                    from: stackLayout.x + 500//(stackLayout.width) / 5
                    to: columnMenu.width//stackLayout.x
                    duration: 150
                    easing.type: Easing.OutQuad
                }

//                NumberAnimation {
//                    target: stackLayout
//                    properties: "x"
//                    from: stackLayout.width
//                    to: 0
//                    duration: 150
//                    easing.type: Easing.OutQuad
//                }

                NumberAnimation {
                    target: stackLayout
                    properties: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            WelcomeSambaConfig {
                id: welcomeView
                parentName:  mainWindow
                applicationState: ApplicationState
                fontPadding: mainWindow.fontPadding
            }

            // SSHServer {
            //     parentName:      mainWindow
            //     applicationState:     ApplicationState
            //     sshServerConfig: sshServerConfig
            //     fontPadding:     mainWindow.fontPadding
            //     bDark:           mainWindow.bDark
            //     bServerMode:     mainWindow.bServerMode
            // }

            // SSHTest {
            //     parentName:      mainWindow
            //     applicationState:     ApplicationState
            //     sshServerConfig: sshServerConfig
            //     fontPadding:     mainWindow.fontPadding
            //     bDark:           mainWindow.bDark
            //     bServerMode:     mainWindow.bServerMode
            // }

            // ModeSettings {
            //     id: modeSettings
            //     parentName:   mainWindow
            //     applicationState:  ApplicationState
            //     sshService:   sshService
            //     oldFontCheck: mainWindow.fontCheck
            // }

            AboutQt {
                id: aboutQtView
                parentName:  mainWindow
                applicationState: ApplicationState
                fontPadding: mainWindow.fontPadding
            }
        }
    }
}
