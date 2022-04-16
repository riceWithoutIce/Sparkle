Shader "Rice/Sparkle"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}

        [Header(Sparkle)]
        _SparkleTex ("Sparkle texture (rgb: color, a: mask)", 2D) = "black" {}
        [Header(Color)]
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
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"
                #include "Sparkle.cginc"

                half4 _Color;
                sampler2D _MainTex;
                float4 _MainTex_ST;

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                    half3 normal : NORMAL;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                    half3 wsNormal : TEXCOORD1;
                    half3 viewDir : TEXCOORD2;
                };

                v2f vert (appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    o.wsNormal = normalize(UnityObjectToWorldNormal(v.normal));
                    o.viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                    return o;
                }

                fixed4 frag (v2f i) : SV_Target
                {
                    fixed4 col = tex2D(_MainTex, i.uv) * _Color;

                    half2 uv = i.uv;
                    half nv = abs(dot(i.wsNormal, i.viewDir));
                    col.rgb = Sparkle(col, uv, nv);

                    // half4 sparkleTex = tex2D(_SparkleTex, uv);
                    
                    // half intensity = sparkleTex.a * pow(nv, _SparkleRange);

                    // half2 coord = half2(uv.x * _SparkleScale, uv.y * _SparkleScale);
                    // half2 coordFloor = floor(coord);
                    // coord -= coordFloor;
                    // half2 coordCenter = 0.5f;
                    // half3 sparkle = Sparkle(coord, coordFloor, coordCenter, intensity).xxx * _SparkleColor.rgb * sparkleTex.rgb;
                    
                    // col.rgb += sparkle;

                    return col;
                }
            ENDCG
        }
    }
}
