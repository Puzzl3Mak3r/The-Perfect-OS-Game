--[[
  *
        require "sway"
        object.fill.effect = "filter.custom.sway"
        object.fill.effect.offset = 0.0 -- make different
        object.fill.effect.heightOffset = 0.6 -- The height where the wind begins to move
        object.fill.effect.distortion = 0.5 -- The strength of geometry distortion.
]]

local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"

kernel.name = "sway"
kernel.isTimeDependent = true

kernel.vertexData =
{
    {
        name = "offset",
        default = 0.0, 
        min = 0.0,
        max = 10.0,
        index = 0,  -- This corresponds to "CoronaVertexUserData.x"
    },
    {
        name = "heightOffset",
        default = 0.5,
        min = 0.0,
        max = 1.0,
        index = 1 -- This corresponds to "CoronaVertexUserData.y"
    },
    {
        name = "distortion",
        default = 0.5,
        min = 0.0,
        max = 1.0,
        index = 2 -- This corresponds to "CoronaVertexUserData.z"
    }
}

kernel.vertex =
[[

    P_COLOR float speed = 1.0; //The speed of the wind movement.

    P_COLOR float minStrength = 0.2; //The minimal strength of the wind movement.
    
    P_COLOR float maxStrength = 0.1; //The maximal strength of the wind movement.
    
    P_COLOR float strengthScale = 100.0; //Scalefactor for the wind strength.
    
    P_COLOR float interval = 3.5;//The time between minimal and maximal strength changes.
    
    P_COLOR float detail = 1.0;//The detail (number of waves) of the wind movement.
    


    P_COLOR float getWind(P_COLOR vec2 vertex, P_COLOR vec2 uv, P_COLOR float time, P_COLOR float heightOffset, P_COLOR float distortion){
        P_COLOR float diff = pow(maxStrength - minStrength, 2.0);
        P_COLOR float strength = clamp(minStrength + diff + sin(time / interval) * diff, minStrength, maxStrength) * strengthScale;
        P_COLOR float wind = (sin(time) + cos(time * detail)) * strength * max(0.0, (1.0-uv.y) - heightOffset);
        
        return wind; 
    }

    P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
    {
        P_COLOR float distortion = CoronaVertexUserData.z;//The strength of geometry distortion.
    
        P_COLOR float heightOffset = CoronaVertexUserData.y;//The height where the wind begins to move. By default 0.0.
    
        P_COLOR float time = CoronaTotalTime * speed + CoronaVertexUserData.x;
        position.x += getWind(position.xy, CoronaTexCoord, time, heightOffset, distortion);

        return position;
    }
]]

graphics.defineEffect(kernel)
