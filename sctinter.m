%Interpolation using Scattered Interpolation

%1_Load data
coastline = shaperead('CAIS.shp');       % EPSG : 3031 (m)
D = readtable("allsta_75.xlsx");             
antCrs = projcrs(3031);
lat=D{:,3}; lon=D{:,4}; temp=D{:,5};   %temp change manually %JAN =5 %des
mask = temp ~= 0;       %only use non zero value for
lat = lat(mask);
lon = lon(mask);
temp = temp(mask);
[xm, ym] = projfwd(antCrs, lat, lon);

%2_Grid data information
nx = 600; ny = 600;             % grid size
interpMethod  = 'natural';      % 'natural' or 'linear'
extrapMethod  = 'nearest';      % fill to coastline

%3_Making grid from intersection of shapefile & data
xs = cell(numel(coastline),1);
ys = cell(numel(coastline),1);
for k = 1:numel(coastline)
    xs{k} = coastline(k).X(:);   
    ys{k} = coastline(k).Y(:);
end

allX = vertcat(xs{:}); 
allY = vertcat(ys{:});
m = ~(isnan(allX)|isnan(allY)); 
allX = allX(m); 
allY = allY(m);

xmin = max(min(allX), min(xm)); 
xmax = min(max(allX), max(xm));
ymin = max(min(allY), min(ym)); 
ymax = min(max(allY), max(ym));

%linespace => make grid for map depend on nx, ny
%meshgrid => fill the map point in linspace grid
[xq, yq] = meshgrid(linspace(xmin,xmax,nx), linspace(ymin,ymax,ny));


%4_Interpolation
F  = scatteredInterpolant(xm, ym, temp, interpMethod, extrapMethod);
Tq = F(xq, yq);

%5_Coastline mask (robust over rings) 
in = false(size(xq));
for k = 1:numel(coastline)
    vx = coastline(k).X(:); vy = coastline(k).Y(:);
    br = [0; find(isnan(vx)|isnan(vy)); numel(vx)+1];   % split rings
    for s = 1:numel(br)-1
        ii = br(s)+1:br(s+1)-1;
        if numel(ii) >= 3
            in = in | inpolygon(xq, yq, vx(ii), vy(ii));
        end
    end
end
Tq(~in) = NaN;   % clip to coastline

%6_Plot (fixed color range)
lo = -67;                           %temp min = -66.642
hi = 5;                             %temp max = 4.834
nLevels = 80;                       %amount of colour level 
LV = linspace(lo, hi, nLevels);     %vector level

figure('Color','w'); hold on

%7_Make coastline on top of contour 
contourf(xq, yq, Tq, LV, 'LineColor','none'); 
colormap('turbo');
caxis([lo hi]);                    % colorbar from 5, to -67

%8_Coastline contour (light)
for k = 1:min(numel(coastline), 300)
    plot(coastline(k).X, coastline(k).Y, 'k', 'LineWidth', 0.5);
end

%9_Axis plot
axis equal; box on 
xlabel('x (m)','FontWeight','bold', 'FontSize',12); 
ylabel('y (m)','FontWeight','bold', 'FontSize',12);

xlim([-3.5e6 3.5e6])    %center = 0
ylim([-3.5e6 3.5e6])

plot(xm, ym, 'k.', 'MarkerSize', 7) %from data

%10_Colorbar
cb = colorbar;
cb.Ticks = linspace(lo, hi, 6);    
cb.Label.String = 'Temperature (°C)';
cb.Label.FontSize = 15;
cb.LineWidth = 1.5;         %line in colorbar              
cb.FontSize = 13;          %colorbar scale        

%12_Title
sgtitle('January', 'FontWeight','bold', 'FontSize',20);

%13_Top margin 
ax = gca;
ax.Units = 'normalized';
p = ax.Position;
ax.Position = [p(1) p(2) p(3) p(4)];  %(0.05–0.12)

% tambahan biar axis jelas
set(ax, 'LineWidth',1.5, ...      % axis bold
        'FontWeight','bold', ...  
        'FontSize',11);           

%14_New station = -83.8030, 146.5891
nx=-83.8030;
ny=146.5891;
[nx, ny] = projfwd(antCrs, nx, ny);
plot(nx, ny, '^', 'MarkerSize', 10, ...
    'MarkerEdgeColor', 'k', ...   % triangle outline color black
    'MarkerFaceColor', 'w');      % triangle fill color white

%15_Saving the figure
saveas(gcf, fullfile('1_75.png'));   %name file change manually

%16_Extract data for new station
newStationTemp = F(nx, ny);  

%17_Saving new station temperature in excel
outFile   = ('new_temp_75.xlsx');
val       = newStationTemp;  
monthIdx  = 1;               % 1=Jan, 2=Feb...    %Manually change

%18_Column in sequence from monthIdx
colLetter = char('A' + monthIdx - 1);   % 1->'A', 12->'L'
rangeCell = sprintf('%s1', colLetter);  % first row

%19_Sheet and cell setting
writematrix(val, outFile, 'Sheet', 1, 'Range', rangeCell);
