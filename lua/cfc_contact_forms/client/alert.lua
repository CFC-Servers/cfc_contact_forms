local DARK_GRAY = Color( 41, 41, 41 )
local LIGHT_GRAY = Color( 150, 150, 150 )
local GREEN = Color( 87, 242, 135 )
local RED = Color( 237, 66, 69 )
local YELLOW = Color( 254, 231, 92 )
local BLURPLE = Color( 88, 101, 242 )

net.Receive( "CFC_ContactForms_Alert", function()
    local data = net.ReadTable()
    local reporter = player.GetBySteamID( data.steam_id )
    local reported = player.GetBySteamID( data.reported_steam_id )

    if not IsValid( reporter ) or not IsValid( reported ) then return end

    local reporterName = reporter:GetName()
    local reporterRankColor = team.GetColor( reporter:Team() )

    local reportedName = reported:GetName()
    local reportedRankColor = team.GetColor( reported:Team() )

    chat.AddText(
        reporterRankColor, reporterName,
        YELLOW, " has submitted a forms report on ",
        reportedRankColor, reportedName
    )

    LocalPlayer():PrintMessage( HUD_PRINTCENTER, reporterName .. " has submitted a forms report on " .. reportedName )

    chat.AddText(
        DARK_GRAY, "[", LIGHT_GRAY, "CFC Forms", DARK_GRAY, "] ",
        Color( 206, 206, 206 ), string.Left( data.message, 99 ),
        LIGHT_GRAY, "...\nFull message in console."
    )

    local decor = "+" .. string.rep( "-", 80 )

    -- Each field is a two-index table since string keys have an unpredictable order
    local reportDataFields = {
        { "Reporter", reporterName .. " (" .. data.steam_id .. ")" },
        { "Reported", reportedName .. " (" .. data.reported_steam_id .. ")" },
        { "Message", data.message }
    }

    MsgN( decor )

    for _, field in ipairs( reportDataFields ) do
        MsgN( "| " .. field[1] .. "\t: " .. field[2] )
    end

    MsgN( decor )
end )

local function closeForm()
    CFCContactForms.FormContainer:Close()
end

net.Receive( "CFC_ContactForms_SuccessAlert", function()
    closeForm()

    surface.PlaySound( "buttons/button5.wav" )
    chat.AddText( GREEN, "Your form was successfully forwarded to the staff team!" )
end )

net.Receive( "CFC_ContactForms_FailureAlert", function()
    closeForm()

    surface.PlaySound( "buttons/button8.wav" )
    chat.AddText(
        RED, "Something went wrong! The staff team did not receive your report.\n",
        YELLOW, "We apologize. Please reach out to us on Discord if you need immediate assistance: ",
        BLURPLE, "cfc.gg/discord\n"
    )
end )

