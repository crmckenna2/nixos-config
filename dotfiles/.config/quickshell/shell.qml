pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
    id: root

    property color backgroundColor: "#000000"
    property color textColor: "#ffffff"
    property color highlightColor: "#808080"
    property real alpha: 1.0 
    property int barHeight: 24
    property string fontFamily: "cascadia-code"
    property string iconFontFamily: "Cascadia Code NF"
    property string metricFontFamily: iconFontFamily
    property int iconFontSize: 24
    property int workspaceWidth: 24
    property int metricsRightMargin: 8
    property int metricSpacing: 4
    property int iconValueSpacing: 2
    property int metricIconWidth: 14
    property int metricValueWidth: 28 
    property int metricUpdateInterval: 2000
    property string clockFormat: "HH:mm"
    property string cpuIcon: "\uf2db"
    property string ramIcon: "\u{f035b}"
    property string gpuIcon: "\uf108"
    property string vramIcon: "\uf0a0"
    property string batteryIcon: "\uf240"
    property var metricOrder: ["cpu", "ram", "nvidiaGpu", "nvidiaVram", "battery"]
    property var workspaceKeys: ({ 1: "U", 2: "I", 3: "O", 4: "P", 5: "[", 6: "]" })

    SystemClock { id: clock; precision: SystemClock.Minutes }

    readonly property var defaultMetrics: ({ cpu: true, ram: true, nvidiaGpu: false, nvidiaVram: false, battery: true })
    property var metrics: Object.assign({}, defaultMetrics)

    FileView {
        path: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/quickshell/metrics.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const config = JSON.parse(text())
                if (!config || typeof config !== "object" || Array.isArray(config))
                    throw new Error("Expected a JSON object")
                const next = Object.assign({}, root.defaultMetrics)
                for (const key of Object.keys(next)) {
                    if (key in config) {
                        if (typeof config[key] !== "boolean")
                            throw new Error(key + " must be a boolean")
                        next[key] = config[key]
                    }
                }
                if (next.cpu !== root.metrics.cpu) {
                    root.previousTotal = 0
                    root.previousIdle = 0
                    root.cpuText = root.unavailableText
                }
                root.metrics = next
            } catch (error) {
                console.warn("Invalid metrics configuration:", error)
            }
        }
    }

    readonly property int percentScale: 100
    readonly property string unavailableText: "--"
    property string cpuText: unavailableText
    property string ramText: unavailableText
    property string batteryText: unavailableText
    property string gpuText: unavailableText
    property string vramText: unavailableText
    property real previousTotal: 0
    property real previousIdle: 0

    FileView {
        id: cpuFile
        path: root.metrics.cpu ? "/proc/stat" : ""
        onLoaded: {
            const fields = text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number)
            const accountingFieldCount = 8
            const idleIndex = 3
            const ioWaitIndex = 4
            if (fields.length < accountingFieldCount || fields.some(isNaN)) { root.cpuText = root.unavailableText; return }
            const total = fields.slice(0, accountingFieldCount).reduce((a, b) => a + b, 0)
            const idle = fields[idleIndex] + fields[ioWaitIndex]
            const delta = total - root.previousTotal
            if (root.previousTotal && delta > 0)
                root.cpuText = Math.round(Math.max(0, Math.min(root.percentScale, root.percentScale * (1 - (idle - root.previousIdle) / delta)))) + "%"
            root.previousTotal = total
            root.previousIdle = idle
        }
        onLoadFailed: root.cpuText = root.unavailableText
    }

    FileView {
        id: ramFile
        path: root.metrics.ram ? "/proc/meminfo" : ""
        onLoaded: {
            const total = text().match(/^MemTotal:\s+(\d+)/m)
            const available = text().match(/^MemAvailable:\s+(\d+)/m)
            root.ramText = total && available && Number(total[1]) > 0
                ? Math.round(root.percentScale * (1 - Number(available[1]) / Number(total[1]))) + "%" : root.unavailableText
        }
        onLoadFailed: root.ramText = root.unavailableText
    }

    Process {
        id: batteryProcess
        command: ["sh", "-c", "for d in /sys/class/power_supply/*; do if [ \"$(cat \"$d/type\" 2>/dev/null)\" = Battery ] && [ -r \"$d/capacity\" ]; then cat \"$d/capacity\"; exit; fi; done; exit 1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const value = text.trim()
                root.batteryText = /^\d+$/.test(value) && Number(value) <= root.percentScale ? value + "%" : root.unavailableText
            }
        }
        onExited: function(exitCode, exitStatus) { if (exitCode !== 0) root.batteryText = root.unavailableText }
    }

    Process {
        id: gpuProcess
        command: ["nvidia-smi", "--query-gpu=utilization.gpu,memory.used,memory.total", "--format=csv,noheader,nounits"]
        stdout: StdioCollector {
            onStreamFinished: {
                const [utilization, memoryUsed, memoryTotal] = text.trim().split("\n")[0].split(",").map(v => v.trim())
                root.gpuText = /^\d+$/.test(utilization || "") ? utilization + "%" : root.unavailableText
                root.vramText = /^\d+$/.test(memoryUsed || "") && /^\d+$/.test(memoryTotal || "") && Number(memoryTotal) > 0
                    ? Math.round(root.percentScale * Number(memoryUsed) / Number(memoryTotal)) + "%" : root.unavailableText
            }
        }
        onExited: function(exitCode, exitStatus) {
            if (exitCode !== 0) { root.gpuText = root.unavailableText; root.vramText = root.unavailableText }
        }
    }

    Timer {
        interval: root.metricUpdateInterval; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            if (root.metrics.cpu) cpuFile.reload()
            if (root.metrics.ram) ramFile.reload()
            if (root.metrics.battery && !batteryProcess.running) batteryProcess.running = true
            if ((root.metrics.nvidiaGpu || root.metrics.nvidiaVram) && !gpuProcess.running) gpuProcess.running = true
        }
    }

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
                    width: root.workspaceWidth
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
            text: Qt.formatDateTime(clock.date, root.clockFormat)
            color: root.textColor
            font.family: root.fontFamily
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: root.metricsRightMargin
            anchors.verticalCenter: parent.verticalCenter
            spacing: root.metricSpacing

            Repeater {
                model: {
                    const entries = {
                        cpu: { enabled: root.metrics.cpu, icon: root.cpuIcon, value: root.cpuText },
                        ram: { enabled: root.metrics.ram, icon: root.ramIcon, value: root.ramText },
                        nvidiaGpu: { enabled: root.metrics.nvidiaGpu, icon: root.gpuIcon, value: root.gpuText },
                        nvidiaVram: { enabled: root.metrics.nvidiaVram, icon: root.vramIcon, value: root.vramText },
                        battery: { enabled: root.metrics.battery, icon: root.batteryIcon, value: root.batteryText }
                    }
                    return root.metricOrder.map(key => entries[key]).filter(entry => entry !== undefined)
                }
                Row {
                    id: metric
                    required property var modelData
                    visible: modelData.enabled
                    spacing: root.iconValueSpacing
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: metric.modelData.icon
                        width: root.metricIconWidth
                        horizontalAlignment: Text.AlignHCenter
                        color: root.textColor
                        font.family: root.iconFontFamily
                        font.pixelSize: root.iconFontSize
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: metric.modelData.value
                        width: root.metricValueWidth
                        color: root.textColor
                        font.family: root.metricFontFamily
                    }
                }
            }
        }
    }
}
