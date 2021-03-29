shader_type spatial;

uniform sampler2D heightTexture;
uniform sampler2D grassTexture;
uniform sampler2D grassNormal;
uniform sampler2D rockTexture;
uniform sampler2D rockNormal;
uniform sampler2D sandTexture;
uniform sampler2D sandNormal;
uniform sampler2D snowTexture;
uniform sampler2D snowNormal;
uniform vec3 weightness = vec3(0.25, 0.45, 0.85);
uniform vec2 textureTiling = vec2(8, 8);
uniform float heightMultiplier = 1.0;
uniform float startHeight = 0.5;
uniform float roughness = 0.9;

void vertex()
{
	float height = texture(heightTexture, UV).r;
	float k = (height * heightMultiplier);
	VERTEX.y = k - startHeight;
	NORMAL = normalize(VERTEX);
}

vec3 getWeightMap(float height)
{
	if (height <= weightness.x)
	{
		return vec3(1, 0, 0); // Sand
	}
	else if (height <= weightness.y)
	{
		return vec3(0, 0, 0); // Grass
	}
	else if (height <= weightness.z)
	{
		return vec3(0, 1, 0); // Rock
	}
	
	return vec3(0, 0, 1); // Snow
}

vec3 sampleTextures(sampler2D sampler1, sampler2D sampler2, sampler2D sampler3, sampler2D sampler4, vec2 uv, vec3 weight)
{
	vec3 sandTex = texture(sampler1, uv).xyz;
    vec3 grassTex = texture(sampler2, uv).xyz;
	vec3 rockTex = texture(sampler3, uv).xyz;
    vec3 snowTex = texture(sampler4, uv).xyz;
	
	float lum = clamp(1.0 - weight.x - weight.y - weight.z, 0, 1);
    vec3 diffuse = lum * grassTex;
    diffuse += weight.x * sandTex + weight.y * rockTex + weight.z * snowTex;
	return diffuse;
}

void fragment()
{
	float height = texture(heightTexture, UV).x;
	vec3 weight = getWeightMap(height);
    vec3 albedo = sampleTextures(sandTexture, grassTexture, rockTexture, snowTexture, UV * textureTiling, weight);
	vec3 normal = sampleTextures(sandNormal, grassNormal, rockNormal, snowNormal, UV * textureTiling, weight);
		
	ALBEDO = albedo;
	NORMALMAP = normal;
	ROUGHNESS = roughness;
}