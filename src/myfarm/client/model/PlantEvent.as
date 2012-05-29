package myfarm.client.model
{
import flash.events.Event;

import myfarm.common.vo.Plant;

public class PlantEvent extends Event
{
    public static const PLANT_ADD:String = "plantAdd";
    public static const PLANT_MOVE:String = "plantMove";
    public static const PLANT_STAGE_CHANGE:String = "plantStageChange";
    public static const PLANT_REMOVE:String = "plantRemove";

    private var _plant:Plant;

    public function PlantEvent(type:String, plant:Plant)
    {
        super(type);
        _plant = plant;
    }

    public function get plant():Plant
    {
        return _plant;
    }
}
}
