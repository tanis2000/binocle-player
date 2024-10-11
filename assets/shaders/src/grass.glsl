#pragma sokol @vs vs

in vec3 vertexPosition;
in vec2 vertexTCoord;
in vec4 vertexColor;
in vec3 vertexNormal;

out vec2 tcoord;
out vec4 color;

uniform vs_params {
    mat4 projectionMatrix;
    mat4 viewMatrix;
    mat4 modelMatrix;
};

void main(void) {
    gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(vertexPosition, 1.0);
    tcoord = vertexTCoord;
    color = vertexColor;
    vec3 n = vertexNormal;
    gl_PointSize = 1.0;
}

#pragma sokol @end

#pragma sokol @fs fs

uniform texture2D tex0;
uniform sampler smp;

uniform fs_params {
    float time;
    float verticalOffset;
    float horizontalOffset;
};

in vec2 tcoord;
in vec4 color;
out vec4 fragColor;


void main(void) {
    float t = time;
    vec2 uv = tcoord;
    float uv_x_deform = cos(uv.x);
    vec2 offs_uv = vec2(cos(t * 2.0 + uv.y * 10.0) + horizontalOffset * ( uv.x) * ( uv.x) * 0.3, cos(t * 2.0 + uv.x * 20.0) + verticalOffset * (1.2 - uv.x)) * 0.03 * (1.0 - uv.x);

    vec4 texcolor = texture(sampler2D(tex0, smp), tcoord + vec2(offs_uv.x, offs_uv.y));
    fragColor = color * texcolor;
}


#pragma sokol @end

#pragma sokol @program grass vs fs