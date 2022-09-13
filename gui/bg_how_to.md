# Character Backgrounds How To:

1. Look in gfx/interface/portrait to see the two sizes required to add a custom background, there is huge and...not huge.

2. Search imp19c for "background_city_republic_rome"

3. Open customizable_localization\bg_texture.txt, gui\bg_characters.gui, gui\bg_font_icons.gui and english\character_bg_l_english.yml

4. Start with bg_characters.gui. Add a new custom_background, the two required fields are texture and visible, which is when the icon will be visible.

5. Open bg_font_icons and add a new font icon. The texture for it should be the smaller texture, not the huge one.

6. Open bg_texture custom loc file and add a entry that corresponds to the SAME name as the "icon = X" section of your font icon

7. Finally, open character_bg_l_english.yml and add another entry with the SAME name as the custom localization key 
   (which should be the same as your texture). It should look like this: background_city_republic_rome: "@background_city_republic_rome!"