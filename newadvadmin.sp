#include <sourcemod>
#include <sdktools>
#include <cstrike>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = 
{
	name = "Advanced Admin",
	author = "proobs",
	description = "",
	version = "1.0",
	url = "https://github.com/proobs"
};

#define SOUND_BURY "physics/concrete/boulder_impact_hard4.wav" //Bury sound, leave blank to disable
#define CMD_PREFIX " /x0b➤➤➤"
#define DEBUG

char WeaponsList[][] = //VALID WEAPON NAMES HERE
{
	"c4", "knife", "knifegg", "taser", "healthshot", //misc
	"decoy", "flashbang", "hegrenade", "molotov", "incgrenade", "smokegrenade", "tagrenade", //grenades
	"usp_silencer", "glock", "tec9", "p250", "hkp2000", "cz75a", "deagle", "revolver", "fiveseven", "elite", //pistols
	"nova", "xm1014", "sawedoff", "mag7", "m249", "negev", //heavy
	"mp9", "mp7", "mp5sd", "ump45", "p90", "bizon", "mac10", //smgs
	"ak47", "aug", "famas", "sg556", "galilar", "m4a1", "m4a1_silencer", //rifles
	"awp", "ssg08", "scar20", "g3sg1" //snipers
};
char ItemsList[][] = //VALID ITEM NAMES HERE, HEAVYASSAULTSUIT ONLY WORKS WHEN ITS ENABLED (mp_max_armor 3)
{
	"defuser", "cutters", //defuser and rescue kit
	"kevlar", "assaultsuit", "heavyassaultsuit", //armors
	"nvgs" //nightvision
};

public void OnPluginStart()
{
	//all super+ commands
	RegAdminCmd("sm_team",				Command_Team,			ADMFLAG_CHANGEMAP,		"Set the targets team");
	RegAdminCmd("sm_give",				Command_Give,			ADMFLAG_CHANGEMAP,		"Give something for the targets");
	RegAdminCmd("sm_disarm",			Command_Disarm,			ADMFLAG_CHANGEMAP,		"Disarming the targets");
	RegAdminCmd("sm_bury",				Command_Bury,           ADMFLAG_CHANGEMAP,      "Burying the targets");
	RegAdminCmd("sm_unbury",			Command_UnBury,         ADMFLAG_CHANGEMAP,     "Burying the targets");
	RegAdminCmd("sm_hp",			    Command_Health,		    ADMFLAG_CHANGEMAP,		"Set the health for the targets");
	RegAdminCmd("sm_health",		    Command_Health,			ADMFLAG_CHANGEMAP,		"Set the health for the targets");
}

public void OnMapStart()
{
	if(!StrEqual(SOUND_BURY, "", false))
	{
		PrecacheSound(SOUND_BURY, true);
	}
}
public Action Command_Team(int client, int args)
{
	if(!IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if((args != 2) && (args != 3))
	{
		ReplyToCommand(client, "%s Usage: \x04sm_team <target> <T | CT | SPEC>", CMD_PREFIX);
		return Plugin_Handled;
	}

	char nameBuf[MAX_NAME_LENGTH];
	char target_name[MAX_TARGET_LENGTH];
	char buffer[64];
	int target_list[MAXPLAYERS];
	int target_count;
	bool tn_is_ml;
	
	GetCmdArg(1, buffer, sizeof(buffer));
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	int team;	
	FormatActivitySource(client, client, nameBuf, sizeof(nameBuf));
	GetCmdArg(2, buffer, sizeof(buffer));
	if(StrEqual(buffer, "spectator", false) || StrEqual(buffer, "spec", false) || StrEqual(buffer, "1", false))
	{
		team = CS_TEAM_SPECTATOR;
		{
			PrintToChatAll("%s %s has moved %s to spectator!", CMD_PREFIX, nameBuf, target_name);
		}
	}
	else if(StrEqual(buffer, "t", false) || StrEqual(buffer, "2", false))
	{
		team = CS_TEAM_T;
		{
			PrintToChatAll("%s %s has moved %s to T!", CMD_PREFIX, nameBuf, target_name);
		}
	}
	else if(StrEqual(buffer, "ct", false) || StrEqual(buffer, "3", false))
	{
		team = CS_TEAM_CT;
		{
			PrintToChatAll("%s %s has moved %s to CT!", CMD_PREFIX, nameBuf, target_name);
		}
	}
	else
	{
		ReplyToCommand(client, "%s Invalid team!", CMD_PREFIX);
		return Plugin_Handled;
	}
	
	GetCmdArg(3, buffer, sizeof(buffer));
	int value = StringToInt(buffer);
	
	for(int i = 0; i < target_count; i++)
	{
		if(IsClientInGame(target_list[i]))
		{
			if(!value)
			{
				if(team != 1)
				{
					CS_SwitchTeam(target_list[i], team);
					if(IsPlayerAlive(target_list[i]))
					{
						CS_RespawnPlayer(target_list[i]);
					}
				}
				else
				{
					ChangeClientTeam(target_list[i], team);
				}
			}
			else
			{
				SetEntProp(target_list[i], Prop_Data, "m_iPendingTeamNum", team);
			}
		}
	}
	return Plugin_Handled;
}
public Action Command_Give(int client, int args)
{
	if(!IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if((args != 1) && (args != 2))
	{
		ReplyToCommand(client, "%s Usage: sm_give <target> <leave blank for knife | weapon name>", CMD_PREFIX);
		return Plugin_Handled;
	}
	
	char nameBuf[MAX_NAME_LENGTH];
	char target_name[MAX_TARGET_LENGTH];
	char buffer[128];
	int target_list[MAXPLAYERS];
	int target_count;
	bool tn_is_ml;
 
	GetCmdArg(1, buffer, sizeof(buffer));
	if ((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	GetCmdArg(2, buffer, sizeof(buffer));
	if(StrEqual(buffer, "", false))
	{
		Format(buffer, sizeof(buffer), "knife");
	}
	int type = ItemType(buffer);
	if(!type)
	{
		ReplyToCommand(client, "%s Invalid weapon.. Please try again.." CMD_PREFIX);
		return Plugin_Handled;
	}
	
	for(int i = 0; i < target_count; i++)
	{
		if(StrEqual(buffer, "knife", false) && !GetConVarBool(FindConVar("mp_drop_knife_enable")))
		{
			int knife = -1;
			while((knife = GetPlayerWeaponSlot(target_list[i], 2)) != -1)
			{
				if(IsValidEntity(knife))
				{
					RemovePlayerItem(target_list[i], knife);
				}
			}
		}
		GivePlayerWeapon(target_list[i], buffer, type);
	}
	FormatActivitySource(client, client, nameBuf, sizeof(nameBuf));
	PrintToChatAll("%s %s has given %s item %d", CMD_PREFIX, nameBuf, target_name, buffer);
	return Plugin_Handled;
}
public Action Command_Disarm(int client, int args)
{
	
	if(!IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(args < 1)
	{
		ReplyToCommand(client, "%s Usage: sm_disarm <target>", CMD_PREFIX);
		return Plugin_Handled;
	}
	
	char target_name[MAX_TARGET_LENGTH];
	char nameBuf[MAX_NAME_LENGTH];
	char buffer[64];
	int target_list[MAXPLAYERS];
	int target_count;
	bool tn_is_ml;
	

	GetCmdArg(1, buffer, sizeof(buffer));
	if ((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for(int i = 0; i < target_count; i++)
	{
		DisarmPlayer(target_list[i]);
	}
	
	FormatActivitySource(client, client, nameBuf, sizeof(nameBuf));
	PrintToChatAll("%s %s has disarmed %s", CMD_PREFIX, nameBuf, target_name);
	return Plugin_Handled;
}
public Action Command_Bury(int client, int args)
{
	if(!IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(args < 1)
	{
		ReplyToCommand(client, "%s Usage: sm_bury <player>", CMD_PREFIX);
		return Plugin_Handled;
	}
	
	char nameBuf[MAX_NAME_LENGTH];
	char target_name[MAX_TARGET_LENGTH];
	char buffer[64];
	int target_list[MAXPLAYERS];
	int target_count;
	bool tn_is_ml;

	GetCmdArg(1, buffer, sizeof(buffer));
	if ((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	float pos[3];
	for(int i = 0; i < target_count; i++)
	{
		GetClientAbsOrigin(target_list[i], pos);
		pos[2] -= 36.5;
		TeleportEntity(target_list[i], pos, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));
		if(!StrEqual(SOUND_BURY, "", false))
		{
			EmitSoundToAll(SOUND_BURY, target_list[i]);
		}
	}
	
	FormatActivitySource(client, client, nameBuf, sizeof(nameBuf));
	PrintToChatAll("%s %s has burried %s", CMD_PREFIX, nameBuf, target_name);
	return Plugin_Handled;
}
public Action Command_UnBury(int client, int args)
{
	if(!IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(args < 1)
	{
		ReplyToCommand(client, "%s Usage: sm_unbury <player>", CMD_PREFIX);
		return Plugin_Handled;
	}
	
	char nameBuf[MAX_NAME_LENGTH];
	char target_name[MAX_TARGET_LENGTH];
	char buffer[64];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;

	GetCmdArg(1, buffer, sizeof(buffer));
	if ((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	float pos[3];
	for(int i = 0; i < target_count; i++)
	{
		GetClientAbsOrigin(target_list[i], pos);
		pos[2] += 36.5;
		TeleportEntity(target_list[i], pos, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));
		if(!StrEqual(SOUND_BURY, "", false))
		{
			EmitSoundToAll(SOUND_BURY, target_list[i]);
		}
	}
	
	FormatActivitySource(client, client, nameBuf, sizeof(nameBuf));
	PrintToChatAll("%s %s has unburried %s", CMD_PREFIX, nameBuf, target_name);
	return Plugin_Handled;
}
public Action Command_Health(int client, int args)
{
	if(!IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(args != 2)
	{
		ReplyToCommand(client, "%s Usage: sm_health <target> <hp amount>", CMD_PREFIX);
		return Plugin_Handled;
	}
	
	char nameBuf[MAX_NAME_LENGTH];
	char target_name[MAX_TARGET_LENGTH];
	char buffer[64];
	int target_list[MAXPLAYERS];
	int target_count;
	bool tn_is_ml;
	
	GetCmdArg(1, buffer, sizeof(buffer));
	if((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	GetCmdArg(2, buffer, sizeof(buffer));
	int value = StringToInt(buffer);
	
	for(int i = 0; i < target_count; i++)
	{
		if((buffer[0] == '+') || (buffer[0] == '-'))
		{
			value = value + GetEntProp(target_list[i], Prop_Data, "m_iHealth");
		}
		SetEntProp(target_list[i], Prop_Data, "m_iHealth", value);
	}
	FormatActivitySource(client, client, nameBuf, sizeof(nameBuf));
	PrintToChatAll("%s %s has set %s's health to %d HP", CMD_PREFIX, nameBuf, target_name, value);
	return Plugin_Handled;
}

//stocks
stock void GivePlayerWeapon(int client, char weapon, int type)
{
	char buffer[64];
	if(type == 1)
	{
		Format(buffer, sizeof(buffer), "weapon_%s", weapon);
	}
	else
	{
		Format(buffer, sizeof(buffer), "item_%s", weapon);
	}
	return GivePlayerItem(client, buffer);
}

stock void DisarmPlayer(int client)
{
	for(int i = 0; i < 5; i++)
	{
		int weapon = -1;
		while((weapon = GetPlayerWeaponSlot(client, i)) != -1)
		{
			if(IsValidEntity(weapon))
			{
				RemovePlayerItem(client, weapon);
			}
		}
	}
	SetEntProp(client, Prop_Send, "m_bHasDefuser", 0);
	SetEntProp(client, Prop_Send, "m_bHasHeavyArmor", 0);
	SetEntProp(client, Prop_Send, "m_ArmorValue", 0);
	SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
}
stock void ItemType(char buffer)
{
	for(new i = 0; i < sizeof(WeaponsList); i++)
	{
		if(StrEqual(itemname, WeaponsList[i], false))
		{
			return 1;
		}
	}
	for(new i = 0; i < sizeof(ItemsList); i++)
	{
		if(StrEqual(itemname, ItemsList[i], false))
		{
			return 2;
		}
	}
	return 0;
}
