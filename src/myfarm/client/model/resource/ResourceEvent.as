package myfarm.client.model.resource
{
import flash.events.Event;

public class ResourceEvent extends Event
{
    public static const LOAD_COMPLETE:String = "loadComplete";
    public static const LOAD_FAILED:String = "loadFailed";

    private var _url:String;

    public function ResourceEvent(type:String, url:String)
    {
        super(type);
        _url = url;
    }

    public function get url():String
    {
        return _url;
    }

    override public function clone():Event
    {
        return new ResourceEvent(type, _url);
    }
}
}
