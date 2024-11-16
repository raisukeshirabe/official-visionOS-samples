/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A Metal texture shader.
*/

#include <metal_stdlib>
using namespace metal;

struct Args {
    float time;
};

bool equal(half a, half b) {
    return abs(a - b) < 1E-2;
}

[[kernel]]
void textureShader(uint2 gid [[thread_position_in_grid]],
                   constant Args *args [[buffer(0)]],
                   texture2d<half, access::read_write> texture [[texture(0)]],
                   texture2d<half, access::write> textureOut [[texture(1)]]
                   ){
    half aliveCount = 0;
    aliveCount += texture.read(uint2(gid[0] - 1, gid[1] + 1))[0];
    aliveCount += texture.read(uint2(gid[0] + 0, gid[1] + 1))[0];
    aliveCount += texture.read(uint2(gid[0] + 1, gid[1] + 1))[0];
    aliveCount += texture.read(uint2(gid[0] - 1, gid[1] - 1))[0];
    aliveCount += texture.read(uint2(gid[0] + 0, gid[1] - 1))[0];
    aliveCount += texture.read(uint2(gid[0] + 1, gid[1] - 1))[0];
    aliveCount += texture.read(uint2(gid[0] - 1, gid[1] + 0))[0];
    aliveCount += texture.read(uint2(gid[0] + 1, gid[1] + 0))[0];
    
    half cell = texture.read(gid)[0];
    
    if (equal(aliveCount, 3)) {
        cell = 1.0;
    } else if (!(equal(aliveCount, 2) || equal(aliveCount, 3))) {
        cell = 0.0;
    }
    
    texture.write(half4(cell, cell, cell, 1.0), gid);
    textureOut.write(half4(cell, cell, cell, 1.0), gid);
}
