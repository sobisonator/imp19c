PixelShader =
{
	Code
	[[
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
		float4 CreateStyleToFlag( float4 OutColor, float AlphaColor, float4 StyleColor, float2 UV, float3 UVPos, float GlobalTime) {
			float value = dot(float3(1, 1, 1) / 45, OutColor.xyz);
			float f = sin(GlobalTime * -1 * 0.5 * (1.0f + 0.0001 * abs(sin(UVPos.y * 0.02))) + UVPos.x * 0.06 + 0.5 * sin(UVPos.y * 0.02));
			f *= f;
			f *= 1.0 - value;
			f *= f;
			float outerness = 1.0f - 2.0f * min(min(min(UV.x, UV.y), 1.0f - UV.x), 1.0f - UV.y);
			f *= outerness;
			f = lerp(0.75f, 1.0f, 1.0 - f);
			OutColor.xyz *= f;
			OutColor.xyz += lerp(0.08f, 0.25f, outerness) * float3(1.0f, 1.0f, 0.5f) * value * value * max(0.0, sin(GlobalTime * -3.3 + UVPos.x * 0.12 + UVPos.y * 0.14 + 0.51 * sin(UVPos.y * 0.011)));


			OutColor = Blend( OutColor, StyleColor, 0.6, AlphaColor, 2);
			OutColor = Blend( OutColor, StyleColor, 0.4, AlphaColor, 1);
			OutColor = Blend( OutColor, StyleColor, 0.05, AlphaColor, 4);
			return OutColor;
		}
	]]
}