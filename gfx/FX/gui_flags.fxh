PixelShader =
{
	Code
	[[
		float CreateWave( float2 UV, float Time ) {
			// https://www.shadertoy.com/view/flsXRM
			float Wave =  UV.x * 12.0 - 1.5 * Time + UV.y * 3.0;
			return Wave;
		}
		float2 CreateWaveUV( float2 UV, float Wave ) {
			UV.y += sin(Wave) * 0.02;
			return UV;
		}
		float2 SettingsUV0ToFlag( float2 UV ) {
			float FlagShape = SpriteFramesTypeBlendMode[4].x;

			if ( FlagShape == 2.0 )
			{
				UV.x *= 1.5;
				UV.x += -0.25;
			}
			if ( FlagShape == 4.0 )
			{
				UV.y *= 1.5;
				UV.y += -0.25;
			}
			if ( FlagShape == 7.0 )
			{
				UV.x *= 2.0;
				UV.x += -0.5;
			}
			
			return UV;
		}
		float2 SettingsUV1ToFlag( float2 UV ) {
			float FlagShape = SpriteFramesTypeBlendMode[4].x;
			UV.x *= 0.125;
			UV.x += 0.125 * FlagShape;
			return UV;
		}
		float4 CreateStyleToFlag( float4 OutColor, float AlphaColor, float4 StyleColor, float2 UV, float Wave) {
			OutColor = Blend( OutColor, StyleColor, 0.6, AlphaColor, 2);
			// OutColor = Blend( OutColor, StyleColor, 0.4, AlphaColor, 1);
			OutColor = Blend( OutColor, StyleColor, 0.5, AlphaColor, 5);

			OutColor.rgb *= 0.95 + cos(Wave) * 0.1;

			return OutColor;
		}
	]]
}