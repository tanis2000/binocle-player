#ifdef GL_ES
precision mediump float;
#endif
uniform sampler2D tex0;
varying vec2 tcoord;
varying vec4 color;

void main(void) {
    vec4 texcolor = texture2D(tex0, tcoord);
    if (texcolor.a < 0.1) {
        discard;
    }
    gl_FragColor = color * texcolor;
}
