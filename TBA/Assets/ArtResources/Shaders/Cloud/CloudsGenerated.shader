Shader "Cloud Generated"
{
    Properties
    {
        Vector4_A472B6CF("RotateProjection", Vector) = (1, 0, 0, 0)
        Vector1_4D839AAC("NoiseScale", Float) = 10
        Vector1_150AEC14("NoiseSpeed", Float) = 0.1
        Vector1_D5D352DC("NoiseHeight", Float) = 100
        Vector4_973DA92B("NoiseRemap", Vector) = (0, 1, -1, 1)
        Color_1AB5F3EF("ColorPeack", Color) = (1, 1, 1, 0)
        Color_D23C8EF9("ColorValley", Color) = (0, 0, 0, 0)
        Vector1_1C13E9DB("NoiseEdge1", Float) = 0
        Vector1_2AEBF55E("NoiseEdge2", Float) = 1
        Vector1_D82284B6("NoisePower", Float) = 2
        Vector1_A931D240("BaseScale", Float) = 5
        Vector1_8F89338B("BaseSpeed", Float) = 0.2
        Vector1_5FD091B9("BaseStrength", Float) = 1
        Vector1_DB85C24D("EmissionStrength", Float) = 2
        Vector1_75DA7D10("CurvatureRadius", Float) = 1
        Vector1_7710C9B("FresnelPower", Float) = 1
        Vector1_2A0C971B("FresnelOpacity", Float) = 1
        Vector1_F2113D60("FadeDepth", Float) = 100
    }
    SubShader
    {
        Tags
    {
        "RenderPipeline"="UniversalPipeline"
        "RenderType"="Transparent"
        "Queue"="Transparent+0"
    }

        Pass
    {
        Name "Pass"
        Tags 
        { 
            // LightMode: <None>
        }
       
        // Render State
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        Cull Off
        ZTest LEqual
        //Zwrite default OFF
        ZWrite On
        //
        // ColorMask: <None>
        

        HLSLPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        // Pragmas
        #pragma prefer_hlslcc gles
    #pragma exclude_renderers d3d11_9x
    #pragma target 2.0
    #pragma multi_compile_fog
    #pragma multi_compile_instancing

        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    #pragma shader_feature _ _SAMPLE_GI
        // GraphKeywords: <None>
        
        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS 
        #define FEATURES_GRAPH_VERTEX
        #define SHADERPASS_UNLIT
    #define REQUIRE_DEPTH_TEXTURE

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"

        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
    float4 Vector4_A472B6CF;
    float Vector1_4D839AAC;
    float Vector1_150AEC14;
    float Vector1_D5D352DC;
    float4 Vector4_973DA92B;
    float4 Color_1AB5F3EF;
    float4 Color_D23C8EF9;
    float Vector1_1C13E9DB;
    float Vector1_2AEBF55E;
    float Vector1_D82284B6;
    float Vector1_A931D240;
    float Vector1_8F89338B;
    float Vector1_5FD091B9;
    float Vector1_DB85C24D;
    float Vector1_75DA7D10;
    float Vector1_7710C9B;
    float Vector1_2A0C971B;
    float Vector1_F2113D60;
    CBUFFER_END

        // Graph Functions
        
    void Unity_Distance_float3(float3 A, float3 B, out float Out)
    {
        Out = distance(A, B);
    }

    void Unity_Divide_float(float A, float B, out float Out)
    {
        Out = A / B;
    }

    void Unity_Power_float(float A, float B, out float Out)
    {
        Out = pow(A, B);
    }

    void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
    {
        Out = A * B;
    }

    void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
    {
        Rotation = radians(Rotation);

        float s = sin(Rotation);
        float c = cos(Rotation);
        float one_minus_c = 1.0 - c;
        
        Axis = normalize(Axis);

        float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                  one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                  one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                };

        Out = mul(rot_mat,  In);
    }

    void Unity_Multiply_float(float A, float B, out float Out)
    {
        Out = A * B;
    }

    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
    {
        Out = UV * Tiling + Offset;
    }


    float2 Unity_GradientNoise_Dir_float(float2 p)
    {
        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
        p = p % 289;
        float x = (34 * p.x + 1) * p.x % 289 + p.y;
        x = (34 * x + 1) * x % 289;
        x = frac(x / 41) * 2 - 1;
        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
    }

    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
    { 
        float2 p = UV * Scale;
        float2 ip = floor(p);
        float2 fp = frac(p);
        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
    }

    void Unity_Add_float(float A, float B, out float Out)
    {
        Out = A + B;
    }

    void Unity_Saturate_float(float In, out float Out)
    {
        Out = saturate(In);
    }

    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
    {
        RGBA = float4(R, G, B, A);
        RGB = float3(R, G, B);
        RG = float2(R, G);
    }

    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
    {
        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
    }

    void Unity_Absolute_float(float In, out float Out)
    {
        Out = abs(In);
    }

    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
    {
        Out = smoothstep(Edge1, Edge2, In);
    }

    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
    {
        Out = A + B;
    }

    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
    {
        Out = lerp(A, B, T);
    }

    void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
    {
        Out = A * B;
    }

    void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
    {
        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
    }

    void Unity_Subtract_float(float A, float B, out float Out)
    {
        Out = A - B;
    }

        // Graph Vertex
        struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 WorldSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float3 WorldSpacePosition;
        float3 TimeParameters;
    };

    struct VertexDescription
    {
        float3 VertexPosition;
        float3 VertexNormal;
        float3 VertexTangent;
    };

    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
    {
        VertexDescription description = (VertexDescription)0;
        float _Distance_E1AD3426_Out_2;
        Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_E1AD3426_Out_2);
        float _Property_50179BBC_Out_0 = Vector1_75DA7D10;
        float _Divide_A0D866_Out_2;
        Unity_Divide_float(_Distance_E1AD3426_Out_2, _Property_50179BBC_Out_0, _Divide_A0D866_Out_2);
        float _Power_8EA7AB9E_Out_2;
        Unity_Power_float(_Divide_A0D866_Out_2, 3, _Power_8EA7AB9E_Out_2);
        float3 _Multiply_F07C4AF5_Out_2;
        Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_8EA7AB9E_Out_2.xxx), _Multiply_F07C4AF5_Out_2);
        float _Property_FB45F40C_Out_0 = Vector1_1C13E9DB;
        float _Property_346016F9_Out_0 = Vector1_2AEBF55E;
        float4 _Property_2E24F547_Out_0 = Vector4_A472B6CF;
        float _Split_62F2AFD1_R_1 = _Property_2E24F547_Out_0[0];
        float _Split_62F2AFD1_G_2 = _Property_2E24F547_Out_0[1];
        float _Split_62F2AFD1_B_3 = _Property_2E24F547_Out_0[2];
        float _Split_62F2AFD1_A_4 = _Property_2E24F547_Out_0[3];
        float3 _RotateAboutAxis_6188BD4F_Out_3;
        Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_2E24F547_Out_0.xyz), _Split_62F2AFD1_A_4, _RotateAboutAxis_6188BD4F_Out_3);
        float _Property_BC923B99_Out_0 = Vector1_150AEC14;
        float _Multiply_40461E27_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_BC923B99_Out_0, _Multiply_40461E27_Out_2);
        float2 _TilingAndOffset_D42429F0_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_6188BD4F_Out_3.xy), float2 (1, 1), (_Multiply_40461E27_Out_2.xx), _TilingAndOffset_D42429F0_Out_3);
        float _Property_EA670B62_Out_0 = Vector1_4D839AAC;
        float _GradientNoise_BFC07395_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_D42429F0_Out_3, _Property_EA670B62_Out_0, _GradientNoise_BFC07395_Out_2);
        float2 _TilingAndOffset_4D7F6455_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_6188BD4F_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4D7F6455_Out_3);
        float _GradientNoise_42CB3D21_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_4D7F6455_Out_3, _Property_EA670B62_Out_0, _GradientNoise_42CB3D21_Out_2);
        float _Add_207E0907_Out_2;
        Unity_Add_float(_GradientNoise_BFC07395_Out_2, _GradientNoise_42CB3D21_Out_2, _Add_207E0907_Out_2);
        float _Divide_FDA1AFCB_Out_2;
        Unity_Divide_float(_Add_207E0907_Out_2, 2, _Divide_FDA1AFCB_Out_2);
        float _Saturate_62761A1_Out_1;
        Unity_Saturate_float(_Divide_FDA1AFCB_Out_2, _Saturate_62761A1_Out_1);
        float _Property_B2A9A59D_Out_0 = Vector1_D82284B6;
        float _Power_4B1FDE2B_Out_2;
        Unity_Power_float(_Saturate_62761A1_Out_1, _Property_B2A9A59D_Out_0, _Power_4B1FDE2B_Out_2);
        float4 _Property_1A2B3890_Out_0 = Vector4_973DA92B;
        float _Split_BDA7FCA2_R_1 = _Property_1A2B3890_Out_0[0];
        float _Split_BDA7FCA2_G_2 = _Property_1A2B3890_Out_0[1];
        float _Split_BDA7FCA2_B_3 = _Property_1A2B3890_Out_0[2];
        float _Split_BDA7FCA2_A_4 = _Property_1A2B3890_Out_0[3];
        float4 _Combine_7D405F42_RGBA_4;
        float3 _Combine_7D405F42_RGB_5;
        float2 _Combine_7D405F42_RG_6;
        Unity_Combine_float(_Split_BDA7FCA2_R_1, _Split_BDA7FCA2_G_2, 0, 0, _Combine_7D405F42_RGBA_4, _Combine_7D405F42_RGB_5, _Combine_7D405F42_RG_6);
        float4 _Combine_8247C46F_RGBA_4;
        float3 _Combine_8247C46F_RGB_5;
        float2 _Combine_8247C46F_RG_6;
        Unity_Combine_float(_Split_BDA7FCA2_B_3, _Split_BDA7FCA2_A_4, 0, 0, _Combine_8247C46F_RGBA_4, _Combine_8247C46F_RGB_5, _Combine_8247C46F_RG_6);
        float _Remap_28F198A_Out_3;
        Unity_Remap_float(_Power_4B1FDE2B_Out_2, (_Combine_7D405F42_RGBA_4.xy), _Combine_8247C46F_RG_6, _Remap_28F198A_Out_3);
        float _Absolute_F00D8B3C_Out_1;
        Unity_Absolute_float(_Remap_28F198A_Out_3, _Absolute_F00D8B3C_Out_1);
        float _Smoothstep_1E35709D_Out_3;
        Unity_Smoothstep_float(_Property_FB45F40C_Out_0, _Property_346016F9_Out_0, _Absolute_F00D8B3C_Out_1, _Smoothstep_1E35709D_Out_3);
        float _Property_870122A4_Out_0 = Vector1_8F89338B;
        float _Multiply_ED03077B_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_870122A4_Out_0, _Multiply_ED03077B_Out_2);
        float2 _TilingAndOffset_71F78084_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_6188BD4F_Out_3.xy), float2 (1, 1), (_Multiply_ED03077B_Out_2.xx), _TilingAndOffset_71F78084_Out_3);
        float _Property_2CF24586_Out_0 = Vector1_A931D240;
        float _GradientNoise_9D3CC735_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_71F78084_Out_3, _Property_2CF24586_Out_0, _GradientNoise_9D3CC735_Out_2);
        float _Property_D6F9E15B_Out_0 = Vector1_5FD091B9;
        float _Multiply_14634420_Out_2;
        Unity_Multiply_float(_GradientNoise_9D3CC735_Out_2, _Property_D6F9E15B_Out_0, _Multiply_14634420_Out_2);
        float _Add_D1851436_Out_2;
        Unity_Add_float(_Smoothstep_1E35709D_Out_3, _Multiply_14634420_Out_2, _Add_D1851436_Out_2);
        float _Add_DE5F53F1_Out_2;
        Unity_Add_float(1, _Property_D6F9E15B_Out_0, _Add_DE5F53F1_Out_2);
        float _Divide_5493E97E_Out_2;
        Unity_Divide_float(_Add_D1851436_Out_2, _Add_DE5F53F1_Out_2, _Divide_5493E97E_Out_2);
        float3 _Multiply_AD1B9D35_Out_2;
        Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_5493E97E_Out_2.xxx), _Multiply_AD1B9D35_Out_2);
        float _Property_574E2389_Out_0 = Vector1_D5D352DC;
        float3 _Multiply_2866962_Out_2;
        Unity_Multiply_float(_Multiply_AD1B9D35_Out_2, (_Property_574E2389_Out_0.xxx), _Multiply_2866962_Out_2);
        float3 _Add_B67FEF90_Out_2;
        Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2866962_Out_2, _Add_B67FEF90_Out_2);
        float3 _Add_D1E575B_Out_2;
        Unity_Add_float3(_Multiply_F07C4AF5_Out_2, _Add_B67FEF90_Out_2, _Add_D1E575B_Out_2);
        description.VertexPosition = _Add_D1E575B_Out_2;
        description.VertexNormal = IN.ObjectSpaceNormal;
        description.VertexTangent = IN.ObjectSpaceTangent;
        return description;
    }
        
        // Graph Pixel
        struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float3 TimeParameters;
    };

    struct SurfaceDescription
    {
        float3 Color;
        float Alpha;
        float AlphaClipThreshold;
    };

    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
    {
        SurfaceDescription surface = (SurfaceDescription)0;
        float4 _Property_AFBB372A_Out_0 = Color_D23C8EF9;
        float4 _Property_FFE50059_Out_0 = Color_1AB5F3EF;
        float _Property_FB45F40C_Out_0 = Vector1_1C13E9DB;
        float _Property_346016F9_Out_0 = Vector1_2AEBF55E;
        float4 _Property_2E24F547_Out_0 = Vector4_A472B6CF;
        float _Split_62F2AFD1_R_1 = _Property_2E24F547_Out_0[0];
        float _Split_62F2AFD1_G_2 = _Property_2E24F547_Out_0[1];
        float _Split_62F2AFD1_B_3 = _Property_2E24F547_Out_0[2];
        float _Split_62F2AFD1_A_4 = _Property_2E24F547_Out_0[3];
        float3 _RotateAboutAxis_6188BD4F_Out_3;
        Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_2E24F547_Out_0.xyz), _Split_62F2AFD1_A_4, _RotateAboutAxis_6188BD4F_Out_3);
        float _Property_BC923B99_Out_0 = Vector1_150AEC14;
        float _Multiply_40461E27_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_BC923B99_Out_0, _Multiply_40461E27_Out_2);
        float2 _TilingAndOffset_D42429F0_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_6188BD4F_Out_3.xy), float2 (1, 1), (_Multiply_40461E27_Out_2.xx), _TilingAndOffset_D42429F0_Out_3);
        float _Property_EA670B62_Out_0 = Vector1_4D839AAC;
        float _GradientNoise_BFC07395_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_D42429F0_Out_3, _Property_EA670B62_Out_0, _GradientNoise_BFC07395_Out_2);
        float2 _TilingAndOffset_4D7F6455_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_6188BD4F_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4D7F6455_Out_3);
        float _GradientNoise_42CB3D21_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_4D7F6455_Out_3, _Property_EA670B62_Out_0, _GradientNoise_42CB3D21_Out_2);
        float _Add_207E0907_Out_2;
        Unity_Add_float(_GradientNoise_BFC07395_Out_2, _GradientNoise_42CB3D21_Out_2, _Add_207E0907_Out_2);
        float _Divide_FDA1AFCB_Out_2;
        Unity_Divide_float(_Add_207E0907_Out_2, 2, _Divide_FDA1AFCB_Out_2);
        float _Saturate_62761A1_Out_1;
        Unity_Saturate_float(_Divide_FDA1AFCB_Out_2, _Saturate_62761A1_Out_1);
        float _Property_B2A9A59D_Out_0 = Vector1_D82284B6;
        float _Power_4B1FDE2B_Out_2;
        Unity_Power_float(_Saturate_62761A1_Out_1, _Property_B2A9A59D_Out_0, _Power_4B1FDE2B_Out_2);
        float4 _Property_1A2B3890_Out_0 = Vector4_973DA92B;
        float _Split_BDA7FCA2_R_1 = _Property_1A2B3890_Out_0[0];
        float _Split_BDA7FCA2_G_2 = _Property_1A2B3890_Out_0[1];
        float _Split_BDA7FCA2_B_3 = _Property_1A2B3890_Out_0[2];
        float _Split_BDA7FCA2_A_4 = _Property_1A2B3890_Out_0[3];
        float4 _Combine_7D405F42_RGBA_4;
        float3 _Combine_7D405F42_RGB_5;
        float2 _Combine_7D405F42_RG_6;
        Unity_Combine_float(_Split_BDA7FCA2_R_1, _Split_BDA7FCA2_G_2, 0, 0, _Combine_7D405F42_RGBA_4, _Combine_7D405F42_RGB_5, _Combine_7D405F42_RG_6);
        float4 _Combine_8247C46F_RGBA_4;
        float3 _Combine_8247C46F_RGB_5;
        float2 _Combine_8247C46F_RG_6;
        Unity_Combine_float(_Split_BDA7FCA2_B_3, _Split_BDA7FCA2_A_4, 0, 0, _Combine_8247C46F_RGBA_4, _Combine_8247C46F_RGB_5, _Combine_8247C46F_RG_6);
        float _Remap_28F198A_Out_3;
        Unity_Remap_float(_Power_4B1FDE2B_Out_2, (_Combine_7D405F42_RGBA_4.xy), _Combine_8247C46F_RG_6, _Remap_28F198A_Out_3);
        float _Absolute_F00D8B3C_Out_1;
        Unity_Absolute_float(_Remap_28F198A_Out_3, _Absolute_F00D8B3C_Out_1);
        float _Smoothstep_1E35709D_Out_3;
        Unity_Smoothstep_float(_Property_FB45F40C_Out_0, _Property_346016F9_Out_0, _Absolute_F00D8B3C_Out_1, _Smoothstep_1E35709D_Out_3);
        float _Property_870122A4_Out_0 = Vector1_8F89338B;
        float _Multiply_ED03077B_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_870122A4_Out_0, _Multiply_ED03077B_Out_2);
        float2 _TilingAndOffset_71F78084_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_6188BD4F_Out_3.xy), float2 (1, 1), (_Multiply_ED03077B_Out_2.xx), _TilingAndOffset_71F78084_Out_3);
        float _Property_2CF24586_Out_0 = Vector1_A931D240;
        float _GradientNoise_9D3CC735_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_71F78084_Out_3, _Property_2CF24586_Out_0, _GradientNoise_9D3CC735_Out_2);
        float _Property_D6F9E15B_Out_0 = Vector1_5FD091B9;
        float _Multiply_14634420_Out_2;
        Unity_Multiply_float(_GradientNoise_9D3CC735_Out_2, _Property_D6F9E15B_Out_0, _Multiply_14634420_Out_2);
        float _Add_D1851436_Out_2;
        Unity_Add_float(_Smoothstep_1E35709D_Out_3, _Multiply_14634420_Out_2, _Add_D1851436_Out_2);
        float _Add_DE5F53F1_Out_2;
        Unity_Add_float(1, _Property_D6F9E15B_Out_0, _Add_DE5F53F1_Out_2);
        float _Divide_5493E97E_Out_2;
        Unity_Divide_float(_Add_D1851436_Out_2, _Add_DE5F53F1_Out_2, _Divide_5493E97E_Out_2);
        float4 _Lerp_7BA39A2C_Out_3;
        Unity_Lerp_float4(_Property_AFBB372A_Out_0, _Property_FFE50059_Out_0, (_Divide_5493E97E_Out_2.xxxx), _Lerp_7BA39A2C_Out_3);
        float _Property_26424DC3_Out_0 = Vector1_DB85C24D;
        float4 _Multiply_ACB8EE16_Out_2;
        Unity_Multiply_float(_Lerp_7BA39A2C_Out_3, (_Property_26424DC3_Out_0.xxxx), _Multiply_ACB8EE16_Out_2);
        float _SceneDepth_23A34ED8_Out_1;
        Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_23A34ED8_Out_1);
        float4 _ScreenPosition_11D5E144_Out_0 = IN.ScreenPosition;
        float _Split_F3199AB9_R_1 = _ScreenPosition_11D5E144_Out_0[0];
        float _Split_F3199AB9_G_2 = _ScreenPosition_11D5E144_Out_0[1];
        float _Split_F3199AB9_B_3 = _ScreenPosition_11D5E144_Out_0[2];
        float _Split_F3199AB9_A_4 = _ScreenPosition_11D5E144_Out_0[3];
        float _Subtract_AD703830_Out_2;
        Unity_Subtract_float(_Split_F3199AB9_A_4, 1, _Subtract_AD703830_Out_2);
        float _Subtract_C4FA93E4_Out_2;
        Unity_Subtract_float(_SceneDepth_23A34ED8_Out_1, _Subtract_AD703830_Out_2, _Subtract_C4FA93E4_Out_2);
        float _Property_2646B4F2_Out_0 = Vector1_F2113D60;
        float _Divide_E2FDC8DA_Out_2;
        Unity_Divide_float(_Subtract_C4FA93E4_Out_2, _Property_2646B4F2_Out_0, _Divide_E2FDC8DA_Out_2);
        float _Saturate_736439E3_Out_1;
        Unity_Saturate_float(_Divide_E2FDC8DA_Out_2, _Saturate_736439E3_Out_1);
        surface.Color = (_Multiply_ACB8EE16_Out_2.xyz);
        surface.Alpha = _Saturate_736439E3_Out_1;
        surface.AlphaClipThreshold = 0;
        return surface;
    }

        // --------------------------------------------------
        // Structs and Packing

        // Generated Type: Attributes
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };

        // Generated Type: Varyings
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                float3 interp00 : TEXCOORD0;
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output = (PackedVaryings)0;
                output.positionCS = input.positionCS;
                output.interp00.xyz = input.positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp00.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

        // --------------------------------------------------
        // Build Graph Inputs

        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);

        output.ObjectSpaceNormal =           input.normalOS;
        output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
        output.ObjectSpaceTangent =          input.tangentOS;
        output.ObjectSpacePosition =         input.positionOS;
        output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
        output.TimeParameters =              _TimeParameters.xyz;

        return output;
    }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





        output.WorldSpacePosition =          input.positionWS;
        output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
    }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"

        ENDHLSL
    }

        Pass
    {
        Name "ShadowCaster"
        Tags 
        { 
            "LightMode" = "ShadowCaster"
        }
       
        // Render State
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        Cull Off
        ZTest LEqual
        ZWrite On
        // ColorMask: <None>
        

        HLSLPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        // Pragmas
        #pragma prefer_hlslcc gles
    #pragma exclude_renderers d3d11_9x
    #pragma target 2.0
    #pragma multi_compile_instancing

        // Keywords
        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        // GraphKeywords: <None>
        
        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS 
        #define FEATURES_GRAPH_VERTEX
        #define SHADERPASS_SHADOWCASTER
    #define REQUIRE_DEPTH_TEXTURE

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"

        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
    float4 Vector4_A472B6CF;
    float Vector1_4D839AAC;
    float Vector1_150AEC14;
    float Vector1_D5D352DC;
    float4 Vector4_973DA92B;
    float4 Color_1AB5F3EF;
    float4 Color_D23C8EF9;
    float Vector1_1C13E9DB;
    float Vector1_2AEBF55E;
    float Vector1_D82284B6;
    float Vector1_A931D240;
    float Vector1_8F89338B;
    float Vector1_5FD091B9;
    float Vector1_DB85C24D;
    float Vector1_75DA7D10;
    float Vector1_7710C9B;
    float Vector1_2A0C971B;
    float Vector1_F2113D60;
    CBUFFER_END

        // Graph Functions
        
    void Unity_Distance_float3(float3 A, float3 B, out float Out)
    {
        Out = distance(A, B);
    }

    void Unity_Divide_float(float A, float B, out float Out)
    {
        Out = A / B;
    }

    void Unity_Power_float(float A, float B, out float Out)
    {
        Out = pow(A, B);
    }

    void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
    {
        Out = A * B;
    }

    void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
    {
        Rotation = radians(Rotation);

        float s = sin(Rotation);
        float c = cos(Rotation);
        float one_minus_c = 1.0 - c;
        
        Axis = normalize(Axis);

        float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                  one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                  one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                };

        Out = mul(rot_mat,  In);
    }

    void Unity_Multiply_float(float A, float B, out float Out)
    {
        Out = A * B;
    }

    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
    {
        Out = UV * Tiling + Offset;
    }


    float2 Unity_GradientNoise_Dir_float(float2 p)
    {
        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
        p = p % 289;
        float x = (34 * p.x + 1) * p.x % 289 + p.y;
        x = (34 * x + 1) * x % 289;
        x = frac(x / 41) * 2 - 1;
        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
    }

    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
    { 
        float2 p = UV * Scale;
        float2 ip = floor(p);
        float2 fp = frac(p);
        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
    }

    void Unity_Add_float(float A, float B, out float Out)
    {
        Out = A + B;
    }

    void Unity_Saturate_float(float In, out float Out)
    {
        Out = saturate(In);
    }

    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
    {
        RGBA = float4(R, G, B, A);
        RGB = float3(R, G, B);
        RG = float2(R, G);
    }

    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
    {
        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
    }

    void Unity_Absolute_float(float In, out float Out)
    {
        Out = abs(In);
    }

    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
    {
        Out = smoothstep(Edge1, Edge2, In);
    }

    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
    {
        Out = A + B;
    }

    void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
    {
        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
    }

    void Unity_Subtract_float(float A, float B, out float Out)
    {
        Out = A - B;
    }

        // Graph Vertex
        struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 WorldSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float3 WorldSpacePosition;
        float3 TimeParameters;
    };

    struct VertexDescription
    {
        float3 VertexPosition;
        float3 VertexNormal;
        float3 VertexTangent;
    };

    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
    {
        VertexDescription description = (VertexDescription)0;
        float _Distance_E1AD3426_Out_2;
        Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_E1AD3426_Out_2);
        float _Property_50179BBC_Out_0 = Vector1_75DA7D10;
        float _Divide_A0D866_Out_2;
        Unity_Divide_float(_Distance_E1AD3426_Out_2, _Property_50179BBC_Out_0, _Divide_A0D866_Out_2);
        float _Power_8EA7AB9E_Out_2;
        Unity_Power_float(_Divide_A0D866_Out_2, 3, _Power_8EA7AB9E_Out_2);
        float3 _Multiply_F07C4AF5_Out_2;
        Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_8EA7AB9E_Out_2.xxx), _Multiply_F07C4AF5_Out_2);
        float _Property_FB45F40C_Out_0 = Vector1_1C13E9DB;
        float _Property_346016F9_Out_0 = Vector1_2AEBF55E;
        float4 _Property_2E24F547_Out_0 = Vector4_A472B6CF;
        float _Split_62F2AFD1_R_1 = _Property_2E24F547_Out_0[0];
        float _Split_62F2AFD1_G_2 = _Property_2E24F547_Out_0[1];
        float _Split_62F2AFD1_B_3 = _Property_2E24F547_Out_0[2];
        float _Split_62F2AFD1_A_4 = _Property_2E24F547_Out_0[3];
        float3 _RotateAboutAxis_6188BD4F_Out_3;
        Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_2E24F547_Out_0.xyz), _Split_62F2AFD1_A_4, _RotateAboutAxis_6188BD4F_Out_3);
        float _Property_BC923B99_Out_0 = Vector1_150AEC14;
        float _Multiply_40461E27_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_BC923B99_Out_0, _Multiply_40461E27_Out_2);
        float2 _TilingAndOffset_D42429F0_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_6188BD4F_Out_3.xy), float2 (1, 1), (_Multiply_40461E27_Out_2.xx), _TilingAndOffset_D42429F0_Out_3);
        float _Property_EA670B62_Out_0 = Vector1_4D839AAC;
        float _GradientNoise_BFC07395_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_D42429F0_Out_3, _Property_EA670B62_Out_0, _GradientNoise_BFC07395_Out_2);
        float2 _TilingAndOffset_4D7F6455_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_6188BD4F_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4D7F6455_Out_3);
        float _GradientNoise_42CB3D21_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_4D7F6455_Out_3, _Property_EA670B62_Out_0, _GradientNoise_42CB3D21_Out_2);
        float _Add_207E0907_Out_2;
        Unity_Add_float(_GradientNoise_BFC07395_Out_2, _GradientNoise_42CB3D21_Out_2, _Add_207E0907_Out_2);
        float _Divide_FDA1AFCB_Out_2;
        Unity_Divide_float(_Add_207E0907_Out_2, 2, _Divide_FDA1AFCB_Out_2);
        float _Saturate_62761A1_Out_1;
        Unity_Saturate_float(_Divide_FDA1AFCB_Out_2, _Saturate_62761A1_Out_1);
        float _Property_B2A9A59D_Out_0 = Vector1_D82284B6;
        float _Power_4B1FDE2B_Out_2;
        Unity_Power_float(_Saturate_62761A1_Out_1, _Property_B2A9A59D_Out_0, _Power_4B1FDE2B_Out_2);
        float4 _Property_1A2B3890_Out_0 = Vector4_973DA92B;
        float _Split_BDA7FCA2_R_1 = _Property_1A2B3890_Out_0[0];
        float _Split_BDA7FCA2_G_2 = _Property_1A2B3890_Out_0[1];
        float _Split_BDA7FCA2_B_3 = _Property_1A2B3890_Out_0[2];
        float _Split_BDA7FCA2_A_4 = _Property_1A2B3890_Out_0[3];
        float4 _Combine_7D405F42_RGBA_4;
        float3 _Combine_7D405F42_RGB_5;
        float2 _Combine_7D405F42_RG_6;
        Unity_Combine_float(_Split_BDA7FCA2_R_1, _Split_BDA7FCA2_G_2, 0, 0, _Combine_7D405F42_RGBA_4, _Combine_7D405F42_RGB_5, _Combine_7D405F42_RG_6);
        float4 _Combine_8247C46F_RGBA_4;
        float3 _Combine_8247C46F_RGB_5;
        float2 _Combine_8247C46F_RG_6;
        Unity_Combine_float(_Split_BDA7FCA2_B_3, _Split_BDA7FCA2_A_4, 0, 0, _Combine_8247C46F_RGBA_4, _Combine_8247C46F_RGB_5, _Combine_8247C46F_RG_6);
        float _Remap_28F198A_Out_3;
        Unity_Remap_float(_Power_4B1FDE2B_Out_2, (_Combine_7D405F42_RGBA_4.xy), _Combine_8247C46F_RG_6, _Remap_28F198A_Out_3);
        float _Absolute_F00D8B3C_Out_1;
        Unity_Absolute_float(_Remap_28F198A_Out_3, _Absolute_F00D8B3C_Out_1);
        float _Smoothstep_1E35709D_Out_3;
        Unity_Smoothstep_float(_Property_FB45F40C_Out_0, _Property_346016F9_Out_0, _Absolute_F00D8B3C_Out_1, _Smoothstep_1E35709D_Out_3);
        float _Property_870122A4_Out_0 = Vector1_8F89338B;
        float _Multiply_ED03077B_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_870122A4_Out_0, _Multiply_ED03077B_Out_2);
        float2 _TilingAndOffset_71F78084_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_6188BD4F_Out_3.xy), float2 (1, 1), (_Multiply_ED03077B_Out_2.xx), _TilingAndOffset_71F78084_Out_3);
        float _Property_2CF24586_Out_0 = Vector1_A931D240;
        float _GradientNoise_9D3CC735_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_71F78084_Out_3, _Property_2CF24586_Out_0, _GradientNoise_9D3CC735_Out_2);
        float _Property_D6F9E15B_Out_0 = Vector1_5FD091B9;
        float _Multiply_14634420_Out_2;
        Unity_Multiply_float(_GradientNoise_9D3CC735_Out_2, _Property_D6F9E15B_Out_0, _Multiply_14634420_Out_2);
        float _Add_D1851436_Out_2;
        Unity_Add_float(_Smoothstep_1E35709D_Out_3, _Multiply_14634420_Out_2, _Add_D1851436_Out_2);
        float _Add_DE5F53F1_Out_2;
        Unity_Add_float(1, _Property_D6F9E15B_Out_0, _Add_DE5F53F1_Out_2);
        float _Divide_5493E97E_Out_2;
        Unity_Divide_float(_Add_D1851436_Out_2, _Add_DE5F53F1_Out_2, _Divide_5493E97E_Out_2);
        float3 _Multiply_AD1B9D35_Out_2;
        Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_5493E97E_Out_2.xxx), _Multiply_AD1B9D35_Out_2);
        float _Property_574E2389_Out_0 = Vector1_D5D352DC;
        float3 _Multiply_2866962_Out_2;
        Unity_Multiply_float(_Multiply_AD1B9D35_Out_2, (_Property_574E2389_Out_0.xxx), _Multiply_2866962_Out_2);
        float3 _Add_B67FEF90_Out_2;
        Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2866962_Out_2, _Add_B67FEF90_Out_2);
        float3 _Add_D1E575B_Out_2;
        Unity_Add_float3(_Multiply_F07C4AF5_Out_2, _Add_B67FEF90_Out_2, _Add_D1E575B_Out_2);
        description.VertexPosition = _Add_D1E575B_Out_2;
        description.VertexNormal = IN.ObjectSpaceNormal;
        description.VertexTangent = IN.ObjectSpaceTangent;
        return description;
    }
        
        // Graph Pixel
        struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
    };

    struct SurfaceDescription
    {
        float Alpha;
        float AlphaClipThreshold;
    };

    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
    {
        SurfaceDescription surface = (SurfaceDescription)0;
        float _SceneDepth_23A34ED8_Out_1;
        Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_23A34ED8_Out_1);
        float4 _ScreenPosition_11D5E144_Out_0 = IN.ScreenPosition;
        float _Split_F3199AB9_R_1 = _ScreenPosition_11D5E144_Out_0[0];
        float _Split_F3199AB9_G_2 = _ScreenPosition_11D5E144_Out_0[1];
        float _Split_F3199AB9_B_3 = _ScreenPosition_11D5E144_Out_0[2];
        float _Split_F3199AB9_A_4 = _ScreenPosition_11D5E144_Out_0[3];
        float _Subtract_AD703830_Out_2;
        Unity_Subtract_float(_Split_F3199AB9_A_4, 1, _Subtract_AD703830_Out_2);
        float _Subtract_C4FA93E4_Out_2;
        Unity_Subtract_float(_SceneDepth_23A34ED8_Out_1, _Subtract_AD703830_Out_2, _Subtract_C4FA93E4_Out_2);
        float _Property_2646B4F2_Out_0 = Vector1_F2113D60;
        float _Divide_E2FDC8DA_Out_2;
        Unity_Divide_float(_Subtract_C4FA93E4_Out_2, _Property_2646B4F2_Out_0, _Divide_E2FDC8DA_Out_2);
        float _Saturate_736439E3_Out_1;
        Unity_Saturate_float(_Divide_E2FDC8DA_Out_2, _Saturate_736439E3_Out_1);
        surface.Alpha = _Saturate_736439E3_Out_1;
        surface.AlphaClipThreshold = 0;
        return surface;
    }

        // --------------------------------------------------
        // Structs and Packing

        // Generated Type: Attributes
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };

        // Generated Type: Varyings
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                float3 interp00 : TEXCOORD0;
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output = (PackedVaryings)0;
                output.positionCS = input.positionCS;
                output.interp00.xyz = input.positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp00.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

        // --------------------------------------------------
        // Build Graph Inputs

        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);

        output.ObjectSpaceNormal =           input.normalOS;
        output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
        output.ObjectSpaceTangent =          input.tangentOS;
        output.ObjectSpacePosition =         input.positionOS;
        output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
        output.TimeParameters =              _TimeParameters.xyz;

        return output;
    }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





        output.WorldSpacePosition =          input.positionWS;
        output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
    }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

        ENDHLSL
    }

        Pass
    {
        Name "DepthOnly"
        Tags 
        { 
            "LightMode" = "DepthOnly"
        }
       
        // Render State
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        Cull Off
        ZTest LEqual
        ZWrite On
        ColorMask 0
        

        HLSLPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        // Pragmas
        #pragma prefer_hlslcc gles
    #pragma exclude_renderers d3d11_9x
    #pragma target 2.0
    #pragma multi_compile_instancing

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS 
        #define FEATURES_GRAPH_VERTEX
        #define SHADERPASS_DEPTHONLY
    #define REQUIRE_DEPTH_TEXTURE

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"

        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
    float4 Vector4_A472B6CF;
    float Vector1_4D839AAC;
    float Vector1_150AEC14;
    float Vector1_D5D352DC;
    float4 Vector4_973DA92B;
    float4 Color_1AB5F3EF;
    float4 Color_D23C8EF9;
    float Vector1_1C13E9DB;
    float Vector1_2AEBF55E;
    float Vector1_D82284B6;
    float Vector1_A931D240;
    float Vector1_8F89338B;
    float Vector1_5FD091B9;
    float Vector1_DB85C24D;
    float Vector1_75DA7D10;
    float Vector1_7710C9B;
    float Vector1_2A0C971B;
    float Vector1_F2113D60;
    CBUFFER_END

        // Graph Functions
        
    void Unity_Distance_float3(float3 A, float3 B, out float Out)
    {
        Out = distance(A, B);
    }

    void Unity_Divide_float(float A, float B, out float Out)
    {
        Out = A / B;
    }

    void Unity_Power_float(float A, float B, out float Out)
    {
        Out = pow(A, B);
    }

    void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
    {
        Out = A * B;
    }

    void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
    {
        Rotation = radians(Rotation);

        float s = sin(Rotation);
        float c = cos(Rotation);
        float one_minus_c = 1.0 - c;
        
        Axis = normalize(Axis);

        float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                  one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                  one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                };

        Out = mul(rot_mat,  In);
    }

    void Unity_Multiply_float(float A, float B, out float Out)
    {
        Out = A * B;
    }

    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
    {
        Out = UV * Tiling + Offset;
    }


    float2 Unity_GradientNoise_Dir_float(float2 p)
    {
        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
        p = p % 289;
        float x = (34 * p.x + 1) * p.x % 289 + p.y;
        x = (34 * x + 1) * x % 289;
        x = frac(x / 41) * 2 - 1;
        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
    }

    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
    { 
        float2 p = UV * Scale;
        float2 ip = floor(p);
        float2 fp = frac(p);
        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
    }

    void Unity_Add_float(float A, float B, out float Out)
    {
        Out = A + B;
    }

    void Unity_Saturate_float(float In, out float Out)
    {
        Out = saturate(In);
    }

    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
    {
        RGBA = float4(R, G, B, A);
        RGB = float3(R, G, B);
        RG = float2(R, G);
    }

    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
    {
        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
    }

    void Unity_Absolute_float(float In, out float Out)
    {
        Out = abs(In);
    }

    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
    {
        Out = smoothstep(Edge1, Edge2, In);
    }

    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
    {
        Out = A + B;
    }

    void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
    {
        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
    }

    void Unity_Subtract_float(float A, float B, out float Out)
    {
        Out = A - B;
    }

        // Graph Vertex
        struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 WorldSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float3 WorldSpacePosition;
        float3 TimeParameters;
    };

    struct VertexDescription
    {
        float3 VertexPosition;
        float3 VertexNormal;
        float3 VertexTangent;
    };

    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
    {
        VertexDescription description = (VertexDescription)0;
        float _Distance_E1AD3426_Out_2;
        Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_E1AD3426_Out_2);
        float _Property_50179BBC_Out_0 = Vector1_75DA7D10;
        float _Divide_A0D866_Out_2;
        Unity_Divide_float(_Distance_E1AD3426_Out_2, _Property_50179BBC_Out_0, _Divide_A0D866_Out_2);
        float _Power_8EA7AB9E_Out_2;
        Unity_Power_float(_Divide_A0D866_Out_2, 3, _Power_8EA7AB9E_Out_2);
        float3 _Multiply_F07C4AF5_Out_2;
        Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_8EA7AB9E_Out_2.xxx), _Multiply_F07C4AF5_Out_2);
        float _Property_FB45F40C_Out_0 = Vector1_1C13E9DB;
        float _Property_346016F9_Out_0 = Vector1_2AEBF55E;
        float4 _Property_2E24F547_Out_0 = Vector4_A472B6CF;
        float _Split_62F2AFD1_R_1 = _Property_2E24F547_Out_0[0];
        float _Split_62F2AFD1_G_2 = _Property_2E24F547_Out_0[1];
        float _Split_62F2AFD1_B_3 = _Property_2E24F547_Out_0[2];
        float _Split_62F2AFD1_A_4 = _Property_2E24F547_Out_0[3];
        float3 _RotateAboutAxis_6188BD4F_Out_3;
        Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_2E24F547_Out_0.xyz), _Split_62F2AFD1_A_4, _RotateAboutAxis_6188BD4F_Out_3);
        float _Property_BC923B99_Out_0 = Vector1_150AEC14;
        float _Multiply_40461E27_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_BC923B99_Out_0, _Multiply_40461E27_Out_2);
        float2 _TilingAndOffset_D42429F0_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_6188BD4F_Out_3.xy), float2 (1, 1), (_Multiply_40461E27_Out_2.xx), _TilingAndOffset_D42429F0_Out_3);
        float _Property_EA670B62_Out_0 = Vector1_4D839AAC;
        float _GradientNoise_BFC07395_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_D42429F0_Out_3, _Property_EA670B62_Out_0, _GradientNoise_BFC07395_Out_2);
        float2 _TilingAndOffset_4D7F6455_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_6188BD4F_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4D7F6455_Out_3);
        float _GradientNoise_42CB3D21_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_4D7F6455_Out_3, _Property_EA670B62_Out_0, _GradientNoise_42CB3D21_Out_2);
        float _Add_207E0907_Out_2;
        Unity_Add_float(_GradientNoise_BFC07395_Out_2, _GradientNoise_42CB3D21_Out_2, _Add_207E0907_Out_2);
        float _Divide_FDA1AFCB_Out_2;
        Unity_Divide_float(_Add_207E0907_Out_2, 2, _Divide_FDA1AFCB_Out_2);
        float _Saturate_62761A1_Out_1;
        Unity_Saturate_float(_Divide_FDA1AFCB_Out_2, _Saturate_62761A1_Out_1);
        float _Property_B2A9A59D_Out_0 = Vector1_D82284B6;
        float _Power_4B1FDE2B_Out_2;
        Unity_Power_float(_Saturate_62761A1_Out_1, _Property_B2A9A59D_Out_0, _Power_4B1FDE2B_Out_2);
        float4 _Property_1A2B3890_Out_0 = Vector4_973DA92B;
        float _Split_BDA7FCA2_R_1 = _Property_1A2B3890_Out_0[0];
        float _Split_BDA7FCA2_G_2 = _Property_1A2B3890_Out_0[1];
        float _Split_BDA7FCA2_B_3 = _Property_1A2B3890_Out_0[2];
        float _Split_BDA7FCA2_A_4 = _Property_1A2B3890_Out_0[3];
        float4 _Combine_7D405F42_RGBA_4;
        float3 _Combine_7D405F42_RGB_5;
        float2 _Combine_7D405F42_RG_6;
        Unity_Combine_float(_Split_BDA7FCA2_R_1, _Split_BDA7FCA2_G_2, 0, 0, _Combine_7D405F42_RGBA_4, _Combine_7D405F42_RGB_5, _Combine_7D405F42_RG_6);
        float4 _Combine_8247C46F_RGBA_4;
        float3 _Combine_8247C46F_RGB_5;
        float2 _Combine_8247C46F_RG_6;
        Unity_Combine_float(_Split_BDA7FCA2_B_3, _Split_BDA7FCA2_A_4, 0, 0, _Combine_8247C46F_RGBA_4, _Combine_8247C46F_RGB_5, _Combine_8247C46F_RG_6);
        float _Remap_28F198A_Out_3;
        Unity_Remap_float(_Power_4B1FDE2B_Out_2, (_Combine_7D405F42_RGBA_4.xy), _Combine_8247C46F_RG_6, _Remap_28F198A_Out_3);
        float _Absolute_F00D8B3C_Out_1;
        Unity_Absolute_float(_Remap_28F198A_Out_3, _Absolute_F00D8B3C_Out_1);
        float _Smoothstep_1E35709D_Out_3;
        Unity_Smoothstep_float(_Property_FB45F40C_Out_0, _Property_346016F9_Out_0, _Absolute_F00D8B3C_Out_1, _Smoothstep_1E35709D_Out_3);
        float _Property_870122A4_Out_0 = Vector1_8F89338B;
        float _Multiply_ED03077B_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_870122A4_Out_0, _Multiply_ED03077B_Out_2);
        float2 _TilingAndOffset_71F78084_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_6188BD4F_Out_3.xy), float2 (1, 1), (_Multiply_ED03077B_Out_2.xx), _TilingAndOffset_71F78084_Out_3);
        float _Property_2CF24586_Out_0 = Vector1_A931D240;
        float _GradientNoise_9D3CC735_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_71F78084_Out_3, _Property_2CF24586_Out_0, _GradientNoise_9D3CC735_Out_2);
        float _Property_D6F9E15B_Out_0 = Vector1_5FD091B9;
        float _Multiply_14634420_Out_2;
        Unity_Multiply_float(_GradientNoise_9D3CC735_Out_2, _Property_D6F9E15B_Out_0, _Multiply_14634420_Out_2);
        float _Add_D1851436_Out_2;
        Unity_Add_float(_Smoothstep_1E35709D_Out_3, _Multiply_14634420_Out_2, _Add_D1851436_Out_2);
        float _Add_DE5F53F1_Out_2;
        Unity_Add_float(1, _Property_D6F9E15B_Out_0, _Add_DE5F53F1_Out_2);
        float _Divide_5493E97E_Out_2;
        Unity_Divide_float(_Add_D1851436_Out_2, _Add_DE5F53F1_Out_2, _Divide_5493E97E_Out_2);
        float3 _Multiply_AD1B9D35_Out_2;
        Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_5493E97E_Out_2.xxx), _Multiply_AD1B9D35_Out_2);
        float _Property_574E2389_Out_0 = Vector1_D5D352DC;
        float3 _Multiply_2866962_Out_2;
        Unity_Multiply_float(_Multiply_AD1B9D35_Out_2, (_Property_574E2389_Out_0.xxx), _Multiply_2866962_Out_2);
        float3 _Add_B67FEF90_Out_2;
        Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2866962_Out_2, _Add_B67FEF90_Out_2);
        float3 _Add_D1E575B_Out_2;
        Unity_Add_float3(_Multiply_F07C4AF5_Out_2, _Add_B67FEF90_Out_2, _Add_D1E575B_Out_2);
        description.VertexPosition = _Add_D1E575B_Out_2;
        description.VertexNormal = IN.ObjectSpaceNormal;
        description.VertexTangent = IN.ObjectSpaceTangent;
        return description;
    }
        
        // Graph Pixel
        struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
    };

    struct SurfaceDescription
    {
        float Alpha;
        float AlphaClipThreshold;
    };

    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
    {
        SurfaceDescription surface = (SurfaceDescription)0;
        float _SceneDepth_23A34ED8_Out_1;
        Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_23A34ED8_Out_1);
        float4 _ScreenPosition_11D5E144_Out_0 = IN.ScreenPosition;
        float _Split_F3199AB9_R_1 = _ScreenPosition_11D5E144_Out_0[0];
        float _Split_F3199AB9_G_2 = _ScreenPosition_11D5E144_Out_0[1];
        float _Split_F3199AB9_B_3 = _ScreenPosition_11D5E144_Out_0[2];
        float _Split_F3199AB9_A_4 = _ScreenPosition_11D5E144_Out_0[3];
        float _Subtract_AD703830_Out_2;
        Unity_Subtract_float(_Split_F3199AB9_A_4, 1, _Subtract_AD703830_Out_2);
        float _Subtract_C4FA93E4_Out_2;
        Unity_Subtract_float(_SceneDepth_23A34ED8_Out_1, _Subtract_AD703830_Out_2, _Subtract_C4FA93E4_Out_2);
        float _Property_2646B4F2_Out_0 = Vector1_F2113D60;
        float _Divide_E2FDC8DA_Out_2;
        Unity_Divide_float(_Subtract_C4FA93E4_Out_2, _Property_2646B4F2_Out_0, _Divide_E2FDC8DA_Out_2);
        float _Saturate_736439E3_Out_1;
        Unity_Saturate_float(_Divide_E2FDC8DA_Out_2, _Saturate_736439E3_Out_1);
        surface.Alpha = _Saturate_736439E3_Out_1;
        surface.AlphaClipThreshold = 0;
        return surface;
    }

        // --------------------------------------------------
        // Structs and Packing

        // Generated Type: Attributes
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };

        // Generated Type: Varyings
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                float3 interp00 : TEXCOORD0;
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output = (PackedVaryings)0;
                output.positionCS = input.positionCS;
                output.interp00.xyz = input.positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp00.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

        // --------------------------------------------------
        // Build Graph Inputs

        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);

        output.ObjectSpaceNormal =           input.normalOS;
        output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
        output.ObjectSpaceTangent =          input.tangentOS;
        output.ObjectSpacePosition =         input.positionOS;
        output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
        output.TimeParameters =              _TimeParameters.xyz;

        return output;
    }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





        output.WorldSpacePosition =          input.positionWS;
        output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
    }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

        ENDHLSL
    }

    }
    FallBack "Hidden/Shader Graph/FallbackError"
}
