%Extract data from ERA5 for new station

%1_File and location
fnc = 'nc_file/12_1980_2021.nc';     % change name manually   %1=JAN
lat_sta = -83.8030;
lon_sta = 146.5891;
lon_sta = mod(lon_sta+180,360)-180;     % ERA lon format = 0-360

%2_Read coordinate
lat = ncread(fnc,'latitude');
lon = ncread(fnc,'longitude'); lon = mod(lon+180,360)-180;

%3_Looking for nearest grid from new station
[~,ilat] = min(abs(lat - lat_sta));
[~,ilon] = min(abs(lon - lon_sta));

%4_Read temp
T = ncread(fnc,'t2m');   %in Kelvin

%5_Temperature for  all for nearest grid (asumsi [lon x lat x time])
if size(T,1)==numel(lon) && size(T,2)==numel(lat)
    tempK = squeeze(T(ilon, ilat, :));
else
    tempK = squeeze(T(ilat, ilon, :));
end

%6_Covertion Celcius
tempC = tempK - 273.15;

%7_Average
meanC = mean(tempC, 'omitnan');

%8_Save into excel
outFile   = 'era_temp_1980_2021.xlsx';
val       = meanC;       
monthIdx  = 12;          % 1=Jan %Manually change   %ALWAYS START FROM 1

%9_Column in sequence from monthIdx
colLetter = char('A' + monthIdx - 1);   % 1->'A', 12->'L'
rangeCell = sprintf('%s1', colLetter);  % first row

%10_Sheet and cell setting
writematrix(val, outFile, 'Sheet', 1, 'Range', rangeCell);
