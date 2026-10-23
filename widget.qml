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
        anchors.topMargin: 100
        implicitWidth: 560
        implicitHeight: 110
        radius: Styling.radius(14)
        enableShadow: true

        // popup ඇතුළේ click → close නොවෙන්න
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            // Browser chips
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "Browser:"
                    color: Styling.colors?.onSurface ?? "#ccc"
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignVCenter
                }

                Repeater {
                    model: root.browsers

                    delegate: Rectangle {
                        required property var modelData
                        implicitWidth: chipText.width + 16
                        implicitHeight: 26
                        radius: 8
                        color: root.selectedBrowser === modelData.id
                               ? (Styling.colors?.primary ?? "#ff6b6b")
                               : (Styling.colors?.surfaceContainer ?? "#333")
                        border.width: 1
                        border.color: root.selectedBrowser === modelData.id
                                      ? "transparent"
                                      : (Styling.colors?.outline ?? "#555")

                        Text {
                            id: chipText
                            anchors.centerIn: parent
                            text: modelData.label
                            font.pixelSize: 12
                            color: root.selectedBrowser === modelData.id ? "#fff" : "#ddd"
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

            // Search row
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                Text {
                    text: "▶"
                    color: "#FF0000"
                    font.pixelSize: 18
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                }

                SearchInput {
                    id: searchInput
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    placeholderText: "YouTube හි සොයන්න..."
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

