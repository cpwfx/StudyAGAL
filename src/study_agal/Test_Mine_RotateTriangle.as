package study_agal {
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.Context3DVertexBufferFormat;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;

import study_agal.Main3D;

public class Test_Mine_RotateTriangle extends Main3D {

    private var rotationMat:Matrix3D = new Matrix3D();

    protected override function main():void {
        super.main();

        backgroundColor =   0x444444;


        var agal_vertex:String =
                //回転行列を座標に掛け合わせる
                "m44 vt0, va0, vc0|" +
                //出力
                "mov op, vt0|" +
                //カラーはそのまま受けわたす
                "mov v0, va1";

        var agal_fragment:String =
                //そのまま出力
                "mov oc, v0";

        program =   createProgram(agal_vertex, agal_fragment);

        setVertexData( 6, new <Number>[
            //Coordinates & Colors
              0 ,  .6, 0,    1, 0, 1,
            -.5 , -.6, 0,    1, 1, 0,
             .5 , -.6, 0,    0, 1, 1
        ]);

        indexData = new <uint>[
            2,1,0
        ];

        context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
        context3D.setVertexBufferAt(1, _vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);
        context3D.setCulling(Context3DTriangleFace.NONE);

        addLabel('マウスを動かしてください\n<font size="12">(三角形の回転スピードが変化します)</font>');
    }

    protected override function draw():void {
        super.draw();

        var ratio1:Number =  stage.mouseX / viewWidth;
        var ratio2:Number =  stage.mouseY / viewHeight;

        rotationMat.appendRotation(0.1 + 4 * (ratio1 + ratio2), new Vector3D(0,0,1));

        context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, rotationMat);
        context3D.drawTriangles(_indexDataBuffer);
    }
}
}