#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR ""
#define PLUGIN_VERSION "0.00"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
//#include <sdkhooks>

#pragma newdecls required

EngineVersion g_Game;

public Plugin myinfo = 
{
	name = "Force_Restart",
	author = "proobs",
	description = "root restart command for linux servers",
	version = "1.0",
	url = "github.com/proobs"
};

public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO && g_Game != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");	
	}
	RegAdminCmd("sm_forcerestart", forcecrash, ADMFLAG_ROOT);
}
public Action forcecrash(int client, int args)
{
	ServerCommand("_restart");
}
