package myfarm.client.view.iso
{
import flash.display.DisplayObject;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;

import myfarm.common.IDisposable;

/**
 * Base isometric object class. Stores the display object
 * and isometric coordinates and works tightly with IsoScene
 * to provide proper rendering.
 *
 * It also redispatches mouse events from its display object,
 * so you can listen directly from IsoObject.
 *
 * Setting x and y properties change object's coordinates in
 * isometric world.
 *
 * TODO: z coordinate???
 */
public class IsoObject extends EventDispatcher implements IDisposable
{
    private var _displayObject:DisplayObject;
    private var _position:Point = new Point(0, 0);

    internal var scene:IsoScene;
    internal var updating:Boolean = false;

    public function IsoObject(displayObject:DisplayObject)
    {
        _displayObject = displayObject;
        _displayObject.addEventListener(MouseEvent.CLICK, dispatchEvent);
        _displayObject.addEventListener(MouseEvent.ROLL_OVER, dispatchEvent);
        _displayObject.addEventListener(MouseEvent.ROLL_OUT, dispatchEvent);
    }

    public function dispose():void
    {
        _displayObject.removeEventListener(MouseEvent.CLICK, dispatchEvent);
        _displayObject.removeEventListener(MouseEvent.ROLL_OVER, dispatchEvent);
        _displayObject.removeEventListener(MouseEvent.ROLL_OUT, dispatchEvent);
    }

    public function get displayObject():DisplayObject
    {
        return _displayObject;
    }

    public function get x():Number
    {
        return _position.x;
    }

    public function set x(value:Number):void
    {
        if (_position.x == value)
            return;

        _position.x = value;
        markForUpdating();
    }

    public function get y():Number
    {
        return _position.y;
    }

    public function set y(value:Number):void
    {
        if (_position.y == value)
            return;

        _position.y = value;
        markForUpdating();
    }

    public function get position():Point
    {
        return _position;
    }

    public function set position(value:Point):void
    {
        if (_position.equals(value))
            return;

        _position = value;
        markForUpdating();
    }

    internal function markForUpdating():void
    {
        if (updating || !scene)
            return;

        updating = true;
        scene.updates.push(this);
    }
}
}
