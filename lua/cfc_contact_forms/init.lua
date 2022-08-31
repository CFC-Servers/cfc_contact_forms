AddCSLuaFile()

if SERVER then
    AddCSLuaFile( "client/alert.lua" )
    AddCSLuaFile( "client/contact_forms.lua" )
    AddCSLuaFile( "client/elements.lua" )
    AddCSLuaFile( "client/fields.lua" )
    AddCSLuaFile( "client/form.lua" )
    AddCSLuaFile( "client/forms.lua" )
    include( "server/contact_forms.lua" )
else
    include( "client/contact_forms.lua" )
end
