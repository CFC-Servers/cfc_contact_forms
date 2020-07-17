util.AddNetworkString( "CFC_SubmitContactForm" )
util.AddNetworkString( "CFC_SubmitFeedbackForm" )
util.AddNetworkString( "CFC_SubmitBugReport" )
util.AddNetworkString( "CFC_SubmitPlayerReport" )
util.AddNetworkString( "CFC_SubmitFreezeReport" )
util.AddNetworkString( "CFC_SubmitStaffReport" )

local FORM_PROCESSOR_URL = file.Read( "cfc/contact/url.txt", "DATA" )
if not FORM_PROCESSOR_URL or FORM_PROCESSOR_URL == "" then
    error( "[CFC Contact Forms] Couldn't find cfc/contact/url.txt or file was empty - cannot start" )
end

FORM_PROCESSOR_URL = string.Replace( FORM_PROCESSOR_URL, "\r", "" )
FORM_PROCESSOR_URL = string.Replace( FORM_PROCESSOR_URL, "\n", "" )

local REALM = file.Read( "cfc/realm.txt", "DATA" )
if not REALM or REALM == "" then
    error( "[CFC Contact Forms] Couldn't find cfc/realm.txt or file was empty - cannot start" )
end

REALM = string.Replace( REALM, "\r", "" )
REALM = string.Replace( REALM, "\n", "" )

local SUBMISSION_GROOM_INTERVAL = 60

local playerSubmissionCounts = {}

local function serverLog( message )
    local prefix = "[CFC Contact Forms] "
    print( prefix .. message )
end

local function alertPlayer( ply, message )
  local prefix = "[CFC Contact Forms] "
  ply:ChatPrint( prefix .. message )
end

local function groomSubmissionCounts()
    for ply, submissionCount in pairs( playerSubmissionCounts ) do
        if submissionCount == 1 then
            playerSubmissionCounts[ply] = nil
        else
            playerSubmissionCounts[ply] = submissionCount - 1
        end
    end
end
timer.Create( "CFC_GroomFormSubmissions", SUBMISSION_GROOM_INTERVAL, 0, groomSubmissionCounts )

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

local function getDebugInformation()
    local debugInformation = {}

    debugInformation["counts"] = getPlayerCounts()
    debugInformation["E2Info"] = getE2Information()
    debugInformation["playerInfo"] = getPlayersInfo()
    debugInformation["serverInfo"] = getServerInfo()

    return util.TableToJSON( debugInformation )
end

local function recordPlayerSubmission( ply )
    local count = playerSubmissionCounts[ply] or 0

    playerSubmissionCounts[ply] = count + 1
end

local function playerCanSubmit( ply )
    return ( playerSubmissionCounts[ply] or 0 ) < 3
end

local function submitFormForPlayer( data, endpoint, ply )
    local plyName = ply and ply:GetName() or "Unknown Player"

    data["realm"] = REALM

    serverLog( "Sending request for <" .. plyName .. "> with form data: " )
    PrintTable( data )

    if not playerCanSubmit( ply ) then return alertPlayer( ply, "You\'re doing that too much! Please wait or reach out on our discord" ) end

    local url = FORM_PROCESSOR_URL ..  endpoint
    http.Post( url, data,
        function( success )
            print( success )
        end,
        function( failure )
            serverLog( "Request failed with data:" )
            PrintTable( data )
            serverLog( failure )
        end
    )

    recordPlayerSubmission( ply )
end

local function submitContactForm( len, ply )
    local contactMethod = net.ReadString()
    local message = net.ReadString()

    local data = {}
    data["steam_id"] = ply:SteamID()
    data["steam_name"] = ply:GetName()
    data["contact_method"] = contactMethod
    data["message"] = message

    submitFormForPlayer( data, "contact", ply )
end

local function submitFeedbackForm( len, ply )
    local rating = net.ReadString()
    local likelyToReturn = net.ReadString()
    local message = net.ReadString()

    local data = {}
    data["steam_id"] = ply:SteamID()
    data["steam_name"] = ply:GetName()
    data["rating"] = rating
    data["likely_to_return"] = likelyToReturn
    data["message"] = message

    submitFormForPlayer( data, "feedback", ply )
end

local function submitBugReport( len, ply )
    local urgency = net.ReadString()
    local message = net.ReadString()

    local data = {}
    data["steam_id"] = ply:SteamID()
    data["steam_name"] = ply:GetName()
    data["urgency"] = urgency
    data["message"] = message

    submitFormForPlayer( data, "bug-report", ply )
end

local function submitPlayerReport( len, ply )
    local reportedSteamID = net.ReadString()
    local urgency = net.ReadString()
    local message = net.ReadString()

    local data = {}
    data["steam_id"] = ply:SteamID()
    data["steam_name"] = ply:GetName()
    data["reported_steam_id"] = reportedSteamID
    data["reported_steam_name"] = player.GetBySteamID( reportedSteamID ):GetName()
    data["urgency"] = urgency
    data["message"] = message

    submitFormForPlayer( data, "player-report", ply )
end

local function submitStaffReport( len, ply )
    local reportedSteamID = net.ReadString()
    local urgency = net.ReadString()
    local message = net.ReadString()

    local data = {}
    data["reported_steam_id"] = reportedSteamID
    data["reported_steam_name"] = player.GetBySteamID( reportedSteamID ):GetName()
    data["urgency"] = urgency
    data["message"] = message

    submitFormForPlayer( data, "staff-report", ply )
end

local function submitFreezeReport( len, ply )
    local severity = net.ReadString()
    local message = net.ReadString()

    local data = {}
    data["steam_id"] = ply:SteamID()
    data["steam_name"] = ply:GetName()
    data["debug_information"] = getDebugInformation()
    data["severity"] = severity
    data["message"] = message

    submitFormForPlayer( data, "freeze-report", ply )
end

net.Receive( "CFC_SubmitContactForm", submitContactForm )
net.Receive( "CFC_SubmitFeedbackForm", submitFeedbackForm )
net.Receive( "CFC_SubmitBugReport", submitBugReport )
net.Receive( "CFC_SubmitPlayerReport", submitPlayerReport )
net.Receive( "CFC_SubmitFreezeReport", submitFreezeReport )
net.Receive( "CFC_SubmitStaffReport", submitStaffReport )
