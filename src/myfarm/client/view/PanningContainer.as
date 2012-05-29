package myfarm.client.view
{
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import myfarm.client.view.util.clamp;

/**
 * A wrapper for any display object that provides
 * mouse panning (drag scrolling), when display object
 * is larger than given width/height.
 */
public class PanningContainer extends Sprite
{
    public var mouseThreshold:Number = 10; // mouse move threshold, to disable children mouse events
                                           // this will prevent undesired behaviour when one wants to
                                           // click an object inside child, but moves his mouse a little
                                           // between mouseUp and mouseDown events.

    private var _width:Number;
    private var _height:Number;
    private var panPoint:Point;
    private var panStartPoint:Point;

    public function PanningContainer(child:DisplayObject, width:Number, height:Number)
    {
        addChild(child);
        setSize(width, height);
        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    }

    public function get child():DisplayObject
    {
        return getChildAt(0);
    }

    private function setSize(width:Number, height:Number):void
    {
        _width = width;
        _height = height;
        scrollRect = new Rectangle(0, 0, width, height);
        panBy(0, 0);
    }

    public function panBy(dx:Number, dy:Number):void
    {
        var minX:Number = _width - child.width;
        var maxX:Number = 0;
        var minY:Number = _height - child.height;
        var maxY:Number = 0;
        child.x = clamp(child.x + dx, minX, maxX);
        child.y = clamp(child.y + dy, minY, maxY);
    }

    private function onMouseDown(event:MouseEvent):void
    {
        removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);

        // listen to stage, so it will drag even if mouse leaves PanningContainer
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

        panPoint = new Point(event.stageX, event.stageY);
        panStartPoint = panPoint.clone();
    }

    private function onMouseMove(event:MouseEvent):void
    {
        var currentPoint:Point = new Point(event.stageX, event.stageY);

        // disable children mouse interaction if we dragged far enough, meaning
        // that we really want to drag the view, not click on an object inside
        if (mouseChildren && Math.abs(currentPoint.subtract(panStartPoint).length) > mouseThreshold)
            mouseChildren = false;

        panBy(currentPoint.x - panPoint.x, currentPoint.y - panPoint.y);
        panPoint.x = currentPoint.x;
        panPoint.y = currentPoint.y;
    }

    private function onMouseUp(event:MouseEvent):void
    {
        // cleanup stuff and reset listeners
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        mouseChildren = true;
        panPoint = panStartPoint = null;
    }
}
}
