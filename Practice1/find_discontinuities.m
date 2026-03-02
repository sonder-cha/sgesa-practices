function jump_times_year = find_discontinuities(discontinuity_file, station_name)
% find_discontinuities.m
% Parses the discontinuity file to find jump epochs for a given station.
% Returns a vector of jump times in decimal years.

    jump_times_year = []; % Initialize as an empty array
    
    fid = fopen(discontinuity_file, 'r');
    if fid == -1
        error('Cannot open discontinuity file: %s', discontinuity_file);
    end
    
    % Regular expression to match the specific date format YY:DDD:SSSSS
    date_regex = '^\d{2}:\d{3}:\d{5}$';
    
    tline = fgetl(fid);
    while ischar(tline)
        % Check if the line starts with the exact station name followed by a space
        if startsWith(strtrim(tline), [station_name, ' '])
            parts = strsplit(strtrim(tline));
            
            % A valid discontinuity line for position ('P') has a specific structure.
            % It should have at least 6 parts, with the 4th being 'P',
            % and the 5th and 6th matching the date format. This check avoids
            % misinterpreting descriptive lines.
            if length(parts) >= 6 && strcmp(parts{7}, 'P') &&...
               ~isempty(regexp(parts{5}, date_regex, 'once')) &&...
               ~isempty(regexp(parts{6}, date_regex, 'once'))
                
                % The jump occurs at the start of the new interval.
                % We extract the date that is NOT '00:000:00000'.
                % This is typically the end date of the first segment.
                date_str = parts{6};
                
                if strcmp(date_str, '00:000:00000')
                    % If the end date is zero, the jump is at the start date.
                    % This happens for lines defining the segment *after* a jump.
                    date_str = parts{5};
                end
                
                % Only process non-zero dates
                if ~strcmp(date_str, '00:000:00000')
                    date_parts = sscanf(date_str, '%d:%d:%d');
                    
                    yy = date_parts(1);
                    ddd = date_parts(2);
                    sssss = date_parts(3);
                    
                    % Convert YY to full year (e.g., 98 -> 1998, 01 -> 2001)
                    if yy > 50 % Heuristic for 20th vs 21st century
                        year = 1900 + yy;
                    else
                        year = 2000 + yy;
                    end
                    
                    % Check for leap year to get the correct number of days
                    is_leap = (mod(year, 4) == 0 && mod(year, 100) ~= 0) || (mod(year, 400) == 0);
                    days_in_year = 365 + is_leap;
                    
                    % Convert to decimal year
                    decimal_year = year + (ddd - 1 + sssss / 86400) / days_in_year;
                    
                    % Add to the list of jump times
                    jump_times_year = [jump_times_year; decimal_year];
                end
            end
        end
        tline = fgetl(fid);
    end
    
    fclose(fid);
    
    % Return unique jump times, sorted, to handle duplicates
    jump_times_year = unique(jump_times_year);
end