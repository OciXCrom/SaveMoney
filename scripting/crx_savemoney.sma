#include <amxmodx>
#include <cstrike>
#include <fvault>

#define PLUGIN_VERSION "1.1"
new const g_szVault[] = "PlayerMoney"
new g_cvMapOnly

public plugin_init()
{
	register_plugin("Save Money", PLUGIN_VERSION, "OciXCrom")
	register_cvar("SaveMoney", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	register_logevent("eventRoundRestart", 2, "0=World triggered", "1&Restart_Round_")
	g_cvMapOnly = register_cvar("sm_maponly", "1")
}

public client_putinserver(id)
	LoadData(id)

public client_disconnect(id)
	SaveData(id)

SaveData(id)
{
	new szName[32], szMoney[10]
	get_user_name(id, szName, charsmax(szName))
	num_to_str(cs_get_user_money(id), szMoney, charsmax(szMoney))
	fvault_set_data(g_szVault, szName, szMoney)
}

LoadData(id)
{
	new szName[32], szData[10]
	get_user_name(id, szName, charsmax(szName))
	
	if(fvault_get_data(g_szVault, szName, szData, charsmax(szData)))
		cs_set_user_money(id, str_to_num(szData))
}

public eventRoundRestart()
{
	new iPlayers[32], iPnum, iMoney = get_cvar_num("mp_startmoney")
	get_players(iPlayers, iPnum)
	fvault_clear(g_szVault)
	
	for(new i; i < iPnum; i++)
		cs_set_user_money(iPlayers[i], iMoney)
}

public plugin_end()
{
	if(get_pcvar_num(g_cvMapOnly))
		fvault_clear(g_szVault)
}