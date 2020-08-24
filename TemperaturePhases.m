%% Temperature Phases %%
% Establish rate of change of a temperature curve %

global par;

%% Information about the experiment:
par.expName = 'Run';
par.expVersion = '1';
par.expChangeData = '140212';

%% Keyboard settings:
KbName('UnifyKeyNames');

%% Debugging:
% Enter the debugger when an error/warning is signalled.
dbstop if error
dbstop if warning

%% Define duration of time pre-experimental phase to allow for recording to be 
% started and define duration of each temperature phas
par.PreRecording = 7; %Times defined in seconds
par.StimulusDur =60;

%% Start temperature-controlled box
arena = LoB;
if (ispc)
    par.port_nat = 'COM5'; %Change according to computer
end

if (ismac)
    par.port_nat = '/dev/tty.usbmodem2411'; %Change according to computer
end

arena.Init(par.port_nat)
arena.Message('Init done'); %Message will appear on LCD screen

arena.LED(0,0); % Both indicative red LEDs will be off

arena.SetBaseTemp(16); % Minimum temperature for continuous cooling
arena.SetTileTemp(16,16,16); %Start-up temperature of each of the three copper tiles

arena.Wait('Init...',5);
startTime = datestr(now,'yymmddHHMM');
GetChar;

arena.Wait('Explore...',par.PreRecording); %During this moment the ring of light can be placed
                                         % and the recording can be started

%% Start the experimental block

for i = 1:23
    if mod(i,2) == 1
        arena.LED(1,0) % The left indicative LED will turn on during phase 1, then                       
    else               % the right indicative LED will turn on during phase 2, and so on.
        arena.LED(0,1)
    end
    if i > 8          % The first 7 minutes happen at 16?C to allor flies to explore
        a = a + 2;
    else
        a = 16;
    end
    
    arena.SetTileTemp(a,a,a);
    arena.Wait(sprintf('%dStim',i),par.StimulusDur);
end

arena.LED(0,0);
arena.SetTileTemp(16,16,16);


