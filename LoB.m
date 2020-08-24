%
% 1.0a HvR: Simple version, just allows for setting temperatures and boost. No
% readout yet.
%
% 1.0b MMS: 
% Change the input to a single cable, attached to the upper port of the
% arena. Used for both in-and output
%
% M.M. Span & H. van Rijn
% Department of Psychology
% Faculty of Behavioral Sciences
% University of Groningen, the Netherlands
            

%%    clear; a = LoB; a.Init('/dev/tty.usbmodem1d111'); a.Wait('xx',10)

classdef LoB < hgsetget
    properties (GetAccess = private)

        bufSize = 100000; % in ms
        bufChannels = 9;
        
        arduinoPort = '';
        dataPort = '';
        serialHandle = -1;
        dataFile = [];
        dataHandle = -1;
        
        version = '1.0a'
        
        curTargetBaseTemp = 15;
        curTargetTileTemp = {25, 25, 25};
        
        % For the video camera
        videoWin = -1;
        grabber = -1;

    end
    properties (GetAccess = public)

        
        data;

    end
    methods
        
        %% Constructor
        function obj = LoB()
            fprintf('LoB Arena interface code, version %s\n',obj.version);
        end
        
        function Wait(obj,msg,dur) 
            endTime = GetSecs + dur;
            startTime = GetSecs;
            nextUpdate = 0;
            while (GetSecs < endTime)
                if (nextUpdate < GetSecs) 
                    obj.Message(sprintf('%s %d',msg,dur-round(GetSecs-startTime)));
                    nextUpdate = GetSecs + 1;
                end
                 pause(.01);
            end
            obj.Message(sprintf('%s done',msg));
        end
        
        function delete(obj)
            Stop(obj)
            if (obj.grabber ~= -1)
                obj.VideoStop()
                Screen('CloseVideoCapture', obj.grabber);
            end
            if (obj.videoWin ~= -1) 
                Screen('Close',obj.videoWin)
            end
        end
                
        function VideoInit(obj,deviceIndex)
            AssertOpenGL;
            
            % Default is to auto-detect video device to use:
            if nargin < 2
                deviceIndex = [];
            end
            
            winlevel = Screen('Preference','WindowShieldinglevel', -1);
    
            % Open an invisible dummy window of 10 x 10 pixels size:
            obj.videoWin = Screen('OpenWindow', 0, 0, [0 0 10 10]);
            Screen('Preference','WindowShieldinglevel',winlevel);
            
            % Open videocapture device, requesting 640 x 480 pixels resolution:
            obj.grabber = Screen('OpenVideoCapture', obj.videoWin, deviceIndex, [0 0 640 480],[],[],[],[],[],1,8);
        end
        
        function grbr = VideoGrabber(obj)
            grbr = obj.grabber;
        end
        
        function VideoStart(obj)
            % Start low-latency capture with requested 30 fps:
            Screen('StartVideoCapture', obj.grabber, 30, 1);
        end
        
        function VideoStop(obj)
            Screen('StopVideoCapture', obj.grabber);
        end
        
        function matImage = VideoGetImage(obj)
            % Retrieve next captured image in 'rawImage'. The 'waitforImage=2'
            % flag disables texture creation, so 'tex' is actually an empty
            % handle. The 'specialMode'=2 flag requests video data as matrix:
            [tex, pts, nrdropped, rawImage]=Screen('GetCapturedImage', obj.videoWin, obj.grabber, 2, [], 2); %#ok<ASGLU>
                     
            % Convert rawImage matrix into a matrix suitable for display with
            % Matlabs imshow(). imshow needs a height x width x 3 colors
            % matrix, whereas rawImage is a c by width x height matrix with c=1
            % for luminance data, c=3 or 4 for RGB data, where the 4th
            % component - if present - is a useless alpha channel.
            channels = min(size(rawImage,1), 3);
            for ci=1:channels
                if channels == 1
                    tci=1;
                else
                    tci = 4 - ci;
                end
                matImage(1:size(rawImage,3), 1:size(rawImage,2), tci) = transpose(squeeze(rawImage(ci,:,:))); %#ok<AGROW>
            end            
        end
            
        function Init(obj,dataPort)
        %    obj.arduinoPort = arduinoPort;
            obj.dataPort = dataPort;
            
%            obj.serialHandle = serial(obj.arduinoPort,'BaudRate',115200);
            obj.dataHandle = serial(obj.dataPort,'BaudRate',115200,'InputBufferSize',((obj.bufChannels)*4)*obj.bufSize, 'Timeout',Inf);
            obj.serialHandle = obj.dataHandle;
            fopen(obj.serialHandle);
            if (strcmp(obj.serialHandle,'open'))
                err = MException('LoB:SerialPortError', ...
                    'Could not open serial port: %s (command)', obj.arduinoPort);
                throw(err)
            end
            flushinput(obj.serialHandle)

            %flushinput(obj.dataHandle)
        end
        
        function SetBaseTemp(obj,temp)
            if (temp < 5 || temp > 25) 
                err = MException('LoB:BaseTempOutOfRange', ...
                    'Base temperature should be between 5 and 25');
                throw(err)
            end
            
            obj.CheckSerialPort();
            obj.curTargetBaseTemp = temp;
            fprintf(obj.serialHandle,sprintf('setcoppertemp=%d',temp));
        end
        
        function CheckSerialPort(obj) 
            if (obj.serialHandle == -1)
                err = MException('LoB:SerialPortErrorNotOpen', ...
                    'Serial port is not open, call LoB.Init() first');
                throw(err)
            end
        end
        
        function Message(obj, msg)
            %obj.CheckSerialPort()
            fprintf(obj.serialHandle,sprintf('message=%s',msg));
            disp(sprintf('message=%s',msg));
        end
        
        function SetTileTemp(obj, t1, t2, t3)
            if (min([t1,t2,t3]) < 5 || max([t1,t2,t3]) > 60) 
                err = MException('LoB:TileTempOutOfRange', ...
                    'Tile temperature should be between 5 and 60');
                throw(err)
            end
            obj.CheckSerialPort();
            fprintf(obj.serialHandle,sprintf('settiletemp=%d,%d,%d',t1,t2,t3));
        end

        function Boost(obj, b1, b2, b3)
            if (sum([b1,b2,b3]) > 2) 
                err = MException('LoB:TooMuchBoost', ...
                    'Only two tiles can be boosted at the same time');
                throw(err)
            end
            obj.CheckSerialPort();
            fprintf(obj.serialHandle,sprintf('boost=%d,%d,%d',b1,b2,b3));
        end
        
        function AreYouThere(obj)
            obj.CheckSerialPort();
            Message(obj,'Yes I am')
        end
        
        function hdl = GetHandle(obj)
            hdl = obj.serialHandle;
        end
        
        function Stop(obj)
            if (obj.serialHandle ~= -1) 
                fclose(obj.serialHandle);
            end
            obj.serialHandle = -1;

        end
        function StartSampling(obj, fileName)
            fprintf(obj.serialHandle,'startSampling');
            %fopen(obj.dataHandle);
            if (strcmp(obj.dataHandle,'open'))
                err = MException('LoB:SerialPortError', ...
                    'Could not open serial port: %s (data)', obj.dataPort);
                throw(err)
            end
            obj.dataFile=fopen(fileName,'w+');
        end
        function StopSampling(obj)
            fclose(obj.dataFile);
            fprintf(obj.serialHandle,'stopSampling');          
        end
        function Flush(obj)
            ba = obj.dataHandle.BytesAvailable;
            if(ba)
               sample = fread(obj.dataHandle,[obj.bufChannels floor((ba/4)/obj.bufChannels)],'float');
               fwrite(obj.dataFile,sample,'float');
               obj.data = [obj.data;sample];
            end
        end
        % LEDs
        function LED(obj, l1,l2)
            obj.CheckSerialPort();
            fprintf(obj.serialHandle,sprintf('leds=%d,%d', l1,l2));
        end
        
    end
    
    methods(Static)
        function ShowPorts()
            disp('The following serial ports are known:');
            tmp = instrhwinfo('serial');
            disp(tmp.SerialPorts);
        end

    end
end

