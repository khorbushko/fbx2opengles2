//
//  Shader.fsh
//  testOpenGL
//
//  Created by Kirill Gorbushko on 09.07.16.
//  Copyright © 2016 - present redTree. All rights reserved.
//

uniform sampler2D u_texture;

varying lowp vec2 v_texCoordOut;
varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = texture2D(u_texture, v_texCoordOut) * colorVarying;
}
