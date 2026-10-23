# Ambxshell YouTube Search Widget 🚀

A minimalist, fast, and elegant YouTube search popup widget designed specifically for Hyprland window manager running Ambxshell (powered by Quickshell).

## ✨ Features

- Ambxshell Native Styling: Uses native `StyledRect` components to seamlessly match your system theme, rounded corners, and blur effects.
- Multi-Browser Support: Instantly switch between Default browser, Firefox, Brave, and Chromium using sleek interactive browser chips.
- Quick Launch: Type your search query, press `Enter`, and it automatically launches YouTube in your chosen browser and closes the popup.
- IPC Controlled: Easily toggleable via Quickshell IPC commands and custom Hyprland keybinds.

## 📂 Installation & Setup

1. Place the `YoutubeSearchPopup.qml` file inside your Ambxshell configuration modules directory (for example, `modules/tools/`).
2. Include a Loader for the component inside your main `shell.qml`:

```qml
Loader {
    active: true
    source: "modules/tools/YoutubeSearchPopup.qml"
}
```

3. Add a keybind or command to toggle the widget:

```bash
GEN=$(ls -1d ~/.local/share/ambxst/mods/generations/*/ | tail -1)
quickshell -c "$GEN" ipc call youtubeSearch toggle
```

## 🧩 Notes

- This widget is designed for the Ambxshell + Quickshell ecosystem.
- It focuses on a lightweight, popup experience for fast YouTube searches from the desktop.

## License

This project is provided as-is for personal and customization use within Ambxshell setups.

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/7ab21fca-7055-452f-b109-b9780289fc01" />

