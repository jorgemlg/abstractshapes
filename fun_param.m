function p = fun_param (window, numLines, backColor, lineColor, degreeStim, distScreen, squaresinGrid)

% Sets all the stimulus parameters required for drawing
% abstract line-shapes. This function is meant to be used with 
% fun_generate_shapes.m

% COPYRIGHT 
% This code is freely distributed and may be changed as needed by the user.
% I just kindly ask that if you use the original or a modified version of
% the code, you cite the paper where figures using this code first
% appeared:

% Morales, J., Lau, H., & Fleming, S. M. (2018). Domain-General and 
% Domain-Specific Patterns of Activity Supporting Metacognition in Human 
% Prefrontal Cortex. The Journal of Neuroscience Vol(Issue): Pages.
% https://doi.org/10.1523/JNEUROSCI.2360-17.2018

% Jorge Morales Dec 2014
% Last Updated: Jorge Morales March 2018   

%%

%  ------------------
%  SPATIAL PARAMETERS
%  ------------------

%%% DISPLAY PROPERTIES

p.window                = window;
p.distFromScreen_inCm   = distScreen;                                       % distance in cm from screen. Important parameter to estimate visual angle. Default is 60cm
p.windowRect            = Screen('Rect', p.window);

p.midW = p.windowRect(3)/2;
p.midH = p.windowRect(4)/2;

p.widthOfScreen_inPixels  = p.windowRect(3);
p.heightOfScreen_inPixels = p.windowRect(4);

[p.widthOfScreen_inMm, p.heightOfScreen_inMm ] = Screen('DisplaySize', ...
                                                p.window);
                                            
p.widthOfScreen_inCm  = p.widthOfScreen_inMm / 10;
p.heightOfScreen_inCm = p.heightOfScreen_inMm / 10;
p.pixels_perCm        = round(p.widthOfScreen_inPixels/ ... 
                                    p.widthOfScreen_inCm);


%%

% -------------
% STIMULUS
% -------------
    
% COLORS
% In RGB space

p.BGColor    = backColor;                                                   % Shapes background color. Default is black
p.lineColor  = lineColor;                                                   % Shapes line color. Default is white

%%% SHAPE GRID SIZE IN DEGREES OF VISUAL ANGLE

p.stimWidth_inDegrees          = degreeStim;                                % Width size of grid in degrees of visual angle
p.stimWidth_inPixels           = degrees2pixels ...
                                        (p.stimWidth_inDegrees, ...
                                        p.distFromScreen_inCm);

%--%---%--%---
%%% POSITION STIMULUS FROM CENTER
p.stimRadialDistance_inDegrees = p.stimWidth_inDegrees; 
% stimRadialDistance_inPixels  = degrees2pixels...
%                                         (stimRadialDistance_inDegrees, ...
%                                         p.distFromScreen_inCm);

%--%---%--%---
%%% STIMULUS RECTS

%%% Stimulation positions

% Presentation of two stimuli
% stimRect     = [0 0 stimWidth_inPixels stimHeight_inPixels];
% x_pos               = stimDistance_inPixels; 
% %y_pos               = stimRadialDistance_inPixels;  
% stimRectL    = CenterRectOnPoint(stimRect, ...
%                         p.midW-x_pos, p.midH);
% stimRectR    = CenterRectOnPoint(stimRect, ...
%                         p.midW+x_pos, p.midH);
% stimRectC    = CenterRectOnPoint(stimRect, p.midW, ...
%                         p.midH);
                  

% Shapes %

p.squaresinGrid    =  squaresinGrid;                                        % Number of squares per side in the grid (default is 6 * 6)
p.numLines         =  numLines;                                             % Number of lines in the stimulus. Default is 20
p.maxLimit         =  (p.squaresinGrid^2)*2 + ...
                             ((p.squaresinGrid+1)*p.squaresinGrid)*2;       % Ensures the number of selected lines is not higher than what the grid allows

% Squares in grid & Line size

p.squareSize       = round(p.stimWidth_inPixels/...                         % Determines size of each square in the grid in pixels
                            p.squaresinGrid);              
                        
p.lineWidth        = round(p.squareSize * .1);                              % Determine line width based on grid size. Default is .2 of square size in pixels

if mod(p.lineWidth,2) == 0 
    p.lineWidth = p.lineWidth + 1;
end                                                                         % Linewidth to be an ODD number for proper alignment

p.halfLine         = floor(p.lineWidth/2);                                  % Determine half of the width of a line
p.lineLength       = p.squareSize;                                          % Determine true line length based on square grid size         



end