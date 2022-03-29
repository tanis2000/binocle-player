#ifdef GL_ES
precision highp float;
#endif

uniform vec2 resolution;
uniform sampler2D texture;

void main() {

  vec2 uv = gl_FragCoord.xy / resolution.xy;
  vec4 texColor = texture2D( texture, uv );
  gl_FragColor = texColor;

}

/*
void main() {
  gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}
*/