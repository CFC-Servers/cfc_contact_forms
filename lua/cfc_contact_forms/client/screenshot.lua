local rawget = rawget
local tostring = tostring
local hookName = "ContactForms_Screenshot"

local GREEN = Color( 0, 200, 0 )

local Screenshot = {
    screenshotTriggered = false
}

local colors = {
    Color( 255, 0, 0 ), -- Red
    Color( 0, 255, 0 ), -- Green
    Color( 0, 0, 255 ), -- Blue
    Color( 255, 255, 0 ),
    Color( 0, 255, 255 ), -- Cyan
    Color( 255, 0, 255 ), -- Magenta
    Color( 128, 0, 128 ), -- Purple
    Color( 128, 64, 0 ), -- Brown
    Color( 255, 192, 203 ), -- Pink
    Color( 192, 255, 0 ), -- Lime
    Color( 255, 229, 180 ), -- Peach
    Color( 230, 230, 250 ), -- Lavender
    Color( 128, 0, 0 ), -- Maroon
    Color( 0, 0, 128 ), -- Navy Blue
    Color( 128, 128, 0 ), -- Olive
    Color( 0, 128, 128 ), -- Teal
}

local function getColor()
    return colors[math.random(#colors)]
end

function Screenshot:Start( callback )
    local function cb( data )
        hook.Remove( "PreDrawViewModel", hookName )
        hook.Remove( "HUDPaint", hookName )
        hook.Remove( "PostDrawHUD", hookName )
        hook.Remove( "PostRender", hookName )
        hook.Remove( "CreateMove", hookName )

        callback( data )
    end

    hook.Add( "PreDrawViewModel", hookName, function( _, ply )
        if ply == LocalPlayer() then return true end
    end )


    local function isLookingAt( target )
        local diff = target:GetPos() - LocalPlayer():GetShootPos()
        return LocalPlayer():GetAimVector():Dot(diff) / diff:Length() >= 0.75
    end

    local canDraw = {
        prop_physics = true,
        player = true,
        gmod_wire_hologram = true,
        starfall_hologram = true,
        gmod_wire_expression2 = true,
        starfall_processor = true,
    }

    hook.Add( "HUDPaint", hookName, function()
        -- if not self.screenshotTriggered then return end

        local ents = ents.GetAll()
        local entCount = #ents

        for i = 1, entCount do
            local ent = rawget( ents, i )
            local entClass = ent:GetClass()

            if canDraw[entClass] and isLookingAt( ent ) then
                local entPos = ent:GetPos()
                local screenPos = entPos:ToScreen()

                local entInfo = ""
                if entClass == "player" then
                    entInfo = ent:GetName() .. "<" .. ent:SteamID64() .. ">"
                else
                    local entOwner = ent:CPPIGetOwner() or ent:GetOwner() or "Unknown"
                    entInfo = "[" .. entClass .. "]<" .. ent:EntIndex() .. "> (" .. tostring( entOwner ) .. ")"
                end

                draw.SimpleText( entInfo, "Trebuchet18", screenPos.x, screenPos.y, getColor(), TEXT_ALIGN_CENTER )
            end
        end
    end )

    hook.Add( "PostDrawHUD", hookName, function()
        if self.screenshotTriggered then return end

        surface.SetDrawColor( 255, 0, 0, 200 )
        surface.DrawOutlinedRect( 0, 0, ScrW(), ScrH(), 5 )

        draw.SimpleText( "Take a Screenshot with Left Click", "Trebuchet24", ScrW() * 0.5, 50, GREEN, TEXT_ALIGN_CENTER )
    end )


    timer.Simple( 0, function()
        hook.Add( "CreateMove", hookName, function()
            if self.screenshotTriggered then return end

            if input.WasMousePressed( MOUSE_LEFT ) then
                self.screenshotTriggered = true

                hook.Add( "PostRender", hookName, function()
                    local imageData = render.Capture({
                        format = "jpeg",
                        x = 0,
                        y = 0,
                        w = ScrW(),
                        h = ScrH(),
                        quality = 1
                    })

                    imageData = util.Base64Encode( imageData )
                    imageData = util.Compress( imageData )

                    cb( imageData )
                end )

                hook.Remove( "CreateMove", hookName )
            end
        end )
    end )
end

return Screenshot
