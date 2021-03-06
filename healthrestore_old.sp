// © Maxim "Kailo" Telezhenko, 2015
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>

public Plugin:myinfo =
{
	name = "Health restore",
	author = "Kailo",
	description = "Restore your health after fall down",
	version = "1.0.0",
	url = "http://steamcommunity.com/id/kailo97/"
};

new Handle:hns_healthrestore = INVALID_HANDLE;
new Handle:hns_healthrestore_hp = INVALID_HANDLE;
new Handle:WelcomeTimers[MAXPLAYERS+1];

public OnPluginStart()
{
	LoadTranslations("healthrestore.phrases");
	
	hns_healthrestore = CreateConVar("hns_healthrestore", "1", "Turns the health restore On/Off (0=OFF, 1=ON)", FCVAR_NOTIFY|FCVAR_PLUGIN, true, 0.0, true, 1.0);
	hns_healthrestore_hp = CreateConVar("hns_healthrestore_hp", "55", "HP amount that will restored", _, true, 0.0, true, 99.0);
	
	HookEvent("player_hurt", OnPlayerHurt);
	
	AutoExecConfig();
}
 
public OnClientPutInServer(client)
{
	WelcomeTimers[client] = CreateTimer(10.0, WelcomePlayer, client);
}
 
public OnClientDisconnect(client)
{
	if (WelcomeTimers[client] != INVALID_HANDLE)
	{
		KillTimer(WelcomeTimers[client]);
		WelcomeTimers[client] = INVALID_HANDLE;
	}
}
 
public Action:WelcomePlayer(Handle:timer, any:client)
{
	PrintToChat(client, "[\x07%t\x01] %t", "Attention", "Welcome");
	WelcomeTimers[client] = INVALID_HANDLE;
}

public OnPlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarBool(hns_healthrestore))
	{
		new client=GetClientOfUserId(GetEventInt(event, "userid")), health=GetEventInt(event, "health"), dmg_health=GetEventInt(event, "dmg_health"), hpbonus = GetConVarInt(hns_healthrestore_hp);
		if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientOfUserId(GetEventInt(event, "attacker")) == 0 && health != 0) {
			if (dmg_health > hpbonus) {
				health = health + hpbonus;
				PrintToChat(client, "  \x04[HNS] %t", "Health Restore", hpbonus);
			} else {
				health = health + dmg_health;
				PrintToChat(client, "  \x04[HNS] %t", "Health Restore", dmg_health);
			}
			SetEntProp(client, Prop_Send, "m_iHealth", health);
		}
	}
}