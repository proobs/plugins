#include <sourcemod>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = 
{
	name = "Fake say",
	author = "proobs",
	description = "fake messages",
	version = "1.0",
	url = "https://github.com/proobs"
};

public void OnPluginStart() {
	RegAdminCmd("sm_fakesay", CMD_FakeSay, ADMFLAG_ROOT, "sm_fakesay <message>");
}

public Action CMD_FakeSay(int client, int args) {
	if (args < 1) {
		ReplyToCommand(client, "[SM] You need to write out a messsage!");
		return Plugin_Handled;
	}
	char msg[128];
	GetCmdArgString(msg, sizeof(msg));
	
	for (int i; i <= MAXPLAYERS; i++) {
		if(IsValidClient(i))
			FakeClientCommand(i, "say %s", msg);
	}
		
	return Plugin_Handled;
}

stock bool IsValidClient(int client) {
	if (client == 0) return false;
	if (client > MaxClients) return false;
	if (!IsClientConnected(client)) return false;
	if (IsFakeClient(client)) return false;
	if (IsClientSourceTV(client))return false;
	return IsClientInGame(client);
}