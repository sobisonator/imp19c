Code
[[
	#define AdjustedTime			GlobalTime * 0.01f
	// #define AdjustedTime			3.0f /// Freeze time for debugging
	#define CloudDirection			float2( -1.0, 0.4 )		// Paning direction
	#define CloudOpacity			1.0f						// Cloud Opacity

	// Main Cloud settings, works as base for secondary and detail settings
	#define CloudMainTiling			36						// Cloud noise tiling, can control size and amount (increased for smaller clouds)
	#define CloudMainSpeed			2.0						// Cloud pan speed
	#define CloudMainPosition		0.58					// Cloud position, combine with tiling to adjust size (adjusted for better coverage)
	#define CloudMainContrast		0.25					// Cloud sharpness (increased for more defined edges)

	// Secondary clouds settings are adjustedments of main settings
	#define CloudSecondaryTiling 	5.0						// Secondary clouds tiling (increased for smaller secondary patterns)
	#define CloudSecondarySpeed		12.0					// Secondary clouds adjusted speed (slightly slower)
	#define CloudSecondaryPosition	-0.15					// Secondary clouds adjusted position (offset for variation)
	#define CloudSecondaryContrast	0.18					// Secondary clouds adjusted contrast (increased for more definition)

	// Detail clouds settings are adjustedments of on main settings
	#define CloudDetailTiling		11.4					// Detail clouds tiling (increased for smaller detail patterns)
	#define CloudDetailSpeed		25.0					// Detail clouds adjusted speed (slightly slower)
	#define CloudDetailPosition		-0.25					// Detail clouds adjusted position (adjusted for better blending)
	#define CloudDetailContrast		0.35					// Detail clouds adjusted contrast (reduced for softer details)

	#define HasCloudShadowEnabled 1.0

	#define ZoomInHeight 100.0 // This could impact a significant number of terrain-related shaders, so please exercise caution before making any changes.
	#define ZoomOutHeight 2600.0 // This could impact a significant number of terrain-related shaders, so please exercise caution before making any changes.

	//-------------------------------
	// Lighting configuration -------
	//-------------------------------

	// Sun position coordinates (0-1 range)
	// Azimuth: 0.0=north, 0.25=west, 0.5=south, 0.75=east, 1.0=north again
	// Elevation: 0.0=horizon, 0.5=45 degrees up, 1.0=zenith (straight up)

	// Terrain sunny scenario lighting parameters
	#define TERRAIN_SUNNY_SPECULAR_FACTOR          1.0f
	#define TERRAIN_SUNNY_SUN_COLOR                SunDiffuse
	#define TERRAIN_SUNNY_SUN_INTENSITY            SunIntensity
	#define TERRAIN_SUNNY_IBL_SCALE		           0.25f

	// Terrain shadow scenario lighting parameters
	#define TERRAIN_OVERCAST_SPECULAR_FACTOR         1.0f
	#define TERRAIN_OVERCAST_SUN_COLOR               SunDiffuse
	#define TERRAIN_OVERCAST_SUN_INTENSITY           SunIntensity * 0.5f
	#define TERRAIN_OVERCAST_IBL_SCALE               0.5f

	// Map objects sunny scenario lighting parameters
	#define MAP_OBJECTS_SUNNY_SPECULAR_FACTOR      1.0f
	#define MAP_OBJECTS_SUNNY_SUN_COLOR            SunDiffuse
	#define MAP_OBJECTS_SUNNY_SUN_INTENSITY        SunIntensity
	#define MAP_OBJECTS_SUNNY_IBL_SCALE            1.5f

	// Map objects shadow scenario lighting parameters
	#define MAP_OBJECTS_OVERCAST_SPECULAR_FACTOR     1.0f
	#define MAP_OBJECTS_OVERCAST_SUN_COLOR           SunDiffuse
	#define MAP_OBJECTS_OVERCAST_SUN_INTENSITY       SunIntensity * 0.5f
	#define MAP_OBJECTS_OVERCAST_IBL_SCALE           1.2f

	// Water sunny scenario lighting parameters
	#define WATER_SUNNY_GLOSS_SCALE                0.8f
	#define WATER_SUNNY_SPECULAR_FACTOR            0.1f
	#define WATER_SUNNY_SUN_INTENSITY_MULTIPLIER   1.0f
	#define WATER_SUNNY_IBL_SCALE                  1.5f

	// Water shadow scenario lighting parameters
	#define WATER_OVERCAST_GLOSS_SCALE               0.1f
	#define WATER_OVERCAST_SPECULAR_FACTOR           0.1f
	#define WATER_OVERCAST_SUN_INTENSITY_MULTIPLIER  0.3f
	#define WATER_OVERCAST_IBL_SCALE                 0.5f

	#define ToWaterSunnySunDir                 		ToSunDir
	#define ToWaterOvercastSunDir                	ToSunDir
]]
