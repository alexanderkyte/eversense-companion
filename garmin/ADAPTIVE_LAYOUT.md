# Adaptive Layout for Round and Rectangular Screens

The Eversense Garmin watchface now automatically adapts its layout based on the screen shape of your device.

## Screen Detection

The watchface automatically detects whether your device has a round or rectangular screen by analyzing the screen dimensions:

- **Round screens**: Devices with square or near-square dimensions (aspect ratio 0.9-1.1)
- **Rectangular screens**: Devices with significantly different width and height

## Layout Differences

### Round Screen Layout (Fenix, Venu, Forerunner)
Elements are arranged in a circular pattern to make optimal use of the round screen:

- **Time**: Positioned at the top
- **Glucose reading**: Centered in the middle with large, easy-to-read text
- **Heart rate**: Positioned at 8 o'clock (lower left)
- **Battery**: Positioned at 4 o'clock (lower right)  
- **Connection status**: Positioned at the bottom

### Rectangular Screen Layout (Vivoactive)
Elements use the original grid-based layout optimized for rectangular screens:

- **Time**: Upper center
- **Glucose reading**: Center
- **Heart rate**: Lower left
- **Battery**: Lower right
- **Connection status**: Bottom center

## Supported Devices

The adaptive layout has been tested with the following screen dimensions:

| Device | Dimensions | Layout Type |
|--------|------------|-------------|
| Fenix 6/6S/6X | 260x260 | Round |
| Venu/Venu 2/2S | 416x416 | Round |
| Forerunner 245 | 240x240 | Round |
| Vivoactive 4/4S | 348x442 | Rectangular |

## Benefits

- **Better space utilization** on round screens
- **Improved readability** with elements positioned away from screen edges
- **Consistent experience** across different device types
- **Automatic adaptation** - no manual configuration needed

The layout automatically adjusts element positions to ensure they remain visible and readable on all supported devices.