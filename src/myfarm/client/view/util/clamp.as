package myfarm.client.view.util
{
/**
 * Clamp a number between given min and max values.
 *
 * @param value to clamp
 * @param min minimal value
 * @param max maximum value
 * @return either min, max or value itself if it's in between
 */
public function clamp(value:Number, min:Number, max:Number):Number
{
    return Math.min(max, Math.max(min, value));
}
}
