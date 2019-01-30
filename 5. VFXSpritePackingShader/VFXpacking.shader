Shader "Sprites/VFXpacking"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				half3 uv : TEXCOORD0;
			};

			struct v2f
			{
				half3 uv : TEXCOORD0;
				half4 color : COLOR;
				half4 mix : COLOR1;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half _Offset;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.vertex.z += _Offset;
				o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
				o.uv.z = v.uv.z;
				half4 mix = lerp(half4(0,0,0,1), half4(1,0,0,0), max(0,sign(abs(v.uv.z) - 0.99)));
				mix = lerp(mix, half4(0,1,0,0), max(0,sign(abs(v.uv.z) - 1.99)));
				mix = lerp(mix, half4(0,0,1,0), max(0,sign(abs(v.uv.z) - 2.99)));
				mix = lerp(mix, half4(0,0,0,1), max(0,sign(abs(v.uv.z) - 3.99)));
				o.mix = mix;
				o.color = v.color;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				half4 col = tex2D(_MainTex, i.uv.xy);
				half4 colA = col * i.mix;
				half channel = colA.r + colA.g + colA.b + colA.a;
				half mix = step(0.99, (i.uv.z*i.uv.z));
				col = lerp(col, half4(1,1,1,channel), mix);
				col = lerp(col, half4(col.rgb * channel, channel), step(i.uv.z, -0.01));

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col * i.color;
			}
			ENDCG
		}
	}
}
