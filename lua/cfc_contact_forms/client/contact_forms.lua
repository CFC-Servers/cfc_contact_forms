ProtectedCall( function()
    require( "mixpanel" )
end )

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

CFCContactForms.openForms = function()
    local x = 400
    local y = 585

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

    Pane = vgui.Create( "DPanel", Frame )
    Pane:SetBackgroundColor( Color( 36, 41, 67, 255 ) )
    Pane:DockPadding( 30, 15, 30, 0 )
    Pane:Dock( FILL )
    Pane:Center()

    Elements.FormButton( "Contact", Forms.Contact, Pane )
    Elements.FormButton( "Feedback", Forms.Feedback, Pane )
    Elements.FormButton( "Bug Report", Forms.BugReport, Pane )
    Elements.FormButton( "Player Report", Forms.PlayerReport, Pane )
    Elements.FormButton( "Freeze Report", Forms.FreezeReport, Pane )
    Elements.FormButton( "Staff Report", Forms.StaffReport, Pane )
end
concommand.Add( "cfc_forms", CFCContactForms.openForms )

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
