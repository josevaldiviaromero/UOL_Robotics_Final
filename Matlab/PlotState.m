function PlotState(app)
scan = getVisionScanner(app); %this is not the name of the function, but yk
map_width_m = 10;  % 10 meters wide
map_height_m = 5;  % 5 meters tall
cell_size = 0.01;   % Each cell is 1 cm
map_width = map_width_m / cell_size;   % 1000 cells
map_height = map_height_m / cell_size; 

% On Startup, initalize values during first plot
if (~app.mapInit)    
    app.currentTheta = 0;    
    app.currentVelocity = 0;
    app.currentAngVelocity = 0;
    app.dt = 0.2;
    app.mapInit = true;
    app.step = 0;
    app.distance_to_bot = 0; %cartesian distance to youBot 
    app.LogOddsMap = zeros(map_height, map_width);
    
end

%break apart scn into relative cartesian coordinates
[x_global, y_global] = scan_to_globalCarte(app, scan);
% Log-odds parameters
log_odds_occupied = 0.85;
log_odds_free = -0.4;
X_grid = zeros(684,1);
Y_grid = zeros(684,1);
for i = 1:684
    X_grid(i) = round(x_global(i) + 500); %xcenter
    Y_grid(i) = round(y_global(i) + 250); %ycenter
end

%plot changes
for i = 1:684
    % Compute line points from robot (0,0) to the detected obstacle
   % c = CalcLine(0, 0, X_grid(i), Y_grid(i));
    
    % Mark free space along the ray (excluding the last point)
   % for j = 1:size(c, 1) 
    %    if c(j,1) > 0 && c(j,1) <= map_width && c(j,2) > 0 && c(j,2) <= map_height
   %         app.LogOddsMap(c(j,2), c(j,1)) = app.LogOddsMap(c(j,2), c(j,1)) + log_odds_free;                
 %       end
  %  end
    
    % Mark the final detected obstacle cell
    if X_grid(i) > 0 && X_grid(i) <= map_width && Y_grid(i) > 0 && Y_grid(i) <= map_height
        app.LogOddsMap(Y_grid(i), X_grid(i)) = app.LogOddsMap(Y_grid(i), X_grid(i)) + log_odds_occupied;
    end
end

% Clamp log-odds values to keep them within the valid range
app.LogOddsMap = max(min(app.LogOddsMap, 10), -10);

% Convert log-odds to probability
app.LogOddsMap = 1 ./ (1 + exp(-app.LogOddsMap)); 

% Display the map
hold on;
imshow(app.LogOddsMap, 'Parent', app.UIAxes2);  
colormap(app.UIAxes2, 'gray');
title(app.UIAxes2, 'Global Occupancy Grid');
hold off;
end