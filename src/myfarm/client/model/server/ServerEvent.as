package myfarm.client.model.server
{
import flash.events.Event;

public class ServerEvent extends Event
{
    public static const GAME_DATA:String = "gameData";

    private var _data:XML;

    public function ServerEvent(type:String, data:XML)
    {
        super(type);
        _data = data;
    }

    public function get data():XML
    {
        return _data;
    }

    override public function clone():Event
    {
        return new ServerEvent(type, data);
    }
}
}
