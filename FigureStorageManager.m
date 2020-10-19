classdef FigureStorageManager<handle
    % Figureのサイズとかを統一する規格として製作
    % 
    % plot系の出力コントロール
    % 
    % 
    %% properties
    properties
        analysisName
        flags
        sorts
        savetitle
    end
    %% properties(private)
    properties(Access=private)
        motherDir=("../../5_result");
        saveDir=("../../5_result");
        defaultSize=[600,500];
    end
    methods
        %% original functions
        function obj=FigureStorageManager(analysisName)
            obj.analysisName=analysisName;
            obj.sorts=analysisName;
            obj.setDir();
        end
        
        function addSorts(obj,newSort,varargin)
            %
            if nargin>3
                error("too many parameter")
            elseif nargin==3
                if isnumeric(varargin{1})
                    if varargin{1}==1
                    elseif varargin{1}<size(sort,2)
                        bef=obj.sorts(1:varargin{1}-1);
                        aft=obj.sorts(varargin{1}:end);
                        obj.sorts=[bef,newSort,aft];
                    else
                        obj.sorts=[obj.sorts,newSort];
                    end
                else
                    if strcmpi(varargin{1},"prior")
                        obj.sorts=[newSort,obj.sorts];
                    else
                        obj.sorts=[obj.sorts,newSort];
                    end
                end
            else
                obj.sorts=[obj.sorts,newSort];
            end
        end
        
        function delSorts(obj,target)
            %
            for i=1:size(obj.sorts,2)
                if strcmpi(obj.sorts(i),target)
                    for j=i:size(obj.sorts,2)-1
                        obj.sorts(j)=obj.sorts(j+1);
                    end
                    obj.sorts=obj.sorts(1:end-1);
                    break
                end
            end
        end
        
        function setDir(obj)
            % set directory
            obj.saveDir=obj.motherDir;
            for n=1:length(obj.sorts)
                dir=obj.sorts(n);
                obj.saveDir=erase(obj.saveDir,"/"+dir);
                obj.saveDir=obj.saveDir+"/"+dir;
            end
        end
        
        function title=getTitle(obj,titleCore)
            % 
            fields=string(fieldnames(obj.flags));
            title=titleCore;
            if isempty(fields)
            else
                for i=1:length(fields)
                    option=fields(i);
                    if strcmpi(option,"score")
                        %個々の分岐が分かりにくい。今度かきなおせ
                        title=title+"("+obj.flags.(option)+")";
                    elseif strcmpi(option,"oddEven")
                        title=title+"("+obj.flags.(option)+")";
                    elseif isstring(obj.flags.(option))
                        if obj.flags.(option)=="on"
                            title=title+"("+option+")";
                        end
                    elseif obj.flags.(option)==true
                        title=title+"("+option+")";
                    elseif isnumeric(obj.flags.(option))
                        if obj.flags.(option)>1
                            title=title+"("+option+"-"+num2str(obj.flags.(option))+")";
                        else
                            title=title+"("+option+")";
                        end
                    end
                end
                title=erase(title,"(reset)"); %reset条件は載ってると邪魔なので
            end
            obj.savetitle=title;
        end
        
        function store(obj)
            % save targeted figure
            obj.setDir();
            f=gcf;
            figout(f.Number,obj.saveDir,obj.savetitle,"nosync");
            flgs=obj.flags;
            mkdir(obj.saveDir+"/flags");
            save(obj.saveDir+"/flags/"+obj.savetitle+"flag","flgs",'-v7.3');
        end
    end
    %% static methods
    methods(Static)
    end
    
end