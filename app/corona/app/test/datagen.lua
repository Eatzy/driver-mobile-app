local M = {};

M.generateOrderDetails = function ()
	local orderData = {};
	orderData["id"] = math.random(1000,999999999);
	orderData["info_code"] = "KEDVCA";
	orderData["order_status_id"] = math.random(1,14);
	orderData["event_name"] = nil;
	orderData["restaurant"] = nil;
	orderData["address"] = nil;
	orderData["customer"] = nil;
	orderData["target_arrive_at"] = nil;
	orderData["driver_confirmed_at"] = nil;
	orderData["arrived_rest_at"] = nil;
	orderData["picked_up_at"] = nil;
	orderData["arrived_cust_at"] = nil;
	
	
	local result = orderData;
	
	-- print generated
  	logger.log("DATAGEN generateOrderDetails: "..tostring((require("json")).encode(result)));
	
	return result;
end

return M;