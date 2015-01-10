package {
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.UncaughtErrorEvent;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.setTimeout;

import study_agal.Main3D;

import study_agal.Test_ChangeBrightnessByMouse;
import study_agal.Test_Mine_RotateManyTriangles;
import study_agal.Test_Mine_RotateManyTrianglesEach;
import study_agal.Test_Mine_RotateManyTrianglesEachPosterization;
import study_agal.Test_Mine_RotateTriangle;

[SWF(frameRate=60,width=480,height=360,backgroundColor=0x333333)]
public class StudyAGAL extends Sprite {

    private static const SHADOW:DropShadowFilter = new DropShadowFilter(4.0, 45, 0x000000, 0.3);

    private var _testLookup:Object = {};
    private var _propsLookup:Object = {};
    private var _titleLookup:Object = {};

    public function StudyAGAL()
    {
        stage.color = 0x333333;

        _createTest("p1","Change brightness by mouse (pierrechamberlain blog part1)", Test_ChangeBrightnessByMouse);//http://pierrechamberlain.ca/blog/2011/12/as3-level-4-experimenting-agal-p1/
        _createTest("test1","Rotate Triangle", Test_Mine_RotateTriangle);//test2でもある
        _createTest("test3","Rotate Many Triangles", Test_Mine_RotateManyTriangles);
        _createTestAndButton("test3_2","Rotate Many Triangles Each", Test_Mine_RotateManyTrianglesEach);
        _createTestAndButton("test3_3","Rotate Many Posterized Triangles Each", Test_Mine_RotateManyTrianglesEachPosterization,{step:4});

        var autotestId:String = loaderInfo.parameters["autotest"];
        trace("autotestId",autotestId);
        if(autotestId)
        {
            _startTest(autotestId);
        }

        loaderInfo.uncaughtErrorEvents.addEventListener(
                UncaughtErrorEvent.UNCAUGHT_ERROR, function(e:UncaughtErrorEvent):void{
                    _showError(e.text);
                }
        );
    }

    private function _createTest(id:String, title:String, clazz:Class, props:Object = null):void
    {
        _titleLookup[id] = title;
        _testLookup[id] = clazz;
        _propsLookup[id] = props;
    }
    
    private function _createTestAndButton(id:String, title:String, clazz:Class, props:Object = null):void
    {
        _createTest(id, title, clazz, props);

        var tf:TextField = _createTf(title);
        tf.x = 20;
        tf.y = getBounds(this).bottom + 10;
        tf.border = true;
        tf.borderColor = 0xeeeeee;
        tf.background = true;
        tf.backgroundColor = 0x999999;
        tf.filters = [SHADOW];
        addChild(tf);

        tf.addEventListener(MouseEvent.CLICK, function(ev:MouseEvent):void{
            _startTest(id);
        });
    }

    private function _createTf(str:String,size:int=12,color:uint=0xffffff):TextField
    {
        var tf:TextField = new TextField();
        tf.width = 440;
        tf.height = size * 1.5;
        tf.selectable = false;
        tf.defaultTextFormat = new TextFormat("_sans", size, color, false, false, false, null, null, TextFormatAlign.CENTER);
        tf.text = str;
        return tf;
    }

    private function _startTest(id:String):void
    {
        var clazz:Class = _testLookup[id];
        var props:Object = _propsLookup[id];
        var title:String = _titleLookup[id];
        if(clazz)
        {
            _clearDisplayObject();
            try {
                var tf:TextField = _createTf(title ? title : clazz+"", 20, 0xff8811);
                tf.x = 5;
                tf.y = 5;
                tf.filters = [new GlowFilter(0x000000, 1.0, 2.0, 2.0)];
                addChild(tf);
                setTimeout(function():void{
                    if(tf && tf.parent)
                    {
                        tf.parent.removeChild(tf);
                    }
                },5000)

                var content:Main3D = new clazz() as Main3D;
                content.backgroundColor = 0x555555;
                for (var key:String in props) {
                    content.properties[key] = props[key];
                }
                addChild(content);
            }
            catch (e:Error)
            {
                _showError(e.message);
            }
        }
    }

    private function _showError(mes:String):void
    {
        _clearDisplayObject();
        var tf:TextField = _createTf(mes);
        tf.x = 20;
        tf.y = getBounds(this).bottom + 10;
        addChild(tf);
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