import LoB

# Define duration of time pre-experimental phase to allow for recording to be 
# started and define duration of each temperature phas
PreRecording = 7; # Times defined in seconds
StimulusDur = 60;

# Start temperature-controlled box
arena = LoB.Arena();
port_nat = '/dev/tty.usbmodem2411'; #Change according to computer

arena.Init(port_nat)
arena.Message('Init done'); #Message will appear on LCD screen

arena.LED(0,0); # Both indicative red LEDs will be off

arena.SetBaseTemp(16); # Minimum temperature for continuous cooling
arena.SetTileTemp(16,16,16); #Start-up temperature of each of the three copper tiles

arena.Wait('Init...',5);
#startTime = datestr(now,'yymmddHHMM');
#GetChar;

arena.Wait('Explore...',par.PreRecording); #During this moment the ring of light can be placed
                                         # and the recording can be started

# Start the experimental block

for i in range(1,23):
    if i%2 == 1:
        arena.LED(1,0) # The left indicative LED will turn on during phase 1, then                       
    else:              # the right indicative LED will turn on during phase 2, and so on.
        arena.LED(0,1)
    if i > 8:          # The first 7 minutes happen at 16?C to allor flies to explore
        a = a + 2
    else:
        a = 16
    
    arena.SetTileTemp(a,a,a)
    arena.Wait(str(i) + "Stim", StimulusDur);

arena.LED(0,0)
arena.SetTileTemp(16,16,16)

