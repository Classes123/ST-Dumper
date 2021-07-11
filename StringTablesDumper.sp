#define PLUGIN_NAME "ST Dumper"

#pragma semicolon 1
#pragma newdecls required

#include <sdktools_stringtables>

public Plugin myinfo =
{
    name     =  PLUGIN_NAME,
    author   =  "Young <",
    version  =  "1.0.0"
}

public void OnPluginStart()
{
    RegServerCmd("sm_list_stringtables", Command_ListStringTables);
    RegServerCmd("sm_dump_stringtable", Command_DumpStringTable);
}

public Action Command_ListStringTables(int iArgs)
{
    char szTableName[64];
    for(int i = 0; i < GetNumStringTables(); i++)
    {
        GetStringTableName(i, szTableName, sizeof szTableName);
        PrintToServer("- %s", szTableName);
    }

    return Plugin_Handled;
}   

public Action Command_DumpStringTable(int iArgs)
{
    if(iArgs != 2)
    {
        PrintToServer(PLUGIN_NAME...": Usage: sm_dump_stringtable <table_name> <file>");
        return Plugin_Handled;
    }


    char szBuffer[PLATFORM_MAX_PATH];

    /**
     *  Processing argument 1, table.
     */
    GetCmdArg(1, szBuffer, sizeof szBuffer);

    int iTable = FindStringTable(szBuffer);
    if(iTable == INVALID_STRING_TABLE)
	{
		PrintToServer(PLUGIN_NAME...": Invalid stringtable \"%s\"", szBuffer);
        return Plugin_Handled;
	}

    /**
     *  Processing argument 2, file.
     */
    GetCmdArg(2, szBuffer, sizeof szBuffer);

    File hFile = OpenFile(szBuffer, "w");
    if(!hFile)
    {
        PrintToServer(PLUGIN_NAME...": Failed to open file with name \"%s\"", szBuffer);
        return Plugin_Handled;
    }

    /**
     *  Writing.
     */
    int iNum = GetStringTableNumStrings(iTable);
    int iMax = GetStringTableMaxStrings(iTable);

    hFile.WriteLine("%i/%i items", iNum, iMax);
    for(int i = 0; i < iNum; i++)
    {
        ReadStringTable(iTable, i, szBuffer, sizeof szBuffer);
        hFile.WriteLine("\t%i : %s", i, szBuffer);
    }
    delete hFile;

    return Plugin_Handled;
}