package myfarm.client.model.resource
{
import flash.events.IEventDispatcher;

import myfarm.common.IDisposable;

public interface IResourceManager extends IEventDispatcher, IDisposable
{
    /**
     * Check if resource manager has the resource with given URL loaded.
     *
     * @param url URL of resource to check
     * @return true if resource is loaded
     */
    function hasResource(url:String, addBaseURL:Boolean = true):Boolean;

    /**
     * Get previously loaded resource with given URL.
     * Returns null if resource is not loaded.
     *
     * @param url URL of the resource
     * @return resource object
     */
    function getResource(url:String, addBaseURL:Boolean = true):Object;

    /**
     * Initiate loading of the resource with given URL.
     * If it's already loading, nothing happens.
     *
     * @param url
     */
    function load(url:String, addBaseURL:Boolean = true):void;

    /**
     * Construct an event name to be dispatched when specific resource is loaded.

     * @param url
     * @param addBaseURL
     * @return event name
     */
    function constructCompleteEventName(url:String, addBaseURL:Boolean = true):String;

    /**
     * Construct an event name to be dispatched when specific resource is failed to load.

     * @param url
     * @param addBaseURL
     * @return event name
     */
    function constructFailedEventName(url:String, addBaseURL:Boolean = true):String;

            /**
     * Set base URL for urls to prefix with when addBaseURL parameter
     * is true for has/getResource methods as well as load method.
     *
     * @param value URL prefix
     */
    function set baseURL(value:String):void;

    /**
     * Get current base URL prefix.
     */
    function get baseURL():String;
}
}
