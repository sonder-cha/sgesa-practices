function plot_gia_map(gia_file, model_name, coastline_file, Results, station_list)
% plot_gia_map.m
% Visualizes a GIA model on a global map and plots station locations.

    gia_data = load(gia_file); % loads lat, lon, v_crust
    load(coastline_file, "lam", "phi"); % loads coast
    
    % Set figure size larger (e.g., 1200x600 pixels)
    figure('Name', ['GIA Model: ' model_name], 'Color', 'w', 'Position', [100, 100, 1200, 600]);
    
    % Plot the GIA model grid
    fields = fieldnames(gia_data); 
    v_crust = gia_data.(fields{1});
    
    lat_grid = -89.5:1:89.5;
    lon_grid = -179.5:1:179.5;
    
    % Use contourf for smooth filled contours
    [LON, LAT] = meshgrid(lon_grid, lat_grid);
    
    contourf(LON, LAT, v_crust, 20, 'LineStyle', 'none');
    
    set(gca, 'YDir', 'normal'); 
    
    % Colormap and Bar
    colormap('jet');
    c = colorbar;
    ylabel(c, 'Vertical Velocity (mm/year)', 'FontSize', 10);
    caxis([-15 20]); 
    
    hold on;
    
    % Plot coastlines
    plot(mod(lam+180,360)-180, phi, 'k', 'LineWidth', 1.0);
    
    % Plot station locations
    for i = 1:length(station_list)
        station_name = station_list{i};
        llh = Results.(station_name).llh0_deg;
        station_lat = llh(1);
        station_lon = llh(2);
        
        if station_lon > 180
            station_lon = station_lon - 360;
        end
        
        plot(station_lon, station_lat, 'kp', 'MarkerSize', 12, 'MarkerFaceColor', 'm', 'LineWidth', 1.5);
        % Smaller font size, reduced margin
        text(station_lon + 2, station_lat, station_name, 'Color', 'k', 'FontWeight', 'bold', 'FontSize', 8, 'BackgroundColor', 'w', 'Margin', 0.5);
    end
    
    hold off;
    
    axis equal;
    axis([-180 180 -90 90]);
    xlabel('Longitude (degrees)');
    ylabel('Latitude (degrees)');
    title(['GIA Model: ' model_name], 'FontSize', 14, 'FontWeight', 'bold');
    
    grid on;
    set(gca, 'Layer', 'top'); 
    
    saveas(gcf, ['./output/' model_name '_map.png']);
end