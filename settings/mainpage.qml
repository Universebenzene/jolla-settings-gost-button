import QtQuick 2.1
import Sailfish.Silica 1.0
import com.jolla.settings 1.0
import org.nemomobile.dbus 2.0
import org.nemomobile.configuration 1.0
import Mer.Cutes 1.1

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
                        systemdServiceIface.call(activeState ? "Stop" : "Start", ["replace"])
                        
                        systemdServiceIface.updateProperties()
                        enableSwitch.busy = true
                    }
                    onPressAndHold: enableItem.showMenu({ settingEntryPath: entryPath, isFavorite: favorites.isFavorite(entryPath) })
                }
            }

            
        }
    }
}
