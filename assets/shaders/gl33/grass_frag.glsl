#version 330
uniform sampler2D tex0;
uniform float time;
uniform float verticalOffset;
uniform float horizontalOffset;

in vec2 tcoord;
in vec4 color;
out vec4 fragColor;


void main(void) {
    float t = time;
    vec2 uv = tcoord;
    float uv_x_deform = cos(uv.x);
    vec2 offs_uv = vec2(cos(t * 2.0 + uv.y * 10.0) + horizontalOffset * ( uv.x) * ( uv.x) * 0.3, cos(t * 2.0 + uv.x * 20.0) + verticalOffset * (1.2 - uv.x)) * 0.03 * (1.0 - uv.x);

    vec4 texcolor = texture(tex0, tcoord + vec2(offs_uv.x, offs_uv.y));
    fragColor = color * texcolor;
}
