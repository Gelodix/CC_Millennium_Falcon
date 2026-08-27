-- wget https://raw.githubusercontent.com/Gelodix/CC_Millennium_Falcon/master/installer.lua installer.lua

local repo_url = "https://raw.githubusercontent.com/Gelodix/CC_Millennium_Falcon/main/"

local files = {
    ["faucon.lua"] = "faucon.lua",
    ["faucon_files/controls.lua"] = "faucon_files/controls.lua",
    ["faucon_files/peripherals.lua"] = "faucon_files/peripherals.lua",
    ["faucon_files/state.lua"] = "faucon_files/state.lua",
    ["faucon_files/ui.lua"] = "faucon_files/ui.lua",
    ["library/quaternion.lua"] = "library/quaternion.lua",
}

print("Cleaning files...")

for localPath, _ in pairs(files) do
    if fs.exists(localPath) then     
        fs.delete(localPath)
        print("- " .. localPath .. " deleted")
    end
end

print("Checking for Basalt")

if fs.exists("basalt.lua") then
    print("Basalt detected, continuing ...")
else
    print("Basalt not detected, installing basalt")
    shell.run("wget run https://basalt.madefor.cc/2.5/install.lua minified")
end

print("Starting installation...")

for localPath, remotePath in pairs(files) do
    print("- Downloading " .. localPath .. "...")

    local request = http.get(repo_url .. remotePath)

    if request then
        local content = request.readAll()
        request.close()

        local dir = fs.getDir(localPath)

        if not fs.exists(dir) and dir ~= ".." then
            fs.makeDir(dir)
        end

        local file = fs.open(localPath, "w")
        file.write(content)
        file.close()
    else
        print("[!] HTTP Error : can't find " .. remotePath)
    end
end

print("Installation finished")
