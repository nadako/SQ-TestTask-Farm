package myfarm.client.model.server
{
import flash.events.ErrorEvent;
import flash.events.Event;

public class ServerErrorEvent extends ErrorEvent
{
    public static const SERVER_ERROR:String = "serverError";

    public function ServerErrorEvent(type:String, id:uint, text:String)
    {
        super(type, false, false, text, id);
    }

    override public function clone():Event
    {
        return new ServerErrorEvent(type, errorID, text);
    }
}
}
