local composer = require( "composer" )
local scene = composer.newScene()

local _W = display.contentWidth;
local _H = display.contentHeight;
local _CX = _W*0.5;
local _CY = _H*0.5;

-- Display objects
local targetPage;
local loader;

local function processUpdate(prevVersion, currentVersion)
	logger.log("UPDATING FROM "..tostring(prevVersion).." TO "..tostring(currentVersion));
	-- TODO
end

local function processConfiguration()
	local appConfiguration = storage.getConfiguration();
    if appConfiguration ~= nil then
    	local appVersion = nil;
    	if device.platform == "ios" then
    		appVersion = tostring(system.getInfo("appVersionString"));
    	elseif device.platform == "android" then
    		appVersion = tostring(system.getInfo("appVersionString"));
    	else
    		appVersion = tostring(parameters.GENERAL.BUILD);
    	end
    	
    	local utcDate = os.date( "!*t" );
		local utcTime = tonumber(os.time(utcDate));
		local epochTime = tonumber(os.time{year=1970, month=1, day=1, hour=0});
	
		local nowTime = (utcTime - epochTime);
    	
    	local appStats = appConfiguration["stats"];
    	if appStats == nil then
    		appStats = {};
    		
    		local versionObj = {
    			["install_ver"] = appVersion,
    			["install_ts"] = nowTime,
    			["current_ver"] = appVersion,
    			["current_ts"] = nowTime
    		};
    		appStats["version"] = versionObj;
    	else
    		local versionObj = appStats["version"];
    		
    		if appVersion == nil then
    			versionObj = {
					["install_ver"] = appVersion,
					["install_ts"] = nowTime,
					["current_ver"] = appVersion,
					["current_ts"] = nowTime
				};
    		else
    			local installVersion = versionObj["install_ver"];
    			local installTS = versionObj["install_ts"];
    			local currentVersion = versionObj["current_ver"];
    			local currentTS = versionObj["current_ts"];
    			
    			if appVersion ~= currentVersion then
    				processUpdate(currentVersion,appVersion);
    				
    				versionObj["current_ver"] = appVersion;
    				versionObj["current_ts"] = nowTime;
    			end
    		end
    		appStats["version"] = versionObj;
    	end
    	appConfiguration["stats"] = appStats;
    	
    	storage.saveConfiguration(appConfiguration);
    end
end

local function getTargetSceneForCurrentConfiguration(callback)
	local targetScene = "app.scenes.login";
	
	local appConfiguration = storage.getConfiguration();
    if appConfiguration ~= nil then
    	local validSoFar = true;
    	if validSoFar == true and appConfiguration["user_id"] == nil then
    		validSoFar = false;
    	end
    	if validSoFar == true and menunu.isTokenExpired() == true then
    		validSoFar = false;
    	end
    	
    	if validSoFar == true then
    		local onDriverStatus = function (data)
    			if data["error"] == true then
    				logger.log("driver data error");
    				targetScene = "app.scenes.login";
    			else
    				contents = data["data"];
					local driverData = contents["driver"];
					
					if driverData ~= nil then
						local appConfiguration = storage.getConfiguration();
						appConfiguration["driver"] = driverData;
						storage.saveConfiguration(appConfiguration);
						
						if driverData["clocked_in"] == true then
							targetScene = "app.scenes.driver";
						else
							targetScene = "app.scenes.clock";
						end
    				else
    					logger.log("no driver data received");
    					targetScene = "app.scenes.login";
    				end
    			end
    			
    			callback(targetScene);
    		end
    		
    		menunu.getDriverStatus(onDriverStatus);
    	else
    		callback(targetScene);
    	end
    else
    	callback(targetScene);
    end
end

function scene:create( event )
  	local group = self.view;

  	local Background = display.newGroup();
  	local Foreground = display.newGroup();
  	local GUI = display.newGroup();

  	group:insert(Background);
  	group:insert(Foreground);
  	group:insert(GUI);

	local goToMain = function (event)
	  	if targetPage ~= nil then
			loader.stop();
			logger.log("GO TO "..targetPage.." SCENE");
				
			local composer = require( "composer" );
			composer.gotoScene(targetPage);
		end
	end

	local loaderBuilder = require( "app.lib.loader" );
  	loader = loaderBuilder.newLoader();
  	loader.initialize({onRepeat=goToMain});
	
	Foreground:insert(loader);
end

function scene:show( event )
    local phase = event.phase;

    if ( phase == "will" ) then
    	-- TODO
    elseif ( phase == "did" ) then
	  	-- TODO
	  	if loadingAnimation == nil then
	  		loader.start();
	  		
	  		local function onAppChecked(response)
	  			local goodVersion = false;
	  			local badVersionCode = nil;
	  			local badVersionReason = nil;
	  			
				if response == nil then
					badVersionCode = "server-offline";
					badVersionReason = "No response from the server";
				elseif response["error"] == true then
					logger.log("Appcheck Error: "..tostring(response["message"]));
					
					badVersionCode = "server-error";
					badVersionReason = tostring(response["message"]);
				elseif response["data"] == nil then
					badVersionCode = "server-missing-response";
					badVersionReason = "No response data";
				else
					local contents = response["data"];
					if contents["message"] ~= nil then
						goodVersion = true;
					else
						badVersionCode = "server-missing-message";
						badVersionReason = "No response message";
					end
				end
	  			
	  			if goodVersion == true then
	  				-- Check app permissions
	  				local permissionsOk = true;
	  				
	  				if device.platform == "android" then
	  					-- Check android permissions
	  					local deniedPermissions = system.getInfo("deniedAppPermissions");
	  					if deniedPermissions ~= nil then
	  						for i=1, #deniedPermissions do
	  							if deniedPermissions[i] ~= nil then
									local deniedPermissionName = deniedPermissions[i];
									logger.log("DENIED PERMISSION: "..tostring(deniedPermissionName));
	  							end
	  						end
	  					end
	  				end
	  				
	  				if permissionsOk == true then
						-- Check login credentials
						processConfiguration();
		
						local setTargetPage = function (tPage)
							targetPage = tPage;
							logger.log("targetPage is "..tostring(targetPage));
						end
						getTargetSceneForCurrentConfiguration(setTargetPage);
					else
						-- Navigate to forced update scene
						logger.log("NAVIGATE TO FORCED UPDATE SCENE: credentials are insufficient");
					
						local transitionParams = {
							effect = nil,
							time = 0,
							params = {
								source = "bad-credentials",
								missing = {
									-- TODO
								}
							}
						}
					
						local composer = require( "composer" );
						composer.gotoScene("app.scenes.actionrequired", transitionParams);
					end
				else
					-- Navigate to forced update scene
					logger.log("NAVIGATE TO FORCED UPDATE SCENE: badVersionCode="..tostring(badVersionCode).." badVersionReason="..tostring(badVersionReason));
					
					local transitionParams = {
						effect = nil,
    					time = 0,
						params = {
							source = "app-check",
							code = badVersionCode,
							reason = badVersionReason
						}
					}
					
					local composer = require( "composer" );
					composer.gotoScene("app.scenes.actionrequired", transitionParams);
				end
	  		end
	  		
	  		-- Check app version
	  		menunu.checkApp(onAppChecked);
    	end
    end
end

function scene:hide( event )
  	local phase = event.phase;

    if ( phase == "will" ) then
        -- TODO
    elseif ( phase == "did" ) then
        if loadingAnimation ~= nil then
	  		transition.cancel(loadingAnimation);
	  		loadingAnimation = nil;
    	end
    end
end

function scene:destroy( event )
-- TODO
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene