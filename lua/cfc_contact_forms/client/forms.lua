local Forms = {}
local Form = CFCContactForms.Form


function Forms.Contact()
    local formData = {}
    formData.title = "Contact"
    formData.formType = "contact"

    formData.headerText = {
        "We'd love to hear from you! Tell us how we can get in touch with you and include a brief description of your question/comment/concern. We'll get back to you ASAP!"
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

    Form( formData )
end


function Forms.Feedback()
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

    Form( formData )
end


function Forms.BugReport()
    local formData = {}
    formData.title = "Bug Report"
    formData.formType = "bug-report"

    formData.headerText = {
        "Have you experienced something unsavory or otherwise unexpected?",
        "Tell us about it! Please be descriptive so we can tackle your issue quickly.",
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

    Form( formData )
end


function Forms.PlayerReport()
    local formData = {}
    formData.title = "Player Report"
    formData.formType = "player-report"

    formData.headerText = {
        "Is a player ruining the experience of others?",
        "Tell us about it! Our staff will receive this report and take action as soon as they can.",
        "(Only one player per report!)"
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

    Form( formData )
end

function Forms.StaffReport()
    local formData = {}
    formData.title = "Staff Report"
    formData.formType = "staff-report"

    formData.headerText = {
        "Is a staff member breaking the rules?",
        "You can report them anonymously so that we can take action as fast as possible!",
        "(Only one staff member per report!)"
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

    Form( formData )
end


function Forms.FreezeReport()
    local formData = {}
    formData.title = "Freeze Report"
    formData.formType = "freeze-report"

    formData.headerText = {
        "Are you experiencing freezing? Please tell us about it!"
    }

    local questions = {}

    local severity = {}
    severity.query = "How severe is the freezing?"
    severity.name = "severity"
    severity.fieldType = "urgency"
    table.insert( questions, severity )

    local message = {}
    message.query = "Please share any additional comments, the more information the better!"
    message.name = "message"
    message.fieldType = "text"
    table.insert( questions, message )

    formData.questions = questions

    Form( formData )
end

concommand.Add( "cfc_forms_feedback", Forms.Feedback )
concommand.Add( "cfc_forms_freezereport", Forms.FreezeReport )

local function discordAlert()
    surface.PlaySound( "buttons/button8.wav" )
    chat.AddText( Color( 255, 255, 0 ), "Please join our discord to submit a report: cfc.gg/discord" )
end

concommand.Add( "cfc_forms_contact", discordAlert )
concommand.Add( "cfc_forms_bugreport", discordAlert )
concommand.Add( "cfc_forms_playerreport", discordAlert )
concommand.Add( "cfc_forms_staffreport", discordAlert )

return Forms
