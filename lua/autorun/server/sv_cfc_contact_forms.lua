util.AddNetworkString( 'CFC_SubmitContactForm' )

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
    data['steam-id'] = ply:SteamId()
    data['contact_method'] = contactMethod
    data['message'] = message

    submitForm( data, 'contact' )
end

net_receive( 'CFC_SubmitContactForm', submitContactForm )
