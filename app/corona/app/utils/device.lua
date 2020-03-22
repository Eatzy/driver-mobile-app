local M = {};

-- Public constants
local currentPlatform = string.lower(tostring(system.getInfo("platformName")));
if tostring(system.getInfo("environment")) ~= "simulator" then
	if string.find(currentPlatform,"iphone") ~= nil then
		M.platform = "ios";
	elseif string.find(currentPlatform,"android") ~= nil then
		M.platform = "android";
	elseif string.find(currentPlatform,"win") ~= nil then
		M.platform = "windows";
	elseif string.find(currentPlatform,"mac") ~= nil then
		M.platform = "macos";
	else
		M.platform = "unknown";
	end
else
	M.platform = "simulator";
end
			
M.model = string.lower(tostring(system.getInfo("model")));
M.architectureInfo = string.lower(tostring(system.getInfo("architectureInfo")));
M.arch = 1;
M.rel = 1;
local idx = string.find(M.architectureInfo,",");
if idx ~= nil and tonumber(M.architectureInfo:sub(idx-1,idx-1)) ~= nil and tonumber(M.architectureInfo:sub(idx+1,idx+1)) ~= nil then
	M.arch = tonumber(M.architectureInfo:sub(idx-1,idx-1));
	M.rel = tonumber(M.architectureInfo:sub(idx+1,idx+1));
end

local systemLanguage = string.lower(system.getPreference("ui", "language"));
if systemLanguage ~= nil then
	M.language = systemLanguage;
end

return M;