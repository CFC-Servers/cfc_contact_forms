require( "logger" )

util.AddNetworkString( "CFC_SubmitContactForm" )
util.AddNetworkString( "CFC_SubmitFeedbackForm" )
util.AddNetworkString( "CFC_SubmitBugReport" )
util.AddNetworkString( "CFC_SubmitPlayerReport" )
util.AddNetworkString( "CFC_SubmitFreezeReport" )
util.AddNetworkString( "CFC_SubmitStaffReport" )
util.AddNetworkString( "CFC_ContactForms_SuccessAlert" )
util.AddNetworkString( "CFC_ContactForms_FailureAlert" )
util.AddNetworkString( "CFC_ContactForms_Alert" )

local logger = Logger( "CFC Contact Forms" )

local realm = CreateConVar( "cfc_realm", "unknown", FCVAR_REPLICATED + FCVAR_ARCHIVE, "The Realm Name" )
local processorUrl = CreateConVar( "cfc_contact_forms_url", "", FCVAR_ARCHIVE + FCVAR_PROTECTED, "Form Processor URL" )
local staffRanks = { moderator = true }

local playerCounts = {}

local function alertPlayer( ply, message )
  local prefix = "[CFC Contact Forms] "
  ply:ChatPrint( prefix .. message )
end

local function groomSubmissionCounts()
    for ply, submissionCount in pairs( playerCounts ) do
        if submissionCount == 1 then
            playerCounts[ply] = nil
        else
            playerCounts[ply] = submissionCount - 1
        end
    end
end
timer.Create( "CFC_GroomFormSubmissions", 60, 0, groomSubmissionCounts )


local function recordPlayerSubmission( ply )
    local count = playerCounts[ply] or 0

    playerCounts[ply] = count + 1
end

local function playerCanSubmit( ply )
    return ( playerCounts[ply] or 0 ) < 3
end

local function sendSuccessAlert( ply )
    if not IsValid( ply ) then return end

    net.Start( "CFC_ContactForms_SuccessAlert" )
    net.Send( ply )
end

local function sendFailureAlert( ply )
    if not IsValid( ply ) then return end

    net.Start( "CFC_ContactForms_FailureAlert" )
    net.Send( ply )
end

local function submitFormForPlayer( data, endpoint, formSubmitter )
    local submitterName = formSubmitter and formSubmitter:GetName() or "Unknown Player"

    data["realm"] = realm:GetString()

    logger:info( "Sending request for <" .. submitterName .. "> with form data: " )
    PrintTable( data )

    if not playerCanSubmit( formSubmitter ) then
        return alertPlayer( formSubmitter, "You're doing that too much! Please wait or reach out on our discord" )
    end

    local url = processorUrl:GetString() ..  endpoint
    http.Post( url, data,
        function( success )
            logger:info( success )
            sendSuccessAlert( formSubmitter )
        end,

        function( failure )
            sendFailureAlert( formSubmitter )
            logger:warn( "Request failed with data:" )
            PrintTable( data )
            logger:warn( failure )
        end
    )

    recordPlayerSubmission( formSubmitter )

    if endpoint ~= "player-report" then return end

    for _, ply in ipairs( player.GetHumans() ) do
        if ply:IsAdmin() or staffRanks[ply:GetUserGroup()] then
            net.Start( "CFC_ContactForms_Alert" )
            net.WriteTable( data ) -- writes the report data
            net.Send( ply )
        end
    end
end


local Forms = include( "forms.lua" )( submitFormForPlayer )
net.Receive( "CFC_SubmitContactForm", Forms.Contact )
net.Receive( "CFC_SubmitFeedbackForm", Forms.Feedback )
net.Receive( "CFC_SubmitBugReport", Forms.BugReport )
net.Receive( "CFC_SubmitPlayerReport", Forms.PlayerReport )
net.Receive( "CFC_SubmitFreezeReport", Forms.FreezeReport )
net.Receive( "CFC_SubmitStaffReport", Forms.StaffReport )
