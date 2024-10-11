cbuffer fs_params : register(b0)
{
    float _11_time : packoffset(c0);
    float _11_verticalOffset : packoffset(c0.y);
    float _11_horizontalOffset : packoffset(c0.z);
};

Texture2D<float4> tex0 : register(t0);
SamplerState smp : register(s0);

static float2 tcoord;
static float4 fragColor;
static float4 color;

struct SPIRV_Cross_Input
{
    float2 tcoord : TEXCOORD0;
    float4 color : TEXCOORD1;
};

struct SPIRV_Cross_Output
{
    float4 fragColor : SV_Target0;
};

void frag_main()
{
    fragColor = color * tex0.Sample(smp, tcoord + ((float2(mad((_11_horizontalOffset * tcoord.x) * tcoord.x, 0.300000011920928955078125f, cos(mad(_11_time, 2.0f, tcoord.y * 10.0f))), mad(_11_verticalOffset, 1.2000000476837158203125f - tcoord.x, cos(mad(_11_time, 2.0f, tcoord.x * 20.0f)))) * 0.02999999932944774627685546875f) * (1.0f - tcoord.x)));
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    tcoord = stage_input.tcoord;
    color = stage_input.color;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.fragColor = fragColor;
    return stage_output;
}
