Includes = {
	"cw/pdxgui.fxh"
	"cw/pdxgui_sprite.fxh"
	"standardfuncsgfx.fxh"
}


VertexShader =
{
	MainCode VertexShader
	{
		Input = "VS_INPUT_PDX_GUI"
		Output = "VS_OUTPUT_PDX_GUI"
		Code
		[[
			PDX_MAIN
			{
				return PdxGuiDefaultVertexShader( Input );
			}
		]]
	}
}


PixelShader =
{
	MainCode PixelShader
	{
		TextureSampler Texture
		{
			Ref = PdxTexture0
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
		}
	
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float4 OutColor = SampleImageSprite( Texture, Input.UV0 );
				OutColor *= Input.Color;
				
				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif

			    return OutColor;
			}
		]]
	}

	MainCode test_PixelShader
	{
		TextureSampler Texture
		{
			Ref = PdxTexture0
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
		}
		TextureSampler ShipTexture
		{
			Ref = PdxTexture1
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
			File = "gfx/interface/images/test/steamer_s.dds"
			srgb = yes
		}
		TextureSampler WaterAlphaTexture
		{
			Ref = PdxTexture2
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
			File = "gfx/interface/images/test/water_alpha.dds"
			srgb = yes
		}
		TextureSampler FogAlphaTexture
		{
			Ref = PdxTexture3
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
			File = "gfx/interface/images/test/fog_alpha.dds"
			srgb = yes
		}
		TextureSampler NoiseTexture
		{
			Ref = PdxTexture4
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Wrap"
			SampleModeV = "Wrap"
			File = "gfx/interface/images/test/noise.dds"
			srgb = yes
		}
		TextureSampler WheelTexture
		{
			Ref = PdxTexture5
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
			File = "gfx/interface/images/test/wheel.dds"
			srgb = yes
		}
		TextureSampler WheelAlphaTexture
		{
			Ref = PdxTexture6
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
			File = "gfx/interface/images/test/wheel_a.dds"
			srgb = yes
		}
		TextureSampler Flag0Texture
		{
			Ref = PdxTexture7
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
			File = "gfx/interface/images/test/flag_1.dds"
			srgb = yes
		}
		TextureSampler Flag1Texture
		{
			Ref = PdxTexture8
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
			File = "gfx/interface/images/test/flag_2.dds"
			srgb = yes
		}
		TextureSampler FinalMask
		{
			Ref = PdxTexture9
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
			File = "gfx/interface/base_parts/gradient_black_invert.dds"
			srgb = yes
		}
		TextureSampler SideMask
		{
			Ref = PdxTexture10
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
			File = "gfx/interface/images/test/horizontal.dds"
			srgb = yes
		}
		Input = "VS_OUTPUT_PDX_GUI"
		Output = "PDX_COLOR"

		Code
		[[
			// float4 testfloat( PdxTextureSampler2D NewTexture, in float2 UV )
			// {
			// 	float4 Color = SampleImageSprite( NewTexture, UV );
			// 	return Color;
			// }
			float4 MixImages(in float4 Texture01, in float4 Texture02)
			{
				float4 Color = lerp(Texture01, Texture02, lerp(Texture01.a, Texture02.a, 1.0));
				return Color;
			}
			float2 rotateUV(float2 uv, float rotation)
			{
			    float mid_x = 0.5;
			    float mid_y = 1.0;
			    return float2(
			        cos(rotation) * (uv.x - mid_x) + sin(rotation) * (uv.y - mid_y) + mid_x,
			        cos(rotation) * (uv.y - mid_y) - sin(rotation) * (uv.x - mid_x) + mid_y
			    );
			}
			float2 rotateUV_2(float2 uv, float rotation)
			{
			    float mid = 0.5;
			    return float2(
			        cos(rotation) * (uv.x - mid) + sin(rotation) * (uv.y - mid) + mid,
			        cos(rotation) * (uv.y - mid) - sin(rotation) * (uv.x - mid) + mid
			    );
			}
			float4 Flag(PdxTextureSampler2D Texture01, in float2 UV, in float2 BaseUV, in float3 BasePosition, in float Time, in float FlagWaveSize) {
				float2 FlagWave = sin((UV.x+Time*0.1) * FlagWaveSize) * 0.03;
				float4 Color = SampleImageSprite( Texture01, float3(UV.x, UV.y + FlagWave) );
				float value = dot(float3(1, 1, 1) / 45, Color.xyz);
				float f = sin(Time * -1 * 0.5 * (1.0f + 0.0001 * abs(sin(BasePosition.y * 0.02))) + BasePosition.x * 0.06 + 0.5 * sin(BasePosition.y * 0.02));
				f *= f;
				f *= 1.0 - value;
				f *= f;
				float outerness = 1.0f - 2.0f * min(min(min(BaseUV.x, BaseUV.y), 1.0f - BaseUV.x), 1.0f - BaseUV.y);
				f *= outerness;
				f = lerp(0.75f, 1.0f, 1.0 - f);
				Color.xyz *= f;
				Color.xyz += lerp(0.08f, 0.25f, outerness) * float3(1.0f, 1.0f, 0.5f) * value * value * max(0.0, sin(Time * -3.3 + BasePosition.x * 0.12 + BasePosition.y * 0.14 + 0.51 * sin(BasePosition.y * 0.011)));

				return Color;
			}
		]]

		Code
		[[
			PDX_MAIN
			{
				float2 UV = Input.UV0;
				float3 Position = Input.Position;
				float4 BaseColor = SampleImageSprite( Texture, UV );
				float4 OutColor = BaseColor;
				OutColor *= Input.Color;

			    float iTime = GuiTime * -2.0;
			    float WaveSize = 12.0;
			    float Scale = 0.55;
			    float2 Wave = sin((UV.x + iTime * 0.1) * WaveSize) * 0.02;
			    float2 WaveFront = sin((UV.x + iTime * 0.1) * WaveSize) * 0.02;
			    float2 WaveBack = sin((UV.x + iTime * 0.15) * WaveSize) * 0.015;
			    float3 WaterColor = float3( 0.004f, 0.051f, 0.051f );
			    // float3 WaterColor = float3( 0.016f, 0.412f, 0.592f );  // темно-голубой
			    // float3 WaterColor = float3( 0.192f, 0.553f, 0.698f );
			    // float3 WaterColor = float3( 0.024f, 0.259f, 0.451f );
			    // float3 WaterColor = float3( 0.114f, 0.635f, 0.847f );

			    float4 FinalMaskAlpha = SampleImageSprite( FinalMask, UV );
			    OutColor.a = FinalMaskAlpha.a;
			    // BaseColor.a

				// Water Front Shadow
				float4 WaterBackShadowAlpha = SampleImageSprite( WaterAlphaTexture, float3(UV.x, (UV.y - 0.355) + WaveBack) );
				float4 WaterBackShadow = float4( WaterColor * 0.9f * 0.5f, WaterBackShadowAlpha.a * 0.25 );

				OutColor = MixImages( OutColor, WaterBackShadow );

				// Water Back
				float4 WaterBackAlpha = SampleImageSprite( WaterAlphaTexture, float3(UV.x, (UV.y - 0.36) + WaveBack) );
				float4 WaterBack = float4( WaterColor * 0.9f, WaterBackAlpha.a );

				OutColor = MixImages( OutColor, WaterBack );

			    // Ship
				float2 UV0 = UV;
				UV0.x *= 4.0 * Scale;
				UV0.y *= Scale;
				UV0.x += -0.6;
				UV0.y += 0.2;
				UV0.y += sin((iTime * 0.1) * WaveSize) * 0.01;
				UV0 = rotateUV(UV0, sin((iTime * 0.1) * WaveSize) * 0.02);

				float4 Ship = SampleImageSprite( ShipTexture, UV0 );

				OutColor = MixImages( OutColor, Ship );

				// Wheel
				float2 UV2 = UV0;
				// UV2.x *= 2.0;
				UV2 *= 10.0;
				UV2.x += -4.5;
				UV2.y += -6.4;
				float2 UV2Rotate = rotateUV_2( UV2, iTime * 0.4);

				float4 Wheel = SampleImageSprite( WheelTexture, UV2Rotate );

				float4 WheelAlpha = SampleImageSprite( WheelAlphaTexture, UV2 );
				Wheel.a = lerp(Wheel.a, WheelAlpha.a, Wheel.a);
				Wheel.a = smoothstep(0.1, 1.0, Wheel.a);

				OutColor = MixImages( OutColor, Wheel );

				// Flags start
				float FlagWaveSize = 12.0;

				float2 UV3 = UV0;
				UV3 *= 14.0;
				UV3.y *= 1.5;
				UV3.x += -11.47;
				UV3.y += -6.7;

				UV3.y += -1.0 * (sin((iTime * 0.1) * FlagWaveSize) * 0.03);
				float4 Flag0 = Flag( Flag0Texture, UV3, UV, Position, iTime, FlagWaveSize );

				OutColor = MixImages( OutColor, Flag0 );

				float2 UV4 = UV0;
				UV4 *= 7.0;
				UV4.x += -4.49;
				UV4.y += -1.19;

				UV4.y += -1.0 * (sin((iTime * 0.1) * FlagWaveSize) * 0.03);
				float4 Flag1 = Flag( Flag1Texture, UV4, UV, Position, iTime, FlagWaveSize );

				OutColor = MixImages( OutColor, Flag1 );

				float2 UV5 = UV0;
				UV5 *= 7.0;
				UV5.x += -2.73;
				UV5.y += -1.37;

				UV5.y += -1.0 * (sin((iTime * 0.1) * FlagWaveSize) * 0.03);
				float4 Flag2 = Flag( Flag1Texture, UV5, UV, Position, iTime, FlagWaveSize );

				OutColor = MixImages( OutColor, Flag2 );
				// Flags end

				// Water Fog
				float4 DownFogAlpha = SampleImageSprite( FogAlphaTexture, float3(UV.x, (UV.y - 0.65) + Wave) );
				float4 DownFogColor = float4( WaterColor * 1.1f, DownFogAlpha.a * 0.5 );

				OutColor = MixImages( OutColor, DownFogColor );

				// Fog Noise
				float2 UV1 = UV;
				UV1.x += iTime * 0.01;
				float4 UpFog = SampleImageSprite( NoiseTexture, UV1 );
				UpFog.a = lerp(0.0, 1.0, UpFog.r);
				UpFog.a *= 0.25;
				float4 UpFogColor = float4( 1.0f, 1.0f, 1.0f, UpFog.a );

				OutColor = MixImages( OutColor, UpFogColor );

				// Water Front Shadow
				float4 WaterFrontShadowAlpha = SampleImageSprite( WaterAlphaTexture, float3(UV.x, (UV.y - 0.445) + WaveFront) );
				float4 WaterFrontShadow = float4( WaterColor * 0.5f, WaterFrontShadowAlpha.a * 0.25 );

				OutColor = MixImages( OutColor, WaterFrontShadow );

				// Water Front
				float4 WaterFrontAlpha = SampleImageSprite( WaterAlphaTexture, float3(UV.x, (UV.y - 0.45) + WaveFront) );
				float4 WaterFront = float4( WaterColor, WaterFrontAlpha.a );

				OutColor = MixImages( OutColor, WaterFront );
				float4 SideMaskAlpha = SampleImageSprite( SideMask, UV );
				OutColor.a = OutColor.a - SideMaskAlpha.a;
				// OutColor.a = WaterBackShadowAlpha.a;
				// float4 FinalMaskColor = SampleImageSprite( FinalMask, UV );

				// OutColor = float4( OutColor.rgb, 1.0f );
				// OutColor = float4( OutColor.rgb, BaseColor.a );
				// FinalMaskColor.a = lerp(FinalMaskColor.a, OutColor.a, 1.0);
				// OutColor = float4( OutColor.rgb, FinalMaskColor.a );
			    return OutColor;
			}
		]]
	}
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
}

BlendState BlendStateNoAlpha
{
	BlendEnable = no
}

BlendState PreMultipliedAlpha
{
	BlendEnable = yes
	SourceBlend = "ONE"
	DestBlend = "INV_SRC_ALPHA"
}

DepthStencilState DepthStencilState
{
	DepthEnable = no
}


Effect PdxGuiDefault
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}
Effect PdxGuiDefaultDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "DISABLED" }
}

Effect test_PixelShader
{
	VertexShader = "VertexShader"
	PixelShader = "test_PixelShader"
}
Effect test_PixelShaderDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "test_PixelShader"
	
	Defines = { "DISABLED" }
}