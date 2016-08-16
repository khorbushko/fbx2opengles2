//
//  Shader.vsh
//  testOpenGL
//
//  Created by Kirill Gorbushko on 09.07.16.
//  Copyright © 2016 - present redTree. All rights reserved.
//

uniform mat4 u_modelViewProjectionMatrix;
uniform mat3 normalMatrix;

attribute vec4 a_position;
attribute vec2 a_texCoordIn;
attribute vec3 normal;

varying lowp vec2 v_texCoordOut;
varying lowp vec4 colorVarying;

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 1.0, 1.0); //configure somehow position of light
    vec4 diffuseColor = vec4(1.0, 1.0, 1.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    colorVarying = diffuseColor * nDotVP;
    
    v_texCoordOut = vec2(a_texCoordIn.s, 1.0 - a_texCoordIn.t);//flip and mirror texture
//    v_texCoordOut = vec2(1.0 - a_texCoordIn.s, 1.0 - a_texCoordIn.t);//flip and mirror and invert texture

    
//    v_texCoordOut = a_texCoordIn;//original texture

    gl_Position = u_modelViewProjectionMatrix * a_position;
}
