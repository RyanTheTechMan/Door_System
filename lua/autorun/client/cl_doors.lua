
surface.CreateFont( "DoorFont", {
	font = "Arial",
	size = 20,
	weight = 1000
} )

local allowed = {
	["prop_door"] = true,
	["prop_door_rotating"] = true,
	["func_door"] = true,
	["func_door_rotating"] = true
}

local distance = DOOR_CONFIG_DISTANCE * DOOR_CONFIG_DISTANCE

local OpenDoorMenuAdmin
local OpenDoorConfigRestricted
local OpenDoorConfig

local function DS_Notify( ply, text )
	local textcolor1 = color_black
	local textcolor2 = color_white
	chat.AddText( textcolor1, "[Door System]: ", textcolor2, text )
end
net.Receive( "DS_Notify", function( len, ply )
	local text = net.ReadString()
	DS_Notify( ply, text )
end )

local function SetDoorName( ply, door )
	local owner = door:GetNWEntity( "DoorOwner" )
	if owner != ply then
		DS_Notify( ply, "You do not own this door." )
		return
	end
	local frame = vgui.Create( "DFrame" )
	frame:SetTitle( "Set Door Name" )
	frame:SetSize( 180, 70 )
	frame:Center()
	frame:MakePopup()
	frame.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( DOOR_CONFIG_MENU_COLOR, 255 ) )
	end
	local getname = vgui.Create( "DTextEntry", frame )
	getname:SetSize( 170, 20 )
	getname:SetPos( 5, 35 )
	getname.OnEnter = function( self )
		net.Start( "SetDoorName" )
		net.WriteEntity( door )
		net.WriteString( self:GetValue() )
		net.SendToServer()
		frame:Close()
	end
end

OpenDoorConfig = function( ply, door )
	local menu = vgui.Create( "DFrame" )
	menu:SetTitle( "Admin Config" )
	menu:SetSize( 180, 150 )
	menu:Center()
	menu:MakePopup()
	menu.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_MENU_COLOR )
	end
	menu.OnClose = function()
		ply.MenuOpen = false
	end
	local backbutton = vgui.Create( "DButton", menu )
	backbutton:SetText( "Back" )
	backbutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
	backbutton:SetPos( 30, 30 )
	backbutton:SetSize( 150, 30 )
	backbutton:CenterHorizontal()
	backbutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
	end
	backbutton.DoClick = function()
		menu:Close()
		OpenDoorMenuAdmin( ply, door )
	end
	local sellbutton = vgui.Create( "DButton", menu )
	sellbutton:SetText( "Remove Door Ownership" )
	sellbutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
	sellbutton:SetPos( 30, 70 )
	sellbutton:SetSize( 150, 30 )
	sellbutton:CenterHorizontal()
	sellbutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
	end
	sellbutton.DoClick = function()
		net.Start( "UnownDoor" )
		net.WriteEntity( door )
		net.WriteBool( true )
		net.SendToServer()
		menu:Close()
	end
	local restrictbutton = vgui.Create( "DButton", menu )
	restrictbutton:SetText( "Add Restriction" )
	restrictbutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
	restrictbutton:SetPos( 30, 110 )
	restrictbutton:SetSize( 150, 30 )
	restrictbutton:CenterHorizontal()
	restrictbutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
	end
	restrictbutton.DoClick = function()
		local joblist = vgui.Create( "DComboBox", menu )
		joblist:SetPos( 30, 110 )
		joblist:SetSize( 100, 20 )
		joblist:CenterHorizontal()
		joblist:SetValue( "Select Restriction" )
		for k,v in pairs( DoorRestrictions ) do
			joblist:AddChoice( v.Name, k )
		end
		function joblist:OnSelect( index, value, data )
			local entindex = door:EntIndex()
			DoorTable[entindex] = data
			net.Start( "SyncDoorTable" )
			net.WriteString( tostring( entindex ) )
			net.WriteString( tostring( data ) )
			net.SendToServer()
			menu:Close()
			OpenDoorConfigRestricted( ply, door )
		end
	end
	ply.MenuOpen = true
end

OpenDoorConfigRestricted = function( ply, door )
	local menu = vgui.Create( "DFrame" )
	menu:SetTitle( "Admin Config" )
	menu:SetSize( 180, 120 )
	menu:Center()
	menu:MakePopup()
	menu.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_MENU_COLOR )
	end
	menu.OnClose = function()
		ply.MenuOpen = false
	end
	local restrictbutton = vgui.Create( "DButton", menu )
	restrictbutton:SetText( "Change Restriction" )
	restrictbutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
	restrictbutton:SetPos( 30, 30 )
	restrictbutton:SetSize( 150, 30 )
	restrictbutton:CenterHorizontal()
	restrictbutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
	end
	restrictbutton.DoClick = function()
		local joblist = vgui.Create( "DComboBox", menu )
		joblist:SetPos( 30, 30 )
		joblist:SetSize( 100, 20 )
		joblist:CenterHorizontal()
		joblist:SetValue( "Select Player" )
		for k,v in pairs( DoorRestrictions ) do
			joblist:AddChoice( v.Name, k )
		end
		function joblist:OnSelect( index, value, data )
			local entindex = door:EntIndex()
			DoorTable[entindex] = data
			net.Start( "SyncDoorTable" )
			net.WriteString( tostring( entindex ) )
			net.WriteString( tostring( data ) )
			net.SendToServer()
			menu:Close()
			OpenDoorConfigRestricted( ply, door )
		end
	end
	local restrictremove = vgui.Create( "DButton", menu )
	restrictremove:SetText( "Remove Restriction" )
	restrictremove:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
	restrictremove:SetPos( 30, 70 )
	restrictremove:SetSize( 150, 30 )
	restrictremove:CenterHorizontal()
	restrictremove.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
	end
	restrictremove.DoClick = function()
		local entindex = door:EntIndex()
		DoorTable[entindex] = nil
		net.Start( "SyncDoorTableRemove" )
		net.WriteString( tostring( entindex ) )
		net.SendToServer()
		menu:Close()
		OpenDoorConfig( ply, door )
	end
	ply.MenuOpen = true
end

OpenDoorMenuAdmin = function( ply, door )
	local menu = vgui.Create( "DFrame" )
	menu:SetTitle( "Door Settings" )
	menu:SetSize( 180, 150 )
	menu:Center()
	menu:MakePopup()
	menu.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_MENU_COLOR )
	end
	menu.OnClose = function()
		ply.MenuOpen = false
	end
	if !IsValid( door:GetNWEntity( "DoorOwner" ) ) then
		local buybutton = vgui.Create( "DButton", menu )
		buybutton:SetText( "Own Door" )
		buybutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
		buybutton:SetPos( 30, 30 )
		buybutton:SetSize( 150, 30 )
		buybutton:CenterHorizontal()
		buybutton.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
		end
		buybutton.DoClick = function()
			net.Start( "OwnDoor" )
			net.WriteEntity( door )
			net.SendToServer()
			menu:Close()
		end
	else
		local sellbutton = vgui.Create( "DButton", menu )
		sellbutton:SetText( "Remove Door Ownership" )
		sellbutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
		sellbutton:SetPos( 30, 30 )
		sellbutton:SetSize( 150, 30 )
		sellbutton:CenterHorizontal()
		sellbutton.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
		end
		sellbutton.DoClick = function()
			net.Start( "UnownDoor" )
			net.WriteEntity( door )
			net.SendToServer()
			menu:Close()
		end
	end
	local configbutton = vgui.Create( "DButton", menu )
	configbutton:SetText( "Admin Door Config" )
	configbutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
	configbutton:SetPos( 30, 70 )
	configbutton:SetSize( 150, 30 )
	configbutton:CenterHorizontal()
	configbutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
	end
	configbutton.DoClick = function()
		menu:Close()
		OpenDoorConfig( ply, door )
	end
	local namebutton = vgui.Create( "DButton", menu )
	namebutton:SetText( "Set Door Name" )
	namebutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
	namebutton:SetPos( 30, 110 )
	namebutton:SetSize( 150, 30 )
	namebutton:CenterHorizontal()
	namebutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
	end
	namebutton.DoClick = function()
		SetDoorName( ply, door )
	end
	ply.MenuOpen = true
end

local function OpenDoorMenu( ply, door )
	local menu = vgui.Create( "DFrame" )
	menu:SetTitle( "Door Settings" )
	menu:SetSize( 180, 110 )
	menu:Center()
	menu:MakePopup()
	menu.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_MENU_COLOR )
	end
	menu.OnClose = function()
		ply.MenuOpen = false
	end
	if !IsValid( door:GetNWEntity( "DoorOwner" ) ) then
		local buybutton = vgui.Create( "DButton", menu )
		buybutton:SetText( "Own Door" )
		buybutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
		buybutton:SetPos( 30, 30 )
		buybutton:SetSize( 150, 30 )
		buybutton:CenterHorizontal()
		buybutton.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
		end
		buybutton.DoClick = function()
			net.Start( "OwnDoor" )
			net.WriteEntity( door )
			net.SendToServer()
			menu:Close()
		end
	else
		local sellbutton = vgui.Create( "DButton", menu )
		sellbutton:SetText( "Unown Door" )
		sellbutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
		sellbutton:SetPos( 30, 30 )
		sellbutton:SetSize( 150, 30 )
		sellbutton:CenterHorizontal()
		sellbutton.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
		end
		sellbutton.DoClick = function()
			net.Start( "UnownDoor" )
			net.WriteEntity( door )
			net.SendToServer()
			menu:Close()
		end
	end
	local namebutton = vgui.Create( "DButton", menu )
	namebutton:SetText( "Set Door Name" )
	namebutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
	namebutton:SetPos( 30, 70 )
	namebutton:SetSize( 150, 30 )
	namebutton:CenterHorizontal()
	namebutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
	end
	namebutton.DoClick = function()
		SetDoorName( ply, door )
	end
	ply.MenuOpen = true
end

local function GetDoorRestrictions( index )
	return DoorRestrictions[DoorTable[index]].Name
end

local color_red = DOOR_CONFIG_TEXT_COLOR
hook.Add( "HUDPaint", "DoorHUD", function()
	local ply = LocalPlayer()
	local ent = ply:GetEyeTrace().Entity
	local doorowner = ent:GetNWEntity( "DoorOwner" )
	local doorname = ent:GetNWString( "DoorName" )
	local entindex = ent:EntIndex()
	local keyname = language.GetPhrase( input.GetKeyName( GetConVar( "DoorKey" ):GetInt() ) )
	if ply.MenuOpen then return end
	if IsValid( ent ) and ply:GetPos():DistToSqr( ent:GetPos() ) < distance and allowed[ent:GetClass()] then
		if doorname != "" then
			draw.SimpleText( doorname, "DoorFont", ScrW() / 2, ScrH() / 2 - 20, DOOR_CONFIG_NAME_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		if IsValid( doorowner ) then
			draw.SimpleText( "Owner: "..doorowner:Nick(), "DoorFont", ScrW() / 2, ScrH() / 2, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		else
			if DoorTable[entindex] then
				draw.SimpleText( "Owner: "..GetDoorRestrictions( entindex ), "DoorFont", ScrW() / 2, ScrH() / 2, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			else
				draw.SimpleText( "Owner: None", "DoorFont", ScrW() / 2, ScrH() / 2, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
		end
		draw.SimpleText( "Press "..keyname.." for door options.", "DoorFont", ScrW() / 2, ScrH() / 2 + 20, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		if DoorGroups and DoorGroups[game.GetMap()] and DoorGroups[game.GetMap()][entindex] then
			draw.SimpleText( "Door Group: "..doorgroups.Name, "DoorFont", ScrW() / 2, ScrH() / 2 + 40, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
end )

hook.Add( "PlayerButtonDown", "DoorButtons", function( ply, button )
	local doorkey = GetConVar( "DoorKey" ):GetInt()
	local ent = ply:GetEyeTrace().Entity
	if !IsFirstTimePredicted() or ply.MenuOpen then return end
	if IsValid( ent ) and button == doorkey and ply:GetPos():DistToSqr( ent:GetPos() ) < distance and allowed[ent:GetClass()] then
		if DoorTable[ent:EntIndex()] then
			if ply:IsSuperAdmin() or ( ply:IsAdmin() and DOOR_CONFIG_ALLOW_ADMIN ) then
				OpenDoorConfigRestricted( ply, ent )
			end
			return
		end
		if ply:IsSuperAdmin() or ( ply:IsAdmin() and DOOR_CONFIG_ALLOW_ADMIN ) then
			OpenDoorMenuAdmin( ply, ent )
		else
			OpenDoorMenu( ply, ent )
		end
	end
end )

net.Receive( "SyncDoorTableClient", function( len, ply )
	local tbl = net.ReadTable()
	DoorTable = tbl
end )