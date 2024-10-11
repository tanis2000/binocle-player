#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct vs_params
{
    float2 disp_size;
    float4x4 projmtx;
};

struct main0_out
{
    float2 uv [[user(locn0)]];
    float4 color [[user(locn1)]];
    float4 gl_Position [[position]];
};

struct main0_in
{
    float2 position [[attribute(0)]];
    float2 texcoord0 [[attribute(1)]];
    float4 color0 [[attribute(2)]];
};

vertex main0_out main0(main0_in in [[stage_in]], constant vs_params& _23 [[buffer(0)]])
{
    main0_out out = {};
    out.gl_Position = float4(((in.position / _23.disp_size) - float2(0.5)) * float2(2.0, -2.0), 0.5, 1.0);
    out.uv = in.texcoord0;
    out.color = in.color0;
    return out;
}

