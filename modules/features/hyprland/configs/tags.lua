-- tags.lua

-- Multimedia video players
hl.window_rule({ match = { class = "[Mm]pv|vlc" }, tag = "+multimedia_video" })

-- Settings / system utilities (group 1)
hl.window_rule({ match = { class = "nm-applet|nm-connection-editor|blueman-manager|org.gnome.FileRoller" }, tag =
"+settings" })

-- Settings / system utilities (group 2)
hl.window_rule({ match = { class = "org.gnome.DiskUtility|wihotspot(-gui)?" }, tag = "+settings" })

-- Viewers: system monitor
hl.window_rule({ match = { class = "org.gnome.SystemMonitor" }, tag = "+viewer" })

-- Viewers: document viewer
hl.window_rule({ match = { class = "org.gnome.Evince" }, tag = "+viewer" })

-- Viewers: image viewer
hl.window_rule({ match = { class = "eog|org.gnome.Loupe" }, tag = "+viewer" })
