local M = {};

M.log = function (message)
	if (parameters.GENERAL.LOG_ENABLED == true) then
		print(message);
	end
end

return M;