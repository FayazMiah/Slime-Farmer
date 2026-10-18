
local DataStoreService = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")
local TeleportService = game:GetService("TeleportService")

local ServerManager = {}
local serverManagementStore = DataStoreService:GetDataStore("ServerManagement")

local activeServers = {} -- in memory cache for real-time updates

MessagingService:SubscribeAsync("ActiveServerUpdates", function(message)
	local data = message.Data
	if data and data.WorldId and data.ServerCode then
		activeServers[data.WorldId] = {
			ServerCode = data.ServerCode,
			PlayerCount = data.PlayerCount,
			Timestamp = data.Timestamp,
		}
	end
end)

MessagingService:SubscribeAsync("RemoveWorldFromCache", function(message)
	local worldId = message.Data and message.Data.WorldId
	if worldId then
		activeServers[worldId] = nil
		--warn("World with ID " .. worldId .. " removed from all server caches.")
	end
end)

local function publishServerUpdate(worldId, serverCode, playerCount)
	local message = {
		WorldId = worldId,
		ServerCode = serverCode,
		PlayerCount = playerCount,
		Timestamp = os.time(),
	}
	MessagingService:PublishAsync("ActiveServerUpdates", message)
end

local function publishWorldCacheRemoval(worldId)
	local message = {
		WorldId = worldId,
	}
	MessagingService:PublishAsync("RemoveWorldFromCache", message)
end

local function getPlayersInWorld(worldId)
	local success, playersInWorld = pcall(function()
		return serverManagementStore:GetAsync(worldId)
	end)

	if success and playersInWorld then
		return playersInWorld
	else
		return {}  
	end
end


function ServerManager.createPrivateServer(worldId)
	local success, serverCode = pcall(function()
		return TeleportService:ReserveServer(134739518457633)
	end)

	if success then
		local serverData = {
			ServerCode = serverCode,
			PlayerCount = 0,
			Timestamp = os.time(),
		}

		local saveSuccess, saveError = pcall(function()
			serverManagementStore:SetAsync(worldId, serverData)
		end)

		if saveSuccess then
			activeServers[worldId] = serverData
			publishServerUpdate(worldId, serverCode, 0)
			return serverCode
		else
			warn("Failed to save private server data:", saveError)
			return nil
		end
	else
		warn("Failed to create private server for world:", worldId)
		return nil
	end
end


function ServerManager.getPrivateServer(worldId)
	if activeServers[worldId] then
		if activeServers[worldId].PlayerCount > 0 then
			return activeServers[worldId].ServerCode
		end
	end

	local serverData
	local success, errorMessage = pcall(function()
		serverData = serverManagementStore:GetAsync(worldId)
	end)

	if success and serverData and serverData.PlayerCount > 0 then
		activeServers[worldId] = serverData
		return serverData.ServerCode
	else
		return nil
	end
end


function ServerManager.updatePlayerCount(worldId, change)
	local serverData = activeServers[worldId]

	if not serverData then
		
		local success, errorMessage = pcall(function()
			serverData = serverManagementStore:GetAsync(worldId)
		end)

		if not success or not serverData then
			warn("Failed to retrieve server data for world:", errorMessage)
			return
		end
	end


	serverData.PlayerCount += change

	if serverData.PlayerCount <= 0 then
		
		pcall(function()
			serverManagementStore:RemoveAsync(worldId)
		end)
		activeServers[worldId] = nil
	else
		
		pcall(function()
			serverManagementStore:SetAsync(worldId, serverData)
		end)
		activeServers[worldId] = serverData
	end

	publishServerUpdate(worldId, serverData.ServerCode, serverData.PlayerCount)
end


function ServerManager.ConnectToWorld(player, worldId)
	local serverCode = ServerManager.getPrivateServer(worldId)

	if not serverCode then
		
		serverCode = ServerManager.createPrivateServer(worldId) 

	end

	if serverCode then
		ServerManager.updatePlayerCount(worldId, 1) 
		local tpoptions = Instance.new("TeleportOptions")
		tpoptions.ReservedServerAccessCode = serverCode
		local sendData = {
			{["WorldId"] = worldId}
		}
		tpoptions:SetTeleportData(sendData)
		TeleportService:TeleportAsync(134739518457633, {player}, tpoptions)
	else
		warn("Failed to connect player to private server for world:", worldId)
	end
end


function ServerManager.DisconnectFromWorld(player, worldId)
	ServerManager.updatePlayerCount(worldId, -1)
end


function ServerManager.DeleteActiveServersForWorld(worldId)
	--if activeServers[worldId] then
		--local serverData = activeServers[worldId]
		
		local message = {worldId = worldId}
		local success, errormessage = pcall(function()
			print("sent delete message to servers")
			MessagingService:PublishAsync("WorldDeletion", message)
		end)
		if success then
			pcall(function()
				serverManagementStore:RemoveAsync(worldId)
			end)
			publishWorldCacheRemoval(worldId)
			if activeServers[worldId] then
				activeServers[worldId] = nil
			end
		end
	--end
end

return ServerManager

