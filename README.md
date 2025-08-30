# envsc-704-case2

1. nc_file : ERA5; 2m height temperature; 3-hourly data (00,03,06,09,12,18,21 UTC), everyday, each month; 1981-2021;
             coordinates location for the new station : N = −83.3030, S = −84.3030, W = 146.0891, E = 147.0891;
             [link to download](https://cds.climate.copernicus.eu/datasets/reanalysis-era5-single-levels?tab=download);
   
3. allsta_75.xlsx : excel for all aws temperature data monthly average 75% availability; 1981-2021

4. sctinter.m : script file for display allsta_75.xlsx by interpolation in png;
                extract temperature for the new station in excel

5. readera.m : script for take the new station temperature from ERA5 in excel

6. CAIS.shp : shapefile for Antartica map
