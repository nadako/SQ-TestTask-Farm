package myfarm.client.model.resource
{
import flash.events.Event;
import flash.events.EventDispatcher;

/**
 * Very simple resource manager. It handles resource
 * loading and storage, preventing duplicate loads.
 *
 * You should manually check if resource is already
 * present with "hasResource" method, and if it is,
 * retrieve it with "getResource", or load it using
 * the "load" method and listening to ResourceEvent.LOAD_COMPLETE
 * and ResourceEvent.LOAD_FAILED events.
 */
public class ResourceManager extends EventDispatcher implements IResourceManager
{
    private var storage:Object = {};
    private var currentLoadings:Object = {};
    private var _baseURL:String;

    public function ResourceManager(baseURL:String = "")
    {
        super();
        _baseURL = baseURL;
    }

    /**
     * Return whether resource with given URL is present.
     *
     * @param url the URL of the resource
     * @return true if resource is loaded, or false if not
     */
    public function hasResource(url:String, addBaseURL:Boolean = true):Boolean
    {
        if (addBaseURL)
            url = _baseURL + url;
        return url in storage;
    }

    /**
     * Return loaded resource with given URL
     *
     * @param url the URL of the resource
     * @return the loaded content (directly from Loader.content)
     */
    public function getResource(url:String, addBaseURL:Boolean = true):Object
    {
        if (addBaseURL)
            url = _baseURL + url;

        if (!(url in storage))
            return null;
        return storage[url];
    }


    /**
     * Load resource with given URL and store it in the manager.
     *
     * After calling this method, ResourceEvent.LOAD_COMPLETE
     * or ResourceEvent.LOAD_FAILED event will be dispatched with
     * given URL.
     *
     * @param url the URL of the resource
     */
    public function load(url:String, addBaseURL:Boolean = true):void
    {
        if (addBaseURL)
            url = _baseURL + url;

        if (url in currentLoadings)
            return;

        var loader:ResourceLoader = currentLoadings[url] = new ResourceLoader(url);
        loader.addEventListener(Event.COMPLETE, onLoadComplete);
        loader.addEventListener(Event.CANCEL, onLoadCancel);
        loader.load();
    }

    /**
     * Stop and cancel any current loadings and clear stored resources.
     */
    public function dispose():void
    {
        for each (var loader:ResourceLoader in currentLoadings)
            loader.dispose();
        currentLoadings = null;
        storage = null;
    }

    public function constructCompleteEventName(url:String, addBaseURL:Boolean = true):String
    {
        if (addBaseURL)
            url = _baseURL + url;

        return ResourceEvent.LOAD_COMPLETE + ":" + url;
    }

    public function constructFailedEventName(url:String, addBaseURL:Boolean = true):String
    {
        if (addBaseURL)
            url = _baseURL + url;

        return ResourceEvent.LOAD_FAILED + ":" + url;
    }

    /**
     * Called on successful load, storing loaded data, cleaning up
     * loader and dispatching ResourceEvent.LOAD_COMPLETE.
     */
    private function onLoadComplete(event:Event):void
    {
        var loader:ResourceLoader = event.target as ResourceLoader;
        loader.removeEventListener(Event.COMPLETE, onLoadComplete);
        loader.removeEventListener(Event.CANCEL, onLoadCancel);
        delete currentLoadings[loader.url];
        storage[loader.url] = loader.content;
        loader.dispose();
        dispatchEvent(new ResourceEvent(ResourceEvent.LOAD_COMPLETE, loader.url));
        dispatchEvent(new ResourceEvent(constructCompleteEventName(loader.url, false), loader.url));
    }

    /**
     * Called on unsuccessful load, cleaning up loader and dispatching
     * ResourceEvent.LOAD_FAILED.
     */
    private function onLoadCancel(event:Event):void
    {
        var loader:ResourceLoader = event.target as ResourceLoader;
        loader.removeEventListener(Event.COMPLETE, onLoadComplete);
        loader.removeEventListener(Event.CANCEL, onLoadCancel);
        delete currentLoadings[loader.url];
        loader.dispose();
        dispatchEvent(new ResourceEvent(ResourceEvent.LOAD_FAILED, loader.url));
        dispatchEvent(new ResourceEvent(constructFailedEventName(loader.url, false), loader.url));
    }

    public function get baseURL():String
    {
        return _baseURL;
    }

    public function set baseURL(value:String):void
    {
        _baseURL = value;
    }
}
}
