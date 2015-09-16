--[[----------------------------------------------------------------------------

VSCO Keys for Adobe Lightroom
Copyright (C) 2015 Visual Supply Company
Licensed under GNU GPLv2 (or any later version).

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

------------------------------------------------------------------------------]]

local set = {}
set.WhiteBalance = {name = "White Balance"}

set.Exposure2012 = {name = "Exposure", min = -5, max = 5}
set.Exposure = {name = "Exposure", maxVersion = 3, min = -4, max = 4}
set.IncrementalTemperature = {name = "Temperature", min = -100, max = 100} -- Settings for jpgs
set.IncrementalTint = {name = "Tint", min = -100, max = 100} -- Settings for jpgs
set.Temperature = {name = "Temperature", min = 2000, max = 50000} -- Settings for raw
set.Tint = {name = "Tint", min = -150, max = 150} -- Settings for raw
set.Shadows2012 = {name = "Shadows", min = -100, max = 100}
set.FillLight = {name = "Fill Light", maxVersion = 3, min = 0, max = 100}
set.Highlights2012 = {name = "Highlights", min = -100, max = 100}
set.HighlightRecovery = {name = "Highlight Recovery", maxVersion = 3, min = 0, max = 100}
set.Contrast2012 = {name = "Contrast", min = -100, max = 100}
set.Contrast = {name = "Contrast", maxVersion = 3, min = -50, max = 100}
set.Saturation = {name = "Saturation", min = -100, max = 100}
set.Blacks2012 = {name = "Blacks", min = -100, max = 100}
set.Shadows = {name = "Black Clipping", maxVersion = 3, min = 0, max = 100}
set.Whites2012 = {name = "Whites", min = -100, max = 100}
set.Brightness = {name = "Brightness", maxVersion = 3, min = 0, max = 100}
set.Vibrance = {name = "Vibrance", min = -100, max = 100}
set.Clarity2012 = {name = "Clarity", min = -100, max = 100}
set.Clarity = {name = "Clarity", maxVersion = 3, min = -100, max = 100}

set.Sharpness = {name = "Sharpness", min = 0, max = 150}
set.SharpenRadius = {name = "SharpenRadius", min = 0.5, max = 3.0}
set.SharpenDetail = {name = "SharpenDetail", min = 0, max = 100}
set.SharpenEdgeMasking = {name = "SharpenEdgeMasking", min = 0, max = 100}
set.LuminanceSmoothing = {name = "LuminanceSmoothing", min = 0, max = 100}
set.LuminanceNoiseReductionDetail = {name = "LuminanceNoiseReductionDetail", min = 0, max = 100}
set.LuminanceNoiseReductionContrast = {name = "LuminanceNoiseReductionContrast", min = 0, max = 100}
set.ColorNoiseReduction = {name = "ColorNoiseReduction", min = 0, max = 100}
set.ColorNoiseReductionDetail = {name = "ColorNoiseReductionDetail", min = 0, max = 100}

set.ParametricDarks = {name = "Dark Tones", min = -100, max = 100}
set.ParametricLights = {name = "Light Tones", min = -100, max = 100}
set.ParametricShadows = {name = "Shadow Tones", min = -100, max = 100}
set.ParametricHighlights = {name = "Highlight Tones", min = -100, max = 100}
set.ParametricHighlightSplit = {name = "Highlight Split", min = 30, max = 90}
set.ParametricMidtoneSplit = {name = "Midtone Split", min = 20, max = 80}
set.ParametricShadowSplit = {name = "Shadow Split", min = 10, max = 70}

set.HueAdjustmentRed = {name = "Red Hue Shift", min = -100, max = 100}
set.HueAdjustmentOrange = {name = "Orange Hue Shift", min = -100, max = 100}
set.HueAdjustmentYellow = {name = "Yellow Hue Shift", min = -100, max = 100}
set.HueAdjustmentGreen = {name = "Green Hue Shift", min = -100, max = 100}
set.HueAdjustmentAqua = {name = "Aqua Hue Shift", min = -100, max = 100}
set.HueAdjustmentBlue = {name = "Blue Hue Shift", min = -100, max = 100}
set.HueAdjustmentPurple = {name = "Purple Hue Shift", min = -100, max = 100}
set.HueAdjustmentMagenta = {name = "Magenta Hue Shift", min = -100, max = 100}
set.SaturationAdjustmentRed = {name = "Red Saturation Shift", min = -100, max = 100}
set.SaturationAdjustmentOrange = {name = "Orange Saturation Shift", min = -100, max = 100}
set.SaturationAdjustmentYellow = {name = "Yellow Saturation Shift", min = -100, max = 100}
set.SaturationAdjustmentGreen = {name = "Green Saturation Shift", min = -100, max = 100}
set.SaturationAdjustmentAqua = {name = "Aqua Saturation Shift", min = -100, max = 100}
set.SaturationAdjustmentBlue = {name = "Blue Saturation Shift", min = -100, max = 100}
set.SaturationAdjustmentPurple = {name = "Purple Saturation Shift", min = -100, max = 100}
set.SaturationAdjustmentMagenta = {name = "Magenta Saturation Shift", min = -100, max = 100}
set.LuminanceAdjustmentRed = {name = "Red Luminance Shift", min = -100, max = 100}
set.LuminanceAdjustmentOrange = {name = "Orange Luminance Shift", min = -100, max = 100}
set.LuminanceAdjustmentYellow = {name = "Yellow Luminance Shift", min = -100, max = 100}
set.LuminanceAdjustmentGreen = {name = "Green Luminance Shift", min = -100, max = 100}
set.LuminanceAdjustmentAqua = {name = "Aqua Luminance Shift", min = -100, max = 100}
set.LuminanceAdjustmentBlue = {name = "Blue Luminance Shift", min = -100, max = 100}
set.LuminanceAdjustmentPurple = {name = "Purple Luminance Shift", min = -100, max = 100}
set.LuminanceAdjustmentMagenta = {name = "Magenta Luminance Shift", min = -100, max = 100}

set.GrainAmount = {name = "Grain Amount", min = 0, max = 100}
set.GrainSize = {name = "Grain Size", min = 0, max = 100}
set.GrainFrequency = {name = "Grain Roughness", min = 0, max = 100}
set.PostCropVignetteAmount = {name = "P-C Vignette Amount", min = -100, max = 100}
set.PostCropVignetteMidpoint = {name = "P-C Vignette Midpoint", min = 0, max = 100}
set.PostCropVignetteRoundness = {name = "P-C Vignette Roundness", min = -100, max = 100}
set.PostCropVignetteFeather = {name = "P-C Vignette Feather", min = 0, max = 100}
set.PostCropVignetteHighlightContrast = {name = "P-C Vignette Highlights", min = 0, max = 100}

set.SplitToningBalance = {name = "Split Toning Balance", min = -100, max = 100}
set.SplitToningHighlightHue = {name = "Highlight Hue", min = 0, max = 360}
set.SplitToningHighlightSaturation = {name = "Highlight Saturation", min = 0, max = 100}
set.SplitToningShadowHue = {name = "Shadow Hue", min = 0, max = 360}
set.SplitToningShadowSaturation = {name = "Shadow Saturation", min = 0, max = 100}

set.ShadowTint = {name = "Calibration Shadow Tint", min = -100, max = 100}
set.RedHue = {name = "Calibration Red Hue", min = -100, max = 100}
set.RedSaturation = {name = "Calibration Red Sat", min = -100, max = 100}
set.GreenHue = {name = "Calibration Green Hue", min = -100, max = 100}
set.GreenSaturation = {name = "Calibration Green Sat", min = -100, max = 100}
set.BlueHue = {name = "Calibration Blue Hue", min = -100, max = 100}
set.BlueSaturation = {name = "Calibration Blue Sat", min = -100, max = 100}

set.LensManualDistortionAmount = {name = "Distortion Amount", min = -100, max = 100}
set.PerspectiveVertical = {name = "Vertical Perspective", min = -100, max = 100}
set.PerspectiveHorizontal = {name = "Horizontal Perspective", min = -100, max = 100}
set.PerspectiveRotate = {name = "Perspective Rotate", min = -10, max = 10}
set.PerspectiveScale = {name = "Perspective Rotate", min = 50, max = 150}
set.VignetteAmount = {name = "Vignette Amount", min = -100, max = 100}
set.VignetteMidpoint = {name = "Vignette Midpoint", min = 0, max = 100}
set.DefringePurpleAmount = {name = "Purple Defringe Amount", min = 0, max = 20}
set.DefringePurpleHueLo = {name = "Purple Defringe Hue Lo", min = 0, max = 100}
set.DefringePurpleHueHi = {name = "Purple Defringe Hue Hi", min = 0, max = 100}
set.DefringeGreenAmount = {name = "Green Defringe Amount", min = 0, max = 20}
set.DefringeGreenHueLo = {name = "Green Defringe Hue Lo", min = 0, max = 100}
set.DefringeGreenHueHi = {name = "Green Defringe Hue Hi", min = 0, max = 100}
set.ChromaticAberrationB = {name = "Blue Chromatic Aberration", maxVersion = 3, min = -100, max = 100}
set.ChromaticAberrationR = {name = "Red Chromatic Aberration", maxVersion = 3, min = -100, max = 100}

return set