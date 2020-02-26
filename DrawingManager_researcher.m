classdef DrawingManager_researcher<DrawingManager
    % Figureのサイズとかを統一する規格として製作
    % 
    % plot系のラッパー集
    % 
    % 
    %% properties
    properties
        annoList
        
    end
    %% properties(private)
    properties(Access=protected)
        border=0.8
    end
    methods
        %% original functions
        function obj=DrawingManager_researcher()
            obj.annoList=[];
            obj.defaultSize=[750,500];
            obj.positionStep=[450,450];
            obj.setPos();
        end
        
        function defaultSetting(obj)
            obj.tangoFig.Resize='off';
            obj.tango=obj.tangoFig.Number;
            ax=gca;
            ax.OuterPosition=[0 0 obj.border 1];
            obj.drawNote;
            obj.moveShow;
            obj.anno_update;
            ax.FontSize=14;
        end
        
        function drawNote(obj)
            newAnno=annotation("textbox",[obj.border 0 1-obj.border 1],"string",{"settings:","  KEY:VALUE"});
            while size(obj.annoList,1)<obj.tango
                obj.annoList=[obj.annoList;newAnno];
            end
            obj.annoList(obj.tango)=newAnno;
        end
        
        function anno_update(obj)
            names=string(fieldnames(obj.flags));
            obj.annoList(obj.tango);
            oldMessage=obj.annoList(obj.tango).String;
            for i=1:length(names)
                name=names(i);
                addMessage="  "+name+":"+obj.flags.(name);
                index=[];
                for j=1:length(oldMessage)
                    point=oldMessage(j);
                    ind=strfind(point,name);
                    if isempty(cell2mat(ind(1)))
                        index=[index,j];
                    end
                end
                oldMessage=oldMessage(index);
                oldMessage=[oldMessage{:},{char(addMessage)}];
            end
            obj.annoList(obj.tango).String=oldMessage;
        end
    end
    %% static methods
    methods(Static)
    end
    
end