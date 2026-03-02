function year = mjdweek2year(mjd)
% mjdweek2year.m
% Converts Modified Julian Date (MJD) Weeks (From 1980) to decimal year.
    
    % Mjd weeks instead of mjd
    % year = 1980.0 + (mjd - 44239.0) / 365.25;
    year = 1980.0 + mjd / 365.25 * 7;
end