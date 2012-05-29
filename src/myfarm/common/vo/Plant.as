package myfarm.common.vo
{
import flash.geom.Point;

/**
 * Representation of particular plant on field.
 * Contains data specific for each plant
 */
public class Plant
{
    public var type:PlantType; // plant type definition
    public var id:uint; // plant id
    public var position:Point; // position on the field
    public var stage:uint; // growth stage

    public function Plant(type:PlantType)
    {
        this.type = type;
    }
}
}
