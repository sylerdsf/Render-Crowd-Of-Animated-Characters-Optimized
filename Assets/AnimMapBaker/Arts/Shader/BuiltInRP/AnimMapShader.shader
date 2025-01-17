﻿/*
Created by jiadong chen
https://jiadong-chen.medium.com/
*/

Shader "chenjd/BuiltIn/AnimMapShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_AnimMap ("AnimMap", 2D) ="white" {}
		_AnimLen("Anim Length", Float) = 0
		_PosRegionStart("PosRegionStart", Vector) = (0, 0, 0, 0)
		_PosRegionEnd("PosRegionEnd", Vector) = (0, 0, 0, 0)
	}
	
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Cull off
		LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //开启gpu instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ TEXTURE_COMPRESSION
            #pragma multi_compile _ VTX_CULLING

            #include "UnityCG.cginc"

            struct appdata
            {
                float2 uv : TEXCOORD0;
                float2 uv3 : TEXCOORD2;
                float4 pos : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _AnimMap;
            float4 _AnimMap_TexelSize;//x == 1/width

            float _AnimLen;

#if TEXTURE_COMPRESSION
            float3 _PosRegionStart;
            float3 _PosRegionEnd;
#endif
            v2f vert (appdata v, uint vid : SV_VertexID)
            {
                UNITY_SETUP_INSTANCE_ID(v);

#if VTX_CULLING
                uint vindex = v.uv3.x;
#else
                uint vindex = vid;
#endif

                float animMap_x = (vindex + 0.5) * _AnimMap_TexelSize.x;
                float animMap_y = fmod(_Time.y / _AnimLen, 1.0);

                float4 pos = tex2Dlod(_AnimMap, float4(animMap_x, animMap_y, 0, 0));

#if TEXTURE_COMPRESSION
                pos.xyz = lerp(_PosRegionStart, _PosRegionEnd, pos.xyz);
#endif
                v2f o;
                o.vertex = UnityObjectToClipPos(pos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				//v2f o;
				//o.vertex = UnityObjectToClipPos(v.pos);
				//o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
	}
}
