#ifdef GL_ES
precision highp float;
#endif

#if __VERSION__ >= 140
	in vec4 Color0;
	in vec2 TexCoord0;
	in vec4 ColorizeOut;
	in vec3 ColorOffsetOut;
	in vec2 TextureSizeOut;
	in float PixelationAmountOut;
	in vec3 ClipPlaneOut;
	out vec4 fragColor;
#else
	varying vec4 Color0;
	varying vec2 TexCoord0;
	varying vec4 ColorizeOut;
	varying vec3 ColorOffsetOut;
	varying vec2 TextureSizeOut;
	varying float PixelationAmountOut;
	varying vec3 ClipPlaneOut;
	#define fragColor gl_FragColor
	#define texture texture2D
#endif

uniform sampler2D Texture0;

vec3 rainbow(float t) {
	t *= 4.0;
    vec3 rara = 0.5 + 0.5 * cos(6.28318 * (t + vec3(0.0, 1.0 / 3.0, 2.0 / 3.0)));
	// do that stuff. if you fancy
	return rara;
}

void main(void) {
	if (dot(gl_FragCoord.xy, ClipPlaneOut.xy) < ClipPlaneOut.z) discard;

	vec2 pa = vec2(1.0+PixelationAmountOut, 1.0+PixelationAmountOut) / TextureSizeOut;
	vec4 textureColor = texture(Texture0, PixelationAmountOut > 0.0 ? TexCoord0 - mod(TexCoord0, pa) + pa * 0.5 : TexCoord0);

    vec4 Color = Color0 * textureColor;
    vec3 Colorized = Color.rgb;

	vec2 uv_aligned = TexCoord0 - mod(TexCoord0, pa) + pa * 0.5;
	vec2 uv = PixelationAmountOut > 0.0 ? uv_aligned : TexCoord0;

	if (Color.a > 0.0) {
		Colorized += rainbow(uv_aligned.x + uv_aligned.y + ColorizeOut.r * 0.01) * 0.3;
	}

	fragColor = vec4(Colorized + ColorOffsetOut * Color.a, Color.a);
}