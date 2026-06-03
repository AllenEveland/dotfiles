local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- Turn off blur
hl.window_rule({
    match = {
        class = ".*"
    },
    no_blur = true
})

-- Floating & Center
local floating_titles = {
    "Open File", "Select a File", "Choose wallpaper",
    "Open Folder", "Save As", "Library", "File Upload",
    "Pick Files",
    "wants to save", "wants to open"
}
for _, title in ipairs(floating_titles) do
    hl.window_rule({
        match = {
            title = "^(" .. title .. ")(.*)$"
        },
        float = true,
        center = true
    })
end

-- Tearing
hl.window_rule({
    match = {
        title = ".*\\.exe|.*minecraft.*",
        class = "^(steam_app).*"
    },
    immediate = true
})

-- No shader
hl.window_rule({
    match = {
        float = 0
    },
    no_shadow = true
})

