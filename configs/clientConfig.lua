Tr = {}
TriggerServerEvent("plouffe_territories:sendConfig")

RegisterNetEvent("plouffe_territories:getConfig",function(list)
	if not list then
		while true do
			Tr = nil
		end
	else
		for k,v in pairs(list) do
			Tr[k] = v
		end

		Tr:Start()
	end
end)