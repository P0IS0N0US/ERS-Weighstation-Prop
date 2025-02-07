
# ERS-Weighstation-Prop

Adds a prop with a working display to the ERS weighstation addon.

## Installation

### Prop Installation

1.  Upload the `stream` folder to the `night_ers_weighstation` folder.
    
2.  Add the following lines to `fxmanifest.lua`
    
    ```
    files {'stream/addon_prop_truck_scale.ytyp'}
    data_file 'DLC_ITYP_REQUEST' 'stream/addon_prop_truck_scale.ytyp'
    ```
    
3.  In `config.lua`, change the value of `ObjectModel` to:
    
    ```
    ObjectModel = "addon_prop_truck_scales"
    ```
    
    Adjust the Z offset in `ObjectOffset` to around `0.0`. At `0.0`, the prop hovers slightly, so you may need to apply a small downward offset.

> [!NOTE]
> If you intend to use only the prop and keep everything else unchanged, replace the display image in the `addon_prop_truck_scales.ytd` file with `display.jpg` from the repository.<br> This replaces the Black Screen that's usually present with a version that has a static turned off 7 segment Display.
    

### Display Installation

1.  Replace `c_function.lua` with the modified version provided in the repository.
> [!WARNING]
> This removes the text that hovers above the weighstation by default.<br>
> To keep this feature, add the unmodified Draw3DText code below the code of the modified function. (I haven't tested this!)
