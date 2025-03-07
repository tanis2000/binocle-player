#version 300 es

uniform vec4 vs_params[5];
layout(location = 0) in vec2 position;
out vec2 uv;
layout(location = 1) in vec2 texcoord0;
out vec4 color;
layout(location = 2) in vec4 color0;

void main()
{
    gl_Position = vec4(((position / vs_params[0].xy) - vec2(0.5)) * vec2(2.0, -2.0), 0.5, 1.0);
    uv = texcoord0;
    color = color0;
}

