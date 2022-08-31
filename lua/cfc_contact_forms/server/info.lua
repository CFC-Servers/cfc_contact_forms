local function getE2Information()
    local playerE2Info = {}

    for _, expression2 in pairs( ents.FindByClass( "gmod_wire_expression2" ) ) do
        if IsValid( expression2 ) then
            local e2Owner = expression2:CPPIGetOwner()
            local ownerId = ( e2Owner and IsValid( e2Owner ) and e2Owner:IsPlayer() and e2Owner:SteamID() ) or "world"

            local e2Info = {}
            e2Info.name = expression2:GetGateName()
            e2Info.cpu = expression2:GetTable().context.timebench * 1000000
            e2Info.owner = ownerId

            table.insert( playerE2Info, e2Info )
        end
    end

    return playerE2Info
end


local function getPlayersInfo()
    local playersInfo = {}

    for _, ply in pairs( player.GetAll() ) do
        local playerInfo = {}
        playerInfo.name = ply:GetName()
        playerInfo.pos = tostring( ply:GetPos() )
        playerInfo.ping = ply:Ping()
        playerInfo.packetloss = ply:PacketLoss()

        local playerId = ply:SteamID()
        playersInfo[playerId] = playerInfo
    end

    return playersInfo
end


local function getServerInfo()
    local serverInfo = {}
    serverInfo.uptime = SysTime()
    serverInfo.ticktime = 1 / FrameTime()

    return serverInfo
end


local function getPlayerCounts()
    local playerCounts = {}

    for _, ent in pairs( ents.GetAll() ) do
        if IsValid( ent ) then
            local className = ent:GetClass()
            local entOwner = ent:CPPIGetOwner() or ent:GetOwner()
            local ownerId = ( entOwner and IsValid( entOwner ) and entOwner:IsPlayer() and entOwner:SteamID() ) or "world"

            playerCounts[ownerId] = playerCounts[ownerId] or {}
            playerCounts[ownerId][className] = ( playerCounts[ownerId][className] or 0 ) + 1
        end
    end

    return playerCounts
end

return function()
    local debugInformation = {}

    debugInformation["counts"] = getPlayerCounts()
    debugInformation["E2Info"] = getE2Information()
    debugInformation["playerInfo"] = getPlayersInfo()
    debugInformation["serverInfo"] = getServerInfo()

    return util.TableToJSON( debugInformation )
end
