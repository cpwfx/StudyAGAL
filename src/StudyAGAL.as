package {
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import study_agal.Main3D;

import study_agal.Test_ChangeBrightnessByMouse;
import study_agal.Test_Mine_RotateManyTriangles;
import study_agal.Test_Mine_RotateTriangle;

[SWF(frameRate=60,width=480,height=360,backgroundColor=0x333333)]
public class StudyAGAL extends Sprite {

    private static const SHADOW:DropShadowFilter = new DropShadowFilter(4.0, 45, 0x000000, 0.3);

    private var _testLookup:Object = {};

    public function StudyAGAL()
    {
        _createButton("p1","Change brightness by mouse (pierrechamberlain blog part1)", Test_ChangeBrightnessByMouse);//http://pierrechamberlain.ca/blog/2011/12/as3-level-4-experimenting-agal-p1/
        _createButton("test1","Rotate Triangle", Test_Mine_RotateTriangle);
        _createButton("test2","Rotate Many Triangles", Test_Mine_RotateManyTriangles);


        var autotestId:String = loaderInfo.parameters["autotest"];
        trace("autotestId",autotestId);
        if(autotestId)
        {
            _startTest(autotestId);
        }
    }

    private function _createButton(id:String, str:String,clazz:Class):void
    {
        _testLookup[id] = clazz;

        var tf:TextField = new TextField();
        tf.width = 440;
        tf.height = 20;
        tf.border = true;
        tf.borderColor = 0xeeeeee;
        tf.background = true;
        tf.backgroundColor = 0x999999;
        tf.selectable = false;
        tf.x = 20;
        tf.y = getBounds(this).bottom + 10;
        tf.defaultTextFormat = new TextFormat("_sans", 12, 0xffffff, false, false, false, null, null, TextFormatAlign.CENTER);
        tf.text = str;
        tf.filters = [SHADOW];
        addChild(tf);

        tf.addEventListener(MouseEvent.CLICK, function(ev:MouseEvent):void{
            _startTest(id);
        });
    }

    private function _startTest(id:String):void
    {
        var clazz:Class = _testLookup[id];
        if(clazz)
        {
            _clearDisplayObject();
            var content:Main3D = new clazz() as Main3D;
            content.backgroundColor = 0x111111;
            addChild(content);
        }
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