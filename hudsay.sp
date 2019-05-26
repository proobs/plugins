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

bool g_bIsTextActive = false; 

public void OnPluginStart()
{
	RegAdminCmd("sm_hudsay", Command_SmHudsay, ADMFLAG_CHAT, "sm_msay <message> - sends message on the hud");
}
public Action Command_SmHudsay(int client, int args)
{
	char text[192];
	GetCmdArgString(text, sizeof(text));
	
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_hudsay <message>");
		return Plugin_Handled;	
	}
	if (!IsTextActive == true)
	{
		ReplyToCommand(client, "[SM] Please try the command again once the text on screen has gone away..");
		return Plugin_Handled; 
	}
	if (!IsClientInGame(client) || IsFakeClient(client))
	{
		return Plugin_Continue;
	}
	CreateTimer(7.5, timer1); //create timer to prevent messages on top of each other
	DisplayHudMsg(client, text);
	LogAction(client, -1, "\"%L\" triggered sm_hudsay (text '%s')", client, text);
	return Plugin_Handled;		
}
public Action timer1(Handle timer)
{
	g_bIsTextActive = true;
	CreateTimer(0.5, timer2);
}
public Action timer2(Handle timer)
{
	g_bIsTextActive = false;
}
void DisplayHudMsg(int client, const char[] text)
{
	char nameBuf[MAX_NAME_LENGTH];
	
	for (int i = 1; i <= MaxClients; i++)
	{
		FormatActivitySource(client, i, nameBuf, sizeof(nameBuf));
		SetHudTextParams(-1.0, -0.90, 8.0, 0, 255, 170, 0, 2, 0.0, 0.0, 0.5); 
		ShowHudText(i, -1, "%s: %s", nameBuf, text);
	}
}
stock bool IsTextActive()
{
	if(g_bIsTextActive == true)
		return true; 
	return false; 
}
