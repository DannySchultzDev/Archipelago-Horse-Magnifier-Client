# Archipelago-Horse-Magnifier-Client
This mod allows Horse Magnifier: The Full Horse to be randomized with Archipelago.<br/>
<br/>
Items to receive include the 10 different lenses, the apple, the horsefly swatter, and an added horse macguffin to unlock the last level.<br/>
Locations to check include beating and (optionaly) perfecting each level.

# Setup
You will need:<br/>
Horse Magnifier: The Full Horse: https://store.steampowered.com/app/4585340/Horse_Magnifier_The_Full_Horse/<br/>
Archipelago: https://github.com/ArchipelagoMW/Archipelago/releases<br/>
GDPatch: https://gdpatch.dev/<br/>
Godot AP (Source Code): https://github.com/EmilyV99/GodotAP/releases<br/>
The Archipelago Horse Magnifier Client: https://github.com/DannySchultzDev/Archipelago-Horse-Magnifier-Client/releases<br/>
The Horse Magnifier AP World: https://github.com/DannySchultzDev/Archipelago-Horse-Magnifier-Client/releases<br/>
<br/>
Setting up the AP World:<br/>
Put the AP World in your custom worlds folder either manually, double clicking it, or using the "Install APWorld" option in the Archipelago Launcher.<br/>
Generate the options .YAML file by using the "Generate Template Options" option in the Archipelago Launcher.<br/>
Place the Horse Magnifier.yaml in your players folder.<br/>
Edit the options in the Horse Magnifier.yaml.<br/>
Generate the multiworld using the "Generate" option in the Archipelago Launcher. (It will be placed in your C:\ProgramData\Archipelago\output folder)<br/>
Upload the world to https://archipelago.gg/uploads, or unzip it and run the .archipelago to run it locally.<br/>
<br/>
Setting up the mod:<br/>
After installing GDPatch rename the .dll to winmm.dll and put it in the same directory as the HorseMagnifier.exe (The HorseMagnifier.exe will most likely be located at C:\Program Files (x86)\Steam\steamapps\common\Horse Magnifier)<br/>
Run the game once, you should see a new GDPatch folder.<br/>
Unzip the mod and add it to the newly created mods folder. (The mods folder will most likely be located at C:\Program Files (x86)\Steam\steamapps\common\Horse Magnifier\GDPatch\mods)<br/>
Add the godot_ap folder to the same directory as the HorseMagnifier.exe (The godot_ap folder is located in the Godot AP source code at GodotAP-0.4.1\GodotAP-0.4.1\godot_ap)<br/>
Run the game, you should see connection fields at the top of the game.<br/>
Input your connection information.<br/>
Enjoy!
