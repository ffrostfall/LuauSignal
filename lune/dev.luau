local rojo = require("@vendor/lunePackages/rojo")
local task = require("@lune/task")
local watch = require("@vendor/lunePackages/watch")
local fs = require("@lune/fs")

watch.file("src/init.luau", function()
	print("mirroring...")
	local content = fs.readFile("src/init.luau")
	local newcontent = string.gsub(content, "--!native", "")
	fs.writeFile("benches/libs/luausignal-mirror.luau", newcontent)
end)

rojo.sourcemap("benches.project.json", "sourcemap.json", true)

rojo.serve("benches.project.json")

while true do
	task.wait(1)
end
