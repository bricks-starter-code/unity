Shader "bricksseeds/PerlinTerrain"
{
	Properties
	{
		_Density ("Density", Range(1, 10)) = 1
		_Height ("Height", Range(.01, .2)) = .1
		
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
	{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

		//
		// Noise Shader Library for Unity - https://github.com/keijiro/NoiseShader
		//
		// Original work (webgl-noise) Copyright (C) 2011 Stefan Gustavson
		// Translation and modification was made by Keijiro Takahashi.
		//
		// This shader is based on the webgl-noise GLSL shader. For further details
		// of the original shader, please see the following description from the
		// original source code.
		//

		//
		// GLSL textureless classic 2D noise "cnoise",
		// with an RSL-style periodic variant "pnoise".
		// Author:  Stefan Gustavson (stefan.gustavson@liu.se)
		// Version: 2011-08-22
		//
		// Many thanks to Ian McEwan of Ashima Arts for the
		// ideas for permutation and gradient selection.
		//
		// Copyright (c) 2011 Stefan Gustavson. All rights reserved.
		// Distributed under the MIT license. See LICENSE file.
		// https://github.com/ashima/webgl-noise
		//

		float4 mod(float4 x, float4 y)
	{
		return x - y * floor(x / y);
	}

	float4 mod289(float4 x)
	{
		return x - floor(x / 289.0) * 289.0;
	}

	float4 permute(float4 x)
	{
		return mod289(((x*34.0) + 1.0)*x);
	}

	float4 taylorInvSqrt(float4 r)
	{
		return (float4)1.79284291400159 - r * 0.85373472095314;
	}

	float2 fade(float2 t) {
		return t * t*t*(t*(t*6.0 - 15.0) + 10.0);
	}

	// Classic Perlin noise
	float cnoise(float2 P)
	{
		float4 Pi = floor(P.xyxy) + float4(0.0, 0.0, 1.0, 1.0);
		float4 Pf = frac(P.xyxy) - float4(0.0, 0.0, 1.0, 1.0);
		Pi = mod289(Pi); // To avoid truncation effects in permutation
		float4 ix = Pi.xzxz;
		float4 iy = Pi.yyww;
		float4 fx = Pf.xzxz;
		float4 fy = Pf.yyww;

		float4 i = permute(permute(ix) + iy);

		float4 gx = frac(i / 41.0) * 2.0 - 1.0;
		float4 gy = abs(gx) - 0.5;
		float4 tx = floor(gx + 0.5);
		gx = gx - tx;

		float2 g00 = float2(gx.x,gy.x);
		float2 g10 = float2(gx.y,gy.y);
		float2 g01 = float2(gx.z,gy.z);
		float2 g11 = float2(gx.w,gy.w);

		float4 norm = taylorInvSqrt(float4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
		g00 *= norm.x;
		g01 *= norm.y;
		g10 *= norm.z;
		g11 *= norm.w;

		float n00 = dot(g00, float2(fx.x, fy.x));
		float n10 = dot(g10, float2(fx.y, fy.y));
		float n01 = dot(g01, float2(fx.z, fy.z));
		float n11 = dot(g11, float2(fx.w, fy.w));

		float2 fade_xy = fade(Pf.xy);
		float2 n_x = lerp(float2(n00, n01), float2(n10, n11), fade_xy.x);
		float n_xy = lerp(n_x.x, n_x.y, fade_xy.y);
		return 2.3 * n_xy;
	}

	// Classic Perlin noise, periodic variant
	float pnoise(float2 P, float2 rep)
	{
		float4 Pi = floor(P.xyxy) + float4(0.0, 0.0, 1.0, 1.0);
		float4 Pf = frac(P.xyxy) - float4(0.0, 0.0, 1.0, 1.0);
		Pi = mod(Pi, rep.xyxy); // To create noise with explicit period
		Pi = mod289(Pi);        // To avoid truncation effects in permutation
		float4 ix = Pi.xzxz;
		float4 iy = Pi.yyww;
		float4 fx = Pf.xzxz;
		float4 fy = Pf.yyww;

		float4 i = permute(permute(ix) + iy);

		float4 gx = frac(i / 41.0) * 2.0 - 1.0;
		float4 gy = abs(gx) - 0.5;
		float4 tx = floor(gx + 0.5);
		gx = gx - tx;

		float2 g00 = float2(gx.x,gy.x);
		float2 g10 = float2(gx.y,gy.y);
		float2 g01 = float2(gx.z,gy.z);
		float2 g11 = float2(gx.w,gy.w);

		float4 norm = taylorInvSqrt(float4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
		g00 *= norm.x;
		g01 *= norm.y;
		g10 *= norm.z;
		g11 *= norm.w;

		float n00 = dot(g00, float2(fx.x, fy.x));
		float n10 = dot(g10, float2(fx.y, fy.y));
		float n01 = dot(g01, float2(fx.z, fy.z));
		float n11 = dot(g11, float2(fx.w, fy.w));

		float2 fade_xy = fade(Pf.xy);
		float2 n_x = lerp(float2(n00, n01), float2(n10, n11), fade_xy.x);
		float n_xy = lerp(n_x.x, n_x.y, fade_xy.y);
		return 2.3 * n_xy;
	}

	float _Density;
	float _Height;

		struct appdata
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
	};

	struct v2f
	{
		float4 vertex : SV_POSITION;
		float3 normal: NORMAL;
		float3 objectSpacePosition : TEXCOORD0;
	};


	float height(fixed2 xy) {
		return cnoise(xy * _Density)*_Height;
	}

	v2f vert(appdata v)
	{
		v2f o;
		fixed3 modelSpace = v.vertex;
		fixed2 P = fixed2(modelSpace.x, modelSpace.z);
		float newY = height(P);
		fixed3 altered = fixed3(P.x, newY, P.y);
		o.vertex = UnityObjectToClipPos(altered);
		o.objectSpacePosition = altered;



		//calculate the normal
		fixed2 offset1 = fixed2(1,0) * .01;
		fixed2 offset2 = fixed2(0,1) * .01;
		fixed2 ms1 = P + offset1;
		fixed2 ms2 = P + offset2;
		float height1 = height(ms1);
		float height2 = height(ms2);
		fixed3 P1 = fixed3(ms1.x, height1, ms1.y);
		fixed3 P2 = fixed3(ms2.x, height2, ms2.y);
		fixed3 tangent1 = normalize(P1 - altered);
		fixed3 tangent2 = normalize(P2 - altered);
		fixed3 newNormal = cross(tangent2, tangent1);
		o.normal = normalize(newNormal);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed3 objectSpaceColor = frac(abs(i.objectSpacePosition));
		fixed3 normalColor = i.normal * .5 + fixed3(.5, .5, .5);

		float d = dot(normalize(half3(0, 1, 0)), i.normal);

		fixed3 baseColor = fixed3(0, 1, 0);

		float h = (i.objectSpacePosition.y / _Height + 1) / 2;
		if (h < .1) {
			baseColor = fixed3(0, 0, 1);
		}
		else if (h < .2) {
			baseColor = fixed3(.7, .7, 0);
		}
		else if (h < .5)
		{
			baseColor = fixed3(0, .8, 0);
		}
		else if (h < .8) {
			baseColor = fixed3(.5, .5, 0);
		}
		else {
			baseColor = fixed3(.9, .9, .9);
		}

		float3 simpleLightingColor = baseColor * d;


		fixed4 final = fixed4(simpleLightingColor, 1);//Or for debugging use normalColor, objectSpaceColor
		return final;

	}



		ENDCG
	}
	}
}
