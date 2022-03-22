#ifdef GL_ES
precision mediump float;
#endif
attribute vec3 position;
uniform mat4 transform;

void main() {
    gl_Position = transform * vec4( position, 1.0 );
}