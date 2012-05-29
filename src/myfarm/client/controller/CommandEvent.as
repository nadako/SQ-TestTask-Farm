package myfarm.client.controller
{
import flash.events.Event;

/**
 * Event to be dispatched on application event relay
 * as a command to the controller (see Controller class).
 */
public class CommandEvent extends Event
{
    public static const INIT:String = "commandInit";
    public static const PLANT:String = "commandPlant";
    public static const GROW:String = "commandGrow";
    public static const GATHER:String = "commandGather";

    private var _data:Object;

    /**
     * Create command event
     *
     * @param type name of the command to issue
     * @param data command specific data object
     *
     * One can make specific strongly-typed CommandEvent subclasses,
     * but it's easier to pass very simple command-specific parameter
     * hashes as the "data" argument to the constructor.
     */
    public function CommandEvent(type:String, data:Object = null)
    {
        super(type);
        _data = data;
    }

    public function get data():Object
    {
        return _data;
    }

    override public function clone():Event
    {
        return new CommandEvent(type, _data);
    }
}
}
