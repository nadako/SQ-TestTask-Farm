package myfarm.client
{
import flash.events.IEventDispatcher;

import myfarm.client.model.GameDataManager;
import myfarm.client.model.resource.IResourceManager;
import myfarm.client.model.server.ServerConnection;

public interface IFacade
{
    function get eventRelay():IEventDispatcher;

    function get resourceManager():IResourceManager;

    function get gameDataManager():GameDataManager;

    function get server():ServerConnection;
}
}
