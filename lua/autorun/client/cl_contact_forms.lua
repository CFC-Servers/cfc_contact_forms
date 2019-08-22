local LEFT_BORDER = 10
local Frame = nil

local function makeFormButton(text, pos, callback, parent)
    local Button = vgui.Create( "DButton", parent )

    Button:SetText( text )
    Button:SetTextColor( Color( 255, 255, 255 ) )
    Button:SetPos( LEFT_BORDER + pos.x, pos.y )

    local parentX = parent:GetSize()
    local desiredSizeX = parentX - ( LEFT_BORDER * 2 )

    Button:SetSize( desiredSizeX, 30 )

    Button.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) )
    end

    Button.DoClick = callback

    return Button
end

FORM_TYPE_TO_NETSTRING = {
    [ "contact" ] = "CFC_SubmitContactForm",
    [ "feedback" ] = "CFC_SubmitFeedbackForm",
    [ "bug-report" ] = "CFC_SubmitBugReport",
    [ "player-report" ] = "CFC_SubmitPlayerReport"
}

local function processFieldsForForm( fields, formData )
    local formType = formData.formType
    local netstring = FORM_TYPE_TO_NETSTRING[formType]

    net.Start( netstring )
        for _, fieldStruct in pairs( fields ) do
            local field = fieldStruct.field
            net.WriteString( field:GetValue() )
        end
    net.SendToServer()
end

local function makeTextField( question, parent )
    local query = question.query

    local TextField = parent:TextEntry( query )

    return TextField
end

local function makeBooleanField( question, parent )
    local query = question.query

    local ComboBox = parent:ComboBox( query )
    ComboBox:AddChoice( "Yes", "yes" )
    ComboBox:AddChoice( "No", "no" )
    ComboBox.GetValue = function()
        local _, data = ComboBox:GetSelected()

        return data
    end

    return ComboBox
end

local function makePlayerDropdownField( question, parent )
    local query = question.query

    local ComboBox = parent:ComboBox( query )

    for _, ply in pairs( player.GetAll() ) do
        ComboBox:AddChoice( ply:GetName(), ply:SteamID() )
    end

    ComboBox.GetValue = function()
        local _, data = ComboBox:GetSelected()

        return data
    end

    return ComboBox
end

local function makeSlidingScaleField( question, parent )
    local query = question.query

    local min = 1
    local max = 5
    local precision = 0

    local NumSlider = parent:NumSlider( query, nil, min, max, precision)

    return NumSlider
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
        return makePlayerDropdownField( ... )
    end

    if fieldType == "urgency" then
        return makeSlidingScaleField( ... )
    end

    if fieldType == "rating" then
        return makeSlidingScaleField( ... )
    end

    print( "Not sure what to do with this field type! :" .. fieldType )
end

local function openForm( formData )
    Frame:Close()

    local containerWidth = 600
    local containerHeight = 600

    local FormContainer = vgui.Create( "DFrame" )
    FormContainer:SetTitle( formData.title )
    FormContainer:SetSize( containerWidth, containerHeight )
    FormContainer:Center()
    FormContainer:MakePopup()

    local Form = vgui.Create( "DForm", FormContainer )
    Form:DockMargin( 30, 30, 30, 30 )
    Form:SetSize( containerWidth, containerHeight  )

    local fields = {}

    for i, question in pairs( formData.questions ) do
        local field = makeFormField( question, Form )

        local fieldStruct = {}
        fieldStruct.name = question.name
        fieldStruct.field = field

        table.insert( fields, fieldStruct )
    end

    local Submit = Form:Button( "Submit" )

    Submit.DoClick = function()
        processFieldsForForm( fields, formData )
        LocalPlayer():ChatPrint("Thanks for your form submission!")

        FormContainer:Close()
    end
end

local function openContactForm()
    local formData = {}
    formData.title = "Contact Form"
    formData.formType = "contact"

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
    formData.title = "Feedback Form"
    formData.formType = "feedback"

    local questions = {}

    local rating = {}
    rating.query = "From 1 - 5, 1 being 'Terrible', and 5 being 'Terrific', how would you rate our server?"
    rating.name = "rating"
    rating.fieldType = "rating"
    table.insert( questions, rating )

    local likelyToReturn = {}
    likelyToReturn.query = "Based on your experiences so far, are you likely to visit our server again within the next two weeks?"
    likelyToReturn.name = "likely_to_return"
    rating.fieldType = "boolean"

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
    formData.title = "Bug Report Form"
    formData.formType = "bug-report"

    local questions = {}

    local urgency = {}
    urgency.query = "On a scale from 1 to 5, where 1 is 'Very low / inconsequential' and 5 is 'Very high / Immediate Concern', how urgent is this bug?"
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
    formData.title = "Player Report Form"
    formData.formType = "player-report"

    local questions = {}

    local reportedPlayer = {}
    reportedPlayer.query = "Please select the player you wish to report"
    reportedPlayer.name = "reportedPlayer"
    reportedPlayer.fieldType = "player-dropdown"
    table.insert( questions, reportedPlayer )

    local urgency = {}
    urgency.query = "On a scale from 1 to 5, where 1 is 'Very low / inconsequential' and 5 is 'Very high / Immediate Concern', how urgent is this situation?"
    urgency.name = "urgency"
    urgency.fieldType = "urgency"
    table.insert( questions, rating )

    local message = {}
    message.query = "Please describe the situation in detail. If you've gathered some, please share links containing evidence of wrongdoing."
    message.name = "message"
    message.fieldType = "text"
    table.insert( questions, message )

    formData.questions = questions

    openForm( formData )
end

local function openForms()
    Frame = vgui.Create( "DFrame" )
    Frame:SetTitle( "Contact Forms" )
    Frame:SetSize( 300, 300 )
    Frame:Center()
    Frame:MakePopup()

    makeFormButton( "Contact", { ['x'] = 0, ['y'] = 50 }, openContactForm, Frame )
    makeFormButton( "Feedback", { ['x'] = 0, ['y'] = 100 }, openFeedbackForm, Frame )
    makeFormButton( "Bug Report", { ['x'] = 0, ['y'] = 150 }, openBugReportForm, Frame )
    makeFormButton( "Player Report", { ['x'] = 0, ['y'] = 200 }, openPlayerReportForm, Frame )
end

concommand.Add( "cfc_forms", openForms )
