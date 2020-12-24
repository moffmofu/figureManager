classdef DrawingManager<handle
    % Figure‚ÌƒTƒCƒY‚Æ‚©‚ð“ˆê‚·‚é‹KŠi‚Æ‚µ‚Ä»ì
    % 
    % plotŒn‚Ìƒ‰ƒbƒp[W
    % 
    % 
    %% properties
    properties
        list    % »ì‚³‚ê‚½figureNum‚ð”cˆ¬‚µ‚Ä‚¨‚«‚½‚¢‚¶‚á‚ñ
        nowPos
        defaultMonitor
        tango   % ‘€ì‘ÎÛ‚Ìfigure number
        tangoFig % ‘{¸‘ÎÛ‚Ìfigure object
        flags
        viewer
        FontSize=15
    end
    %% properties(private)
    properties(Access=private)
        limit
        monitorNum
        positionList
        positionInd
    end
    properties(Access=protected)
        positionStep=[300,250];
        defaultSize=[600,500];
    end
    methods
        %% original functions
        function obj=DrawingManager()
            obj.list=[];
            rt=groot;
            obj.limit=rt.MonitorPositions;
            obj.monitorNum=size(obj.limit,1);
            obj.setPos();
            obj.defaultMonitor="disp1";
            obj.flags=struct();
        end
        
        function setPos(obj)
            for i=1:obj.monitorNum
                obj.positionList.("disp"+num2str(i))=[];
                xWins=fix((obj.limit(1,3)-obj.defaultSize(1))/obj.positionStep(1));
                yWins=fix((obj.limit(1,4)-obj.defaultSize(2))/obj.positionStep(2));
                for xn=0:xWins
                    for yn=0:yWins
                        newPos=[[xn,yn].*obj.positionStep];
                        newPos=[newPos,obj.defaultSize];
                        obj.positionList.("disp"+num2str(i))=[obj.positionList.("disp"+num2str(i));newPos];
                    end
                end
            end
            obj.positionInd=1;
        end
        
        function setSize_square(obj)
            figure(obj.tango);
        end
        
        function varargout=titleset(obj,varargin)
            [varargout{1:nargout}]=titleset(varargin{:});
        end
        
        function setFlag(obj,varargin)
            if rem(nargin-1,2)==1
                error("invalid input: must be a set of Key&Value");
            end
            for i=1:2:nargin-1
                obj.flags.(varargin{i})=varargin{i+1};
            end
        end
        
        function moveShow(obj)
            % show figure on shifted point
            obj.positionList.(obj.defaultMonitor)(obj.positionInd,:);
            obj.tangoFig.Position=obj.positionList.(obj.defaultMonitor)(obj.positionInd,:);
            obj.positionInd=obj.positionInd+1;
            if obj.positionInd>size(obj.positionList.(obj.defaultMonitor),1)
                obj.positionInd=1;
            end
        end
        
        function defaultSetting(obj)
            obj.tangoFig.Resize='off';
            obj.tango=obj.tangoFig.Number;
            obj.moveShow;
            ax=gca;
            ax.FontSize=obj.FontSize;
        end
        
        %% wrapper functions below
        function varargout=figure(obj,varargin)
            % wrapper func for figure
            % disable Resize
            % 
            [varargout{1:nargout}]=figure(varargin{:});
            if nargout>0
                obj.tangoFig=varargout{1};
            else
                obj.tangoFig=obj.gcf;
            end
            obj.defaultSetting();
        end
        
        function hold(obj,varargin)
            % wrapper func of matlab hold.
            hold(varargin{:});
        end
        
        function out=gcf(obj)
            % wrapper func of matlab gcf
            out=gcf;
            obj.tangoFig=out;
            obj.tango=out.Number;
        end
        
        function varargout=plot(obj,varargin)
            % wrapper func of matlab plot.
            [varargout{1:nargout}]=plot(varargin{:});
            [~]=obj.gcf;
            obj.defaultSetting();
        end
        
        function varargout=errorbar(obj,varargin)
            % wrapper func of matlab plot.
            [varargout{1:nargout}]=errorbar(varargin{:});
            [~]=obj.gcf;
            obj.defaultSetting();
        end
        
        function varargout=scatter(obj,varargin)
            % wrapper func of matlab plot.
            [varargout{1:nargout}]=scatter(varargin{:});
            [~]=obj.gcf;
            obj.defaultSetting();
        end
        
        function varargout=compass(obj,varargin)
            % wrapper func of matlab plot.
            [varargout{1:nargout}]=compass(varargin{:});
            [~]=obj.gcf;
            obj.defaultSetting();
        end
        
        function varargout=boxplot(obj,varargin)
            % wrapper func of matlab plot.
            [varargout{1:nargout}]=boxplot(varargin{:});
            [~]=obj.gcf;
            obj.defaultSetting();
        end
        function varargout=polarhistogram(obj,varargin)
            % wrapper func of matlab plot.
            [varargout{1:nargout}]=polarhistogram(varargin{:});
            [~]=obj.gcf;
            obj.defaultSetting();
        end
        function varargout=legend(obj,varargin)
            % wrapper func of matlab legend.
            [varargout{1:nargout}]=legend(varargin{:},'FontSize',obj.FontSize);
            [~]=obj.gcf;
            obj.defaultSetting();
        end
        function varargout=CreateTopographyMap(obj,varargin)
            % wrapper func of matlab legend.
            [varargout{1:nargout}]=CreateTopographyMap(varargin{:});
            [~]=obj.gcf;
            obj.defaultSetting();
        end
        function varargout=CreateTimeFrequencyMap(obj,varargin)
            % wrapper func of matlab legend.
            [varargout{1:nargout}]=CreateTimeFrequencyMap(varargin{:});
            [~]=obj.gcf;
            obj.defaultSetting();
        end
        function varargout=histogram(obj,varargin)
            % wrapper func of matlab legend.
            [varargout{1:nargout}]=histogram(varargin{:});
            [~]=obj.gcf;
            obj.defaultSetting();
        end
        function varargout=quiver(obj,varargin)
            % wrapper func of matlab legend.
            [varargout{1:nargout}]=quiver(varargin{:});
            [~]=obj.gcf;
            obj.defaultSetting();
        end
        function varargout=contourf(obj,varargin)
            % wrapper func of matlab legend.
            [varargout{1:nargout}]=contourf(varargin{:});
            [~]=obj.gcf;
            obj.defaultSetting();
        end
        function varargout=bar(obj,varargin)
            % wrapper func of matlab legend.
            [varargout{1:nargout}]=bar(varargin{:});
            [~]=obj.gcf;
            obj.defaultSetting();
        end
        function varargout=polHist_prepost(obj,varargin)
            % wrapper func of matlab plot.
            [varargout{1:nargout}]=polHist_prepost(varargin{:});
            [~]=obj.gcf;
            obj.defaultSetting();
        end
        function varargout=plotLinRegNConfInt(obj,varargin)
            % wrapper func of matlab plot.
            [varargout{1:nargout}]=plotLinRegNConfInt(varargin{:});
            [~]=obj.gcf;
            obj.defaultSetting();
        end
        %% wrapper for Viewer class
        function Viewer(obj,varargin)
            % wrapper func for viewer
            % disable Resize
            % 
            obj.viewer=Viewer(varargin{:});
        end
        function varargout=tfmapAve_standard(obj,varargin)
            % wrapper func of matlab legend.
            [varargout{1:nargout}]=obj.viewer.tfmapAve_standard(varargin{:});
            [~]=obj.gcf;
            obj.defaultSetting();
            ax=gca;
            ax.InnerPosition=[0.0938 0.1347 0.62 0.7877];
        end
        function varargout=tfmap(obj,varargin)
            % wrapper func of matlab legend.
            [varargout{1:nargout}]=obj.viewer.tfmap(varargin{:});
            [~]=obj.gcf;
            obj.defaultSetting();
            ax=gca;
            ax.InnerPosition=[0.0938 0.1347 0.62 0.7877];
        end
        function varargout=tfmapAve_tVal(obj,varargin)
            % wrapper func of matlab legend.
            [varargout{1:nargout}]=obj.viewer.tfmapAve_tVal(varargin{:});
            [~]=obj.gcf;
            obj.defaultSetting();
            ax=gca;
            ax.InnerPosition=[0.0938 0.1347 0.62 0.7877];
        end
        %% wrapper func for drawWave
        function varargout=drawWave(obj,varargin)
            % wrapper func of matlab legend.
            [varargout{1:nargout}]=drawWave(varargin{:});
            [~]=obj.gcf;
            obj.defaultSetting();
        end
    end
    %% static methods
    methods(Static)
    end
    
end