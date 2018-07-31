#include <amxmodx>
#include <cstrike>
#include <fvault>

#define PLUGIN_VERSION "2.0.1"

enum _:Cvars
{
	sm_maponly,
	sm_save_type,
	mp_startmoney
}

new g_eCvars[Cvars]
new g_eValues[Cvars]
new g_szInfo[33][35]
new bool:g_bRestart
new const g_szVault[] = "CRXPlayerMoney"

public plugin_init()
{
	register_plugin("Save Money", PLUGIN_VERSION, "OciXCrom")
	register_cvar("CRXSaveMoney", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	register_logevent("OnRoundRestart", 2, "0=World triggered", "1&Restart_Round_")
	register_logevent("OnRoundRestart", 2, "0=World triggered", "1=Game_Commencing")
	register_logevent("OnRoundStart", 2, "0=World triggered", "1=Round_Start")
	g_eCvars[sm_maponly] = register_cvar("sm_maponly", "1")
	g_eCvars[sm_save_type] = register_cvar("sm_save_type", "0")
	g_eCvars[mp_startmoney] = get_cvar_pointer("mp_startmoney")
}

public plugin_cfg()
	GetCvars()

public plugin_end()
{
	GetCvars()
	
	if(g_eValues[sm_maponly])
		fvault_clear(g_szVault)
}

public client_putinserver(id)
{
	if(is_user_bot(id))
		return
		
	get_user_save_info(id, g_szInfo[id], charsmax(g_szInfo[]))
	use_vault(id, 1, g_szInfo[id])
}

public client_disconnect(id)
{
	if(!is_user_bot(id))
		use_vault(id, 0, g_szInfo[id])
}
	
public client_infochanged(id)
{
	if(g_eValues[sm_save_type] || !is_user_connected(id) || is_user_bot(id))
		return
		
	static szNewName[32], szOldName[32]
	get_user_info(id, "name", szNewName, charsmax(szNewName))
	get_user_name(id, szOldName, charsmax(szOldName))
	
	if(!equal(szNewName, szOldName))
	{
		use_vault(id, 0, szOldName)
		use_vault(id, 1, szNewName)
		copy(g_szInfo[id], charsmax(g_szInfo[]), szNewName)
	}
}

public OnRoundRestart()
{
	GetCvars()
	
	if(!g_eValues[sm_maponly])
	{
		if(g_bRestart)
			return
			
		g_bRestart = true
		use_vault(0, 0)
		return
	}
		
	fvault_clear(g_szVault)
		
	new iPlayers[32], iPnum
	get_players(iPlayers, iPnum, "ch")
	
	for(new i; i < iPnum; i++)
		cs_set_user_money(iPlayers[i], g_eValues[mp_startmoney])
}

public OnRoundStart()
{
	if(!g_bRestart)
		return
		
	g_bRestart = false
	use_vault(0, 1)
}

use_vault(const id, const iType, const szInfo[] = "")
{
	new szData[10]
	
	switch(iType)
	{
		case 0:
		{
			if(id && is_user_connected(id))
			{
				num_to_str(cs_get_user_money(id), szData, charsmax(szData))
				fvault_set_data(g_szVault, szInfo, szData)
			}
			else
			{
				new iPlayers[32], iPnum
				get_players(iPlayers, iPnum, "ch")
				
				for(new i, iPlayer; i < iPnum; i++)
				{
					iPlayer = iPlayers[i]
					num_to_str(cs_get_user_money(iPlayer), szData, charsmax(szData))
					fvault_set_data(g_szVault, g_szInfo[iPlayer], szData)
				}
			}				
		}
		case 1:
		{
			if(id)
			{
				if(fvault_get_data(g_szVault, szInfo, szData, charsmax(szData)))
					cs_set_user_money(id, str_to_num(szData), 0)
			}
			else
			{
				new iPlayers[32], iPnum
				get_players(iPlayers, iPnum, "ch")
				
				for(new i, iPlayer; i < iPnum; i++)
				{
					iPlayer = iPlayers[i]
					
					if(fvault_get_data(g_szVault, g_szInfo[iPlayer], szData, charsmax(szData)))
						cs_set_user_money(iPlayer, str_to_num(szData), 0)
				}
			}
		}
	}
}

get_user_save_info(const id, szInfo[], const iLen)
{
	switch(g_eValues[sm_save_type])
	{
		case 0: get_user_name(id, szInfo, iLen)
		case 1: get_user_ip(id, szInfo, iLen)
		case 2: get_user_authid(id, szInfo, iLen)
	}
}

GetCvars()
{
	g_eValues[sm_maponly] = get_pcvar_num(g_eCvars[sm_maponly])
	g_eValues[sm_save_type] = get_pcvar_num(g_eCvars[sm_save_type])
	g_eValues[mp_startmoney] = get_pcvar_num(g_eCvars[mp_startmoney])
}
