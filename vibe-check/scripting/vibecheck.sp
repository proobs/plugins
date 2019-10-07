#include <sourcemod>
#include <sdktools>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = 
{
	name = "VibeCheck",
	author = "proobs",
	description = "yall already KNO",
	version = "1.0",
	url = "https://github.com/proobs"
};

// Handles
File g_fVibes;
ArrayList g_aVibes;

// variables
char g_cFileLocation[PLATFORM_MAX_PATH];
bool g_bWasCmdUsed[MAXPLAYERS + 1] =  { false, ... };
char g_cCurrentVibe[MAXPLAYERS + 1][128];

public void OnPluginStart() {
	BuildPath(Path_SM, g_cFileLocation, sizeof(g_cFileLocation), "configs/vibecheck.txt");
	
	g_aVibes = new ArrayList(512);
	
	RegConsoleCmd("sm_vibecheck", CMD_VibeCheck);
}

public void OnMapStart() {
	g_fVibes = OpenFile(g_cFileLocation, "r");
	
	char line[64];
	int i = 0;
	while(!g_fVibes.EndOfFile() && g_fVibes.ReadLine(line, sizeof(line))) {
		TrimString(line);
		
		if ((StrContains(line,"//",true) == -1) && i < 100) {
			g_aVibes.SetString(i, line);
			i++;
		}
	}
	
	if(g_fVibes != INVALID_HANDLE)
		g_fVibes.Close();
}

public void OnMapEnd() {
	g_aVibes.Clear();
	
	for (int i = 1; i <= MaxClients; i++) {
		g_bWasCmdUsed[i] = false;
	}
}

public void OnClientDisconnect(int client) {
	g_bWasCmdUsed[client] = false;
}

public Action CMD_VibeCheck(int client, int args) {
	if(args < 1) {
		CheckVibes(client);
		return Plugin_Handled;
	}
	
	int target = -1;
	char name[MAX_NAME_LENGTH];
	GetCmdArg(1, name, sizeof(name));
	for (int i = 1; i <= MaxClients; i++) {
		if(!IsClientConnected(i))
			continue; //go next
			
		char clientName[MAX_NAME_LENGTH];
		GetClientName(i, clientName, sizeof(clientName));
		if(StrEqual(clientName, name)) {
			target = i;
		}
	}
	
	if(target == -1) {
		ReplyToCommand(client, "[SM] Client does not exist");
		return Plugin_Handled;
	}
	
	CheckVibes(target, true);
	return Plugin_Handled;
}

void CheckVibes(int client, bool OtherClient=false) {
	if(!g_bWasCmdUsed[client]) {
		if(!OtherClient) {
			ReplyToCommand(client, "[SM] Bruh, you already feeling %s, you cant vibe check again o-o", g_cCurrentVibe[client]);
			return;
		} else {
			ReplyToCommand(client, "[SM] Bruh, He already got checked............");
			return;
		}
	}
	int randomVibe = GetRandomInt(0, g_aVibes.Length);
	char buffer[128];
	g_aVibes.GetString(randomVibe, buffer, sizeof(buffer));
		
	if(StrEqual(buffer, "")) {
		buffer = "Rowdy As Fuck Bruh";
	}
	
	PrintToChatAll("[SM] VIBE CHECK ON %N, HE FEELIN %s", client, buffer);
	g_cCurrentVibe[client] = buffer;
	g_bWasCmdUsed[client] = true;
}