function plot_velocity_vectors(Results, station_list, coastline_file)
% plot_velocity_vectors.m
% Creates a quiver plot comparing GNSS and NNR-NUVEL1A horizontal velocities
% on a Polar Stereographic Projection map (North Pole centered).

    figure('Name', 'Horizontal Velocity Comparison', 'Color', 'w');
    
    % --- Setup Map Projection & Limits ---
    ax = gca;
    set(ax, 'Color', 'w'); % White background
    set(ax, 'LineWidth', 2); % Thicker border
    set(ax, 'Box', 'on'); % Black border around the plot area
    set(ax, 'XColor', 'k', 'YColor', 'k');
    hold on;
    
    % --- 1. Plot Coastlines in Polar Stereo ---
    load(coastline_file, 'lam', 'phi'); % lam=lon, phi=lat
    
    % Filter for Northern Hemisphere > 30 deg for efficiency
    valid_idx = phi > 30; 
    lam_plot = lam;
    phi_plot = phi;
    
    [x_coast, y_coast] = polar_stereo_proj(phi_plot, lam_plot);
    
    % Plot coastlines
    plot(x_coast, y_coast, 'Color', [0.5 0.5 0.5], 'LineWidth', 0.8, 'HandleVisibility', 'off');
    
    % --- 2. Plot Grid Lines (Parallels and Meridians) ---
    % Parallels
    for lat = 40:10:80
        lons = 0:1:360;
        lats = repmat(lat, size(lons));
        [x_par, y_par] = polar_stereo_proj(lats, lons);
        plot(x_par, y_par, 'Color', [0.8 0.8 0.8], 'LineStyle', ':', 'LineWidth', 0.5, 'HandleVisibility', 'off');
        
        % Label Parallels (at specific longitude, e.g., 0)
        [x_lbl, y_lbl] = polar_stereo_proj(lat, 0);
        text(x_lbl, y_lbl, sprintf('%d^{\\circ}N', lat), 'FontSize', 8, 'Color', [0.6 0.6 0.6], 'VerticalAlignment', 'bottom');
    end
    
    % Meridians
    for lon = -180:30:180
        lats = 30:1:90;
        lons_vec = repmat(lon, size(lats));
        [x_mer, y_mer] = polar_stereo_proj(lats, lons_vec);
        plot(x_mer, y_mer, 'Color', [0.8 0.8 0.8], 'LineStyle', ':', 'LineWidth', 0.5, 'HandleVisibility', 'off');
        
        % Label Meridians (at lat 35)
        [x_lbl, y_lbl] = polar_stereo_proj(35, lon);
        text(x_lbl, y_lbl, sprintf('%d^{\\circ}', lon), 'FontSize', 8, 'Color', [0.6 0.6 0.6], 'HorizontalAlignment', 'center');
    end

    % --- 3. Plot Velocity Vectors ---
    h = zeros(2, 1); % Handles for legend
    
    scale_factor = 30000; 
    
    % Store station coordinates for centering
    station_xs = [];
    station_ys = [];
    
    for i = 1:length(station_list)
        station_name = station_list{i};
        
        % Get Station Position
        llh = Results.(station_name).llh0_deg;
        lat0 = llh(1);
        lon0 = llh(2);
        
        [x0, y0] = polar_stereo_proj(lat0, lon0);
        station_xs = [station_xs, x0];
        station_ys = [station_ys, y0];
        
        % Get Velocities (East, North) in mm/yr
        v_gnss_en = Results.(station_name).trend_mm_yr(1:2);
        v_nuvel_en = Results.(station_name).nuvel_v_ne_mm_yr(1:2);
        
        % Rotate Vectors
        delta = 0.1;
        [x_n, y_n] = polar_stereo_proj(lat0 + delta, lon0); % Point North
        [x_e, y_e] = polar_stereo_proj(lat0, lon0 + delta); % Point East
        
        vec_n = [x_n - x0; y_n - y0];
        vec_n = vec_n / norm(vec_n);
        
        vec_e = [x_e - x0; y_e - y0];
        vec_e = vec_e / norm(vec_e);
        
        % Project velocities
        v_gnss_proj = v_gnss_en(1) * vec_e + v_gnss_en(2) * vec_n;
        v_nuvel_proj = v_nuvel_en(1) * vec_e + v_nuvel_en(2) * vec_n;
        
        % Plot Vectors
        h(1) = quiver(x0, y0, v_gnss_proj(1)*scale_factor, v_gnss_proj(2)*scale_factor, 0, 'Color', 'k', 'LineWidth', 2, 'MaxHeadSize', 0.5);
        h(2) = quiver(x0, y0, v_nuvel_proj(1)*scale_factor, v_nuvel_proj(2)*scale_factor, 0, 'Color', 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);
        
        % Plot Station Marker
        plot(x0, y0, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6, 'HandleVisibility', 'off');
        % Red text, no background
        text(x0, y0, ['  ' station_name], 'Color', 'r', 'FontSize', 10, 'FontWeight', 'bold');
    end
    
    % --- 4. Calculate Center and Limits ---
    % Center defined as average X/Y of all displayed stations (Visual Center)
    xc = mean(station_xs);
    yc = mean(station_ys);
    
    % Calculate distance to farthest station
    dists = sqrt((station_xs - xc).^2 + (station_ys - yc).^2);
    max_dist = max(dists);
    
    % Set display range (half length = max_dist)
    % Add a small buffer (e.g., 10%)
    buffer = 1.1; 
    half_len = max_dist * buffer;
    
    % Set limits strictly
    xlim([xc - half_len, xc + half_len]);
    ylim([yc - half_len, yc + half_len]);
    
    % Enforce Aspect Ratio
    daspect([1 1 1]); % Data Aspect Ratio 1:1
    pbaspect([1 1 1]); % Plot Box Aspect Ratio 1:1 (Square)
    
    % Hide ticks but keep box
    set(gca, 'XTick', [], 'YTick', []);
    
    title('Comparison of Horizontal Velocities (Polar Stereographic)', 'FontSize', 12);
    
    % --- 5. Scale Bar & Legend ---
    legend(h, 'GNSS', 'NNR-NUVEL 1A', 'Location', 'southwest');
    
    % Draw Scale Bar near Legend (SouthEast)
    x_lims = xlim;
    y_lims = ylim;
    width = x_lims(2) - x_lims(1);
    height = y_lims(2) - y_lims(1);
    
    % Position: Bottom Right
    x_ref = x_lims(2) - 0.25 * width;
    y_ref = y_lims(1) + 0.08 * height;
    
    ref_len = 20 * scale_factor;
    quiver(x_ref, y_ref, ref_len, 0, 0, 'k', 'LineWidth', 2, 'ShowArrowHead', 'off', 'HandleVisibility', 'off');
    text(x_ref + ref_len/2, y_ref - 0.04 * height, '20 mm/yr', 'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
    
    saveas(gcf, './output/velocity_vectors.png');
end

function [x, y] = polar_stereo_proj(lat, lon)
% Converts lat/lon (degrees) to Polar Stereographic (x, y)
    R = 6371000; 
    lat_rad = deg2rad(lat);
    lon_rad = deg2rad(lon);
    rho = 2 * R * tan(pi/4 - lat_rad/2);
    x = rho .* sin(lon_rad);
    y = -rho .* cos(lon_rad);
end