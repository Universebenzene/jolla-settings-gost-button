import QtQuick 2.1
import Sailfish.Silica 1.0
import org.nemomobile.dbus 2.0
import org.nemomobile.configuration 1.0
import Mer.Cutes 1.1


Switch {
    id: enableSwitch

    property string entryPath
    property bool activeState
    icon.source: "image://theme/icon-settings-gost"
    checked: activeState
    automaticCheck: false

    onActiveStateChanged: {
        enableSwitch.busy = false
    }

    CutesActor {
        id: tools
        source: "./tools.js"
    }

    Timer {
        id: checkState
        interval: 3000
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
            // console.log("ActiveState:", activeProperty)
            if (activeProperty === "active") {
                checkState.stop()
                activeState = true
            }
            else if (activeProperty === "inactive") {
                checkState.stop()
                activeState = false
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

    
    onClicked: {
        if (enableSwitch.busy) {
            return
        }
        enableSwitch.busy = true
        systemdServiceIface.call(enableSwitch.activeState ? "Stop" : "Start", ["replace"])
        systemdServiceIface.updateProperties()
        checkState.start()
    }

    Behavior on opacity { FadeAnimation { } }
}