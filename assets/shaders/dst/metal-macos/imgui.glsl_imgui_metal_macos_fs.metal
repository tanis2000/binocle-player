#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct main0_out
{
    float4 frag_color [[color(0)]];
};

struct main0_in
{
    float2 uv [[user(locn0)]];
    float4 color [[user(locn1)]];
};

fragment main0_out main0(main0_in in [[stage_in]], texture2d<float> tex [[texture(0)]], sampler smp [[sampler(0)]])
{
    main0_out out = {};
    out.frag_color = tex.sample(smp, in.uv) * in.color;
    return out;
}

