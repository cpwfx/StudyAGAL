package study_agal {
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.Context3DVertexBufferFormat;

import study_agal.Main3D;

/**
     * @author Pierre Chamberlain
     */
public class Test_ChangeBrightnessByMouse extends Main3D {

    private var brightness:Vector.<Number>;

    protected override function main():void {
        super.main();

        backgroundColor =   0x444444;

        brightness =        new <Number>[0,0,0,1];

        var agal_vertex:String =
            //Copies the vertex input#0's XYZW to the output vertex:
                "mov op, va0|" +
                    //Vary the brightness of the vertex input#1:
                "mul v0, vc0, va1";

        //Set the current program:
        program =  createProgram(agal_vertex, "mov oc, v0");

        setVertexData( 6, new <Number>[
            //Coordinates & Colors
            -.9, -.9, 0,    1, 0, 0,
            -.9, .9, 0,     1, 1, 0,
            .9, .9, 0,      0, 1, 0,
            .9, -.9, 0,     0, 0, 1
        ]);

        indexData = new <uint>[
            //Draw two triangles (a square)
            2,1,0, 3,2,0
        ];

        context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
        context3D.setVertexBufferAt(1, _vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);
        context3D.setCulling(Context3DTriangleFace.NONE);

        addLabel('Move Your Mouse Around\n<font size="12">(control the brightness of the vertices)</font>');
    }

    protected override function draw():void {
        super.draw();

        var currentBrightness:Number =  stage.mouseX / viewWidth;
        brightness[0] = currentBrightness;
        brightness[1] = currentBrightness;
        brightness[2] = currentBrightness;

        context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, brightness);
        context3D.drawTriangles(_indexDataBuffer);
    }
}
}