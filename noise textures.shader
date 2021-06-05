shader_type canvas_item;
// Gonkee's noise textures, original video: https://youtu.be/ybbJz6C9YYA
// this file heavily references https://thebookofshaders.com/
const float pi =3.14159265359;

//pseudorandom values
//note:changing sin with another trigoometrical function(cos or tan) doesn't do much
//changing to sinh,cosh or tanh makes the output one color,same with sign;
float rand(vec2 coord){
	// prevents randomness decreasing from coordinates too large
	coord = mod(coord, 10000.0);
	// returns "random" float between 0 and 1
	return fract(sin(dot(coord, vec2(12.9898,78.233))) * 43758.5453);
}
//same as rand except it returns a vec2
vec2 rand2( vec2 coord ) {
	// prevents randomness decreasing from coordinates too large
	coord = mod(coord, 10000.0);
	// returns "random" vec2 with x and y between 0 and 1
    return fract(sin( vec2( dot(coord,vec2(127.1,311.7)), dot(coord,vec2(269.5,183.3)) ) ) * 43758.5453);
}
//blocky noise
float value_noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);

	// 4 corners of a rectangle surrounding our point
	float tl = rand(i);
	float tr = rand(i + vec2(1.0, 0.0));
	float bl = rand(i + vec2(0.0, 1.0));
	float br = rand(i + vec2(1.0, 1.0));

	vec2 cubic = f * f * (3.0 - 2.0 * f);
	
	float topmix = mix(tl, tr, cubic.x);
	float botmix = mix(bl, br, cubic.x);
	float wholemix = mix(topmix, botmix, cubic.y);
	
	return wholemix;

}

//setting abs_value to true gives some funky results
float perlin_noise(vec2 coord,bool abs_value) {
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	// 4 corners of a rectangle surrounding our point
	// must be up to 2pi radians to allow the random vectors to face all directions
	float tl = rand(i) * pi*2.0;
	float tr = rand(i + vec2(1.0, 0.0)) * pi*2.0;
	float bl = rand(i + vec2(0.0, 1.0)) * pi*2.0;
	float br = rand(i + vec2(1.0, 1.0)) * pi*2.0;
	
	// original unit vector = (0, 1) which points downwards
	vec2 tlvec = vec2(-sin(tl), cos(tl));
	vec2 trvec = vec2(-sin(tr), cos(tr));
	vec2 blvec = vec2(-sin(bl), cos(bl));
	vec2 brvec = vec2(-sin(br), cos(br));
	
	// getting dot product of each corner's vector and its distance vector to current point
	float tldot = dot(tlvec, f);
	float trdot = dot(trvec, f - vec2(1.0, 0.0));
	float bldot = dot(blvec, f - vec2(0.0, 1.0));
	float brdot = dot(brvec, f - vec2(1.0, 1.0));
	
	if(abs_value)
	{
			tldot = abs(tldot);
			trdot = abs(trdot);
			bldot = abs(bldot);
			brdot = abs(brdot);
	}
	
	vec2 cubic = f * f * (3.0 - 2.0 * f);
	
	float topmix = mix(tldot, trdot, cubic.x);
	float botmix = mix(bldot, brdot, cubic.x);
	float wholemix = mix(topmix, botmix, cubic.y);
	
	return 0.5 + wholemix;
}

//voronoi
float cellular_noise(vec2 coord) {
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	float min_dist = 99999.0;
	// going through the current tile and the tiles surrounding it
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			
			// generate a random point in each tile,
			// but also account for whether it's a farther, neighbouring tile
			vec2 node = rand2(i + vec2(x, y)) + vec2(x, y);
			
			// check for distance to the point in that tile
			// decide whether it's the minimum
			float dist = sqrt((f - node).x * (f - node).x + (f - node).y * (f - node).y);
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}
//mix of noises with varying strength
//OCTAVES:the amount of noise textures overlapped
//normalize_factor:for normalizing brightness of the noise,0.5 is a great value
//scale:scale of the noise
//decay:how much each noise pattern is reduced
//type:the noise type
//abs_value:in case you're using perlin noise(type= 2)
float fbm(vec2 coord,int OCTAVES,float normalize_factor,float scale,float decay,int type,bool abs_value){
	
	float value = 0.0;

	for(int i = 0; i < OCTAVES; i++){
		if(type == 0)value += rand(coord) * scale;
		else if(type == 1)value += value_noise(coord) * scale;
		else if(type == 2)value += perlin_noise(coord,abs_value) * scale;
		else if(type == 3)value += cellular_noise(coord) * scale;
		normalize_factor += scale;
		coord *= decay;
		scale /= decay;
	}
	return value / normalize_factor;
}
//mixes diffrent types of noise
//parameters are the same as fbm()
//type determines the first noise type
float mix_fbm(vec2 coord,int OCTAVES,float normalize_factor,float scale,float decay,int type,bool abs_value){
	
	float value = 0.0;

	for(int i = 0; i < OCTAVES; i++){
		if(type == 0)value += rand(coord) * scale;
		else if(type == 1)value += value_noise(coord) * scale;
		else if(type == 2){value += perlin_noise(coord,abs_value) * scale;abs_value=!abs_value;}
		else if(type == 3)value += cellular_noise(coord) * scale;
		normalize_factor += scale;
		coord *= decay;
		scale /= decay;
		if(type==3)type=0;
		else type++;
	}
	return value / normalize_factor;
}

void fragment() {
	vec2 coord = UV * 10.0;
	float noise;
	
//	noise = rand(coord);
//	noise = value_noise(coord);
//	noise = perlin_noise(coord,false);
//	noise = cellular_noise(coord);
	noise = mix_fbm(coord,8,0.5,5,2,1,false);
	
	COLOR = vec4(vec3(noise),1);
}
