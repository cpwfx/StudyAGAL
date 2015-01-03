package {
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

[SWF(frameRate=60,width=640,height=480,backgroundColor=0x333333)]
public class StudyAGAL extends Sprite {

    private static const SHADOW:DropShadowFilter = new DropShadowFilter(4.0, 45, 0x000000, 0.3);

    public function StudyAGAL()
    {
        _createButton("basic agal test", Test_2D);
    }

    private function _createButton(str:String,clazz:Class):void
    {
        var tf:TextField = new TextField();
        tf.width = 200;
        tf.height = 20;
        tf.border = true;
        tf.borderColor = 0xeeeeee;
        tf.background = true;
        tf.backgroundColor = 0x999999;
        tf.selectable = false;
        tf.x = 10;
        tf.y = height + 20;
        tf.defaultTextFormat = new TextFormat("_sans", 12, 0xffffff, false, false, false, null, null, TextFormatAlign.CENTER);
        tf.text = str;
        tf.filters = [SHADOW];
        addChild(tf);

        tf.addEventListener(MouseEvent.CLICK, function(ev:MouseEvent):void{
            _clearDisplayObject();
            addChild(new clazz());
        })
    }

    private function _clearDisplayObject():void
    {
        while(numChildren)
        {
            removeChildAt(0);
        }
    }


}
}