package myfarm.common.vo
{
import flash.geom.Point;

/**
 * Representation of a plant definition,
 * containing common data for plants of
 * some type.
 */
public class PlantType
{
    public var id:String; // string identifier of a plant type
    public var name:String; // human readable name
    public var size:Point; // x and y dimensions of a plant
    public var numStages:uint; // number of growth stages (last one means fully grown)

    public var graphicAnchors:Vector.<Point>; // graphics anchors for rendering, each point in this vector
                                              // contains a graphics anchor for corresponding growth stage graphics

    /**
     * Construct and return a path for graphics to load for given growth stage.
     *
     * @param stage growth stage
     * @return asset path for stage graphics.
     */
    public function getStageGraphicPath(stage:uint):String
    {
        return id + "/" + stage + ".png";
    }
}
}
