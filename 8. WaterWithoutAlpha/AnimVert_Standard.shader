// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Animated/AnimVert_Standard"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Offset ("Sorting Offset", float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Source Blend mode", Float) = 5 // SrcAlpha
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dest Blend mode", Float) = 10 // OneMinusSrcAlpha
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Float) = 4
		_ZWrite ("ZWrite", Float) = 1
		[Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Float) = 2

		__Stencil ("Ref", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)] __StencilComp ("Comparison", Float) = 8
		__StencilReadMask ("Read Mask", Float) = 255
		__StencilWriteMask ("Write Mask", Float) = 255
		[Enum(UnityEngine.Rendering.StencilOp)] __StencilPassOp ("Pass Operation", Float) = 0
		[Enum(UnityEngine.Rendering.StencilOp)] __StencilFailOp ("Fail Operation", Float) = 0
		[Enum(UnityEngine.Rendering.StencilOp)] __StencilZFailOp ("ZFail Operation", Float) = 0
	}

	SubShader
	{
		Lighting Off
		Fog{ Mode Off }
		ZTest[_ZTest]
		ZWrite[_ZWrite]
		Cull[_Cull]
		Blend[_SrcBlend][_DstBlend]
		Offset 0, 0

		Tags
		{
			"CanUseSpriteAtlas" = "True"
		}

		Stencil
		{
			Ref[__Stencil]
			Comp[__StencilComp]
			ReadMask[__StencilReadMask]
			WriteMask[__StencilWriteMask]
			Pass[__StencilPassOp]
			Fail[__StencilFailOp]
			ZFail[__StencilZFailOp]
		}

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma glsl_no_auto_normalization
			#pragma fragmentoption ARB_precision_hint_fastest
			
			#pragma multi_compile _ LIGHTMAP_OFF
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
	
			struct appdata
			{
				fixed4 normal : NORMAL;
				fixed4 color : COLOR;
				float4 vertex : POSITION;
				float2 uv1 : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
			};
	
			struct v2f
			{
				half4 color : COLOR;
				float4 vertex : SV_POSITION;
				half2 uv : TEXCOORD0;
				half2 cap : TEXCOORD1;
			};
	
			sampler2D _MainTex;
			half4 _MainTex_ST;
			uniform sampler2D _MatCapTex;
			half4 _MatCapTex_TexelSize;
			uniform half _AnimMulti;
			uniform half _DistanceMulti;
	
			v2f vert(appdata v)
			{
				v2f o;
				o.color = v.color;
				o.uv = TRANSFORM_TEX (v.uv1, _MainTex);

				//Animate based off UV2 settings
				half distance = (v.uv2.x - frac(v.uv2.x)) / 6400.0;
				half speed = (v.uv2.y - frac(v.uv2.y)) / 255;
				half3 noise = sin(dot(v.normal.xyz + _Time.y, half2(12.9898, 78.233)) * speed * _AnimMulti)* distance * _DistanceMulti;
				noise *= v.normal;
				float4 vertex = v.vertex + half4(noise.xyz, 0.0);

				//matcap atlas
				half3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
				worldNorm = mul((half3x3)UNITY_MATRIX_V, worldNorm) * 0.95;
				o.cap = worldNorm.xy * 0.5 + 0.5;

				o.vertex = UnityObjectToClipPos(vertex);
				return o;
			}
	
			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				half3 col = tex2D(_MainTex, i.uv).rgb;
				// Look up in the matcap!
				half3 matcapColor = tex2D(_MatCapTex, i.cap.xy).rgb;
				half3 matcapColor2 = tex2D(_MatCapTex, half2(0.5,1.0)).rgb;
				// alpha step
				half Step = saturate(i.color.a - 0.9);
				matcapColor = lerp(matcapColor2, matcapColor, Step);
				col = lerp(i.color.rgb, col.rgb * i.color.rgb, i.color.a);

				col = col * matcapColor * 1.5;
				//col = matcapColor;
				return float4(col, 1.0);
			}
			ENDCG
		}
	}
	Fallback "Unlit/Texture"
}
