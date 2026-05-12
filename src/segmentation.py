# ==============================================================================
# Title:        Image Segmentation - Grand River Grasslands (GRG)
# Author:       Lasya Venigalla
# Date:         Created 01/26/2018 | Modified 02/07/2018
# Topic:        LULC Classification via Segment Mean Shift Function
# Environment:  Python 2.7 (ArcGIS Desktop / ArcMap)
# ==============================================================================

import os
import arcpy
from arcpy import env
from arcpy.sa import *

# --- INITIALIZATION ---
arcpy.CheckOutExtension("Spatial")
arcpy.env.overwriteOutput = True
print "Spatial Analyst extension checked out."

# --- INPUT DATA ---
# Source: Sentinel-2 10m Spatial Resolution Raster
inraster = "L:\\Thesis\\Data\\FinalData\\Raster\\grc.tif" 
print "Input raster: SUCCESS"

# --- PRE-PROCESSING ---
# Calculate statistics to optimize the Mean Shift algorithm performance
data = arcpy.CalculateStatistics_management(inraster)
print "Statistics Calculation: COMPLETE"

# --- CORE ANALYSIS: SEGMENT MEAN SHIFT ---
# Parameters optimized for phenological variability in tallgrass prairie
spectral_detail = "20"
spatial_detail  = "20"
min_segment_size = "3"

print "Starting Mean Shift Segmentation..."
seg_raster = SegmentMeanShift(data, spectral_detail, spatial_detail, min_segment_size)
print "Image Segmentation: SUCCESS"

# --- OUTPUT & VECTORIZATION ---
# Save the segmented raster output
out_tif_path = "L:\\Thesis\\Data\\FinalData\\Raster\\grc_seg.tif"
seg_raster.save(out_tif_path)
print "Raster output saved."

# Build pyramids for performance and raster-to-polygon conversion
py_raster = arcpy.BuildPyramids_management(seg_raster)
print "Pyramids Built: SUCCESS"

# Convert image objects (segments) to polygons for feature attribute extraction
out_shp_path = "L:\\Thesis\\Data\\FinalData\\Segments\\grc_seg.shp"
arcpy.RasterToPolygon_conversion(py_raster, out_shp_path, "NO_SIMPLIFY", "VALUE")
print "Vector Polygons Created: SUCCESS"

# --- CLEANUP ---
arcpy.CheckInExtension("Spatial")
print "Spatial Analyst checked in. Process Complete."
