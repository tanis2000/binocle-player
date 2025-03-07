#pragma sokol @vs vs

in vec3 position;

void main() {
    gl_Position = vec4( position, 1.0 );
}

#pragma sokol @end

#pragma sokol @fs fs

uniform fs_params {
    vec2 resolution;
};
uniform texture2D tex0;
uniform sampler smp;
out vec4 fragColor;

void main() {

    vec2 uv = gl_FragCoord.xy / resolution.xy;
    vec4 texColor = texture( sampler2D(tex0, smp), uv );
    fragColor = texColor;

}

/*
void main() {
  gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}
*/

#pragma sokol @end

#pragma sokol @program quad vs fs