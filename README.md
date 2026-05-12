Land Use/Land Cover (LULC) Classification: Grand River Grassland Study
Master's Thesis | University of Missouri

📌 Project Overview
Effective land management requires a precise understanding of current land cover and usage. This study implements a comparative LULC classification within the Grand River Grasslands (GRG) in Harrison County, Missouri—a critical site for tallgrass prairie restoration.

The research utilizes a multi-temporal, two-pronged approach to determine whether object-based methods outperform traditional pixel-based methods in ecologically diverse landscapes.

📡 Data & Inputs
Satellite Imagery: Sentinel-2 (10m spatial resolution).

Temporal Scope: Two contrasting seasons were used to capture phenological variability (essential for distinguishing prairie grasses from other vegetation).

Ground Truth: Field surveys supplemented by UAV-acquired imagery for high-precision labeling.

🛠 Methodology: The Two-Pronged Approach
1. Object-Based Image Analysis (OBIA)
Segmentation: Employed the MeanShiftSegmentation algorithm via ArcPy to group pixels into meaningful image objects.

Attribute Extraction: Extracted multispectral, textural, and spatial attributes for each segment.

Classification: Processed segment attributes in R using the See5 (Classification and Regression Tree) technique.

2. Per-Pixel Classification
Implemented a standard classification using the same field data and the See5 algorithm to serve as a baseline for comparison.

📊 Key Findings
Accuracy Improvement: The study quantified the statistical advantage of using image objects (segments) over individual pixels for restoration monitoring.

Phenological Advantage: Integrating multi-seasonal imagery significantly reduced spectral confusion between cover types with similar signatures
