local M = {};

local json = require "json";
local crypto = require "crypto";

local initialized;

local configuration;

local function saveConfig(config)
	local jsonFileDesc = json.encode(config);
	
	logger.log("SAVING CONFIGURATION:");
	logger.log(jsonFileDesc);
	
	local path = system.pathForFile( "data.json", system.DocumentsDirectory );
	local fhd = io.open( path, "w" );
	fhd:write( tostring(jsonFileDesc) );
	io.close( fhd );
	fhd = nil;
	
	configuration = config;
	logger.log( "Storage configuration saved!");
end

M.init = function ()
	if initialized ~= true then
		local path = system.pathForFile( "data.json", system.DocumentsDirectory );
		local contents;
		
		if path ~= nil then
			local file = io.open( path, "r" );
			if file then
				contents = file:read( "*a" );
				io.close( file );
				if contents ~= nil then
					configuration = json.decode( contents );
				else
					local config = {};
					saveConfig(config);
				end
			else
				local config = {};
				saveConfig(config);
			end
	
			logger.log( "Storage plugin initialized!");
			initialized = true;
		end
	end
end

M.saveConfiguration = function (config)
	if initialized ~= true then
		M.init();
	end
	
	if initialized == true and config ~= nil then
		saveConfig(config);
  	end
end

M.getConfiguration = function ()
	if initialized ~= true then
		M.init();
	end
	
	return configuration;
end

return M;