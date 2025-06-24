CFCContactForms = {
    Frame = {},

    IS_STAFF = {
        sentinel = true,
        moderator = true,
        admin = true,
        superadmin = true,
        developer = true,
        owner = true
    },

    openCommands = {
        contact = true,
        report = true,
        feedback = true
    },

}

local Elements = include( "elements.lua" )
CFCContactForms.Elements = Elements

local Fields = include( "fields.lua" )
CFCContactForms.Fields = Fields
CFCContactForms.Form = include( "form.lua" )

local Forms = include( "forms.lua" )
CFCContactForms.Forms = include( "forms.lua" )

include( "alert.lua" )

surface.CreateFont( "CFCFormTitle", {
    font = "DermaLarge",
    size = 56
} )

surface.CreateFont( "CFCFormAlert", {
    font = "Roboto",
    size = 20
} )

CFCContactForms.openForms = function()
    local x = 400
    local y = 585 + 75

    CFCContactForms.Frame = vgui.Create( "DFrame" )
    local Frame = CFCContactForms.Frame

    Frame:SetBackgroundBlur( true )
    Frame:SetTitle( "Contact Forms" )
    Frame:SetSize( x, y )
    Frame:Center()
    Frame:MakePopup()

    function Frame:Init()
        self.startTime = SysTime()
    end

    Frame.Paint = function( self )
        Derma_DrawBackgroundBlur( self, self.startTime )
        draw.RoundedBox( 8, 0, 0, x, y, Color( 36, 41, 67, 255 ) )
    end

    local Pane = vgui.Create( "DPanel", Frame )
    Pane:SetBackgroundColor( Color( 36, 41, 67, 255 ) )
    Pane:DockPadding( 30, 15, 30, 0 )
    Pane:Dock( FILL )
    Pane:Center()

    local Alert = vgui.Create( "DPanel", Pane )
    Alert:SetSize( x, 75 )
    Alert.Paint = function( _, w, h )
        surface.SetFont( "CFCFormAlert" )
        surface.SetTextColor( 255, 255, 0 )
        surface.SetTextPos( 0, 10 )
        surface.DrawText( "Reports have been moved to our Discord:" )

    end
    Alert:Dock( TOP )

    local DiscordLink = vgui.Create( "DLabel", Alert )
    DiscordLink:SetSize( x, 20 )
    DiscordLink:SetText( "cfc.gg/discord" )
    DiscordLink:SetFont( "CFCFormAlert" )
    DiscordLink:SetTextColor( Color( 0, 185, 185 ) )
    DiscordLink:SetMouseInputEnabled( true )
    DiscordLink:SizeToContents()

    DiscordLink:SetCursor( "hand" )
    DiscordLink:CenterVertical()
    DiscordLink:CenterHorizontal(0.40)
    DiscordLink.DoClick = function()
        print( "Opening Discord" )
        gui.OpenURL( "https://cfc.gg/discord" )
    end

    local disabled = true
    Elements.FormButton( "Contact", Forms.Contact, Pane, disabled )
    Elements.FormButton( "Feedback", Forms.Feedback, Pane )
    Elements.FormButton( "Bug Report", Forms.BugReport, Pane, disabled )
    Elements.FormButton( "Player Report", Forms.PlayerReport, Pane, disabled )
    Elements.FormButton( "Freeze Report", Forms.FreezeReport, Pane )
    Elements.FormButton( "Staff Report", Forms.StaffReport, Pane, disabled )
end

function CFCContactForms:isOpenCommand( msg )
    if string.Explode( "", msg )[1] ~= "!" then return false end

    msg = string.Replace( msg, "!", "" )

    return self.openCommands[msg] or false
end

hook.Add( "OnPlayerChat", "CFC_ContactForms_OpenFormCommand", function( ply, msg )
    if not CFCContactForms:isOpenCommand( msg ) then return end

    if ply == LocalPlayer() then
        CFCContactForms.openForms()
    end

    -- Suppress message
    return true
end )
