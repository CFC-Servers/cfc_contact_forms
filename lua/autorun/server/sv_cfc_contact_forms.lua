util.AddNetworkString( 'CFC_SubmitContactForm' )
util.AddNetworkString( 'CFC_SubmitFeedbackForm' )
util.AddNetworkString( 'CFC_SubmitBugReport' )
util.AddNetworkString( 'CFC_SubmitPlayerReport' )
util.AddNetworkString( 'CFC_SubmitStaffReport' )

local FORM_PROCESSOR_URL = file.Read( 'cfc/contact/url.txt', 'DATA' )
FORM_PROCESSOR_URL = string.Replace( FORM_PROCESSOR_URL, '\r', '' )
FORM_PROCESSOR_URL = string.Replace( FORM_PROCESSOR_URL, '\n', '' )

local SUBMISSION_GROOM_INTERVAL = 60

local playerSubmissionCounts = {}

local function serverLog( message )
    local prefix = '[CFC Contact Forms] '
    print( prefix .. message )
end

local function alertPlayer( ply, message )
  local prefix = '[CFC Contact Forms] '
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
timer.Create( 'CFC_GroomFormSubmissions', SUBMISSION_GROOM_INTERVAL, 0, groomSubmissionCounts )

local function recordPlayerSubmission( ply )
    local count = playerSubmissionCounts[ply] or 0

    playerSubmissionCounts[ply] = count + 1
end

local function playerCanSubmit( ply )
    return ( playerSubmissionCounts[ply] or 0 ) < 3
end

local function submitFormForPlayer( data, endpoint, ply )
    local plyName = ply and ply:GetName() or 'Unknown Player'

    data['realm'] = 'CFC3'

    serverLog( 'Sending request for <' .. plyName .. '> with form data: ' )
    PrintTable( data )

    if not playerCanSubmit( ply ) then return alertPlayer( ply, 'You\'re doing that too much! Please wait or reach out on our discord' ) end

    local url = FORM_PROCESSOR_URL ..  endpoint
    http.Post( url, data,
        function( success )
            print( success )
        end,
        function( failure )
            serverLog( 'Request failed with data:' )
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
    data['steam_id'] = ply:SteamID()
    data['steam_name'] = ply:GetName()
    data['contact_method'] = contactMethod
    data['message'] = message

    submitFormForPlayer( data, 'contact', ply )
end

local function submitFeedbackForm( len, ply )
    local rating = net.ReadString()
    local likelyToReturn = net.ReadString()
    local message = net.ReadString()

    local data = {}
    data['steam_id'] = ply:SteamID()
    data['steam_name'] = ply:GetName()
    data['rating'] = rating
    data['likely_to_return'] = likelyToReturn
    data['message'] = message

    submitFormForPlayer( data, 'feedback', ply )
end

local function submitBugReport( len, ply )
    local urgency = net.ReadString()
    local message = net.ReadString()

    local data = {}
    data['steam_id'] = ply:SteamID()
    data['steam_name'] = ply:GetName()
    data['urgency'] = urgency
    data['message'] = message

    submitFormForPlayer( data, 'bug-report', ply )
end

local function submitPlayerReport( len, ply )
    local reportedSteamID = net.ReadString()
    local urgency = net.ReadString()
    local message = net.ReadString()

    local data = {}
    data['steam_id'] = ply:SteamID()
    data['steam_name'] = ply:GetName()
    data['reported_steam_id'] = reportedSteamID
    data['reported_steam_name'] = player.GetBySteamID( reportedSteamID ):GetName()
    data['urgency'] = urgency
    data['message'] = message

    submitFormForPlayer( data, 'player-report', ply )
end

local function submitStaffReport( len, ply )
    local reportedSteamID = net.ReadString()
    local urgency = net.ReadString()
    local message = net.ReadString()

    local data = {}
    data['reported_steam_id'] = reportedSteamID
    data['reported_steam_name'] = player.GetBySteamID( reportedSteamID ):GetName()
    data['urgency'] = urgency
    data['message'] = message

    submitFormForPlayer( data, 'staff-report', ply )
end

net.Receive( 'CFC_SubmitContactForm', submitContactForm )
net.Receive( 'CFC_SubmitFeedbackForm', submitFeedbackForm )
net.Receive( 'CFC_SubmitBugReport', submitBugReport )
net.Receive( 'CFC_SubmitPlayerReport', submitPlayerReport )
net.Receive( 'CFC_SubmitStaffReport', submitStaffReport )
