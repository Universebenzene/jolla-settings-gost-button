import QtQuick 2.1
import Sailfish.Silica 1.0
import com.jolla.settings 1.0
import org.nemomobile.dbus 2.0
import org.nemomobile.configuration 1.0
import Mer.Cutes 1.1
import io.thp.pyotherside 1.3

Page {
    id: page

    property bool activeState
    onActiveStateChanged: {
        enableSwitch.busy = false
    }

    CutesActor {
        id: tools
        source: "./tools.js"
    }

    ConfigurationGroup {
        id: proxyConf
        path: "/apps/gost-button"
    }

    Timer {
        id: checkState
        interval: 1000
        repeat: true
        onTriggered: {
            systemdServiceIface.updateProperties()
        }
    }

    ListModel{
        id: encryptionModel
        ListElement{
            name: "aes-256-cfb"
        }
        ListElement{
            name: "chacha20"
        }
        ListElement{
            name: "aes-192-cfb"
        }
        ListElement{
            name: "aes-128-cfb"
        }
        ListElement{
            name: "rc4-md5"
        }
        ListElement{
            name: "salsa20"
        }
    }

    DBusInterface {
        id: systemdServiceIface
        bus: DBus.SessionBus
        service: 'org.freedesktop.systemd1'
        path: '/org/freedesktop/systemd1/unit/gost_2eservice'
        iface: 'org.freedesktop.systemd1.Unit'

        signalsEnabled: true
        function updateProperties() {
            var activeProperty = systemdServiceIface.getProperty("ActiveState")
            console.log("ActiveState:", activeProperty)
            if (activeProperty === "active") {
                activeState = true
                checkState.stop()
                enableSwitch.busy = false;
            }
            else if (activeProperty === "inactive") {
                activeState = false
                checkState.stop()
                enableSwitch.busy = false;
            }
            else {
                checkState.start()
            }
        }

        onPropertiesChanged: updateProperties()
        Component.onCompleted: updateProperties()
    }

    DBusInterface {
        bus: DBus.SessionBus
        service: 'org.freedesktop.systemd1'
        path: '/org/freedesktop/systemd1/unit/gost_2eservice'
        iface: 'org.freedesktop.DBus.Properties'

        signalsEnabled: true
        onPropertiesChanged: systemdServiceIface.updateProperties()
        Component.onCompleted: systemdServiceIface.updateProperties()
    }

    DBusInterface {
        bus: DBus.SessionBus
        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1"
        iface: "org.freedesktop.systemd1.Manager"
        signalsEnabled: true

        signal unitNew(string name)
        onUnitNew: {
            if (name == "gost.service") {
                systemdServiceIface.updateProperties()
            }
        }
    }

    Python{
        id: py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('./'))
            py.importModule('main', function () {

            })
        }

        function updateConfig(server, port, passwd, encryption){
            call_sync('main.update',[server, port, passwd, encryption])
        }

        function getConfig(){
            call('main.getSS',[],function(result){
                if(result){
                    // ss://aes-256-cfb:password@192.168.2.1:2379
                    var arr = result.replace("//","").split(":");
                    var encryption = arr[1]
                    var port = arr[3]
                    var passwd = arr[2].split("@")[0];
                    var server = arr[2].split("@")[1];
                    serverField.text = server;
                    portField.text = port;
                    passField.text = passwd;
                    comboField.value = encryption;
                }
            })
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width

            PageHeader {
                title: qsTr("Gost")
            }

            ListItem {
                id: enableItem

                contentHeight: enableSwitch.height
                _backgroundColor: "transparent"

                highlighted: enableSwitch.down || menuOpen

                showMenuOnPressAndHold: false
                menu: Component { FavoriteMenu { } }

                TextSwitch {
                    id: enableSwitch

                    property string entryPath: "system_settings/connectivity/gost/gost_active"

                    automaticCheck: false
                    checked: activeState
                    text: "Gost service state"
                    //description: qsTrId("settings_flight-la-flight-mode-description")

                    onClicked: {
                        if (enableSwitch.busy) {
                            return
                        }
                        if (!activeState &&
                                serverField.text &&
                                portField.text &&
                                passField.text &&
                                comboField.value){
//                            console.log(serverField.text +","+ portField.text  +","+ passField.text  +","+ comboField.value)
                            py.updateConfig(serverField.text, portField.text , passField.text , comboField.value);
                        }
                        enableSwitch.busy = true
                        systemdServiceIface.call(activeState ? "Stop" : "Start", ["replace"])
                        systemdServiceIface.updateProperties()

                    }
                    onPressAndHold: enableItem.showMenu({ settingEntryPath: entryPath, isFavorite: favorites.isFavorite(entryPath) })
                }
            }



            TextField{
                id: serverField
                enabled: !enableSwitch.checked
                placeholderText: "Enter you server"
                label: "Server"
                width: parent.width
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: portField.focus = true
            }

            TextField{
                id: portField
                enabled: !enableSwitch.checked
                width: parent.width
                placeholderText: "Enter you server port"
                label: "Port"
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: passField.focus = true
            }


            PasswordField{
                id: passField
                enabled: !enableSwitch.checked
                width: parent.width
                placeholderText: "Enter you password"
                label: "Password"
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: comboField.focus = true
            }

            ComboBox{
                id: comboField
                enabled: !enableSwitch.checked
                width: parent.width
                label: "Encryption"
                menu: ContextMenu {
                    Repeater {
                        model: encryptionModel
                        MenuItem {
                            text: name
                            onClicked:{
                                comboField.value = name;
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        py.getConfig();
    }

    Component.onDestruction: {
        py.updateConfig(serverField.text, portField.text , passField.text , comboField.value);
    }
}
