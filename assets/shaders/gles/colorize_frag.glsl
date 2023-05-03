#version 300 es
precision mediump float;
precision mediump int;

uniform sampler2D tex0;
uniform vec4 customColor;
in vec2 tcoord;
in vec4 color;
out vec4 fragColor;

void main(void) {
    vec4 texcolor = texture(tex0, tcoord);
    if (texcolor.a < 0.1) {
        discard;
    }
    fragColor = color * texcolor * customColor;
}
