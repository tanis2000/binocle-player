#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct fs_params
{
    float time;
    float verticalOffset;
    float horizontalOffset;
};

struct main0_out
{
    float4 fragColor [[color(0)]];
};

struct main0_in
{
    float2 tcoord [[user(locn0)]];
    float4 color [[user(locn1)]];
};

fragment main0_out main0(main0_in in [[stage_in]], constant fs_params& _11 [[buffer(0)]], texture2d<float> tex0 [[texture(0)]], sampler smp [[sampler(0)]])
{
    main0_out out = {};
    out.fragColor = in.color * tex0.sample(smp, (in.tcoord + ((float2(fma((_11.horizontalOffset * in.tcoord.x) * in.tcoord.x, 0.300000011920928955078125, cos(fma(_11.time, 2.0, in.tcoord.y * 10.0))), fma(_11.verticalOffset, 1.2000000476837158203125 - in.tcoord.x, cos(fma(_11.time, 2.0, in.tcoord.x * 20.0)))) * 0.02999999932944774627685546875) * (1.0 - in.tcoord.x))));
    return out;
}

