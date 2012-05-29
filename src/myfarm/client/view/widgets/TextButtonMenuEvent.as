package myfarm.client.view.widgets
{
import flash.events.Event;

public class TextButtonMenuEvent extends Event
{
    public static const ITEM_SELECT:String = "itemSelect";

    private var _value:String;

    public function TextButtonMenuEvent(type:String, value:String)
    {
        super(type);
        _value = value;
    }

    public function get value():String
    {
        return _value;
    }

    override public function clone():Event
    {
        return new TextButtonMenuEvent(type, _value);
    }
}
}
