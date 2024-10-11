#pragma clang diagnostic ignored "-Wmissing-prototypes"

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct fs_params
{
    float2 resolution;
    float2 scale;
    float2 viewport;
    float pixelPerfect;
};

struct main0_out
{
    float4 fragColor [[color(0)]];
};

struct main0_in
{
    float2 uvCoord [[user(locn0)]];
};

static inline __attribute__((always_inline))
float2 uv_iq(thread const float2& uv, thread const int2& texture_size)
{
    float2 _20 = float2(texture_size);
    float2 _27 = floor(fma(uv, _20, float2(0.5)));
    return (_27 + fast::clamp(fma(uv, _20, -_27) / fwidth(uv * _20), float2(-0.5), float2(0.5))) / float2(texture_size);
}

fragment main0_out main0(main0_in in [[stage_in]], constant fs_params& _50 [[buffer(0)]], texture2d<float> tex0 [[texture(0)]], sampler smp [[sampler(0)]], float4 gl_FragCoord [[position]])
{
    main0_out out = {};
    if (_50.pixelPerfect > 0.0)
    {
        float2 param = ((gl_FragCoord.xy - floor(_50.viewport)) / _50.resolution) * _50.scale;
        int2 param_1 = int2(_50.resolution);
        out.fragColor = tex0.sample(smp, uv_iq(param, param_1));
    }
    else
    {
        out.fragColor = tex0.sample(smp, in.uvCoord);
    }
    return out;
}

