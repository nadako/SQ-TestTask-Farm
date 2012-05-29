package myfarm.client.view.iso
{
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.geom.Point;

/**
 * Isometric scene that manages IsoObjects, placing
 * their display objects on scene container in appropriate
 * projected coordinates and depth.
 *
 * It also provides handy methods to translate coordinates
 * and supports isometric "cells".
 *
 * Object moving and sorting work is delayed and done in
 * "render" method, so you want to call it on your
 * scene to display it properly. It will only recalculate
 * stuff for updated IsoObjects.
 */
public class IsoScene
{
    private var _container:DisplayObjectContainer;
    private const _isoObjects:Vector.<IsoObject> = new Vector.<IsoObject>();

    internal const updates:Vector.<IsoObject> = new Vector.<IsoObject>();

    public var transform:IIsoTransform = new IsoTransform();
    public var cellSize:Number = 10;

    /**
     * Create IsoScene.
     *
     * @param container a container for IsoObject display objects
     */
    public function IsoScene(container:DisplayObjectContainer)
    {
        _container = container;
    }

    public function get container():DisplayObjectContainer
    {
        return _container;
    }

    public function get isoObjects():Vector.<IsoObject>
    {
        return _isoObjects;
    }

    /**
     * Transform isometric coordinates to display coordinates
     * local to scene container.
     *
     * @param isoPoint isometric point
     * @param result if given, this object used for writing
     *               display point, otherwise new Point is created
     *
     * @return display coordinates (local to scene container)
     */
    public function isoToLocal(isoPoint:Point, result:Point = null):Point
    {
        return transform.isoToScreen(isoPoint, result);
    }

    /**
     * Transform display coordinates (local to scene container) to
     * isometric coordinates.
     *
     * @param screenPoint display coordinates
     * @param result if given, this object used for writing
     *               isometric point, otherwise new Point is created
     *
     * @return isometric coordinates
     */
    public function localToIso(screenPoint:Point, result:Point = null):Point
    {
        return transform.screenToIso(screenPoint, result);
    }

    /**
     * Transform isometric world coordinates to cell coordinates
     *
     * @param isoPoint isometric coordinates
     * @param result if given, this object used for writing
     *               cell coordinates, otherwise new Point is created
     *
     * @return cell coordinates
     */
    public function isoToCell(isoPoint:Point, result:Point = null):Point
    {
        result = result ? result : new Point();
        result.x = Math.floor(isoPoint.x / cellSize);
        result.y = Math.floor(isoPoint.y / cellSize);
        return result;
    }

    /**
     * Transform cell coordinates to isometric world point
     *
     * @param cell cell coordinates
     * @param result if given, this object used for writing
     *               isometric point, otherwise new Point is created
     *
     * @return cell isometric coordinates
     */
    public function cellToIso(cell:Point, result:Point = null):Point
    {
        result = result ? result : new Point();
        result.x = cell.x * cellSize;
        result.y = cell.y * cellSize;
        return result;
    }

    /**
     * Align given isometric coordinates to its cell's
     * start coordinates.
     *
     * @param isoPoint isometric coordinates. New coordinates
     *                 will be written to this object.
     */
    public function alignToCell(isoPoint:Point):void
    {
        isoPoint.x = Math.floor(isoPoint.x / cellSize) * cellSize;
        isoPoint.y = Math.floor(isoPoint.y / cellSize) * cellSize;
    }

    /**
     * Add IsoObject to scene.
     *
     * @param isoObject object to add
     */
    public function addObject(isoObject:IsoObject):void
    {
        _isoObjects.push(isoObject);
        _container.addChild(isoObject.displayObject);
        isoObject.scene = this;
        isoObject.markForUpdating();
    }

    /**
     * Remove IsoObject from scene.
     *
     * @param isoObject object to remove
     */
    public function removeObject(isoObject:IsoObject):void
    {
        isoObject.scene = null;

        _isoObjects.splice(_isoObjects.indexOf(isoObject), 1);
        _container.removeChild(isoObject.displayObject);

        var i:int = updates.indexOf(isoObject);
        if (i != -1)
            updates.splice(i, 1);
    }

    /**
     * Render the scene, updating IsoObjects' display coordinates
     * and depth.
     *
     * @param event unused parameter that allows this method
     *        to be added as an event listener, for simplicity.
     */
    public function render(event:Event = null):void
    {
        if (!updates.length)
            return;

        // TODO: depth sorting
        var coords:Point = new Point();
        for each (var isoObject:IsoObject in updates)
        {
            transform.isoToScreen(new Point(isoObject.x, isoObject.y), coords);
            isoObject.displayObject.x = coords.x;
            isoObject.displayObject.y = coords.y;
            isoObject.updating = false;
        }

        updates.length = 0;
    }
}
}
