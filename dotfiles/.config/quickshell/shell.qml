pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    id: root

    property color backgroundColor: "#000000"
    property color textColor: "#ffffff"
    property color highlightColor: "#808080"
    property real alpha: 1.0 
    property int barHeight: 24
    property string fontFamily: "cascadia-code"
    property var workspaceKeys: ({ 1: "U", 2: "I", 3: "O", 4: "P", 5: "[", 6: "]" })

    SystemClock { id: clock; precision: SystemClock.Minutes }

    PanelWindow {
        anchors { top: true; left: true; right: true }
        implicitHeight: root.barHeight
        color: Qt.rgba(root.backgroundColor.r, root.backgroundColor.g,
                       root.backgroundColor.b, root.alpha)

        Row {
            height: parent.height

            Repeater {
                model: Object.keys(root.workspaceKeys)

                Rectangle {
                    required property string modelData
                    width: Math.max(root.barHeight, label.implicitWidth + 20)
                    height: root.barHeight
                    color: Hyprland.focusedWorkspace?.id === Number(modelData)
                           ? root.highlightColor : "transparent"

                    Text {
                        id: label
                        anchors.centerIn: parent
                        text: root.workspaceKeys[parent.modelData]
                        color: root.textColor
                        font.family: root.fontFamily
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: root.textColor
            font.family: root.fontFamily
        }
    }
}
