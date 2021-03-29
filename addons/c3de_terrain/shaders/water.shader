shader_type spatial;

uniform sampler2D waterTexture;
uniform sampler2D waterNormal;
uniform sampler2D noiseTexture;
uniform vec2 textureTiling = vec2(8, 8);
uniform float alpha = 0.35;
uniform float roughness = 0.1;
uniform float startOffset = 0.0;

float wave(vec2 position)
{
  position += texture(waterNormal, position / 100.0).x * 2.0 - 1.0;
  vec2 wv = 1.0 - abs(sin(position));
  return pow(1.0 - pow(wv.x * wv.y, 0.65), 4.0);
}

float height(vec2 position, float time)
{
	float d = wave((position + time) * 0.4) * 0.02;
	d += wave((position - time) * 0.3) * 0.003;
	d += wave((position + time) * 0.5) * 0.002;
	d += wave((position - time) * 0.6) * 0.002;
	return d;
}

void vertex()
{
	vec2 pos = VERTEX.xz;
	float k = height(pos, TIME);
	VERTEX.y = k - startOffset;
	NORMAL = normalize(vec3(k - height(pos + vec2(0.1, 0.0), TIME), 0.1, k - height(pos + vec2(0.0, 0.1), TIME)));
}

void fragment()
{
	vec3 albedo = texture(waterTexture, UV * textureTiling).xyz;
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	
	vec3 normalMap = texture(waterNormal, UV * textureTiling).xyz;
	vec3 normal = normalize(NORMAL + normalMap);
	
	ALBEDO = albedo * vec3(0.1, 0.3, 0.5) + (0.1 * fresnel);
	//ALPHA = alpha;
	//NORMAL = normal;
	RIM = 0.2;
	METALLIC = 0.9;
	ROUGHNESS = roughness * (1.0 - fresnel);
}