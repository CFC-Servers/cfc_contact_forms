# CFC Contact Forms
A collection of in-game forms that allow players to submit data to a remote web server.

# Overview
This addon lets players fill data in pre-made forms that can then be sent to a remote web server to be processed.

## How it works:
The addon will look for a url stored in the file `cfc/contact/url.txt` stored in the server's `DATA` folder.  
Upon sending data to the web server, an endpoint will be added to the URL specified.  
The URL is formatted as such: `<url>/<endpoint>` e.g. `http://localhost:3000/contact-forms/bug-report`  
The addon also requires a file `cfc/realm.txt` in the `DATA` folder that contains the name of the server.  
This is useful for differentiating multiple servers. The realm is included with the data sent to the web server.  

### Contact Form:
The contact form allows players to send a contact method for you to get in touch with them as well as a message of what they would like to talk about.

 Endpoint | Data
 -------- | ----
 `contact` | `steam_id` The steam id of the player that sent the form<br>`steam_name` The steam name of the player that sent the form<br>`contact_method` The prefered contact method of the player<br>`message` The message from the player<br>`realm` The realm of the server

### Feedback Form:
The feedback form allows players to give feedback on the server as well as a rating out of 5 and whether they would come back or not.

 Endpoint | Data
 -------- | ----
 `feedback` | `steam_id` The steam id of the player that sent the form<br>`steam_name` The steam name of the player that sent the form<br>`rating` The rating out of 5<br>`likely_to_return` Whether the player would return or not<br>`message` The player's feedback<br>`realm` The realm of the server

### Bug Report Form:
The bug report form allows players to report a bug they found on the server as well as it's urgency.

 Endpoint | Data
 -------- | ----
 `bug-report` | `steam_id` The steam id of the player that sent the form<br>`steam_name` The steam name of the player that sent the form<br>`urgency` The urgency of the bug<br>`message` A description of the bug<br>`realm` The realm of the server

### Freeze Report Form:
The freeze report form allows player to report freezing on the server with the severity, a description and debug information collected from the server.

 Endpoint | Data
 -------- | ----
 `freeze-report` | `steam_id` The steam id of the player that sent the form<br>`steam_name` The steam name of the player that sent the form<br>`debug_information` A table containing information about the server<br>`severity` The severity of the freezing<br>`message` A description of the situation<br>`realm` The realm of the server

The debug information table contains:
- `counts`: A table of player steam ids as keys with their value being the entity count of that player. (World entities are owned by `world`)
- `E2Info`: A list of all Expression 2 containing their name `name`, code size in characters `size` and owner steam id `owner` (`world` if the owner is invalid ).
- `playerInfo`: A table of player steam ids as keys with a table as value containing the player name `name`, that player's position in the map `pos`, the player's ping `ping` and their packet loss `packetloss`.
- `serverInfo`: A table containing the server's uptime `uptime` and tick rate `ticktime`.

### Player Report Form:
The player report form allows players to report a player that is breaking the rules giving the urgency and a description of the situation.

 Endpoint | Data
 -------- | ----
 `player-report` | `steam_id` The steam id of the player that sent the form<br>`steam_name` The steam name of the player that sent the form<br>`reported_steam_id` The steam id of the reported player<br>`reported_steam_name` The steam name of the reported player<br>`urgency` The urgency of the situation<br>`message` A description of the situation<br>`realm` The realm of the server

### Staff Report Form:
The staff report form allows players to report a staff member that is breaking the rules anonymously giving the urgency and a description of the situation.

 Endpoint | Data
 -------- | ----
 `staff-report` | `reported_steam_id` The steam id of the reported player<br>`reported_steam_name` The steam name of the reported player<br>`urgency` The urgency of the situation<br>`message` A description of the situation<br>`realm` The realm of the server


## Extra information:
The staff report form uses preset ranks and must be changed in the [Client file](https://github.com/CFC-Servers/cfc_contact_forms/blob/master/lua/autorun/client/cl_contact_forms.lua#L38)

## Preview:

![forms](https://user-images.githubusercontent.com/45960263/87813854-ac203a00-c830-11ea-99f3-b631903cf404.png)
