# ==============================================================================
# Title:        Database Table Integration - GRG Project
# Author:       Lasya Venigalla
# Date:         Created 03/13/2018
# Topic:        Merging multispectral band tables into a master database
# Environment:  Python 2.7 (ArcGIS Desktop / ArcMap)
# ==============================================================================

import arcpy
from arcpy import env

# --- ENVIRONMENT SETTINGS ---
arcpy.env.overwriteOutput = True
env.workspace = "L:\\Thesis\\Data\\FinalData.gdb"

# --- DATA DISCOVERY ---
# Retrieve all tables generated during attribute extraction (Bands 1-11)
tables = arcpy.ListTables()
print "Tables found in database: " + str(len(tables))

# --- TABLE JOINING LOGIC ---
# Goal: Join all individual band tables to the primary 'leafoff_b1' table
# using the OBJECTID as the common key for the See5 training set.

for table in tables:
    # Target the base table to begin the join sequence
    if table == "leafoff_b1":
        # Identify the primary key (OBJECTID) dynamically
        fieldList = arcpy.ListFields(table)
        objid = fieldList[0].name
        print "Primary Key identified: " + objid
        
        # Execute permanent join for the first two bands
        # In the full pipeline, this was extended to merge all spectral data
        print "Joining leafoff_b1 and leafoff_b2..."
        arcpy.JoinField_management("leafoff_b1", objid, "leafoff_b2", objid)

# --- COMPLETION ---
print "Database merging process: FINISHED"
