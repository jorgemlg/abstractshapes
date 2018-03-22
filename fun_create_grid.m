function g = fun_create_grid (p)

% Creates the grid and stimulus matrix required for drawing
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

%% Create grid

% Create grid
% Update locations indices to coordinates in row (r) and columns (c) from 
% the grid

g.gridSize_inPixels = (p.squareSize * p.squaresinGrid)...
                     + (p.lineWidth * 2);                                   % Create grid with border around it
                 
g.grid = zeros(g.gridSize_inPixels,g.gridSize_inPixels);

% Valid intersections in the grid (leave room for border)

g.grid (g.gridSize_inPixels-p.lineWidth,g.gridSize_inPixels-p.lineWidth)=1;

for i = p.lineWidth+1:p.squareSize:g.gridSize_inPixels-p.lineWidth
    
    g.grid (i,g.gridSize_inPixels-p.lineWidth) = 1;
    g.grid (g.gridSize_inPixels-p.lineWidth,i) = 1;
    
    for t = p.lineWidth+1:p.squareSize:g.gridSize_inPixels-p.lineWidth
    
        g.grid (i,t) = 1;
        
    end
end

g.gridSize = size(g.grid);

g.locLines  = find(g.grid)';
g.locIndex  = find(g.locLines);
g.locCenter = median(g.locIndex);

% Randomly select line locations. Control to avoid selection of the same 
% location + orientation twice (same location or same orientation is fine, 
% but not both). 

% Determine forbidden locations for orientations when drawing them 
% rightwards from location

g.numInter = p.squaresinGrid+1;                                             % Number of intersections on each direction of the grid
g.lastInter = g.numInter*g.numInter;                                        % Number of last intersection

g.l1 = g.locIndex (g.numInter*g.numInter:-1:g.lastInter-p.squaresinGrid);   % Horizontal line
g.l1 = sort(g.l1);

g.l2 = g.locIndex (g.numInter:g.numInter:g.lastInter);                      % Vertical line
g.l2 = sort(g.l2);

g.l3 = [g.l1, g.l2];                                                        % diagonal 1 (\)
g.l3 = sort(g.l3);
g.l3 = unique(g.l3);

g.l4 = g.locIndex(1:g.numInter:g.lastInter);                                % diagonal 2 (/)
g.l4 = [g.l4 g.l1];
g.l4 = sort(g.l4);
g.l4 = unique(g.l4);

% The same as above but drawing them leftwards

g.l5 = g.locIndex (1:g.numInter);                                           % Horizontal line
g.l5 = sort(g.l5);

g.l6 = g.locIndex (1:g.numInter:g.lastInter);                               % Vertical line
g.l6 = sort(g.l6);

g.l7 = [g.l5, g.l6];                                                        % diagonal 1 (\)
g.l7 = sort(g.l7);
g.l7 = unique(g.l7);

g.l8 = [g.l5 g.l2];                                                         % diagonal 2 (/)
g.l8 = sort(g.l8);
g.l8 = unique(g.l8);


%% Prepare variables for drawing lines

orientation = [];
loc         = [];
endpoint    = [];   
side        = [];
lineOrient  = [1 2 3 4 5 6 7 8]; 
linesDrawn  = 0;
rebootCount = 0;

% Get line coordinates and orientations. 
% Make sure there is continuous drawing, without repetition

for i = 1:p.numLines
    
    usedOrient  = [];
    drawLine = 0;
    rebootCount = 0;
    
    while ~drawLine 
      
        
        if i == 1
            loc(i) = g.locCenter;                                           % select center of stim for first line
        else
            side (i) = rand > 0.5;                                          % select beginning or end of previous line as beginning of new line
            if side (i) == 1                                                
                loc(i) = endpoint(i-1);
            else
                loc(i) = loc(i-1);
            end
        end
        
        if rebootCount >= 7                                                  % if randomly restarting the loop doesn't work, start trying
            loc(i) = randsample(loc,1); 
            usedOrient  = [];                                                % to draw a line in some of the previous free endpoints                                                         
        end
        
        if rebootCount == 0     
            orientation(i) = randsample(lineOrient,1);                      % select orientation randomly  
        else
            usedOrient = [usedOrient orientation(i)];
            orientation(i)  = randsample(setdiff(lineOrient,usedOrient),1);
        end
        
       
        
        switch orientation (i)
            
            %Rightwards
            
            case 1                                                          % horizontal
                endpoint (i) = loc(i) + g.numInter;
            case 2                                                          % vertical
                endpoint (i) = loc(i) + 1;  
            case 3                                                          % diagonal 1 (\)
                endpoint (i) = loc(i) + g.numInter + 1;
            case 4                                                          % diagonal 2 (/)
                endpoint (i) = loc(i) + g.numInter - 1;
            
            %Leftwards
            
            case 5                                                          % horizontal
                endpoint (i) = loc(i) - g.numInter;
            case 6                                                          % vertical
                endpoint (i) = loc(i) - 1;
            case 7                                                          % diagonal 1 (\)
                endpoint (i) = loc(i) - g.numInter - 1;
            case 8                                                          % diagonal 2 (/)
                endpoint (i) = loc(i) - g.numInter + 1;
        end
        
        l = strcat('g.l',num2str(orientation(i)));                               % select orientation forbiden locations
        
        if ~isempty (intersect(loc(i),eval(l)))                             % prevent invalid locations for orientation
            rebootCount = rebootCount + 1;
            continue;
        end
        
        if endpoint(i) < 0
            rebootCount = rebootCount + 1;
            continue;
        end    
        
        if endpoint(i) > g.lastInter
            rebootCount = rebootCount + 1;
            continue;
        end    
        
        % Forbidden combinations of locations and orientations
      
        repeatedLoc     = find(loc(1:i-1) == loc(i));             
        repeatedOrient  = find(orientation(1:i-1) == orientation(i));
        
        if ~isempty (intersect(repeatedLoc,repeatedOrient))
            rebootCount = rebootCount + 1;
            continue;
        end

        repeatedLine1 = find(loc(1:i-1) == endpoint(i));
        repeatedLine2 = find(loc(i) == endpoint(1:i-1));
        if ~isempty (intersect(repeatedLine1,repeatedLine2))                % prevent overwritting a line
            rebootCount = rebootCount + 1;
            continue;
        end
        
        linesDrawn  = linesDrawn + 1;
        drawLine = 1;
      
    end
end


%% Draw Lines

% Draw lines on screen according to stimulus matrix parameters 

% Open off screen for fast drawing
[offWindow, offRect] = Screen('OpenOffscreenWindow',p.window,p.BGColor,p.windowRect);
r=[];
c=[];

for i=1:p.numLines
    
    [r(i), c(i)] = ind2sub(g.gridSize,g.locLines(loc((i))));

%     %allow for gap between lines
%     r_plus = r + lineWidth; 
%     c_plus = c + lineWidth;
%     
%     r_minus = r - lineWidth; 
%     c_minus = c - lineWidth;
     
    
    switch orientation(i)
    
        case 1 
             
            Screen('DrawLine', offWindow, p.lineColor, ...
                r(i),c(i),r(i),c(i)+p.lineLength,p.lineWidth);
        
        case 2
            
            Screen('DrawLine', offWindow, p.lineColor, ...
                r(i),c(i),r(i)+p.lineLength,c(i),p.lineWidth);
            
        case 3
            
            Screen('DrawLine', offWindow, p.lineColor, ...
                r(i)+1,c(i)+1,r(i)+p.lineLength-1,c(i)+p.lineLength-1, ...
                p.lineWidth*1.35);
        
        case 4
            
            Screen('DrawLine', offWindow, p.lineColor, ...
                r(i)-1,c(i)+1,r(i)-p.lineLength+1,c(i)+p.lineLength-1, ...
                p.lineWidth*1.35);
        
        case 5 
             
            Screen('DrawLine', offWindow, p.lineColor, ...
                r(i),c(i),r(i),c(i)-p.lineLength,p.lineWidth);
        
        case 6
            
            Screen('DrawLine', offWindow, p.lineColor, ...
                r(i),c(i),r(i)-p.lineLength,c(i),p.lineWidth);
            
        case 7
            
            Screen('DrawLine', offWindow, p.lineColor, ...
                r(i)-1,c(i)-1,r(i)-p.lineLength+1,c(i)-p.lineLength+1, ...
                p.lineWidth*1.35);
        
        case 8
            
            Screen('DrawLine', offWindow, p.lineColor, ...
                r(i)+1,c(i)-1,r(i)+p.lineLength-1,c(i)-p.lineLength+1, ...
                p.lineWidth*1.35);
    end
    
end

%% Draw dots on intersections to prevent aliasing 

[x,y] = ind2sub(g.gridSize,g.locLines);

Screen('DrawDots', offWindow, [x;y], p.lineWidth*1.35, p.BGColor,[],0);          % squared dots on intersections

stimMatrix = Screen('GetImage', offWindow,...
                [0 0 g.gridSize_inPixels g.gridSize_inPixels]);           

Screen('Close',offWindow);

%% Save drawing parameters

g.r                 = r;
g.c                 = c;
g.side              = side;
g.linesDrawn        = linesDrawn;
g.lineOrient        = lineOrient;
g.orientation            = orientation;
g.rebootCount       = rebootCount;
g.loc               = loc;
g.endpoint          = endpoint;
g.stimMatrix        = stimMatrix;
end
