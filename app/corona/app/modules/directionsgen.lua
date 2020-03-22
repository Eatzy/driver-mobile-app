local M = {};

local _W = display.contentWidth;
local _H = display.contentHeight;
local _CX = _W*0.5;
local _CY = _H*0.5;

local widget = require( "widget" )

M.newTab = function (params)
  	
  	local containerEnabled = false;
  	local containerLoaded = false;
  	local mapUpdatesEnabled = false;
  	
	local containerWidth = _W;
	local containerHeight = _H;
	local externalLoader = nil;
	local notificationsGw = nil;
	local navigationGW = nil;
  	local lastMapUpdate = nil;
  	
  	local currentMarkers = {};
	
	if params ~= nil then
		if params["width"] ~= nil then containerWidth = params["width"]; end
		if params["height"] ~= nil then containerHeight = params["height"]; end
		if params["loader"] ~= nil then externalLoader = params["loader"]; end
		if params["notifications"] ~= nil then notificationsGw = params["notifications"]; end
		if params["navigation"] ~= nil then navigationGW = params["navigation"]; end
	end
	
	local Container = display.newGroup();
	
	local Background = display.newGroup();
  	local Foreground = display.newGroup();
  	local GUI = display.newGroup();
  	
  	Container:insert(Background);
  	Container:insert(Foreground);
  	Container:insert(GUI);
  	
  	local loaderParams = {};
  	loaderParams["width"] = containerWidth;
	loaderParams["height"] = containerHeight;
	loaderParams["bgcolor"] = parameters.GRAPHICS.COLORS["background_directions"];
  	local loaderBuilder = require( "app.lib.loader" );
  	local loader = loaderBuilder.newLoader(loaderParams);
  	loader.initialize();

  	local backgroundBox = display.newRect(0,0,containerWidth,containerHeight);
  	backgroundBox:setFillColor(parameters.GRAPHICS.COLORS["background_directions"][1],parameters.GRAPHICS.COLORS["background_directions"][2],parameters.GRAPHICS.COLORS["background_directions"][3]);
  	backgroundBox.anchorX = 0.5;
  	backgroundBox.anchorY = 0.0;
  	backgroundBox.x = _CX;
  	backgroundBox.y = 0;
  	Background:insert(backgroundBox);
  	
  	--[[
  	local tabNameText = textmaker.newText(parameters.GRAPHICS.TEXT["section_in_progress"],0,0,{"roboto-thin"}, parameters.GRAPHICS.FONT_BASE_SIZE);
  	tabNameText:setFillColor(parameters.GRAPHICS.COLORS["main_text"][1],parameters.GRAPHICS.COLORS["main_text"][2],parameters.GRAPHICS.COLORS["main_text"][3]);
  	tabNameText.anchorX = 0.5;
  	tabNameText.anchorY = 0.5;
  	tabNameText.x = _CX;
  	tabNameText.y = containerHeight*0.5;
  	Foreground:insert(tabNameText);
  	--]]
  	
  	local mapView = nil;
  	
  	GUI:insert(loader);
  	
  	-- FUNCTIONS BEGIN
  	local function updatePositionAndMarkers()
  		if gpshelper.gps_latitude == nil or gpshelper.gps_longitude == nil then
  			logger.log("DirectionsGen - No position data");
  			return;
  		end
  		
  		local utcDate = os.date( "!*t" );
		local utcTime = tonumber(os.time(utcDate));
		local epochTime = tonumber(os.time{year=1970, month=1, day=1, hour=0});
		local nowTime = (utcTime - epochTime);
		local localDate = os.date( "*t" );
		local localTime = tonumber(os.time(localDate));
  		
  		-- mapView:removeAllMarkers();
  		
  		local currentRuns = menunu.getCurrentRuns();
  		-- logger.log( "DirectionsGen - currentRuns: "..tostring(#currentRuns) );
  		
  		
  		local minLatitude = gpshelper.gps_latitude;
  		local maxLatitude = gpshelper.gps_latitude;
  		
  		local minLongitude = gpshelper.gps_longitude;
  		local maxLongitude = gpshelper.gps_longitude;
  		
  		local function markerListener(event)
			logger.log( "DirectionsGen - type: "..tostring(event.type) )  -- event type
			logger.log( "DirectionsGen - markerId: "..tostring(event.markerId) )  -- ID of the marker that was touched
			logger.log( "DirectionsGen - lat: "..tostring(event.latitude) )  -- latitude of the marker
			logger.log( "DirectionsGen - long: "..tostring(event.longitude) )  -- longitude of the marker
		end
		
		local newMarkers = {};
		local markerActions = {};
		
		for k,v in pairs(currentMarkers) do
			markerActions[k] = "remove";
		end
		
		for i=1, #currentRuns do
			local currentRun = currentRuns[i];
			
			local roId = currentRun["id"];
			local runType = currentRun["type"];
			local runLat = currentRun["latitude"];
			local runLng = currentRun["longitude"];
			local runEstimatedAt = currentRun["estimated"];
			
			if roId ~= nil and runType ~= nil and runLat ~= nil and runLng ~= nil then
				
				local markerLat = runLat;
				local markerLng = runLng;
				
				-- TEMP LOCAL TESTING BEGIN
				-- local markerLat = gpshelper.gps_latitude + math.random(-10,10)*0.01;
				-- local markerLng = gpshelper.gps_longitude + math.random(-10,10)*0.01;
				-- TEMP LOCAL TESTING END
		
				minLatitude = math.min(minLatitude,markerLat);
				maxLatitude = math.max(maxLatitude,markerLat);
				minLongitude = math.min(minLongitude,markerLng);
				maxLongitude = math.max(maxLongitude,markerLng);
			
				local markerKey = string.lower(runType).."_"..tostring(roId);
				logger.log("New marker key: "..tostring(markerKey));
				
				local markerFound = false;
				for k,v in pairs(markerActions) do
					if k == markerKey then
						markerActions[k] = "keep";
						markerFound = true;
						break;
					end
				end
				
				if markerFound ~= true then
					
					local subtitleString = "Unknown";
					if runEstimatedAt ~= nil then
						local locationDate = os.date( "*t", (localTime + (runEstimatedAt - nowTime)) );
						if locationDate ~= nil then
							if locationDate.hour > 12 then
								subtitleString = string.format("%02d",(locationDate.hour-12))..":"..string.format("%02d",locationDate.min).." PM";
							else
								subtitleString = string.format("%02d",locationDate.hour)..":"..string.format("%02d",locationDate.min).." AM";
							end
						end
					end
				
					local markerOptions = {};
					markerOptions.title = "Order #"..tostring(roId);
					markerOptions.subtitle = subtitleString;
					markerOptions.listener = markerListener;
					if runType == "pickup" then
						markerOptions.imageFile = "media/images/icons/markers/restaurant.png";
					elseif runType == "dropoff" then
						markerOptions.imageFile = "media/images/icons/markers/house.png";
					end
					
					
					local markerId = mapView:addMarker( markerLat, markerLng, markerOptions );
					
					logger.log( "DirectionsGen - Marker markerId: "..tostring(markerId) );
					if markerId ~= nil and markerId > 0 then
						newMarkers[markerKey] = markerId;
					else
						logger.log( "DirectionsGen - cannot add marker with key "..tostring(markerKey) );
					end
				end
			else
				logger.log( "DirectionsGen - runLat and/or runLng is nil" );
			end
		end
  		
  		local newMarkersToRemove = false;
  		local newCurrentMarkers = {};
  		for k,v in pairs(currentMarkers) do
  			local toRemove = false;
  			
  			if markerActions[k] ~= nil then
  				if markerActions[k] == "remove" then
  					toRemove = true;
  				end
  			else
  				toRemove = true;
  			end
  			
  			if toRemove ~= true then
  				newCurrentMarkers[k] = v;
  			else
  				logger.log( "DirectionsGen - remove marker "..tostring(v) );
  				mapView:removeMarker(v);
  				newMarkersToRemove = true;
  			end
  		end
  		local newMarkersToAdd = false;
  		for k,v in pairs(newMarkers) do
  			newCurrentMarkers[k] = v;
  			newMarkersToAdd = true;
  		end
  		currentMarkers = newCurrentMarkers;
  		
  		if newMarkersToAdd == true then
  			logger.log("New markers found, adapting the view...");
			latDelta = math.max(0.005, ((maxLatitude - minLatitude)*1.25 + 0.001));
			lngDelta = math.max(0.005, ((maxLongitude - minLongitude)*1.25 + 0.001));
		
			mapView:setRegion( gpshelper.gps_latitude, gpshelper.gps_longitude, latDelta, lngDelta, true );		
  		end	
  	end
  	
  	local function onMapUpdate(event)
  		if event ~= nil and event.time ~= nil then
  			local eventTime = event.time;
  			
  			if lastMapUpdate == nil then
  				updatePositionAndMarkers();
  				lastMapUpdate = eventTime;
  			else
  				local delay = eventTime - lastMapUpdate;
  				if delay > parameters.MAPS.DIRECTIONS.REFRESH_PERIOD then
  					updatePositionAndMarkers();
  					lastMapUpdate = eventTime;
  				end
  			end
  		end
  	end
  	
  	local enableMapUpdates = function ()
  		if mapUpdatesEnabled ~= true then
  			lastMapUpdate = nil;
  			Runtime:addEventListener("enterFrame", onMapUpdate);
  			
  			mapUpdatesEnabled = true;
  		end
  	end
  	
  	local disableMapUpdates = function ()
  		if mapUpdatesEnabled == true then
  			Runtime:removeEventListener("enterFrame", onMapUpdate);
  			mapUpdatesEnabled = false;
  		end
  	end
  	
  	local enableContainerFunc = function ()
  		if containerEnabled ~= true then
  			if mapView ~= nil then
  				mapView:removeSelf();
  				mapView = nil;
  			end
  			
  			mapView = native.newMapView( 0, 0, containerWidth, containerHeight );
  			mapView.anchorX = 0.5;
			mapView.anchorY = 0.5;
			mapView.x = _CX;
			mapView.y = containerHeight*0.5;
			Foreground:insert(mapView);
			
			-- updatePositionAndMarkers();
  			enableMapUpdates();
  		
  			containerEnabled = true;
  		end
  	end
  	
  	local disableContainerFunc = function ()
  		if containerEnabled == true then
  			disableMapUpdates();
  			
  			if mapView ~= nil then
  				mapView:removeSelf();
  				mapView = nil;
  			end
  			
  			currentMarkers = {};
  			
  			containerEnabled = false;
  		end
  	end
  	
  	local loadContainerFunc = function ()
  		if containerLoaded ~= true then
  			containerLoaded = true;
  		end
  	end
  	
  	local unloadContainerFunc = function ()
  		if containerLoaded == true then
  			disableContainerFunc();
  		
  			containerLoaded = false;
  		end
  	end
  	
  	-- FUNCTIONS END
  	Container.onEnable = enableContainerFunc;
  	Container.onDisable = disableContainerFunc;
  	Container.onLoad = loadContainerFunc;
  	Container.onUnload = unloadContainerFunc;
  	
  	return Container;
end

return M;