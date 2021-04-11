void CreateCommandsNewMap()
{
	RegConsoleCmd("sm_newmap", Client_NewMap, "[surftimer] shows new maps");
	RegConsoleCmd("sm_nm", Client_NewMap, "[surftimer] shows new maps");
	RegAdminCmd("sm_addnewmap", Client_AddNewMap, ADMFLAG_ROOT, "[surftimer] add a new map");
	RegAdminCmd("sm_anm", Client_AddNewMap, ADMFLAG_ROOT, "[surftimer] add a new map");

}

public Action Client_NewMap(int client, int args)
{
	db_ViewNewestMaps(client);
	return Plugin_Handled;
}

public Action Client_AddNewMap(int client, int args)
{
	db_InsertNewestMaps();
	return Plugin_Handled;
}

public int NewMapMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
		delete menu;
}


public void db_ViewNewestMaps(int client)
{
	SQL_TQuery(g_hDb, sql_selectNewestMapsCallback, sql_selectNewestMaps, client, DBPrio_Low);
}

public void sql_selectNewestMapsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectNewestMapsCallback): %s", error);
		return;
	}

	char szMapName[64];
	char szDate[64];
	if (SQL_HasResultSet(hndl))
	{
		Menu menu = CreateMenu(NewMapMenuHandler);
		SetMenuTitle(menu, "New Maps: ");

		int i = 1;
		char szItem[128];
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szMapName, 64);
			SQL_FetchString(hndl, 1, szDate, 64);
			Format(szItem, sizeof(szItem), "%s since %s", szMapName, szDate);
			AddMenuItem(menu, "", szItem, ITEMDRAW_DISABLED);
			i++;
		}
		if (i == 1)
		{
			delete menu;
		}
		else
		{
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, data, MENU_TIME_FOREVER);
		}
	}
}

public void db_InsertNewestMaps()
{
	char szQuery[512];
	Format(szQuery, 512, sql_insertNewestMaps, g_szMapName);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, DBPrio_Low);
}
