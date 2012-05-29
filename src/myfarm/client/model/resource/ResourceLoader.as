package myfarm.client.model.resource
{
import flash.display.Loader;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;

import myfarm.common.IDisposable;

/**
 * Simple wrapper for flash.display.Loader that handles all the
 * boring stuff.
 *
 * You create an instance of ResourceLoader, specifying resource URL
 * in its constructor, then add listeners to Event.COMPLETE (success)
 * and Event.CANCEL (failure) events, then call "load" function.
 *
 * After successful loading, the "content" property contains loaded
 * data. After using the loader, call "dispose" method to clean up.
 */
public class ResourceLoader extends EventDispatcher implements IDisposable
{
    private var _url:String;
    private var _content:Object;
    private var loader:Loader;

    public function ResourceLoader(url:String)
    {
        _url = url;
    }

    public function get url():String
    {
        return _url;
    }

    public function get content():Object
    {
        return _content;
    }

    /**
     * Try to load resource. After calling this method, ResourceLoader will
     * dispatch Event.COMPLETE and Event.CANCEL events (see class description).
     */
    public function load():void
    {
        loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
        loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderError);
        loader.load(new URLRequest(_url), new LoaderContext(true, ApplicationDomain.currentDomain));
    }

    /**
     * Cancel any loading, and remove a reference to loaded content if present.
     */
    public function dispose():void
    {
        disposeLoader();
        _content = null;
    }

    /**
     * Called on successful loading, cleans up loader,
     * sets the "content" property and dispatches Event.COMPLETE.
     */
    private function onLoaderComplete(event:Event):void
    {
        _content = loader.content;
        disposeLoader();
        dispatchEvent(new Event(Event.COMPLETE));
    }

    /**
     * Called when loading failed for whatever reason,
     * cleans up loading and dispatches Event.CANCEL.
     */
    private function onLoaderError(event:ErrorEvent):void
    {
        disposeLoader();
        dispatchEvent(new Event(Event.CANCEL));
    }

    /**
     * Stop and cancel any loading if present and remove the Loader.
     */
    private function disposeLoader():void
    {
        if (!loader)
            return;

        loader = new Loader();
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaderComplete);
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
        loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderError);
        try
        {
            loader.close();
        }
        catch (error:Error)
        {
            // do nothing if stream is not opened
        }
        loader.unloadAndStop();
        loader = null;
    }
}
}
