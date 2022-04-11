#version 300 es
precision mediump float;
precision mediump int;

uniform vec2 resolution;
uniform sampler2D texture;
out vec4 fragColor;

void main() {

  vec2 uv = gl_FragCoord.xy / resolution.xy;
  vec4 texColor = texture( texture, uv );
  fragColor = texColor;

}

/*
void main() {
  gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}
*/