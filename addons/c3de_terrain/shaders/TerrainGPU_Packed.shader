shader_type spatial;

uniform sampler2D heightTexture;
uniform sampler2D albedosTexture;
uniform sampler2D normalsTexture;
uniform float heightMultiplier = 1.0;
uniform float startHeight = 0.5;
uniform vec3 weightness = vec3(0.25, 0.45, 0.85);
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

vec3 sampleTextures(sampler2D sampler, vec2 uv, vec3 weight)
{
	vec3 sandTex = texture(sampler, vec2(0.0, 0.0) + uv).xyz;
    vec3 grassTex = texture(sampler, vec2(0.5, 0.0) + uv).xyz;
	vec3 rockTex = texture(sampler, vec2(0.0, 0.5) + uv).xyz;
    vec3 snowTex = texture(sampler, vec2(0.5, 0.5) + uv).xyz;
	
	float lum = clamp(1.0 - weight.x - weight.y - weight.z, 0, 1);
    vec3 diffuse = lum * grassTex;
    diffuse += weight.x * sandTex + weight.y * rockTex + weight.z * snowTex;
	return diffuse;
}

void fragment()
{
	float height = texture(heightTexture, UV).x;
	vec3 weight = getWeightMap(height); //texture(weightTexture, UV).xyz;
	vec2 uv = UV * vec2(0.5, 0.5);
	
	vec3 albedo = sampleTextures(albedosTexture, uv, weight);
	vec3 normal = sampleTextures(normalsTexture, uv, weight);
	
	ALBEDO = albedo;
	NORMALMAP = normal;
	ROUGHNESS = roughness;
}