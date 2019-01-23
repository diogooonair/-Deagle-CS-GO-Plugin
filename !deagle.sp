#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "DiogoOnAir"
#define PLUGIN_VERSION "1.00"

#include <sourcemod>
#include <sdktools>
#include <smlib>

#pragma tabsize 0

int g_roundcount = 0;
int g_voteyes = 0;
int g_voteno = 0;
bool g_alreadythismap = false;
bool g_restrictrunning = false;

public Plugin myinfo = 
{
	name = "!Deagle",
	author = PLUGIN_AUTHOR,
	description = "V.I.P players can write !deagle in chat to make a votation to restrict deagle",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	RegAdminCmd("sm_deagle", CMD_MENU, ADMFLAG_RESERVATION);
	HookEvent("round_start", OnRoundStart);
}

public Action OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if(g_voteyes > g_voteno)
	{
		g_alreadythismap = true;
		g_restrictrunning = true;
		g_voteyes = 0;
		g_voteno = 0;
		PrintToChatAll("The next 3 rounds will be played without deagle!!!");
    }
    else if(g_restrictrunning)
    {
    	g_roundcount += 1;
    	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i))
	    {
	    	Client_RemoveWeapon(i, "weapon_deagle");
	    }	
	    if(g_roundcount == 3)
	    {
	    	g_restrictrunning = false;
	    	g_roundcount = 0;
	    }
    }
}	

public OnMapStart()
{
	g_alreadythismap = false;  
}
	
public Action CMD_MENU(int client, int args)
{
	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i))
	  AskIfWantToRestrictDeagle(i);
}

public int AskIfWantToRestrictDeagle(int client)
{
   if(!g_alreadythismap)
   {
   	  Menu menu = new Menu(DeagleMenu);

      menu.SetTitle("Do you want to restrict deagle for 3 rounds?");
      menu.AddItem("yes", "Yes");
      menu.AddItem("no", "No");
      menu.ExitButton = false;
      menu.Display(client, 15);
   }
   else
   {
	  PrintToChat(client, "This command can be used only 1 time per map");
   }
}

public int DeagleMenu(Menu menu, MenuAction action, int client, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(param2, info, sizeof(info));

		    if (StrEqual(info, "yes"))
			{
				g_voteyes += 1;
			}
			else if (StrEqual(info, "no"))
			{
				g_voteno += 1;
			}
		}

		case MenuAction_End:{delete menu;}
	}

	return 0;
}