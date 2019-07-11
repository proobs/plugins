#include <sourcemod>

#pragma newdecls required
#pragma semicolon 1

#define DEBUG

public Plugin myinfo = 
{
	name = "hudsay",
	author = "proobs",
	description = "",
	version = "1.0",
	url = "https://github.com/proobs"
};

ConVar g_cvEnable = null;
ConVar g_cvTime = null; 

Handle g_hHudSync;

public void OnPluginStart()
{
	g_cvEnable = CreateConVar("sm_hud_say", "1", "Enable or disable the hud_text command/plugin");
	g_cvTime = CreateConVar("sm_hud_time", "8.0", "Time to hold the hud text message");
	
	RegAdminCmd("sm_hudsay", Command_SmHudsay, ADMFLAG_CHAT, "sm_msay <message> - sends message on the hud");
	
	g_hHudSync = CreateHudSynchronizer();
}
public Action Command_SmHudsay(int client, int args)
{
	if (!g_cvEnable.BoolValue)
	{
		return Plugin_Handled;
	}
	char text[192];
	GetCmdArgString(text, sizeof(text));
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_hudsay <message>");
		return Plugin_Handled;	
	}
	
	if (!IsClientInGame(client) || IsFakeClient(client))
	{
		return Plugin_Continue;
	}
	
	DisplayHudMsg(client, text);
	LogAction(client, -1, "\"%L\" triggered sm_hudsay (text '%s')", client, text);
	return Plugin_Handled;		
}

void DisplayHudMsg(int client, const char[] text)
{
	char nameBuf[MAX_NAME_LENGTH];
	char message[256];
	
	for (int i = 1; i <= MaxClients; i++)
	{
		FormatActivitySource(client, i, nameBuf, sizeof(nameBuf));
		Format(message, sizeof(message), "%s: %s", nameBuf, text);
		SetHudTextParams(-1.0, -0.90, g_cvTime.FloatValue, 0, 255, 170, 0, 2, 0.0, 0.0, 0.5);
		ShowSyncHudText(i, g_hHudSync, message);
	}
}
