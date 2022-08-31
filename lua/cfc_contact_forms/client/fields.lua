local Elements = CFCContactForms.Elements
local Fields = {}

local function formImage( imageBase, shouldGrayscale )
    local path = "vgui/cfc/forms/"
    local grayscale = shouldGrayscale and "_grayscale" or ""

    return path .. imageBase .. grayscale .. ".png"
end


----------------------
-- Text Field
----------------------
function Fields.Text( question, parent )
    local query = question.query
    Elements.Label( query, parent )

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


----------------------
-- Boolean Field
----------------------
function Fields.Boolean( question, parent )
    local query = question.query
    Elements.Label( query, parent )

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
        ButtonPanel.selectedValue = "true"
        YesButton:SetImage( formImage( "radio-filled" ) )
        NoButton:SetImage( formImage( "radio" ) )
    end

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

    -- No Button
    NoButton = vgui.Create( "DImageButton", ButtonPanel )
    NoButton:SetSize( 40, 40 )
    NoButton:SetImage( formImage( "radio" ) )
    NoButton:Dock( LEFT )
    NoButton.DoClick = function()
        ButtonPanel.selectedValue = "false"
        NoButton:SetImage( formImage( "radio-filled" ) )
        YesButton:SetImage( formImage( "radio" ) )
    end

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

    return ButtonPanel
end


----------------------
-- Player Dropdown
----------------------
function Fields.PlayerDropdown( question, parent, givenPlayers )
    local query = question.query
    Elements.Label( query, parent )

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


----------------------
-- All Player Dropdown
----------------------
function Fields.AllPlayerDropdown( question, parent )
    local plys = {}
    for _, ply in pairs( player.GetAll() ) do
        if ply ~= LocalPlayer() then table.insert( plys, ply ) end
    end

    return Fields.PlayerDropdown( question, parent, plys )
end


----------------------
-- Staff Dropdown
----------------------
function Fields.StaffDropDown( question, parent )
    local plys = {}

    for _, ply in pairs( player.GetAll() ) do
        if CFCContactForms.IS_STAFF[ply:GetUserGroup()] then table.insert( plys, ply ) end
    end

    return Fields.PlayerDropdown( question, parent, plys )
end


----------------------
-- Sliding Scale
----------------------
local function slidingScaleField( question, parent, imageBase )
    local query = question.query
    Elements.Label( query, parent )

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

function Fields.Urgency( question, parent )
    return slidingScaleField( question, parent, "fire" )
end

function Fields.Rating( question, parent )
    return slidingScaleField( question, parent, "star" )
end

function Fields:FormField( ... )
    local args = { ... }
    local question = args[1]
    local fieldType = question.fieldType

    if fieldType == "text" then
        return self.Text( ... )
    end

    if fieldType == "boolean" then
        return self.Boolean( ... )
    end

    if fieldType == "player-dropdown" then
        return self.AllPlayerDropdown( ... )
    end

    if fieldType == "staff-dropdown" then
        return self.StaffDropDown( ... )
    end

    if fieldType == "urgency" then
        return self.Urgency( ... )
    end

    if fieldType == "rating" then
        return self.Rating( ... )
    end

    print( "Not sure what to do with this field type! :" .. fieldType or "nil" )
end

return Fields
