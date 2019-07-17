#include <sourcemod>
#include <sdktools>

#pragma newdecls required
#pragma semicolon 1

#define VERSION "1.0"

public Plugin myinfo = {
	name = "Cheats",
	author = "proobs",
	description = "Allows root admins to use the command and cheat :)",
	version = VERSION,
	url = "https://github.com/proobs"
};


enum /* big boi convars */  { 
	aimbot,
	xray,
	autobhop,
	speed,
	speedboost,
	thirdperson,
	//immunetoflash,
	convars
}
ConVar g_convars[convars] = null; 
ConVar g_cvEnable = null; 

bool g_bAimbot[MAXPLAYERS + 1] =  { false, ... };
bool g_bXray[MAXPLAYERS + 1] =  { false, ... };
bool g_bAutoBhop[MAXPLAYERS + 1] =  { false, ... };
bool g_bSpeed[MAXPLAYERS + 1] =  { false, ... };
bool g_bThirdPerson[MAXPLAYERS + 1] =  { false, ... };
//bool g_bImmuneToFlash[MAXPLAYERS + 1] =  { false, ... };
bool g_bNoSpread[MAXPLAYERS + 1] =  { false, ... };
//Self note/ TODO: Finish anti-flash, add in fov changer, add in fake spinbot, finish aimbot
public void OnPluginStart() {
	g_cvEnable = CreateConVar("sm_cheats_plugin", "1", "Enable or disable the cheat plugin");
	
	g_convars[aimbot] = CreateConVar("sm_cheats_aimbot", "1", "Enable or disable the aimbot option within the cheats menu");
	g_convars[xray] = CreateConVar("sm_cheats_xray", "1", "Enable or disable xray within the cheats menu");
	g_convars[autobhop] = CreateConVar("sm_cheats_autobhop", "1", "Enable or disable autobhop within the cheats menu");
	g_convars[speed] = CreateConVar("sm_cheats_speed", "1", "Enable or disable speed boost within the cheats menu");
	g_convars[speedboost] = CreateConVar("sm_cheats_speed_boost", "2.0", "speed boost multiplied by the servers sv_maxspeed in a floating point value. Max is 20.0x (if you dont add a .0 to the end, it wont work!)", _, true, 1.0, true, 20.0);
	g_convars[thirdperson] = CreateConVar("sm_cheats_third_person", "1", "enable or disable third person within the cheats menu");
	//g_convars[immunetoflash] = CreateConVar("sm_cheats_immune_to_flash", "1", "enable or disable the immune to flash option within the cheats menu");
	
	//HookEventEx("player_blind", OnPlayerBlind);
	//HookEventEx("flashbang_detonate", OnFlashBang);
	
	AutoExecConfig(true, "cheats.cvars.cfg"); 

	RegAdminCmd("sm_cheats", Command_Cheats, ADMFLAG_ROOT, "cheat menu");
}

public Action Command_Cheats(int client, int args) {
	if(!IsPlayerAlive(client) || !IsClientInGame(client)) {
		ReplyToCommand(client, "[SM] You must be alive in order to preform this command");
		return Plugin_Handled;
	}
	if(!g_cvEnable) {
		ReplyToCommand(client, "[SM] This command was disabled by the server operator"); 
		return Plugin_Handled;
	}
	PrintToChat(client, "[SM] Opening the cheat menu :)"); 
	OpenCheatMenu(client);
	return Plugin_Handled; 
}

public void OpenCheatMenu(int client) {
	Menu cheatmenu = new Menu(CHEAT_MENU_HANDLER);
	cheatmenu.SetTitle("♿ Cheat Menu ♿");
	cheatmenu.AddItem("", "Enable the cheats you want!", ITEMDRAW_DISABLED);
	cheatmenu.AddItem("", "", ITEMDRAW_SPACER);
	
	/* s tier coding right here boys */ 
	if(!g_bAimbot[client] || !g_convars[aimbot].BoolValue)
		cheatmenu.AddItem("0", "Aimbot - [DISABLED]", (!g_convars[aimbot].BoolValue) ? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	else
		cheatmenu.AddItem("0", "Aimbot - [ENABLED]");
	if(!g_bXray[client] || !g_convars[xray].BoolValue)
		cheatmenu.AddItem("1", "Xray - [DISABLED]", (!g_convars[xray].BoolValue) ? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	else
		cheatmenu.AddItem("1", "Xray - [ENABLED]");
	if(!g_bAutoBhop || !g_convars[autobhop].BoolValue)
		cheatmenu.AddItem("2", "AutoBhop - [DISABLED]", (!g_convars[autobhop].BoolValue) ? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	else
		cheatmenu.AddItem("2", "AutoBhop - [ENABLED]");
	if(!g_bSpeed || !g_convars[speed].BoolValue)
		cheatmenu.AddItem("3", "SpeedBoost - [DISABLED]", (!g_convars[speed].BoolValue) ? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	else
		cheatmenu.AddItem("3", "SpeedBoost - [ENABLED]");
	if(!g_bThirdPerson || !g_convars[thirdperson].BoolValue)
		cheatmenu.AddItem("4", "Thirdperson - [DISABLED]", (!g_convars[thirdperson]) ? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	else
		cheatmenu.AddItem("4", "Thirdperson - [ENABLED]");

	cheatmenu.Display(client, 0);
	cheatmenu.ExitButton = true;
}

public int CHEAT_MENU_HANDLER(Menu menu, MenuAction action, int param1, int param2) {
	switch (action) {
		case MenuAction_Select: {
			OpenCheatMenu(param1);
			char item[64];
			menu.GetItem(param1, item, sizeof(item));
			
			if(StrEqual(item, "0")) {
				Aimbot(param1);
			}
			else if(StrEqual(item, "1")) {
				Xray(param1);
			}
			else if(StrEqual(item, "2")) {
				Bhop(param1);
			}
			else if(StrEqual(item, "3")) {
				Speed(param1);
			}
			else if(StrEqual(item, "4")) {
				ThirdPerson(param1);
			}
		}
		case MenuAction_End: {
			CloseHandle(menu); 
		}
	}
}

public void Aimbot(int client) {
	
}

public void Xray(int client) {
	//ConVar cvXray = FindConVar("r_drawothermodels");
	//cvXray.Flags|= FCVAR_REPLICATED;
	
	if(!g_bXray[client]) {

		//cvXray.ReplicateToClient(client, "2");
		ClientCommand(client, "r_drawothermodels 2");
		g_bXray[client] = true;
	}
	else {
		//cvXray.ReplicateToClient(client, "0");
		ClientCommand(client, "r_drawothermodels 0");
		g_bXray[client] = false;
	}
}

public void Bhop(int client) {
	ConVar cvEnableBhop = FindConVar("sv_enablebunnyhopping");
	ConVar cvAutoBhop = FindConVar("sv_autobunnyhopping");
	cvEnableBhop.Flags|= FCVAR_REPLICATED;
	cvAutoBhop.Flags|= FCVAR_REPLICATED;
	
	if (!g_bAutoBhop[client]) {
		cvEnableBhop.ReplicateToClient(client, "1");
		cvAutoBhop.ReplicateToClient(client, "1");
		g_bAutoBhop[client] = true;
	}
	else {
		cvEnableBhop.ReplicateToClient(client, "0");
		cvAutoBhop.ReplicateToClient(client, "0");
		g_bAutoBhop[client] = false;
	}
}

public void Speed(int client) {
	ConVar cvSpeed = FindConVar("sv_maxspeed");
	
	if (!g_bSpeed[client]) {
		float fSpeed = g_convars[speedboost].FloatValue * cvSpeed.FloatValue;
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", fSpeed);
		g_bSpeed[client] = true;
	}
	else {
		float fSpeed = cvSpeed.FloatValue;
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", fSpeed);
		g_bSpeed[client] = false;
	}
}

public void ThirdPerson(int client) {
	ConVar AllowTP = FindConVar("sv_allow_thirdperson");
	AllowTP.Flags|= FCVAR_REPLICATED;
	
	if (!g_bThirdPerson[client]) {
		if (!AllowTP.BoolValue)
			AllowTP.ReplicateToClient(client, "1");
		
		ClientCommand(client, "thirdperson");
		g_bThirdPerson[client] = true;
	}
	else {
		/* Makes sure that whoever uses it doesnt try also using the console command afterwards :) */
		if (AllowTP.ReplicateToClient(client, "1"))
			AllowTP.ReplicateToClient(client, "0");
			
		ClientCommand(client, "firstperson");
		g_bThirdPerson[client] = false;
	}
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
	/* for the autobhop option */
	if (g_bAutoBhop[client] && IsPlayerAlive(client)) {
		if (buttons & IN_JUMP) {
			if (!(GetEntityFlags(client) & FL_ONGROUND)) {
				if (!(GetEntityMoveType(client) & MOVETYPE_LADDER)) {
                    if (GetEntProp(client, Prop_Data, "m_nWaterLevel") <= 1) {
						buttons &= ~IN_JUMP; /* This is to confirm the plugins' autobhop and makes sure the lag that the client recieves is gone */
					}
				}
			}
		}
	}
	if (g_bNoSpread[client] && IsPlayerAlive(client)) {
		seed = GetRandomInt(0, 2000000000);
		//return Plugin_Changed;
	}
	//return Plugin_Continue;
}

/* Start of anti-blind cheat 
public Action OnPlayerBlind(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	float blindduration = event.GetFloat("blind_duration");
	
	if(g_bImmuneToFlash[client]) {
		if(blindduration != 0.0) {
			
		}
	}
	return Plugin_Continue;
}

public Action OnFlashBang(Event event, const char[] name, bool dontBroadcast) {
	int owner = GetClientOfUserId(event.GetInt("userid"));
	float Origin[3];
	float eyePos[3];
	//Note to self, add this to the menu, add the convar, and the bool value
	Origin[0] = event.GetFloat("x"); 
	Origin[1] = event.GetFloat("y"); 
	Origin[2] = event.GetFloat("z");
	probably not the best idea preformance wise to do all this stuff in a loop but im lazy 
	for (int client = 1; client <= MaxClients; client++) {
		if (!IsClientInGame(client))
			continue;

		GetClientEyePosition(client, eyePos);
		
		if (GetVectorDistance(Origin, eyePos) <= 1500.0) {
			eyePos[2] -= 0.5;
		
			Handle trace = TR_TraceRayFilterEx(Origin, eyePos, CONTENTS_SOLID, RayType_EndPoint, FilterTarget, client);
			if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == client) || (GetVectorDistance(Origin, eyePos) <= 100.0)) {
				StopFlash(client);
			}
			
			CloseHandle(trace);
		}
	}
}

public bool FilterTarget(int entity, int contentsMask, any data) {
	return (data == entity);
} 

void StopFlash(int client)
{
	ClientCommand(client, "dsp_player 0.0");
	SetEntDataFloat(client, -1, 0.5);
	SetEntDataFloat(client, 1, 0.0);
}
End of anti-blind cheat  */
