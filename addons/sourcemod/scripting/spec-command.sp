#pragma semicolon 1

#include <sourcemod>
#include <cstrike>

#include <multicolors>
#include <autoexecconfig>

#pragma newdecls required

#define PLUGIN_VERSION "1.0"

public Plugin myinfo =
{
    name = "Simple Spec Command",
    author = "Nobody-x",
    description = "Adds !spec and !afk commands.",
    version = PLUGIN_VERSION,
    url = "https://github.com/Nobody-x/spectate-command"
}

ConVar g_cvEnabled;

public void OnPluginStart()
{
    AutoExecConfig_SetFile("plugin.simple-spec-command");

    CreateConVar("sm_ssc_version", PLUGIN_VERSION, "SimpleSpecCommand version.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
    g_cvEnabled = AutoExecConfig_CreateConVar("sm_ssc_enable", "1", "If set to 1, SimpleSpecCommand is enabled. If set to 0, SimpleSpecCommand is disabled.", 0, true, 0.0, true, 1.0);

    AutoExecConfig_ExecuteFile();

    RegConsoleCmd("sm_spec", Command_Switch2Spectator, "Go to the spectator team.");
    RegConsoleCmd("sm_afk", Command_Switch2Spectator, "Go to the spectator team.");

    LoadTranslations("simple-spec-command.phrases");
}

public void OnMapStart()
{
    // Load Prefix at map initialisation because
    // it's here that the translation is reloaded
    CSetPrefix("%T", "Prefix", LANG_SERVER);
}

public Action Command_Switch2Spectator(int client, int args)
{
    if (!g_cvEnabled.BoolValue) {
        CReplyToCommand(client, "%t", "ReplyCommand Disabled");

        return Plugin_Handled;
    }

    if (!IsValidClient(client)) {
        if (client == 0) {
            CReplyToCommand(client, "%T", "ReplyCommand Wrong Client", LANG_SERVER);
        }

        return Plugin_Handled;
    }

    if (GetClientTeam(client) != CS_TEAM_SPECTATOR) {
        FakeClientCommand(client, "sm_pause");
        ChangeClientTeam(client, CS_TEAM_SPECTATOR);

        CReplyToCommand(client, "%t", "ReplyCommand Goes Spec");

        char clientName[MAX_NAME_LENGTH];
        if (GetClientName(client, clientName, sizeof(clientName))) {
            for (int i = 1; i <= MaxClients; i++) {
                if (i != client && IsClientInGame(i))
                    CPrintToChat(i, "%t", "ChatAll Goes Spec", clientName);
            }
        }
    } else {
        CReplyToCommand(client, "%t", "ReplyCommand Already Spec");
    }

    return Plugin_Handled;
}

public bool IsValidClient(int client)
{
    if (client <= 0 || client > MaxClients) {
        return false;
    }

    return IsValidEdict(client) && IsClientInGame(client) && IsClientAuthorized(client) && IsClientConnected(client);
}