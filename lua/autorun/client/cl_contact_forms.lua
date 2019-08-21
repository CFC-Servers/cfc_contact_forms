local LEFT_BORDER = 10

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
        for _, field in pairs( fields ) do
            net.WriteString( field:GetValue() )
        end
    net.SendToServer()

end

local function openForm( formData )
    Frame:Close()

    local Form = vgui.Create( "DFrame" )
    Form:SetTitle( formData.title )
    Form:SetSize( 600, 600 )
    Form:Center()
    Form:MakePopup()

    local baseHeight = 30

    local fields = {}

    local ycounter = baseHeight

    for i, question in pairs( formData.questions ) do
        local query = question.query
        local fieldType = question.fieldType

        local label = vgui.Create( "DLabel", Form )
        label:SetPos( LEFT_BORDER, ycounter )
        label:SetSize( Form:GetSize() * 0.95, 15 )
        label:SetText( query )

        local field = vgui.Create( "DTextEntry", Form )
        field:SetPos( LEFT_BORDER, ycounter + 15 )
        field:SetSize( Form:GetSize() * 0.95, 35 )

        ycounter = ycounter + 60

        fields[question.name] = field
    end

    local Submit = vgui.Create( "DButton", Form )
    Submit:SetText( "Submit" )
    Submit:SetPos( LEFT_BORDER, ycounter )

    Submit.DoClick = function()
        local result = processFieldsForForm( fields, formData )
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

    openForm( formData )
end

local function openBugReportForm()
    local formData = {}
    formData.title = "Bug Report Form"
    formData.formType = "bug-report"

    openForm( formData )
end

local function openPlayerReportForm()
    local formData = {}
    formData.title = "Player Report Form"
    formData.formType = "player-report"

    openForm( formData )
end

local function openForms()
    local Frame = vgui.Create( "DFrame" )
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
