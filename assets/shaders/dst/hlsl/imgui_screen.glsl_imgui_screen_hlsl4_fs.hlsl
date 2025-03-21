cbuffer fs_params : register(b0)
{
    float2 _50_resolution : packoffset(c0);
    float2 _50_scale : packoffset(c0.z);
    float2 _50_viewport : packoffset(c1);
    float _50_pixelPerfect : packoffset(c1.z);
};

Texture2D<float4> tex0 : register(t0);
SamplerState smp : register(s0);

static float4 gl_FragCoord;
static float4 fragColor;
static float2 uvCoord;

struct SPIRV_Cross_Input
{
    float2 uvCoord : TEXCOORD0;
    float4 gl_FragCoord : SV_Position;
};

struct SPIRV_Cross_Output
{
    float4 fragColor : SV_Target0;
};

float2 uv_iq(float2 uv, int2 texture_size)
{
    float2 _20 = float2(texture_size);
    float2 _27 = floor(mad(uv, _20, 0.5f.xx));
    return (_27 + clamp(mad(uv, _20, -_27) / fwidth(uv * _20), (-0.5f).xx, 0.5f.xx)) / float2(texture_size);
}

void frag_main()
{
    if (_50_pixelPerfect > 0.0f)
    {
        float2 param = ((gl_FragCoord.xy - floor(_50_viewport)) / _50_resolution) * _50_scale;
        int2 param_1 = int2(_50_resolution);
        fragColor = tex0.Sample(smp, uv_iq(param, param_1));
    }
    else
    {
        fragColor = tex0.Sample(smp, float2(uvCoord.x, -uvCoord.y));
    }
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    gl_FragCoord = stage_input.gl_FragCoord;
    gl_FragCoord.w = 1.0 / gl_FragCoord.w;
    uvCoord = stage_input.uvCoord;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.fragColor = fragColor;
    return stage_output;
}
