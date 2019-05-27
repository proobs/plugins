#include <sourcemod>
#include <sdktools>

#pragma newdecls required
#pragma semicolon 1

#define DEBUG
#define clouds "jb_clouds_final5"

public Plugin myinfo = 
{
	name = "Clouds air accelerate enforcer",
	author = "proobs",
	description = "Makes sure air acceleration doesn't change if people get into surf",
	version = "1.0",
	url = "https://github.com/proobs"
};

ConVar sv_airaccelerate = null; 


public void OnPluginStart()
{
	sv_airaccelerate = FindConVar("sv_airaccelerate");
	sv_airaccelerate.Flags &= ~(FCVAR_NOTIFY | FCVAR_REPLICATED);
}
public void PreThinkPost(int client)
{
	char mapName[20];
	GetCurrentMap(mapName, sizeof(mapName));
	if(StrEqual(mapName, clouds))
	{	
		sv_airaccelerate.IntValue = 150;
	}
}
/*public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	char mapName[20];
	GetCurrentMap(mapName, sizeof(mapName));
	if(StrEqual(mapName, clouds))
	{
		if(sv_airaccelerate != null)
		{
			sv_airaccelerate.IntValue = 150;
		}
	}
}*/

/*public Action yeah(Handle timer)
{
	char mapName[20];
	GetCurrentMap(mapName, sizeof(mapName));
	if(StrEqual(mapName, clouds))
	{
		PrintToChatAll("nigger");
		PrintToChatAll("nigger");
		PrintToChatAll("nigger");
		PrintToChatAll("nigger");
	}
	PrintToChatAll("test");
}*/ 