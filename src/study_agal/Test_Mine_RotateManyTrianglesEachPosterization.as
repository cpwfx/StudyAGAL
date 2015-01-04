package study_agal {
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.Context3DVertexBufferFormat;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Vector3D;

import study_agal.Main3D;

public class Test_Mine_RotateManyTrianglesEachPosterization extends Main3D {

    private const rotationAxis:Vector3D = new Vector3D(0,0,1);
    private const P1:Point = new Point();
    private const P2:Point = new Point();

    private var _rotationMat:Matrix3D = new Matrix3D();
    private var _projMat:Matrix3D;
    private var _triangles:Vector.<Triangle> = new <Triangle>[];
    private var _count:uint;

    protected override function main():void {
        super.main();

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
                "mov ft0, v0\n"+
                "mul ft0.xyz, ft0, fc0.xxx\n"+
                "frc ft1, ft0\n"+
                "sub ft0.xyz, ft0, ft1\n"+
                "div ft0.xyz, ft0, fc0.yyy\n"+
                "sat oc, ft0"

        program =   createProgram(agal_vertex, agal_fragment, 1 , true, false);

        var vertexes:Vector.<Number> = new <Number>[];
        var indexes:Vector.<uint> = new <uint>[];
        for(var i:int=0;i<64;i++)
        {
            //正三角形を描画
            var xx:Number = (2*Math.random())-1;
            var yy:Number = (2*Math.random())-1;
            var zz:Number = Math.random()*0.1;
            var rot:Number = 2 * Math.random() * Math.PI;
            var tri:Triangle = new Triangle(0.2,xx,yy,zz,rot);
            _triangles.push(tri);
            vertexes.push(
                tri.getVertexAt(0).x, tri.getVertexAt(0).y, tri.getVertexAt(0).z, 1, 1, 0,
                tri.getVertexAt(1).x, tri.getVertexAt(1).y, tri.getVertexAt(1).z, 0, 1, 1,
                tri.getVertexAt(2).x, tri.getVertexAt(2).y, tri.getVertexAt(2).z, 1, 0, 1
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

        context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, new <Number>[properties.step,properties.step-1,0,0]);

        addLabel('マウスを動かしてください\n<font size="12">(三角形の回転スピードが変化します)</font>');
    }

    private function _updateTriangles(step:Number, scale:Number):void
    {
        var vertexes:Vector.<Number>  = getVertexData();
        for(var i:int=0;i<_triangles.length;i++)
        {
            var tri:Triangle = _triangles[i];
            tri.scale = scale;
            tri.rotation += step;
            tri.updateVertexes();

            var index:int = i*3*6;
            vertexes[index + 0 ] = tri.getVertexAt(0).x;
            vertexes[index + 1 ] = tri.getVertexAt(0).y;
            vertexes[index + 2 ] = tri.getVertexAt(0).z;

            vertexes[index + 6 ] = tri.getVertexAt(1).x;
            vertexes[index + 7 ] = tri.getVertexAt(1).y;
            vertexes[index + 8 ] = tri.getVertexAt(1).z;

            vertexes[index + 12] = tri.getVertexAt(2).x;
            vertexes[index + 13] = tri.getVertexAt(2).y;
            vertexes[index + 14] = tri.getVertexAt(2).z;
        }

        setVertexData( 6, vertexes);
        context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
        //context3D.setVertexBufferAt(1, _vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);

    }

    protected override function draw():void {
        super.draw();

        _count++;

        P2.x = stage.mouseX;
        P2.y = stage.mouseY;

        var ratio:Number;
        ratio = P1.subtract(P2).length / (viewHeight >> 1);

        if(ratio >= 1.0)
        {
            ratio = 1.0;
        }

        _updateTriangles(0.01 + 1.0 * (1.0 - ratio), 0.5 + ratio * 0.5);
        _rotationMat.appendRotation(0.1 + 2 * (1.0 - ratio), rotationAxis, new Vector3D(0,0,0.5));

        ratio = 0.9 + ratio * 0.1;
        _projMat.identity();
        _projMat.appendScale(ratio * viewHeight / viewWidth, ratio, ratio);
        context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, _projMat);
        context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _rotationMat);
        context3D.drawTriangles(_indexDataBuffer);
    }
}
}

import flash.geom.Vector3D;

internal class Triangle
{
    private static const BASE_RAD:Number = 2 * Math.PI / 3;

    public var size:Number;

    private var _x:Number = 0;
    private var _y:Number = 0;
    private var _z:Number = 0;
    private var _scale:Number = 0.1;

    private var _rotation:Number = 0;
    private var _vertexes:Vector.<Vector3D> = new <Vector3D>[];

    public function Triangle(size:Number, x:Number,y:Number,z:Number,rotation:Number = 0)
    {
        this.size = size;
        _x = x;
        _y = y;
        _z = z;
        _vertexes.push(new Vector3D());
        _vertexes.push(new Vector3D());
        _vertexes.push(new Vector3D());
        _scale = 1.0;
        this.rotation = rotation;
    }

    public function getVertexAt(index:int):Vector3D
    {
        var v3d:Vector3D = _vertexes[index];
        return v3d;
    }

    public function get rotation():Number {
        return _rotation;
    }

    public function get scale():Number {
        return _scale;
    }

    public function set scale(value:Number):void {
        _scale = value;
    }

    public function set rotation(value:Number):void {
        _rotation = value;
    }

    public function updateVertexes():void
    {
        for(var i:int=0;i<3;i++)
        {
            var rot:Number = _rotation + i * BASE_RAD;
            var v3d:Vector3D = _vertexes[i];
            v3d.x = _x + size * _scale * Math.cos(rot);
            v3d.y = _y + size * _scale * Math.sin(rot);
            v3d.z = _z;
        }

    }
}