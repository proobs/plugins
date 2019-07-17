#include <sourcemod>
#include <sdktools>

#pragma newdecls required
#pragma semicolon 1

#define DEBUG

public Plugin myinfo = 
{
	name = "root auto bhop",
	author = "proobs",
	description = "yes",
	version = "1.0",
	url = "https://github.com/proobs"
};

ConVar sv_autobunnyhopping = null; 

public void OnPluginStart()
{
	sv_autobunnyhopping = FindConVar("sv_autobunnyhopping");
	
	RegAdminCmd("sm_bhop", cmd_bhop, ADMFLAG_ROOT);
}
public Action cmd_bhop(int client, int args) 
{
	OpenMenu(client);
}
void OpenMenu(int client)
{
	Menu bhop = new Menu(menuhandler);
	
	bhop.SetTitle("set bhop stuff yur");
	bhop.AddItem("0", "enable le bhop");
	bhop.AddItem("1", "disable le bhop");
	
	bhop.Display(client, 0);
	bhop.ExitButton = true; 
}
public int menuhandler(Menu bhop, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char item[64];
			GetMenuItem(bhop, param2, item, sizeof(item)); 
			
			if (StrEqual(item, "0"))
			{
				SendConVarValue(param1, sv_autobunnyhopping, "1"); //Old syntax, change to cvar.IntValue or something
				PrintToChat(param1, "Enabled bhop");
				OpenMenu(param1);
			}
			else if (StrEqual(item, "1"))
			{
				PrintToChat(param1, "Disabled bhop");
				SendConVarValue(param1, sv_autobunnyhopping, "0");
				OpenMenu(param1);
			}
		}
		case MenuAction_End:
		{
			CloseHandle(bhop); 
		}
	}
}
//fix for autobhop
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
    if (sv_autobunnyhopping && IsPlayerAlive(client))
    {
        if (buttons & IN_JUMP)
        {
            if (!(GetEntityFlags(client) & FL_ONGROUND))
            {
                if (!(GetEntityMoveType(client) & MOVETYPE_LADDER))
                {
                    if (GetEntProp(client, Prop_Data, "m_nWaterLevel") <= 1)
                    {
                        buttons &= ~IN_JUMP;
                    }
                }
            }
        }
    }
}  
