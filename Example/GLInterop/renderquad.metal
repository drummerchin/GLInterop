//
//  renderquad.metal
//  
//
//  Created by Qin Hong on 7/5/19.
//  Copyright © 2019 Qin Hong. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct
{
    float4 position [[position]];
    float2 texCoord;
} VertexOut;

constant float4x4 renderedCoordinates(float4( -1.0, -1.0, 0.0, 1.0 ),
                                      float4(  1.0, -1.0, 0.0, 1.0 ),
                                      float4( -1.0,  1.0, 0.0, 1.0 ),
                                      float4(  1.0,  1.0, 0.0, 1.0 ));

constant float4x2 textureCoordinates(float2( 0.0, 1.0 ),
                                     float2( 1.0, 1.0 ),
                                     float2( 0.0, 0.0 ),
                                     float2( 1.0, 0.0 ));

constexpr sampler gSampler(coord::normalized, address::clamp_to_edge, filter::linear);

vertex VertexOut vertexDefault(ushort vid [[vertex_id]])
{
    VertexOut out;
    out.position = renderedCoordinates[vid];
    out.texCoord = textureCoordinates[vid];
    return out;
}

fragment half4 passthrough(VertexOut in [[stage_in]], texture2d<half, access::sample> inTexture [[texture(0)]])
{
    return inTexture.sample(gSampler, in.texCoord);
}

