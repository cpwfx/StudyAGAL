package study_agal {
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.Context3DVertexBufferFormat;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Vector3D;

import study_agal.Main3D;

public class Test_Mine_RotateManyTriangles extends Main3D {

    private const rotationAxis:Vector3D = new Vector3D(0,0,1);
    private const P1:Point = new Point();
    private const P2:Point = new Point();

    private var _rotationMat:Matrix3D = new Matrix3D();
    private var _projMat:Matrix3D;

    protected override function main():void {
        super.main();

        backgroundColor =   0x444444;

        P1.x = viewWidth >> 1;
        P1.y = viewHeight >> 1;

        var agal_vertex:String =
                //回転行列を座標に掛け合わせる
                "m44 vt0, va0, vc0|" +
                //射影変換して出力
                "m44 op, vt0, vc4|" +
                //カラーはそのまま受けわたす
                "mov v0, va1";

        var agal_fragment:String =
                //そのまま出力
                "mov oc, v0";

        program =   createProgram(agal_vertex, agal_fragment, 2 , true, false);

        var vertexes:Vector.<Number> = new <Number>[];
        var indexes:Vector.<uint> = new <uint>[];
        const size:Number = 0.3;
        const w:Number = size * Math.cos(1 * Math.PI /3);
        const h:Number = size * Math.sin(2 * Math.PI /3);
        for(var i:int=0;i<32;i++)
        {
            //正三角形を描画
            var xx:Number = (2*Math.random())-1;
            var yy:Number = (2*Math.random())-1;
            var zz:Number = Math.random()*0.1;
            vertexes.push(
                xx    , yy         , zz, 1, 0, 1,
                xx - w, yy - h, zz, 1, 1, 0,
                xx + w, yy - h, zz, 0, 1, 1
            );

            indexes.push((i*3)+2, (i*3)+1, i*3);
        }

        indexData = indexes;//ここでアップロード

        setVertexData( 6, vertexes);

        context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
        context3D.setVertexBufferAt(1, _vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);
        context3D.setCulling(Context3DTriangleFace.NONE);

        _projMat = new Matrix3D();
        _projMat.appendScale(viewHeight / viewWidth, 1.0, 1.0);
        context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, _projMat);

        addLabel('マウスを動かしてください\n<font size="12">(三角形の回転スピードが変化します)</font>');
    }

    protected override function draw():void {
        super.draw();

        P2.x = stage.mouseX;
        P2.y = stage.mouseY;

        var ratio:Number;
        ratio = P1.subtract(P2).length / (viewHeight >> 1);

        if(ratio >= 1.0)
        {
            ratio = 1.0;
        }

        _rotationMat.appendRotation(0.1 + 15 * (1.0 - ratio), rotationAxis, new Vector3D(0,0,0.5));

        ratio = 0.5 + ratio * 0.5;
        _projMat.identity();
        _projMat.appendScale(ratio * viewHeight / viewWidth, ratio, ratio);
        context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, _projMat);

        context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _rotationMat);
        context3D.drawTriangles(_indexDataBuffer);
    }
}
}