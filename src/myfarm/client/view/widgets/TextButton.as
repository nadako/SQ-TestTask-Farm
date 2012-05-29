package myfarm.client.view.widgets
{
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

/**
 * Very basic "button with text" class.
 *
 * No fancy stuff, hardcoded visual style,
 * useful for testing and prototyping purposes.
 */
public class TextButton extends Sprite
{
    private var textField:TextField;

    public function TextButton(text:String = "")
    {
        mouseChildren = false;
        useHandCursor = true;
        buttonMode = true;

        textField = new TextField();
        textField.autoSize = TextFieldAutoSize.LEFT;
        textField.selectable = false;
        textField.x = textField.y = 5;
        addChild(textField);

        this.text = text;
    }

    public function get text():String
    {
        return textField.text;
    }

    public function set text(value:String):void
    {
        textField.text = value;
        graphics.lineStyle(1);
        graphics.beginFill(0xFF0000, 0.75);
        graphics.drawRoundRect(0, 0, width + 10,  height + 10, 5);
        graphics.endFill();
    }
}
}
