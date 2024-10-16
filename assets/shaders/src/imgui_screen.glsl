#pragma sokol @vs vs
#pragma sokol @glsl_options flip_vert_y

in vec3 position;
uniform vs_params {
    mat4 transform;
};
out vec2 uvCoord;

void main(void) {
    gl_Position = transform * vec4( position, 1.0 );
    uvCoord = (position.xy + vec2(1,1))/2.0;
}

#pragma sokol @end

#pragma sokol @fs fs

uniform fs_params {
    vec2 resolution;
    vec2 scale;
    vec2 viewport;
    float pixelPerfect;
};
uniform texture2D tex0;
uniform sampler smp;

out vec4 fragColor;
in vec2 uvCoord;
vec2 uv_iq( vec2 uv, ivec2 texture_size ) {
   vec2 pixel = uv * texture_size;

    vec2 seam = floor(pixel + 0.5);
    vec2 dudv = fwidth(pixel);
    pixel = seam + clamp( (pixel - seam) / dudv, -0.5, 0.5);

    return pixel / texture_size;
}

void main() {
    if (pixelPerfect > 0) {
        vec2 uv = (gl_FragCoord.xy - floor(viewport.xy)) / resolution.xy * scale;
        vec2 pixelPerfectUV = uv_iq(uv, ivec2(resolution.xy));
        fragColor = texture(sampler2D(tex0, smp), pixelPerfectUV);
    } else {
        vec4 texcolor = texture(sampler2D(tex0, smp), vec2(uvCoord.x, -uvCoord.y));
        fragColor = texcolor;
    }

}

#pragma sokol @end

#pragma sokol @program imgui_screen vs fs