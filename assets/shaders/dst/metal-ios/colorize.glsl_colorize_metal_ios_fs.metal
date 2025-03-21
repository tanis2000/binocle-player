#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct main0_out
{
    float4 fragColor [[color(0)]];
};

struct main0_in
{
    float2 tcoord [[user(locn0)]];
};

fragment main0_out main0(main0_in in [[stage_in]], texture2d<float> tex0 [[texture(0)]], sampler smp [[sampler(0)]])
{
    main0_out out = {};
    if (tex0.sample(smp, in.tcoord).w < 0.100000001490116119384765625)
    {
        discard_fragment();
    }
    out.fragColor = float4(1.0);
    return out;
}

