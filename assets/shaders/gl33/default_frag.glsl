#version 410
uniform sampler2D tex0;
in vec2 tcoord;
in vec4 color;
out vec4 fragColor;

void main(void) {
    vec4 texcolor = texture(tex0, tcoord);
    fragColor = color * texcolor;
}
