package study_agal  {
import com.adobe.utils.AGALMiniAssembler;
import flash.display.Sprite;
import flash.display.Stage3D;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display3D.Context3D;
import flash.display3D.Context3DProfile;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DRenderMode;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.VertexBuffer3D;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.ByteArray;

    /**
     * @author Pierre Chamberlain
     */
public class Main3D extends Sprite {
    private var _stage3D:Stage3D;
    private var _context3D:Context3D;
    private var _program:Program3D;

    private var _backgroundColor:Vector.<Number> =    new <Number>[0,0,0];
    private var _indexData:Vector.<uint>;
    private var _vertexDataLength:int;
    private var _vertexData:Vector.<Number>;

    protected var _indexDataBuffer:IndexBuffer3D;
    protected var _vertexBuffer:VertexBuffer3D;

    public var properties:Object = {};

    public function Main3D() {
        super();

        stage ? init() :  addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event = null):void {
        e && removeEventListener(Event.ADDED_TO_STAGE, init);
        // entry point

        stage.align =       StageAlign.TOP_LEFT;
        stage.scaleMode =   StageScaleMode.NO_SCALE;

        prepareStage3D();
    }

    private function prepareStage3D():void {
        _stage3D =  stage.stage3Ds[0];
        _stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
        _stage3D.requestContext3D(Context3DRenderMode.AUTO, Context3DProfile.STANDARD);
    }

    private function onContextCreated(e:Event):void {
        _context3D =    _stage3D.context3D;
        if (!_context3D) {
            return;
        }

        _context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 1, false);
        _context3D.setCulling( Context3DTriangleFace.BACK );

        main();

        addEventListener(Event.ENTER_FRAME, render);
    }

    protected function main():void {
        //OVERRIDE
    }

    public final function render(e:Event=null):void {
        _context3D.clear(_backgroundColor[0], _backgroundColor[1], _backgroundColor[2]);

        draw();

        _context3D.present();
    }

    protected function draw():void {
        //OVERRIDE
    }

    ////////////////////////////////////////////////////////

    public function addLabel(pMessage:String):void {
        var format:TextFormat =     new TextFormat("Courier New", 20, 0xffffff, true);
        format.align =              TextFormatAlign.CENTER;
        var field:TextField =       new TextField();
        field.autoSize =            TextFieldAutoSize.LEFT;
        field.defaultTextFormat =   format;
        field.selectable =          false;
        field.mouseEnabled =        false;
        field.multiline =           true;
        field.wordWrap =            false;
        field.width =               1;
        field.height =              20;
        field.htmlText =            pMessage;
        field.x =                   (viewWidth - field.width) * .5;
        field.y =                   (viewHeight - field.height) * .5;

        addChild(field);
    }

    public function get program():Program3D { return _program; }
    public function set program(value:Program3D):void {
        _program = value;

        _context3D.setProgram(_program);
    }

    public function createProgram(vertexsrc:String, fragmentsrc:String, version:uint=1, debuggingAssembler:Boolean=false, verbose:Boolean=false):Program3D {
        var agal:AGALMiniAssembler = new AGALMiniAssembler(debuggingAssembler);
        agal.verbose = verbose;
        return agal.assemble2(_context3D, version, vertexsrc.replace(/\|/g,"\n"), fragmentsrc.replace(/\|/g,"\n"));
    }

    public function get backgroundColor():uint {
        var r:uint = _backgroundColor[0] * 255;
        var g:uint = _backgroundColor[1] * 255;
        var b:uint = _backgroundColor[2] * 255;

        return r << 16 | g << 8 | b;
    }

    public function set backgroundColor(value:uint):void {
        _backgroundColor[0] =   ((value >> 16) & 0xFF) / 255;
        _backgroundColor[1] =   ((value >> 8 ) & 0xFF) / 255;
        _backgroundColor[2] =   (value & 0xFF) / 255;
    }

    public function get indexData():Vector.<uint> { return _indexData; }
    public function set indexData(value:Vector.<uint>):void {
        _indexData =            value;
        _indexDataBuffer =      _context3D.createIndexBuffer( _indexData.length );
        _indexDataBuffer.uploadFromVector( _indexData, 0, _indexData.length );
    }

    public function setVertexData( pDataLength:int, pVertexData:Vector.<Number> ):void {
        _vertexDataLength = pDataLength;
        _vertexData =       pVertexData;
        _vertexBuffer =     _context3D.createVertexBuffer(numOfVertices, _vertexDataLength);
        _vertexBuffer.uploadFromVector(_vertexData, 0, numOfVertices);
    }

    public function get numOfIndexes():int {
        return !_indexData ? 0 : _indexData.length / 3;
    }

    public function get numOfVertices():int {
        return !_vertexData || _vertexDataLength <= 0 ? 0 : _vertexData.length / _vertexDataLength;
    }

    public function get stage3D():Stage3D { return _stage3D; }
    public function get context3D():Context3D { return _context3D; }
    public function get viewWidth():Number { return stage.stageWidth; }
    public function get viewHeight():Number { return stage.stageHeight; }
    public function get viewRatio():Number { return viewWidth / viewHeight; }
}
}