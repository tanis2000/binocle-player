#version 410

uniform sampler2D tex_smp;

layout(location = 0) out vec4 frag_color;
layout(location = 0) in vec2 uv;
layout(location = 1) in vec4 color;

void main()
{
    frag_color = texture(tex_smp, uv) * color;
}

