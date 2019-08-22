util.AddNetworkString( 'CFC_SubmitContactForm' )
util.AddNetworkString( 'CFC_SubmitFeedbackForm' )
util.AddNetworkString( 'CFC_SubmitBugReport' )
util.AddNetworkString( 'CFC_SubmitPlayerReport' )

local FORM_PROCESSOR_URL = file.Read( "cfc/contact/url.txt", "DATA" )
FORM_PROCESSOR_URL = string.Replace(FORM_PROCESSOR_URL, "\r", "")
FORM_PROCESSOR_URL = string.Replace(FORM_PROCESSOR_URL, "\n", "")

local function submitForm( data, endpoint )
    local url = FORM_PROCESSOR_URL ..  endpoint
    http.Post( url, data, function( success ) print( success ) end, function( failure ) print( failure ) end )
end

local function submitContactForm( len, ply )
    local contactMethod = net.ReadString()
    local message = net.ReadString()

    local data = {}
    data['steam_id'] = ply:SteamID()
    data['contact_method'] = contactMethod
    data['message'] = message

    submitForm( data, 'contact' )
end

local function submitFeedback( len, ply )
    local rating = net.ReadString()
    local likelyToReturn = net.ReadString()
    local message = net.ReadString()

    local data = {}
    data['steam_id'] = ply:SteamID()
    data['rating'] = rating
    data['likelyToReturn'] = likelyToReturn
    data['message'] = message

    submitForm( data, 'feedback' )
end

local function submitBugReport( len, ply )
    local urgency = net.ReadString()
    local message = net.ReadString()

    local data = {}
    data['steam_id'] = ply:SteamID()
    data['urgency'] = urgency
    data['message'] = message

    submitForm( data, 'bug-report' )
end

local function submitPlayerReport( len, ply )
    local reportedSteamID = net.ReadString()
    local urgency = net.ReadString()
    local message = net.ReadString()

    local data = {}
    data['steam_id'] = ply:SteamID()
    data['reported_steam_id'] = reportedSteamID
    data['urgency'] = urgency
    data['message'] = message

    submitForm( data, 'player-report' )
end

net.Receive( 'CFC_SubmitContactForm', submitContactForm )
net.Receive( 'CFC_SubmitFeedbackForm', submitFeedbackForm )
net.Receive( 'CFC_SubmitBugReport', submitBugReport )
net.Receive( 'CFC_SubmitPlayerReport', submitPlayerReport )
