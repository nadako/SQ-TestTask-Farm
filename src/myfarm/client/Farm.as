package myfarm.client
{
import com.junkbyte.console.Cc;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import myfarm.client.controller.CommandEvent;
import myfarm.client.controller.Controller;
import myfarm.client.model.GameDataManager;
import myfarm.client.model.resource.IResourceManager;
import myfarm.client.model.resource.ResourceManager;
import myfarm.client.model.server.ServerConnection;
import myfarm.client.view.WorldView;

public class Farm extends Sprite implements IFacade
{
    private var _eventRelay:IEventDispatcher;
    private var _resourceManager:IResourceManager;
    private var _server:ServerConnection;
    private var _gameDataManager:GameDataManager;
    private var controller:Controller;
    private var view:WorldView;

    public function Farm()
    {
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;

        // Console for debugging purposes.
        Cc.startOnStage(this, "`");

        _eventRelay = new EventDispatcher();
        _resourceManager = new ResourceManager("http://localhost:8080/static/");
        _gameDataManager = new GameDataManager(this);
        _server = new ServerConnection(this, "http://localhost:8080/");

        controller = new Controller(this);
        view = new WorldView(this, this);
        view.init();

        eventRelay.dispatchEvent(new CommandEvent(CommandEvent.INIT));
    }


    // IFacade implementation
    public function get eventRelay():IEventDispatcher
    {
        return _eventRelay;
    }

    public function get resourceManager():IResourceManager
    {
        return _resourceManager;
    }

    public function get server():ServerConnection
    {
        return _server;
    }

    public function get gameDataManager():GameDataManager
    {
        return _gameDataManager;
    }
}
}
