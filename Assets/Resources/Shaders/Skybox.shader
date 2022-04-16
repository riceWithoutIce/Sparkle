// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Rice/Skybox/6 Sided Sparkle" 
{
    Properties 
    {
        _Tint ("Tint Color", Color) = (.5, .5, .5, .5)
        [Gamma] _Exposure ("Exposure", Range(0, 8)) = 1.0
        _Rotation ("Rotation", Range(0, 360)) = 0
        [NoScaleOffset] _FrontTex ("Front [+Z]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _BackTex ("Back [-Z]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _LeftTex ("Left [+X]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _RightTex ("Right [-X]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _UpTex ("Up [+Y]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _DownTex ("Down [-Y]   (HDR)", 2D) = "grey" {}

        [Header(Sparkle)]
        _SparkleTex ("Sparkle texture (rgb: color, a: mask)", 2D) = "black" {}
        [HDR]_SparkleColor1 ("Sparkle color 1", Color) = (1, 1, 1, 1)
        [HDR]_SparkleColor2 ("Sparkle color 2", Color) = (1, 1, 1, 1)
        _SparkleColor01 ("Sparkle threshold", Range(0, 1)) = 0.5
        [Header(Size Scale)]
        _SparkleScale ("Sparkle intensity", Range(0, 1000)) = 1
        _SparkleRange ("Sparkle range", Range(0, 10)) = 1
        _SparkleSize ("Sparkle max size", Range(0, 0.5)) = 0.5
        _SparkleSizeMin ("Sparkle min size", Range(0, 0.5)) = 0.2
        _SparkleOffset ("Sparkle offset", Range(0, 1)) = 0
        [Header(Shine)]
        _SparkleShine ("Sparkle shine", Range(0, 20)) = 0
        _SparkleShineColor ("Sparkle shine color", Range(0, 20)) = 0
        [Header(Speed)]
        _SparkleSpeedU ("Sparkle speed u", Range(-5, 5)) = 0
        _SparkleSpeedV ("Sparkle speed v", Range(-5, 5)) = 0
    }

    SubShader 
    {
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
        Cull Off ZWrite Off

        CGINCLUDE
            #include "UnityCG.cginc"
            #include "Sparkle.cginc"

            half4 _Tint;
            half _Exposure;
            float _Rotation;

            float3 RotateAroundYInDegrees (float3 vertex, float degrees)
            {
                float alpha = degrees * UNITY_PI / 180.0;
                float sina, cosa;
                sincos(alpha, sina, cosa);
                float2x2 m = float2x2(cosa, -sina, sina, cosa);
                return float3(mul(m, vertex.xz), vertex.y).xzy;
            }

            struct appdata_t 
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f 
            {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert (appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                float3 rotated = RotateAroundYInDegrees(v.vertex, _Rotation);
                o.vertex = UnityObjectToClipPos(rotated);
                o.texcoord = v.texcoord;
                return o;
            }

            half4 skybox_frag (v2f i, sampler2D smp, half4 smpDecode)
            {
                half4 tex = tex2D (smp, i.texcoord);
                half3 c = DecodeHDR (tex, smpDecode);
                c = c * _Tint.rgb * unity_ColorSpaceDouble.rgb;
                c *= _Exposure;

                half2 uv = i.texcoord;
                half4 sparkleTex = tex2D(_SparkleTex, uv);
                half intensity = 1;

                half2 coord = half2(uv.x * _SparkleScale, uv.y * _SparkleScale);
                half2 coordFloor = floor(coord);
                coord -= coordFloor;
                half2 coordCenter = 0.5f;
                half4 sparkle = Sparkle(coord, coordFloor, coordCenter, intensity);
                sparkle.rgb *= sparkleTex.rgb;

                c = lerp(c.rgb, sparkle.rgb, sparkle.a);

                return half4(c, 1);
            }
        ENDCG

        Pass 
        {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0
                sampler2D _FrontTex;
                half4 _FrontTex_HDR;
                half4 frag (v2f i) : SV_Target { return skybox_frag(i,_FrontTex, _FrontTex_HDR); }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0
                sampler2D _BackTex;
                half4 _BackTex_HDR;
                half4 frag (v2f i) : SV_Target { return skybox_frag(i,_BackTex, _BackTex_HDR); }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0
                sampler2D _LeftTex;
                half4 _LeftTex_HDR;
                half4 frag (v2f i) : SV_Target { return skybox_frag(i,_LeftTex, _LeftTex_HDR); }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0
                sampler2D _RightTex;
                half4 _RightTex_HDR;
                half4 frag (v2f i) : SV_Target { return skybox_frag(i,_RightTex, _RightTex_HDR); }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0
                sampler2D _UpTex;
                half4 _UpTex_HDR;
                half4 frag (v2f i) : SV_Target { return skybox_frag(i,_UpTex, _UpTex_HDR); }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0
                sampler2D _DownTex;
                half4 _DownTex_HDR;
                half4 frag (v2f i) : SV_Target { return skybox_frag(i,_DownTex, _DownTex_HDR); }
            ENDCG
        }
    }
}
