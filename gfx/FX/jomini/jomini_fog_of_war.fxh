Includes = {
	#"cw/utility.fxh"
}

ConstantBuffer( JominiFogOfWar )
{
	float2	FogOfWarAlphaMapSize;
	float2	InverseWorldSize;
	float2	FogOfWarPatternSpeed;
	float	FogOfWarPatternStrength;
	float	FogOfWarPatternTiling;
	float	FogOfWarTime;
	float	FogOfWarAlphaMin;
}

PixelShader = 
{
	Code
	[[
		#ifndef FOG_OF_WAR_BLEND_FUNCTION
			#define FOG_OF_WAR_BLEND_FUNCTION loc_BlendFogOfWar
			float4 loc_BlendFogOfWar( float Alpha )
			{
				return float4( float3(0.0), 1.0 - Alpha );
			}
		#endif
		
		void loc_ApplyFogOfWarPattern( inout float Alpha, in float3 Coordinate, PdxTextureSampler2D FogOfWarAlphaMask )
		{
			if( FogOfWarPatternStrength > 0.0f )
			{
				float2 UV = Coordinate.xz * InverseWorldSize * FogOfWarPatternTiling;
				UV += FogOfWarPatternSpeed * FogOfWarTime;
				float Noise1 = 1.0f - PdxTex2D( FogOfWarAlphaMask, UV ).g;
				float Noise2 = 1.0f - PdxTex2D( FogOfWarAlphaMask, UV * -0.13 ).g;
				float Detail = 0.5f;
				
				float Noise = saturate( Noise2 * (1.0f-Detail) + Detail * 0.5f + (Noise1-0.5f) * Detail );
				
				Noise *= 1.0f - Alpha;
				Alpha = smoothstep( 0.0, 1.0, Alpha + Noise * FogOfWarPatternStrength );
			}
		}
		float GetFogOfWarAlpha( in float3 Coordinate, PdxTextureSampler2D FogOfWarAlphaMask )
		{		
			float Alpha = PdxTex2D( FogOfWarAlphaMask, Coordinate.xz * InverseWorldSize ).r;
			
			loc_ApplyFogOfWarPattern( Alpha, Coordinate, FogOfWarAlphaMask );
			
			return FogOfWarAlphaMin + Alpha * (1.0f - FogOfWarAlphaMin);
		}
		float GetFogOfWarAlphaMultiSampled( in float3 Coordinate, PdxTextureSampler2D FogOfWarAlphaMask )
		{
			float Width = 5.0f;
			float Alpha = 0.0f; 
			Alpha += PdxTex2D( FogOfWarAlphaMask, ( Coordinate.xz + float2( 0,-1) * Width ) * InverseWorldSize ).r;
			Alpha += PdxTex2D( FogOfWarAlphaMask, ( Coordinate.xz + float2(-1, 0) * Width ) * InverseWorldSize ).r;
			Alpha += PdxTex2D( FogOfWarAlphaMask, ( Coordinate.xz + float2( 1, 0) * Width ) * InverseWorldSize ).r;
			Alpha += PdxTex2D( FogOfWarAlphaMask, ( Coordinate.xz + float2( 0, 1) * Width ) * InverseWorldSize ).r;
			Alpha /= 4.0f;
			
			loc_ApplyFogOfWarPattern( Alpha, Coordinate, FogOfWarAlphaMask );
			return FogOfWarAlphaMin + Alpha * (1.0f - FogOfWarAlphaMin);


			// float2 uv = Coordinate.xz * InverseWorldSize;
			// uv.y++;

			// float mx = 1.0; // start smoothing wt.
			// float sizeX = 1024.0;
			// float sizeY = 512.0;
			// const float k = -1.10; // wt. decrease factor
			// const float max_w = 1.0; // max filter weigth
			// const float min_w = 0.0; // min filter weigth
			// const float lum_add = 0.33; // effects smoothing

			// float4 color = PdxTex2D(FogOfWarAlphaMask, uv);
			// float3 c = color.xyz;


			// float x = 0.5 * (1.0 / sizeX);
			// float y = 0.5 * (1.0 / sizeY);

			// const float3 dt = 1.0*float3(1.0, 1.0, 1.0);

			// float2 dg1 = float2( x, y);
			// float2 dg2 = float2(-x, y);

			// float2 sd1 = dg1*0.5;
			// float2 sd2 = dg2*0.5;

			// float2 ddx = float2(x,0.0);
			// float2 ddy = float2(0.0,y);

			// float4 t1 = float4(uv-sd1,uv-ddy);
			// float4 t2 = float4(uv-sd2,uv+ddx);
			// float4 t3 = float4(uv+sd1,uv+ddy);
			// float4 t4 = float4(uv+sd2,uv-ddx);
			// float4 t5 = float4(uv-dg1,uv-dg2);
			// float4 t6 = float4(uv+dg1,uv+dg2);
				
			// float3 i1 = PdxTex2D(FogOfWarAlphaMask, t1.xy).xyz;
			// float3 i2 = PdxTex2D(FogOfWarAlphaMask, t2.xy).xyz;
			// float3 i3 = PdxTex2D(FogOfWarAlphaMask, t3.xy).xyz;
			// float3 i4 = PdxTex2D(FogOfWarAlphaMask, t4.xy).xyz;

			// float3 o1 = PdxTex2D(FogOfWarAlphaMask, t5.xy).xyz;
			// float3 o3 = PdxTex2D(FogOfWarAlphaMask, t6.xy).xyz;
			// float3 o2 = PdxTex2D(FogOfWarAlphaMask, t5.zw).xyz;
			// float3 o4 = PdxTex2D(FogOfWarAlphaMask, t6.zw).xyz;

			// float3 s1 = PdxTex2D(FogOfWarAlphaMask, t1.zw).xyz;
			// float3 s2 = PdxTex2D(FogOfWarAlphaMask, t2.zw).xyz;
			// float3 s3 = PdxTex2D(FogOfWarAlphaMask, t3.zw).xyz;
			// float3 s4 = PdxTex2D(FogOfWarAlphaMask, t4.zw).xyz;

			// float ko1 = dot(abs(o1-c),dt);
			// float ko2 = dot(abs(o2-c),dt);
			// float ko3 = dot(abs(o3-c),dt);
			// float ko4 = dot(abs(o4-c),dt);

			// float k1=min(dot(abs(i1-i3),dt),max(ko1,ko3));
			// float k2=min(dot(abs(i2-i4),dt),max(ko2,ko4));

			// float w1 = k2; if(ko3<ko1) w1*=ko3/ko1;
			// float w2 = k1; if(ko4<ko2) w2*=ko4/ko2;
			// float w3 = k2; if(ko1<ko3) w3*=ko1/ko3;
			// float w4 = k1; if(ko2<ko4) w4*=ko2/ko4;

			// c=(w1*o1+w2*o2+w3*o3+w4*o4+0.001*c)/(w1+w2+w3+w4+0.001);
			// w1 = k*dot(abs(i1-c)+abs(i3-c),dt)/(0.125*dot(i1+i3,dt)+lum_add);
			// w2 = k*dot(abs(i2-c)+abs(i4-c),dt)/(0.125*dot(i2+i4,dt)+lum_add);
			// w3 = k*dot(abs(s1-c)+abs(s3-c),dt)/(0.125*dot(s1+s3,dt)+lum_add);
			// w4 = k*dot(abs(s2-c)+abs(s4-c),dt)/(0.125*dot(s2+s4,dt)+lum_add);

			// w1 = clamp(w1+mx,min_w,max_w);
			// w2 = clamp(w2+mx,min_w,max_w);
			// w3 = clamp(w3+mx,min_w,max_w);
			// w4 = clamp(w4+mx,min_w,max_w);

			// color = float4((w1*(i1+i3)+w2*(i2+i4)+w3*(s1+s3)+w4*(s2+s4)+c)/(2.0*(w1+w2+w3+w4)+1.0), 1.0);

			// return color;
		}
		
		float3 FogOfWarBlend( float3 Color, float Alpha )
		{		
			float4 ColorAndAlpha = FOG_OF_WAR_BLEND_FUNCTION( Alpha );
			return lerp( Color, ColorAndAlpha.rgb, ColorAndAlpha.a );
		}
		
		// Immediate mode
		float3 ApplyFogOfWar( in float3 Color, in float3 Coordinate, PdxTextureSampler2D FogOfWarAlphaMask )
		{
			float Alpha = GetFogOfWarAlpha( Coordinate, FogOfWarAlphaMask );
			return FogOfWarBlend( Color, Alpha );
		}
		float3 ApplyFogOfWarMultiSampled( in float3 Color, in float3 Coordinate, PdxTextureSampler2D FogOfWarAlphaMask )
		{
			float Alpha = GetFogOfWarAlphaMultiSampled( Coordinate, FogOfWarAlphaMask );
			return FogOfWarBlend( Color, Alpha );
		}
		
		// Post process
		float4 ApplyFogOfWar( in float3 WorldSpacePos, PdxTextureSampler2D FogOfWarAlphaMask )
		{
			return FOG_OF_WAR_BLEND_FUNCTION( GetFogOfWarAlpha( WorldSpacePos, FogOfWarAlphaMask ) );
		}
	]]
}
