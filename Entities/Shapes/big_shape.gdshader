shader_type canvas_item;

void vertex() {
    // 1. Multiply TIME by your exact desired speed (0.1)
    // TIME is a continuous hardware float that bypasses delta fluctuations
    float angle = TIME * 0.1;
    
    // 2. High-precision GPU rotation matrix
    float cos_a = cos(angle);
    float sin_a = sin(angle);
    mat2 rotation_matrix = mat2(vec2(cos_a, sin_a), vec2(-sin_a, cos_a));
    
    // 3. Rotate the vertices
    VERTEX = rotation_matrix * VERTEX;
}
