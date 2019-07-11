#include <sourcemod>

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
	sv_airaccelerate.AddChangeHook(OnCvarChange);
}
public void OnCvarChange(ConVar convar, char[] oldVal, char[] newVal) 
{
	char mapName[20];
	GetCurrentMap(mapName, sizeof(mapName));
	if(StringToInt(newVal) != 150)
	{
		if(StrEqual(mapName, clouds))
		{
			sv_airaccelerate.IntValue = 150;
		}
	}
}
