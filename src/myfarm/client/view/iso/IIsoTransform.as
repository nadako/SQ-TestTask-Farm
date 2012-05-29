package myfarm.client.view.iso
{
import flash.geom.Point;

/**
 * Isometric space-to-screen transformations
 */
public interface IIsoTransform
{
    function isoToScreen(isoPoint:Point, result:Point = null):Point;

    function screenToIso(screenPoint:Point, result:Point = null):Point;
}
}
