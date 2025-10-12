shader_type spatial;

void vertex(){
	if(VERTEX.x < 0.1 && VERTEX.x > -0.1){
		VERTEX.z -= 1.;
	}
}
//// Position of the center of the push (local or world, see below)
//uniform vec3 center = vec3(0.0, 0.0, 0.0);
//uniform float radius = 5.;       // how far the influence reaches
//uniform bool use_world_space = false;
//uniform float portal_size = 1.5;
//
//void vertex() {
	//float push_strength = 5.0; // how far to push
//
    //vec3 pos = VERTEX;
    //if (use_world_space) {
        //pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    //}
    //float dist = length(pos.x * portal_size - center.x* portal_size);
//
    //float t = smoothstep(radius, 0.45, dist);
//
    //VERTEX.y -= t * push_strength;
//}
