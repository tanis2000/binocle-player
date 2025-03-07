#version 410

uniform sampler2D tex0_smp;

layout(location = 0) in vec2 tcoord;
layout(location = 0) out vec4 fragColor;
layout(location = 1) in vec4 color;

void main()
{
    if (texture(tex0_smp, tcoord).w < 0.100000001490116119384765625)
    {
        discard;
    }
    fragColor = vec4(1.0);
}

