-- TODO: De-dupe the image and prereq guard stuff

local function getToken()
    return util.SHA256( tostring( CurTime() * math.random() ) )
end

local function readyForNext( ply )
    net.Start( "CFC_ContactForms_ReadyForNext" )
    net.WriteString( ply.pendingContactForm.token )
    net.Send( ply )
end

return function( submitForm )
    local Forms = {}

    function Forms.FollowupData( _, ply )
        local pending = ply.pendingContactForm
        print( "Pending data for: ", ply )
        PrintTable( pending or {} )
        if not pending then return end

        local givenToken = net.ReadString()
        if givenToken ~= pending.token then
            error( "Player submitted form data with an incorrect token!" )
        end

        local data = pending.data
        local chunkSize = net.ReadUInt( 16 )

        local imageChunk = net.ReadData( chunkSize )
        print( imageChunk )
        print( "Received chunk size: ", chunkSize, #imageChunk )

        data.image = data.image .. imageChunk

        local remaining = pending.remainingChunks - 1
        print( "Remaining chunks: ", remaining )

        if remaining == 0 then
            print( "No more chunks remaining! Decompressing and submitting form" )
            print( "Form Type: ", pending.formType )
            print( data.image )
            print( "Final compressed size: ", #data.image )

            data.image = util.Decompress( data.image )
            print( "Decompressed image data: ")
            print( data.image )
            assert( data.image ~= nil )
            assert( #data.image > 0 )

            PrintTable( pending )
            submitForm( data, pending.formType, ply )

            ply.pendingContactForm = nil
            return
        end

        print( "More chunks remain, now waiting for: ", remaining )
        pending.remainingChunks = remaining
        pending.token = getToken()

        readyForNext( ply )
    end


    function Forms.Contact( _, ply )
        if ply.pendingContactForm then return end

        local contactMethod = net.ReadString()
        local message = net.ReadString()

        local data = {}
        data.steam_id = ply:SteamID()
        data.steam_name = ply:GetName()
        data.contact_method = contactMethod
        data.message = message

        submitForm( data, "contact", ply )
    end


    function Forms.Feedback( _, ply )
        if ply.pendingContactForm then return end

        local rating = net.ReadString()
        local likelyToReturn = net.ReadString()
        local message = net.ReadString()

        local data = {}
        data.steam_id = ply:SteamID()
        data.steam_name = ply:GetName()
        data.rating = rating
        data.likely_to_return = likelyToReturn
        data.message = message

        submitForm( data, "feedback", ply )
    end


    function Forms.BugReport( _, ply )
        print( "Received bug report" )
        if ply.pendingContactForm then return end

        local urgency = net.ReadString()
        local message = net.ReadString()

        -- Including this one
        local chunkCount = net.ReadUInt( 4 )
        print( "Total Chunk Count: ", chunkCount )

        local chunkSize = net.ReadUInt( 16 )
        print( "This Chunk Size: ", chunkSize )

        local imageChunk = net.ReadData( chunkSize )
        print( "Image chunk actual size: ", #imageChunk )

        local data = {}
        data.steam_id = ply:SteamID()
        data.steam_name = ply:GetName()
        data.urgency = urgency
        data.message = message
        data.image = imageChunk

        -- We have all of the image data, no followups
        if chunkCount <= 1 then
            print( "We have all of the chunks we need! Sending report now" )
            return submitForm( data, "bug-report", ply )
        end
        print( "More chunks expected, saving pending form" )

        ply.pendingContactForm = {
            data = data,
            formType = "bug-report",
            remainingChunks = chunkCount - 1,
            token = getToken()
        }

        readyForNext( ply )
    end


    function Forms.PlayerReport( _, ply )
        if ply.pendingContactForm then return end

        local reportedSteamID = net.ReadString()
        local urgency = net.ReadString()
        local message = net.ReadString()
        local reportedPly = player.GetBySteamID( reportedSteamID )

        -- Including this one
        local chunkCount = net.ReadUInt( 4 )

        local chunkSize = net.ReadUInt( 16 )
        local imageChunk = net.ReadData( chunkSize )

        local data = {}
        data.steam_id = ply:SteamID()
        data.steam_name = ply:GetName()
        data.reported_steam_id = reportedSteamID
        data.reported_steam_name = reportedPly and reportedPly:GetName() or "<Unknown Name>"
        data.urgency = urgency
        data.message = message
        data.image = imageChunk

        -- We have all of the image data, no followups
        if chunkCount == 1 then
            data.image = util.Decompress( data.image )
            return submitForm( data, "player-report", ply )
        end

        ply.pendingContactForm = {
            data = data,
            formType = "player-report",
            remainingChunks = chunkCount - 1,
            token = getToken()
        }

        readyForNext( ply )
    end


    function Forms.StaffReport( _, ply )
        if ply.pendingContactForm then return end

        local reportedSteamID = net.ReadString()
        local urgency = net.ReadString()
        local message = net.ReadString()
        local reportedPly = player.GetBySteamID( reportedSteamID )

        -- Including this one
        local chunkCount = net.ReadUInt( 4 )

        local chunkSize = net.ReadUInt( 16 )
        local imageChunk = net.ReadData( chunkSize )

        local data = {}
        data.reported_steam_id = reportedSteamID
        data.reported_steam_name = reportedPly and reportedPly:GetName() or "<Unknown Name>"
        data.urgency = urgency
        data.message = message
        data.image = imageChunk

        -- We have all of the image data, no followups
        if chunkCount == 1 then
            data.image = util.Decompress( data.image )
            return submitForm( data, "staff-report", ply )
        end

        ply.pendingContactForm = {
            data = data,
            formType = "staff-report",
            remainingChunks = chunkCount - 1,
            token = getToken()
        }

        readyForNext( ply )
    end


    function Forms.FreezeReport( _, ply )
        if ply.pendingContactForm then return end

        local severity = net.ReadString()
        local message = net.ReadString()

        local data = {}
        data["steam_id"] = ply:SteamID()
        data["steam_name"] = ply:GetName()
        data["debug_information"] = getDebugInformation()
        data["severity"] = severity
        data["message"] = message

        submitForm( data, "freeze-report", ply )
    end


    return Forms
end
