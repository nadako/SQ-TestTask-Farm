package myfarm.client.model.server
{
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLVariables;

import myfarm.client.IFacade;

/**
 * Server connection class. Provides a method
 * to make an RPC request to the server and
 * dispatches data returned from server.
 */
public class ServerConnection
{
    private var facade:IFacade;
    private var baseURL:String;

    /**
     * Create a server connection object
     *
     * @param facade application facade
     * @param baseURL base URL for making requests
     */
    public function ServerConnection(facade:IFacade, baseURL:String)
    {
        this.facade = facade;

        var i:int = baseURL.lastIndexOf("/");
        if ((i == -1) || (i != (baseURL.length - 1)))
            baseURL += "/";
        this.baseURL = baseURL;
    }

    /**
     * Make an RPC request. This will make a GET HTTP request
     * to the 'baseURL/method' url, supplying parameters as
     * GET query string.
     *
     * @param method server method name
     * @param params parameters object, if needed
     */
    public function request(method:String, params:Object = null):void
    {
        trace("Making RPC request, method: " + method + ", params: " + JSON.stringify(params));
        var request:URLRequest = new URLRequest(baseURL + method);
        if (params)
        {
            var vars:URLVariables = new URLVariables();
            for (var key:String in params)
                vars[key] = params[key];
            request.data = vars;
        }
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, onRequestLoaderComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onRequestLoaderError);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequestLoaderError);
        loader.load(request);
    }

    /**
     * Called when request successfully done. Either dispatches
     * ServerEvent.GAME_DATA or ServerErrorEvent.SERVER_ERROR to
     * the application event relay.
     */
    private function onRequestLoaderComplete(event:Event):void
    {
        var loader:URLLoader = event.target as URLLoader;
        trace("Got response from server: " + loader.data);
        var xml:XML = new XML(loader.data as String);
        if (xml.name() == "error")
            facade.eventRelay.dispatchEvent(new ServerErrorEvent(ServerErrorEvent.SERVER_ERROR, xml.@id, xml.text()));
        else
            facade.eventRelay.dispatchEvent(new ServerEvent(ServerEvent.GAME_DATA, xml));
        disposeLoader(loader);
    }

    /**
     * Called when request is unsuccessful. Dispatches ServerErrorEvent.SERVER_ERROR.
     */
    private function onRequestLoaderError(event:ErrorEvent):void
    {
        trace("Server request error", event.errorID, event.text);
        facade.eventRelay.dispatchEvent(new ServerErrorEvent(ServerErrorEvent.SERVER_ERROR, event.errorID, event.text));
        disposeLoader(event.target as URLLoader);
    }

    /**
     * Remove any listeners for given loader, so we are nice and clean.
     */
    private function disposeLoader(loader:URLLoader):void
    {
        loader.removeEventListener(Event.COMPLETE, onRequestLoaderComplete);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onRequestLoaderError);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequestLoaderError);
    }
}
}
