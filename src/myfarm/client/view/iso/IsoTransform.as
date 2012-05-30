package myfarm.client.view.iso
{
import flash.geom.Point;

/**
 * Default IIsoTransform implementation.
 *
 * Simple 2:1 projection.
 */
public class IsoTransform implements IIsoTransform
{
    public function isoToScreen(isoPoint:Point, result:Point = null):Point
    {
        result = result ? result : new Point();
        result.x = isoPoint.x + isoPoint.y;
        result.y = (isoPoint.y - isoPoint.x) * 0.5;
        return result;
    }

    public function screenToIso(screenPoint:Point, result:Point = null):Point
    {
        result = result ? result : new Point();
        result.x = screenPoint.x * 0.5 - screenPoint.y;
        result.y = screenPoint.x * 0.5 + screenPoint.y;
        return result;
    }

    public function getDepth(isoCoords:Point):Number
    {
        return isoCoords.x - isoCoords.y;
    }
}
}
