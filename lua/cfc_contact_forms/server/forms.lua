return function( submitForm )
    local Forms = {}


    function Forms.Contact( _, ply )
        local contactMethod = net.ReadString()
        local message = net.ReadString()

        local data = {}
        data["steam_id"] = ply:SteamID()
        data["steam_name"] = ply:GetName()
        data["contact_method"] = contactMethod
        data["message"] = message

        submitForm( data, "contact", ply )
    end


    function Forms.Feedback( _, ply )
        local rating = net.ReadString()
        local likelyToReturn = net.ReadString()
        local message = net.ReadString()

        local data = {}
        data["steam_id"] = ply:SteamID()
        data["steam_name"] = ply:GetName()
        data["rating"] = rating
        data["likely_to_return"] = likelyToReturn
        data["message"] = message

        submitForm( data, "feedback", ply )
    end


    function Forms.BugReport( _, ply )
        local urgency = net.ReadString()
        local message = net.ReadString()

        local imageSize = net.ReadUInt( 32 )
        local image = util.Decompress( net.ReadData( imageSize ) )

        local data = {}
        data["steam_id"] = ply:SteamID()
        data["steam_name"] = ply:GetName()
        data["urgency"] = urgency
        data["message"] = message
        data["image"] = image

        submitForm( data, "bug-report", ply )
    end


    function Forms.PlayerReport( _, ply )
        local reportedSteamID = net.ReadString()
        local urgency = net.ReadString()
        local message = net.ReadString()
        local reportedPly = player.GetBySteamID( reportedSteamID )

        local data = {}
        data["steam_id"] = ply:SteamID()
        data["steam_name"] = ply:GetName()
        data["reported_steam_id"] = reportedSteamID
        data["reported_steam_name"] = reportedPly and reportedPly:GetName() or "<Unknown Name>"
        data["urgency"] = urgency
        data["message"] = message

        submitForm( data, "player-report", ply )
    end


    function Forms.StaffReport( _, ply )
        local reportedSteamID = net.ReadString()
        local urgency = net.ReadString()
        local message = net.ReadString()
        local reportedPly = player.GetBySteamID( reportedSteamID )

        local data = {}
        data["reported_steam_id"] = reportedSteamID
        data["reported_steam_name"] = reportedPly and reportedPly:GetName() or "<Unknown Name>"
        data["urgency"] = urgency
        data["message"] = message

        submitForm( data, "staff-report", ply )
    end


    function Forms.FreezeReport( _, ply )
        local severity = net.ReadString()
        local message = net.ReadString()

        local data = {}
        data["steam_id"] = ply:SteamID()
        data["steam_name"] = ply:GetName()
        data["debug_information"] = getDebugInformation()
        data["severity"] = severity
        data["message"] = message

        submitForm( data, "freeze-report", ply )
    end


    return Forms
end
