local Elements = {}


----------------------
-- Label Element
----------------------
function Elements.Label( text, parent )
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


-----------------------
-- FormButton Element
-----------------------
function Elements.FormButton( text, callback, parent )
    local Button = vgui.Create( "DButton", parent )

    Button:SetFont( "Trebuchet24" )
    Button:SetTextColor( Color( 255, 255, 255 ) )
    Button:Dock( TOP )
    Button:DockMargin( 0, 0, 0, 25 )
    Button:SetText( text )

    local parentX = parent:GetSize()
    local desiredSizeX = parentX * 0.8

    Button:SetSize( desiredSizeX, 55 )

    Button.Paint = function( _, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 0 ) )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.DrawOutlinedRect( 0, 0, w, h )
    end

    Button.DoClick = callback

    return Button
end


----------------------
-- Header Element
----------------------
function Elements.Header( text, parent )
    local StagingHeader = Elements.Label( text, parent )
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


----------------------
-- Title Element
----------------------
function Elements.Title( text, parent )
    local Title = vgui.Create( "DLabel", parent )
    Title:SetVerticalScrollbarEnabled( false )
    Title:SetHeight( 80 )
    Title:SetText( text )
    Title:SetContentAlignment( 5 )
    Title:SetWrap( false )
    Title:Dock( TOP )
    Title:DockMargin( 0, 10, 0, 30 )

    function Title:PerformLayout()
        Title:SetFGColor( Color( 255, 255, 255, 255 ) )
        Title:SetFontInternal( "CFCFormTitle" )
        Title:SetToFullHeight()
    end

    return Title
end


----------------------
-- Error Alert
----------------------
function Elements.ErrorAlert( parent )
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

return Elements
