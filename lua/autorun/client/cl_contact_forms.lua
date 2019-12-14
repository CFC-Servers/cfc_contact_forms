local Frame = nil

local function makeFormButton( text, callback, parent )
    local Button = vgui.Create( "DButton", parent )

    Button:SetFont( "Trebuchet24" )
    Button:SetTextColor( Color( 255, 255, 255 ) )
    Button:Dock( TOP )
    Button:DockMargin( 0, 0, 0, 25 )
    Button:SetText( text )

    local parentX = parent:GetSize()
    local desiredSizeX = parentX * 0.8

    Button:SetSize( desiredSizeX, 30 )

    Button.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 0 ) )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.DrawOutlinedRect( 0, 0, w, h )
    end

    Button.DoClick = callback

    return Button
end

FORM_TYPE_TO_NETSTRING = {
    [ "contact" ] = "CFC_SubmitContactForm",
    [ "feedback" ] = "CFC_SubmitFeedbackForm",
    [ "bug-report" ] = "CFC_SubmitBugReport",
    [ "player-report" ] = "CFC_SubmitPlayerReport",
    [ "staff-report" ] = "CFC_SubmitStaffReport"
}

local function formImage( imageBase, shouldGrayscale )
    local path = "vgui/cfc/forms/"
    local grayscale = shouldGrayscale and "_grayscale" or ""

    return path .. imageBase .. grayscale .. ".png"
end

local function processFieldsForForm( fields, formData )
    local formType = formData.formType
    local netstring = FORM_TYPE_TO_NETSTRING[formType]

    net.Start( netstring )
        for _, fieldStruct in pairs( fields ) do
            local field = fieldStruct.field

            print( "Sending '" .. fieldStruct.name .. "' to the server .. " )
            net.WriteString( field:GetValue() )
        end
    net.SendToServer()
end

local function makeLabel( text, parent )
    local StagingLabel = vgui.Create( "DLabel", parent )
    StagingLabel:SetVerticalScrollbarEnabled( false )
    StagingLabel:SetHeight( 50 )
    StagingLabel:SetContentAlignment( 1 )
    StagingLabel:SetText( text )
    StagingLabel:Dock( TOP )
    StagingLabel:DockMargin( 0, 0, 0, 15 )
    StagingLabel:SetMultiline( true )

    function StagingLabel:PerformLayout()
        StagingLabel:SetFGColor( Color( 255, 255, 255, 255 ) )
        StagingLabel:SetFontInternal( "Trebuchet24" )
        StagingLabel:SetToFullHeight()
    end

    StagingLabel:SetWrap( true )

    return StagingLabel
end

local function makeHeader( text, parent )
    local StagingHeader = makeLabel( text, parent )
    StagingHeader:SetHeight( 100 )
    StagingHeader:SetContentAlignment( 5 )
    StagingHeader:Dock( TOP )
    StagingHeader:DockMargin( 0, 0, 0, 0 )
    StagingHeader:Center()

    function StagingHeader:PerformLayout()
        StagingHeader:SetFGColor( Color( 255, 255, 255, 255 ) )
        StagingHeader:SetFontInternal( "Trebuchet24" )
        StagingHeader:SetToFullHeight()
    end

    return StagingHeader
end

surface.CreateFont( "CFCFormTitle", {
    font = "DermaLarge",
    size = 56
} )

local function makeTitle( text, parent )
    local Title = vgui.Create( "DLabel", parent )
    Title:SetVerticalScrollbarEnabled( false )
    Title:SetHeight( 80 )
    Title:SetText( text )
    Title:SetContentAlignment( 5 )
    Title:SetWrap( false )
    Title:Dock( TOP )
    Title:DockMargin( 0, 10, 0, 30 )

    function Title:PerformLayout( w1, w2 )
        Title:SetFGColor( Color( 255, 255, 255, 255 ) )
        Title:SetFontInternal( "CFCFormTitle" )
        Title:SetToFullHeight()
    end

    return Title
end

local function makeTextField( question, parent )
    local query = question.query
    makeLabel( query, parent )

    local TextFieldContainer = vgui.Create( "DPanel", parent )
    TextFieldContainer:Dock( TOP )
    TextFieldContainer:DockMargin( 0, 15, 0, 0 )
    TextFieldContainer:SetHeight( 200 )

    function TextFieldContainer:Paint( w, h )
        surface.SetDrawColor( Color( 44, 48, 74 ) )
        surface.DrawRect( 0, 0, w, h )
    end

    local TextField = vgui.Create( "DTextEntry", TextFieldContainer )
    TextField:Dock( FILL )
    TextField:SetMultiline( true )
    TextField:SetWrap( true )
    TextField:SetTextColor( Color( 255, 255, 255, 255 ) )
    TextField:SetCursorColor( Color( 255, 255, 255 ) )
    TextField:SetFont( "Trebuchet24" )

    TextField:SetUpdateOnType( true )
    TextField:SetPaintBackgroundEnabled( false )
    TextField.m_bBackground = false

    return TextField
end

local function makeBooleanField( question, parent )
    local query = question.query
    makeLabel( query, parent )

    local ButtonPanel = vgui.Create( "DPanel", parent )
    ButtonPanel:Dock( TOP )
    ButtonPanel:SetHeight( 40 )
    ButtonPanel:SetBackgroundColor( Color( 0, 0, 0, 0 ) )
    ButtonPanel.selectedValue = nil
    ButtonPanel.GetValue = function()
        return ButtonPanel.selectedValue
    end

    local YesButton = nil
    local NoButton = nil

    -- Yes Button
    YesButton = vgui.Create( "DImageButton", ButtonPanel )
    YesButton:SetSize( 40, 40 )
    YesButton:SetImage( formImage( "radio" ) )
    YesButton:Dock( LEFT )
    YesButton.DoClick = function()
        ButtonPanel.selectedValue = "yes"
        YesButton:SetImage( formImage( "radio-filled" ) )
        NoButton:SetImage( formImage( "radio" ) )
    end
    ---

    -- Yes Label
    local YesLabel = vgui.Create( "DLabel", ButtonPanel )
    YesLabel:SetVerticalScrollbarEnabled( false )
    YesLabel:SetHeight( 40 )
    YesLabel:SetText( "Yes" )
    YesLabel:Dock( LEFT )
    YesLabel:DockMargin( 15, 0, 0, 0 )
    function YesLabel:PerformLayout()
        YesLabel:SetFGColor( Color( 255, 255, 255, 255 ) )
        YesLabel:SetFontInternal( "Trebuchet24" )
        YesLabel:SetToFullHeight()
    end
    ---

    -- No Button
    NoButton = vgui.Create( "DImageButton", ButtonPanel )
    NoButton:SetSize( 40, 40 )
    NoButton:SetImage( formImage( "radio" ) )
    NoButton:Dock( LEFT )
    NoButton.DoClick = function()
        ButtonPanel.selectedValue = "no"
        NoButton:SetImage( formImage( "radio-filled" ) )
        YesButton:SetImage( formImage( "radio" ) )
    end
    ---

    -- No Label
    local NoLabel = vgui.Create( "DLabel", ButtonPanel )
    NoLabel:SetVerticalScrollbarEnabled( false )
    NoLabel:SetHeight( 40 )
    NoLabel:SetText( "No" )
    NoLabel:Dock( LEFT )
    NoLabel:DockMargin( 15, 0, 0, 0 )
    function NoLabel:PerformLayout()
        NoLabel:SetFGColor( Color( 255, 255, 255, 255 ) )
        NoLabel:SetFontInternal( "Trebuchet24" )
        NoLabel:SetToFullHeight()
    end
    ---

    return ButtonPanel
end

local function makePlayerDropdownField( question, parent, givenPlayers )
    local query = question.query
    makeLabel( query, parent )

    local ComboBox = vgui.Create( "DComboBox", parent )
    ComboBox:Dock( TOP )

    for _, ply in pairs( givenPlayers ) do
        if ply ~= LocalPlayer() then
            ComboBox:AddChoice( ply:GetName(), ply:SteamID() )
        end
    end

    ComboBox.GetValue = function()
        local _, data = ComboBox:GetSelected()
        return data
    end


    return ComboBox
end

local function makeAllPlayerDropdownField( question, parent )
    local plys = {}
    for _, ply in pairs( player.GetAll() ) do
        if ply ~= LocalPlayer() then table.insert( plys, ply ) end
    end

    return makePlayerDropdownField( question, parent, plys )
end

local function makeStaffDropDownField( question, parent )
    local plys = {}

    local isStaff = {
        ["sentinel"] = true,
        ["moderator"] = true,
        ["admin"] = true,
        ["owner"] = true
    }

    for _, ply in pairs( player.GetAll() ) do
        if isStaff[ply:GetUserGroup()] then table.insert( plys, ply ) end
    end

    return makePlayerDropdownField( question, parent, plys )
end

local function makeSlidingScaleField( question, parent, imageBase )
    local query = question.query
    makeLabel( query, parent )

    local ButtonPanel = vgui.Create( "DPanel", parent )
    ButtonPanel:Dock( TOP )
    ButtonPanel:SetHeight( 60 )
    ButtonPanel:SetBackgroundColor( Color( 0, 0, 0, 0 ) )
    ButtonPanel.selectedValue = nil
    ButtonPanel.GetValue = function()
        return ButtonPanel.selectedValue
    end

    for i = 1, 5 do
        local outerBackupLabel = "Select: " .. i
        local Button = vgui.Create( "DImageButton", ButtonPanel )
        Button:SetSize( 60, 60 )
        Button:SetImage( formImage( imageBase, true ), outerBackupLabel )
        Button:DockMargin( 0, 0, 5, 0 )
        Button:Dock( LEFT )
        Button.DoClick = function()
            ButtonPanel.selectedValue = i

            local buttons = ButtonPanel:GetChildren()

            for x = 1, 5 do
                local backupLabel = "Select: " .. x
                local InfantButton = buttons[x]

                local grayscale = x > i

                local image = formImage( imageBase, grayscale )

                if InfantButton:GetImage() ~= image then
                    InfantButton:SetImage( image, backupLabel )
                end
            end
        end
    end

    return ButtonPanel
end

local function makeUrgencyField( question, parent )
    return makeSlidingScaleField( question, parent, "fire" )
end

local function makeRatingField( question, parent )
    return makeSlidingScaleField( question, parent, "star" )
end

local function makeFormField( ... )
    local args = { ... }
    local question = args[1]
    local fieldType = question.fieldType

    if fieldType == "text" then
        return makeTextField( ... )
    end

    if fieldType == "boolean" then
        return makeBooleanField( ... )
    end

    if fieldType == "player-dropdown" then
        return makeAllPlayerDropdownField( ... )
    end

    if fieldType == "staff-dropdown" then
        return makeStaffDropDownField( ... )
    end

    if fieldType == "urgency" then
        return makeUrgencyField( ... )
    end

    if fieldType == "rating" then
        return makeRatingField( ... )
    end

    print( "Not sure what to do with this field type! :" .. fieldType or "nil" )
end

local function makeFormErrorAlert( parent )
    local Alert = vgui.Create( "DLabel", parent )
    Alert:SetFont( "Trebuchet24" )
    Alert:SetText( "Please fill out all of the fields!" )
    Alert:SetTextColor( Color( 255, 0, 0 ) )
    Alert:SetVerticalScrollbarEnabled( false )
    Alert:SetHeight( 60 )
    Alert:SetContentAlignment( 5 )
    Alert:SetWrap( false )

    Alert:Dock( TOP )
    Alert:DockMargin( 0, 0, 0, 0 )

    -- Defaults to invisible
    Alert:SetAlpha( 0 )

    return Alert
end

local function fieldsAreValid( fields )
    for _, fieldStruct in pairs( fields ) do
        local field = fieldStruct.field

        local value = field:GetValue()

        if not value then return false end
        if value == "" then return false end
    end

    return true
end

local function openForm( formData )
    Frame:Close()

    local containerWidth = ScrW() * 0.52
    local containerHeight = ScrH() * 0.93

    local FormContainer = vgui.Create( "DFrame" )
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

    local BackButton = vgui.Create( "DImageButton", FormContainer )
    BackButton:SetSize( 32, 32 )

    local backPosX = containerWidth * 0.02
    local backPosY = containerHeight * 0.02
    BackButton:SetPos( backPosX, backPosY )

    BackButton:SetImage( formImage( "back-button" ), "Back" )
    BackButton.DoClick = function()
        -- local closeDuration = 0.5
        -- local closeSteps = 33
        -- local closeStep = 1

        -- timer.Create( "CFC_FadeOutForm", closeDuration / closeSteps, closeSteps, function()
        --    local newAlpha =  0 * math.pow( 5, 10 * ( closeStep / closeSteps - 1 ) ) + 255;
        --    print( newAlpha )
        --    Form:SetAlpha( newAlpha )

        --    closeStep = closeStep + 1
        -- end )

        -- timer.Create( "CFC_DelayCloseForm", closeDuration, 1, function()
            FormContainer:Close()
            CFCContactForms.openForms()
            timer.Remove( "CFC_FadeInForm" )
            timer.Remove( "CFC_FadeOutForm" )
            timer.Remove( "CFC_DelayCloseForm" )
        -- end )
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

    makeTitle( formData.title, Form )

    local headerTextStruct = formData.headerText
    local headerTextContent = table.concat( headerTextStruct, "\n" )

    makeHeader( headerTextContent, Form )

    local FormAlert = makeFormErrorAlert( Form )

    local fields = {}

    for i, question in pairs( formData.questions ) do
        local Field = makeFormField( question, Form )

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

    SubmitButton.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 0 ) )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.DrawOutlinedRect( 0, 0, w, h )
    end

    SubmitButton.DoClick = function()
        if fieldsAreValid( fields ) then
            processFieldsForForm( fields, formData )
            FormContainer:Close()

            notification.AddLegacy( "Thanks for your form submission!", NOTIFY_UNDO, 5 )
        else
            FormAlert:SetAlpha( 255 )
        end
    end

end

local function openContactForm()
    local formData = {}
    formData.title = "Contact"
    formData.formType = "contact"

    formData.headerText = {
        "We'd love to hear from you! Just tell us how we can get in touch with you, and a brief description of your question/comment/concern and we'll get back to you ASAP!"
    }

    local questions = {}

    local contactMethod = {}
    contactMethod.query = "What is your preferred contact method?"
    contactMethod.name = "contact_method"
    contactMethod.fieldType = "text"
    table.insert( questions, contactMethod )

    local message = {}
    message.query = "What would you like to say?"
    message.name = "message"
    message.fieldType = "text"
    table.insert( questions, message )

    formData.questions = questions

    openForm( formData )
end

local function openFeedbackForm()
    local formData = {}
    formData.title = "Feedback"
    formData.formType = "feedback"

    formData.headerText = {
        "We thrive on your feedback! Please let us know what you think, we're always trying to improve your experience.",
        "Be sure to let us know if you have any suggestions for how we can do better!"
    }

    local questions = {}

    local rating = {}
    rating.query = "How would you rate your experience with our server?"
    rating.name = "rating"
    rating.fieldType = "rating"
    table.insert( questions, rating )

    local likelyToReturn = {}
    likelyToReturn.query = "Based on your experiences so far, are you likely to visit our server again within the next two weeks?"
    likelyToReturn.name = "likely_to_return"
    likelyToReturn.fieldType = "boolean"
    table.insert( questions, likelyToReturn )

    local message = {}
    message.query = "What would you like to say?"
    message.name = "message"
    message.fieldType = "text"
    table.insert( questions, message )

    formData.questions = questions

    openForm( formData )
end

local function openBugReportForm()
    local formData = {}
    formData.title = "Bug Report"
    formData.formType = "bug-report"

    formData.headerText = {
        "Uh oh! Have you experienced something unsavory, or otherwise unexpected?",
        "Please tell us about it - we have a team of dedicated developers who love squashing bugs!"
    }

    local questions = {}

    local urgency = {}
    urgency.query = "How urgent is this bug?"
    urgency.name = "urgency"
    urgency.fieldType = "urgency"
    table.insert( questions, urgency )

    local message = {}
    message.query = "Please describe the bug in detail. Please tell us how we can re-create the issue."
    message.name = "message"
    message.fieldType = "text"
    table.insert( questions, message )

    formData.questions = questions

    openForm( formData )
end

local function openPlayerReportForm()
    local formData = {}
    formData.title = "Player Report"
    formData.formType = "player-report"

    formData.headerText = {
        "Is a player ruining the experience of others?",
        "Tell us about it! Our staff will receive this report immediately and will take action as soon as they can.",
        "Please, only one player per report!"
    }

    local questions = {}

    local reportedPlayer = {}
    reportedPlayer.query = "Please select the player you wish to report."
    reportedPlayer.name = "reportedPlayer"
    reportedPlayer.fieldType = "player-dropdown"
    table.insert( questions, reportedPlayer )

    local urgency = {}
    urgency.query = "How urgent is this situation?"
    urgency.name = "urgency"
    urgency.fieldType = "urgency"
    table.insert( questions, urgency )

    local message = {}
    message.query = "Please describe the situation in detail. If you've gathered some, please share links containing evidence of wrongdoing."
    message.name = "message"
    message.fieldType = "text"
    table.insert( questions, message )

    formData.questions = questions

    openForm( formData )
end

local function openStaffReportForm()
    local formData = {}
    formData.title = "Staff Report"
    formData.formType = "staff-report"

    formData.headerText = {
        "Is a staff member breaking the rules?",
        "You can report them anonymously so that we can take action as fast as possible!",
        "Please, only one staff member per report!"
    }

    local questions = {}

    local reportedStaff = {}
    reportedStaff.query = "Please select the staff member you wish to report."
    reportedStaff.name = "reportedPlayer"
    reportedStaff.fieldType = "staff-dropdown"
    table.insert( questions, reportedStaff )

    local urgency = {}
    urgency.query = "How urgent is this situation?"
    urgency.name = "urgency"
    urgency.fieldType = "urgency"
    table.insert( questions, urgency )

    local message = {}
    message.query = "Please describe the situation in detail. If you've gathered some, please share links containing evidence of wrongdoing."
    message.name = "message"
    message.fieldType = "text"
    table.insert( questions, message )

    formData.questions = questions

    openForm( formData )
end

CFCContactForms = CFCContactForms or {}

CFCContactForms.openForms = function()
    local x = 400
    local y = 500

    Frame = vgui.Create( "DFrame" )
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

    makeFormButton( "Contact", openContactForm, Pane )
    makeFormButton( "Feedback", openFeedbackForm, Pane )
    makeFormButton( "Bug Report", openBugReportForm, Pane )
    makeFormButton( "Player Report", openPlayerReportForm, Pane )
    makeFormButton( "Staff Report", openStaffReportForm, Pane )
end

concommand.Add( "cfc_forms", CFCContactForms.openForms )
