package myfarm.client.view.widgets
{
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.utils.Dictionary;

import myfarm.common.IDisposable;

/**
 * Very basic item selector.
 *
 * It creates a bunch of vertically arranged TextButtons
 * for every option supplied.
 *
 * To use it, listen to TextButtonMenuEvent.ITEM_SELECT event.
 */
public class TextButtonMenu extends Sprite implements IDisposable
{
    private var buttons:Dictionary = new Dictionary();

    /**
     * Create TextButtonMenu.
     *
     * @param values dictionary where keys are values to be dispatched
     * in TextButtonMenuEvent.ITEM_SELECT event and values are button
     * labels for corresponding values.
     */
    public function TextButtonMenu(values:Object)
    {
        var button:TextButton;
        var y:Number = 0;
        for (var value:String in values)
        {
            button = new TextButton(values[value]);
            button.y = y;
            button.addEventListener(MouseEvent.CLICK, onItemButtonClick);
            buttons[button] = value;
            addChild(button);
            y += button.height + 5;
        }
    }

    /**
     * Clean up listeners.
     */
    public function dispose():void
    {
        var button:TextButton;
        for (var b:Object in buttons)
        {
            button = b as TextButton;
            button.removeEventListener(MouseEvent.CLICK, onItemButtonClick);
        }
    }

    /**
     * Dispatch TextButtonMenuEvent.ITEM_SELECT when user clicks one
     * of the buttons.
     *
     * @param event button click event
     */
    private function onItemButtonClick(event:MouseEvent):void
    {
        var value:String = buttons[event.target as TextButton];
        dispatchEvent(new TextButtonMenuEvent(TextButtonMenuEvent.ITEM_SELECT, value));
    }
}
}
