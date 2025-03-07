#version 410

uniform vec2 resolution;
uniform sampler2D tex0;
out vec4 fragColor;

void main() {

  vec2 uv = gl_FragCoord.xy / resolution.xy;
  vec4 texColor = texture( tex0, uv );
  fragColor = texColor;

}

/*
void main() {
  gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}
*/