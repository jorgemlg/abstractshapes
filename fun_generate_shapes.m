function [shapes, p] = fun_generate_shapes(varargin)

% This function allows users to randomly create images of abstract 
% line-shapes by drawing adjacent lines (with a gap) on an invisible grid 
% and  generating an image file.

% The pixel size used to estimate the size 
% of the stimuli depends on the monitor's resolution; i.e. the created 
% images will vary depending on the monitor in which the code is run. 

% This function requires installing The Psychtoolbox (Brainard 1997), a 
% free stimulus presentation toolbox for Matlab: http://psychtoolbox.org
% You can check if Psychtoolbox is installed (and that the Psychtoolbox
% directory is in your Matlab path) by typing PsychtoolboxVersion in
% Matab's command window.

% Inputs
% 
% If there is input values, default values are used. The user can control 
% the following input values (the order doesn't matter):

% 'lines': Number of lines in each stimulus. Default=20
% 'number': Number of stimuli created with the same parameters. Default=1
% 'degrees': Degrees of visual angle of the stimulus. Default=4
% 'distance': Distance in centimeters from the screen (important for 
%    estimating the size of stimuli in degrees of visual angle. Default=60
% 'backColor': color of the background. RGB 3x1 array. Default= [0 0 0]
% 'lineColor': color of the lines. RGB 3x1 array. Default= [255 255 255]
% 'file': Image file type, string (admitted values: 'tif','tiff','jpg', 
%    'jpeg','png'. Default: 'tiff'
% 'squares': Number of squares composing the invisible grid. Default: 6
%    (Must be an even number)

% Example: 

% fun_generate_shapes('lines',56,'number',5,'degrees',10,'squares',8, ...
%    'file','tif','lineColor',[50 15 255],'backColor',[23 23 23]);

% Outputs
% shapes: returns all the values used for generating each stimulus matrix.
%    The stimulus matrix itself is saved in shapes.stimMatrix
% p: returns the stimulus parameters 

% All stimulus images, stimulus parameters and stimulus matrices are saved 
% a specially created folder /images/day*time created wherever this 
% function file is stored.

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
   
%% Initialize directories
cwd = pwd;

if ispc
    data_dir = [cwd '\images\'];
else
    data_dir = [cwd '/images/'];
end

data_dir_2 = [data_dir datestr(now,'yyyy_mm_dd_HH_MM_SS')];

disp(' ')
disp('Images will be saved in the following directory:')
disp(' ')
disp(data_dir_2)

% Create images directory

mkdir(data_dir_2);

%% Open Psychtoolbox Screen

% Psychtoolbox screen size matches monitor size. Opacity is set to 0, this
% entails it will appear as if no screen was open. If the function crashes
% Psychtoolbox won't close on its own. Type 'sca' in the command window to
% close any unclosed screens.

clear Screen
Screen('CloseAll');
w = 0; opacity = 0; 
PsychDebugWindowConfiguration(0, opacity);
Screen('Preference', 'SkipSyncTests', 1);
[window, ~] = Screen('OpenWindow', w); 

%% Unpack parameters

defaultLines     = 20;
defaultStim      = 1;
defaultDegrees   = 4;
defaultDistance  = 60;
defaultBackColor = [0 0 0];
defaultLineColor = [255 255 255];
defaultFileType  = 'tiff';
expectedFileType = {'tif','tiff','jpg','jpeg','png'};
defaultSquares   = 6;

r = inputParser;
validIntegerPosNum = @(x) isnumeric(x) && (x > 0) && mod(x(1),1) == 0;
validColorNum     = @(x) length(x)==3 && mod(x(1),1) == 0 && ...
                        mod(x(2),1) == 0 && mod(x(3),1) == 0 && ...
                        (x(1) >= 0) && (x(2) >= 0) && (x(3) >= 0) && ...
                        (x(1) <= 255) && (x(2) <= 255) && (x(3) <= 255);
               
addOptional(r,'lines', defaultLines, validIntegerPosNum);
addOptional(r,'number',defaultStim, validIntegerPosNum);
addOptional(r,'degrees',defaultDegrees, validIntegerPosNum);
addOptional(r,'distance',defaultDistance, validIntegerPosNum);
addOptional(r,'backColor',defaultBackColor, validColorNum);
addOptional(r,'lineColor',defaultLineColor, validColorNum);
addOptional(r,'file',defaultFileType, @(x) ...
                any(validatestring(x,expectedFileType)));
addOptional(r,'squares',defaultSquares, validIntegerPosNum);

parse(r,varargin{:});
   
numLines        = r.Results.lines;
numStim         = r.Results.number;
degreeStim      = r.Results.degrees;
distScreen      = r.Results.distance;
backColor       = r.Results.backColor;
lineColor       = r.Results.lineColor;
squaresinGrid   = r.Results.squares;
stimType        = r.Results.file;

p = fun_param(window, numLines, backColor, lineColor, degreeStim, ... 
                distScreen,squaresinGrid);

% Terminate if number of lines exceeds number allows by grid size

if numLines > p.maxLimit    
    
    disp('++++++++++++++++++++++++++++')
    disp('++++++++++++++++++++++++++++')
    disp('++++++++++++++++++++++++++++')
    disp('++++++++++++++++++++++++++++')
    disp('   ')
    disp('   ')
    disp('The selected number of lines per stimulus exceeds the number of')
    disp('lines that can fit the grid given present stimulus settings')
    disp('   ')
    disp('The maximum number of lines allowed with current settings is')
    disp(num2str(p.maxLimit))
    disp('   ')
    disp('   ')
    disp('++++++++++++++++++++++++++++')
    disp('++++++++++++++++++++++++++++')
    disp('++++++++++++++++++++++++++++')
    disp('++++++++++++++++++++++++++++')
    
    return
end

%% Creates stimulus

shapes {1,numStim} = {};

for items = 1:numStim
       
    cd(cwd);
    
    shapes {items}   = fun_create_grid(p);
    
    fileName         = strcat('s_', num2str(numLines), ...
                                    '_', num2str(items), '.', stimType);
    
%     save stimulus in image directory
    
    cd(data_dir_2);                                     
    imwrite(shapes{items}.stimMatrix,char(fileName));          
       
end

save stimParameters shapes p;     

Screen('CloseAll');

cd(cwd);

end









