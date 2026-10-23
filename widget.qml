pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.modules.components
import qs.modules.theme
import qs.modules.globals
import qs.config

PanelWindow {
    id: root

    property string selectedBrowser: "default"
    readonly property var browsers: [
        { id: "default",  label: "Default" },
        { id: "firefox",  label: "Firefox" },
        { id: "brave",    label: "Brave" },
        { id: "chromium", label: "Chromium" }
    ]
    readonly property color accentColor: Styling.colors?.primary ?? "#ff5a5f"
    readonly property color panelColor: Styling.colors?.surfaceContainer ?? "#1d1f24"
    readonly property color panelOutline: Styling.colors?.outline ?? "#4d5363"
    readonly property color mutedText: Styling.colors?.onSurfaceVariant ?? "#b9c0d0"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "ambxst:youtube-search"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusionMode: ExclusionMode.Ignore

    color: "transparent"
    visible: GlobalStates.youtubeSearchVisible

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    onVisibleChanged: {
        if (visible) {
            Qt.callLater(() => {
                searchInput.forceActiveFocus()
                searchInput.focusInput()
            })
        }
    }

    function openSearch(query) {
        const url = "https://www.youtube.com/results?search_query=" + encodeURIComponent(query)
        if (selectedBrowser === "default")
            Qt.openUrlExternally(url)
        else
            Quickshell.execDetached([selectedBrowser, url])
    }

    MouseArea {
        anchors.fill: parent
        onClicked: GlobalStates.youtubeSearchVisible = false
    }

    StyledRect {
        id: popupRect
        variant: "popup"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 92
        implicitWidth: 620
        implicitHeight: 150
        radius: Styling.radius(18)
        enableShadow: true

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.08)
        }

        Rectangle {
            width: parent.width
            height: 42
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            radius: parent.radius
            color: Qt.rgba(255, 255, 255, 0.03)
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Browser"
                    color: mutedText
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    Layout.alignment: Qt.AlignVCenter
                }

                Repeater {
                    model: root.browsers

                    delegate: Rectangle {
                        required property var modelData
                        implicitWidth: chipText.width + 22
                        implicitHeight: 28
                        radius: 9
                        color: root.selectedBrowser === modelData.id
                               ? (root.accentColor)
                               : Qt.rgba(1, 1, 1, 0.04)
                        border.width: root.selectedBrowser === modelData.id ? 0 : 1
                        border.color: root.selectedBrowser === modelData.id
                                      ? "transparent"
                                      : root.panelOutline

                        Text {
                            id: chipText
                            anchors.centerIn: parent
                            text: modelData.label
                            color: root.selectedBrowser === modelData.id ? "#ffffff" : "#e8ebf2"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.selectedBrowser = modelData.id
                                searchInput.forceActiveFocus()
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 62
                radius: 16
                color: Qt.rgba(0, 0, 0, 0.16)
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.06)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 10
                        color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.15)
                        border.width: 1
                        border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.35)

                        Text {
                            anchors.centerIn: parent
                            text: "▶"
                            color: root.accentColor
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }

                    SearchInput {
                        id: searchInput
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        placeholderText: "Search YouTube..."
                        clearOnEscape: true

                        onAccepted: {
                            const query = text.trim()
                            if (query.length > 0)
                                root.openSearch(query)
                            clear()
                            GlobalStates.youtubeSearchVisible = false
                        }

                        onEscapePressed: {
                            GlobalStates.youtubeSearchVisible = false
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 60000
        running: root.visible
        onTriggered: GlobalStates.youtubeSearchVisible = false
    }

    IpcHandler {
        target: "youtubeSearch"
        function toggle(): void {
            GlobalStates.youtubeSearchVisible = !GlobalStates.youtubeSearchVisible
        }
        function open(): void {
            GlobalStates.youtubeSearchVisible = true
        }
        function close(): void {
            GlobalStates.youtubeSearchVisible = false
        }
    }
}
