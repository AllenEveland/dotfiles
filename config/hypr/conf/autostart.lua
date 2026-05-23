hl.on("hyprland.start", function () 
    hl.exec_cmd("waybar")
    hl.exec_cmd("fcitx5")
    hl.exec_cmd("hypridle")
    -- Remove command below if successfully complete config
    -- hl.exec_cmd("awww")
end)