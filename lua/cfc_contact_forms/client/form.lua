local Elements = CFCContactForms.Elements
local Fields = CFCContactForms.Fields

local TrackEvent = function( ... )
    if not Mixpanel then return end
    Mixpanel:TrackEvent( ... )
end

local Helpers = {
    FORM_TYPE_TO_NETSTRING = {
        [ "contact" ] = "CFC_SubmitContactForm",
        [ "feedback" ] = "CFC_SubmitFeedbackForm",
        [ "bug-report" ] = "CFC_SubmitBugReport",
        [ "player-report" ] = "CFC_SubmitPlayerReport",
        [ "freeze-report" ] = "CFC_SubmitFreezeReport",
        [ "staff-report" ] = "CFC_SubmitStaffReport"
    },

    formImage = function( imageBase, shouldGrayscale )
        local path = "vgui/cfc/forms/"
        local grayscale = shouldGrayscale and "_grayscale" or ""

        return path .. imageBase .. grayscale .. ".png"
    end,

    ProcessFields = function( self, fields, formData )
        local formType = formData.formType
        local netstring = self.FORM_TYPE_TO_NETSTRING[formType]

        net.Start( netstring )
            for _, fieldStruct in pairs( fields ) do
                local field = fieldStruct.field
                PrintTable( fieldStruct )

                print( "Sending '" .. fieldStruct.name .. "/" .. "' to the server .. " )
                if fieldStruct.name == "image" then
                    print( "Sending image..." )
                    local dataSize = #field:GetValue()
                    print( "Image size: ", dataSize )

                    net.WriteUInt( dataSize, 32 )
                    net.WriteData( field:GetValue(), dataSize )
                else
                    net.WriteString( field:GetValue() )
                end
            end
        net.SendToServer()
    end,

    FieldsAreValid = function( fields )
        for _, fieldStruct in pairs( fields ) do
            local field = fieldStruct.field

            local value = field:GetValue()

            if not value then return false end
            if value == "" then return false end
        end

        return true
    end
}


return function( formData )
    TrackEvent( "Player opened '" .. formData.formType .. "' form" )

    local Frame = CFCContactForms.Frame
    if IsValid( Frame ) then Frame:Close() end

    local containerWidth = ScrW() * 0.52
    local containerHeight = ScrH() * 0.93

    CFCContactForms.FormContainer = vgui.Create( "DFrame" )
    local FormContainer = CFCContactForms.FormContainer
    FormContainer:SetTitle( "" )
    FormContainer:SetSize( containerWidth, containerHeight )
    FormContainer:Center()
    FormContainer:MakePopup()

    local paddingLeft = ( containerWidth * 0.05 ) / 2
    local paddingRight = paddingLeft

    local paddingTop = ( containerHeight * 0.03 ) / 2
    local paddingBottom = paddingTop

    FormContainer:DockPadding( paddingLeft, paddingTop, paddingRight, paddingBottom )

    function FormContainer:Init()
        self.startTime = SysTime()
    end

    FormContainer.Paint = function( self )
        Derma_DrawBackgroundBlur( self, self.startTime )
        draw.RoundedBox( 8, 0, 0, containerWidth, containerHeight, Color( 36, 41, 67, 255 ) )
    end

    -- Needed for the timers to fade the form out
    local Form = nil
    local fields = {}

    local BackButton = vgui.Create( "DImageButton", FormContainer )
    BackButton:SetSize( 32, 32 )

    local backPosX = containerWidth * 0.02
    local backPosY = containerHeight * 0.02
    BackButton:SetPos( backPosX, backPosY )

    BackButton:SetImage( Helpers.formImage( "back-button" ), "Back" )
    BackButton.DoClick = function()
        FormContainer:Close()
        CFCContactForms.openForms()
        timer.Remove( "CFC_FadeInForm" )
        timer.Remove( "CFC_FadeOutForm" )
        timer.Remove( "CFC_DelayCloseForm" )

        local currentData = {}
        for _, fieldStruct in pairs( fields ) do
            currentData[fieldStruct.name] = fieldStruct.field:GetValue() or "<empty>"
        end

        TrackEvent(
            "Player backed out of '" .. formData.formType .. "' form",
            { currentData = currentData }
        )
    end

    Form = vgui.Create( "DScrollPanel", FormContainer )
    Form:SetBackgroundColor( Color( 36, 41, 67, 255 ) )
    Form:Center()
    Form:Dock( FILL )

    local backButtonTopMargin = ScrH() * 0.05

    Form:DockMargin( 0, backButtonTopMargin, 0, 0 )
    Form:Center()
    Form:SetAlpha( 0 )

    -- Transition
    local duration = 1
    local steps = 33

    local step = 1

    timer.Create( "CFC_FadeInForm", duration / steps, steps, function()
        local newAlpha =  255 * math.pow( 5, 10 * ( step / steps - 1 ) );
        Form:SetAlpha( newAlpha )

        step = step + 1
    end )

    function FormContainer:OnClose()
        timer.Remove( "CFC_FadeInForm" )
        timer.Remove( "CFC_FadeOutForm" )
        timer.Remove( "CFC_DelayCloseForm" )
    end
    --

    Elements.Title( formData.title, Form )

    local headerTextStruct = formData.headerText
    local headerTextContent = table.concat( headerTextStruct, "\n" )

    Elements.Header( headerTextContent, Form )

    local FormAlert = Elements.ErrorAlert( Form )

    for _, question in pairs( formData.questions ) do
        local Field = Fields:FormField( question, Form )

        local bottomMargin = ScrH() * 0.025
        Field:DockMargin( 0, 0, 0, bottomMargin )

        local fieldStruct = {}
        fieldStruct.name = question.name
        fieldStruct.field = Field

        table.insert( fields, fieldStruct )
    end

    local SubmitButton = vgui.Create( "DButton", Form )
    SubmitButton:Dock( TOP )
    SubmitButton:SetText( "Submit" )
    SubmitButton:SetTextColor( Color( 255, 255, 255 ) )
    SubmitButton:SetFont( "Trebuchet24" )

    local submitHeight = ScrH() * 0.06
    SubmitButton:SetHeight( submitHeight )

    SubmitButton.Paint = function( _, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 0 ) )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.DrawOutlinedRect( 0, 0, w, h )
    end

    SubmitButton.DoClick = function()
        if Helpers.FieldsAreValid( fields ) then
            Helpers:ProcessFields( fields, formData )

            SubmitButton:SetText( "Sending..." )
            SubmitButton.DoClick = function() end
            SubmitButton:SetDisabled( true )

            TrackEvent( "Player submitted '" .. formData.formType .. "' form" )
        else
            FormAlert:SetAlpha( 255 )
            TrackEvent( "Player submitted invalid '" .. formData.formType .. "' form" )
        end
    end
end
